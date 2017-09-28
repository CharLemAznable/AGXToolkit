//
//  AGXMachineContext.c
//  AGXCrash
//
//  Created by Char Aznable on 17/9/28.
//  Copyright © 2017年 AI-CUC-EC. All rights reserved.
//

//
//  Modify from:
//  kstenerud/KSCrash
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall remain in place
// in this source code.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

#include <mach/mach.h>
#include "AGXMachineContext.h"
#include "AGXMachineContext_Apple.h"
#include "AGXSystemCapabilities.h"
#include "AGXCPU.h"
#include "AGXCPU_Apple.h"
#include "AGXStackCursor_MachineContext.h"
#include "AGXCrashLogger.h"

#ifdef __arm64__
# define UC_MCONTEXT uc_mcontext64
typedef ucontext64_t SignalUserContext;
#else
# define UC_MCONTEXT uc_mcontext
typedef ucontext_t SignalUserContext;
#endif

static AGXThread g_reservedThreads[10];
static int g_reservedThreadsMaxIndex = sizeof(g_reservedThreads) / sizeof(g_reservedThreads[0]) - 1;
static int g_reservedThreadsCount = 0;

static inline bool isStackOverflow(const AGXMachineContext *const context) {
    AGXStackCursor stackCursor;
    agx_sc_initWithMachineContext(&stackCursor, AGX_SC_STACK_OVERFLOW_THRESHOLD, context);
    while (stackCursor.advanceCursor(&stackCursor)) {}
    return stackCursor.state.hasGivenUp;
}

static inline bool getThreadList(AGXMachineContext *context) {
    const task_t thisTask = mach_task_self();
    AGXCrashLogger_DEBUG("Getting thread list");
    kern_return_t kr;
    thread_act_array_t threads;
    mach_msg_type_number_t actualThreadCount;

    if ((kr = task_threads(thisTask, &threads, &actualThreadCount)) != KERN_SUCCESS) {
        AGXCrashLogger_ERROR("task_threads: %s", mach_error_string(kr));
        return false;
    }
    AGXCrashLogger_TRACE("Got %d threads", context->threadCount);
    int threadCount = (int)actualThreadCount;
    int maxThreadCount = sizeof(context->allThreads) / sizeof(context->allThreads[0]);
    if (threadCount > maxThreadCount) {
        AGXCrashLogger_ERROR("Thread count %d is higher than maximum of %d", threadCount, maxThreadCount);
        threadCount = maxThreadCount;
    }
    for (int i = 0; i < threadCount; i++) {
        context->allThreads[i] = threads[i];
    }
    context->threadCount = threadCount;

    for (mach_msg_type_number_t i = 0; i < actualThreadCount; i++) {
        mach_port_deallocate(thisTask, context->allThreads[i]);
    }
    vm_deallocate(thisTask, (vm_address_t)threads, sizeof(thread_t) *actualThreadCount);

    return true;
}

int agx_mc_contextSize() {
    return sizeof(AGXMachineContext);
}

AGXThread agx_mc_getThreadFromContext(const AGXMachineContext *const context) {
    return context->thisThread;
}

bool agx_mc_getContextForThread(AGXThread thread, AGXMachineContext *destinationContext, bool isCrashedContext) {
    AGXCrashLogger_DEBUG("Fill thread 0x%x context into %p. is crashed = %d",
                         thread, destinationContext, isCrashedContext);
    memset(destinationContext, 0, sizeof(*destinationContext));
    destinationContext->thisThread = (thread_t)thread;
    destinationContext->isCurrentThread = thread == agx_thread_self();
    destinationContext->isCrashedContext = isCrashedContext;
    destinationContext->isSignalContext = false;
    if (agx_mc_canHaveCPUState(destinationContext)) {
        agx_cpu_getState(destinationContext);
    }
    if (agx_mc_isCrashedContext(destinationContext)) {
        destinationContext->isStackOverflow = isStackOverflow(destinationContext);
        getThreadList(destinationContext);
    }
    AGXCrashLogger_TRACE("Context retrieved.");
    return true;
}

bool agx_mc_getContextForSignal(void *signalUserContext, AGXMachineContext *destinationContext) {
    AGXCrashLogger_DEBUG("Get context from signal user context and put into %p.", destinationContext);
    _STRUCT_MCONTEXT* sourceContext = ((SignalUserContext*)signalUserContext)->UC_MCONTEXT;
    memcpy(&destinationContext->machineContext, sourceContext, sizeof(destinationContext->machineContext));
    destinationContext->thisThread = (thread_t)agx_thread_self();
    destinationContext->isCrashedContext = true;
    destinationContext->isSignalContext = true;
    destinationContext->isStackOverflow = isStackOverflow(destinationContext);
    getThreadList(destinationContext);
    AGXCrashLogger_TRACE("Context retrieved.");
    return true;
}

void agx_mc_addReservedThread(AGXThread thread) {
    int nextIndex = g_reservedThreadsCount;
    if (nextIndex > g_reservedThreadsMaxIndex) {
        AGXCrashLogger_ERROR("Too many reserved threads (%d). Max is %d", nextIndex, g_reservedThreadsMaxIndex);
        return;
    }
    g_reservedThreads[g_reservedThreadsCount++] = thread;
}

#if AGX_CRASH_HAS_THREADS_API
static inline bool isThreadInList(thread_t thread, AGXThread *list, int listCount) {
    for (int i = 0; i < listCount; i++) {
        if (list[i] == (AGXThread)thread) return true;
    }
    return false;
}
#endif

void agx_mc_suspendEnvironment() {
#if AGX_CRASH_HAS_THREADS_API
    AGXCrashLogger_DEBUG("Suspending environment.");
    kern_return_t kr;
    const task_t thisTask = mach_task_self();
    const thread_t thisThread = (thread_t)agx_thread_self();
    thread_act_array_t threads;
    mach_msg_type_number_t numThreads;

    if ((kr = task_threads(thisTask, &threads, &numThreads)) != KERN_SUCCESS) {
        AGXCrashLogger_ERROR("task_threads: %s", mach_error_string(kr));
        return;
    }

    for (mach_msg_type_number_t i = 0; i < numThreads; i++) {
        thread_t thread = threads[i];
        if (thread != thisThread && !isThreadInList(thread, g_reservedThreads, g_reservedThreadsCount)) {
            if ((kr = thread_suspend(thread)) != KERN_SUCCESS) {
                // Record the error and keep going.
                AGXCrashLogger_ERROR("thread_suspend (%08x): %s", thread, mach_error_string(kr));
            }
        }
    }

    for (mach_msg_type_number_t i = 0; i < numThreads; i++) {
        mach_port_deallocate(thisTask, threads[i]);
    }
    vm_deallocate(thisTask, (vm_address_t)threads, sizeof(thread_t) * numThreads);

    AGXCrashLogger_DEBUG("Suspend complete.");
#endif
}

void agx_mc_resumeEnvironment() {
#if AGX_CRASH_HAS_THREADS_API
    AGXCrashLogger_DEBUG("Resuming environment.");
    kern_return_t kr;
    const task_t thisTask = mach_task_self();
    const thread_t thisThread = (thread_t)agx_thread_self();
    thread_act_array_t threads;
    mach_msg_type_number_t numThreads;

    if ((kr = task_threads(thisTask, &threads, &numThreads)) != KERN_SUCCESS) {
        AGXCrashLogger_ERROR("task_threads: %s", mach_error_string(kr));
        return;
    }

    for (mach_msg_type_number_t i = 0; i < numThreads; i++) {
        thread_t thread = threads[i];
        if (thread != thisThread && !isThreadInList(thread, g_reservedThreads, g_reservedThreadsCount)) {
            if ((kr = thread_resume(thread)) != KERN_SUCCESS) {
                // Record the error and keep going.
                AGXCrashLogger_ERROR("thread_resume (%08x): %s", thread, mach_error_string(kr));
            }
        }
    }

    for (mach_msg_type_number_t i = 0; i < numThreads; i++) {
        mach_port_deallocate(thisTask, threads[i]);
    }
    vm_deallocate(thisTask, (vm_address_t)threads, sizeof(thread_t) * numThreads);

    AGXCrashLogger_DEBUG("Resume complete.");
#endif
}

int agx_mc_getThreadCount(const AGXMachineContext *const context) {
    return context->threadCount;
}

AGXThread agx_mc_getThreadAtIndex(const AGXMachineContext *const context, int index) {
    return context->allThreads[index];
}

int agx_mc_indexOfThread(const AGXMachineContext *const context, AGXThread thread) {
    AGXCrashLogger_TRACE("check thread vs %d threads", context->threadCount);
    for (int i = 0; i < (int)context->threadCount; i++) {
        AGXCrashLogger_TRACE("%d: %x vs %x", i, thread, context->allThreads[i]);
        if (context->allThreads[i] == thread) {
            return i;
        }
    }
    return -1;
}

bool agx_mc_isCrashedContext(const AGXMachineContext *const context) {
    return context->isCrashedContext;
}

static inline bool isContextForCurrentThread(const AGXMachineContext *const context) {
    return context->isCurrentThread;
}

static inline bool isSignalContext(const AGXMachineContext *const context) {
    return context->isSignalContext;
}

bool agx_mc_canHaveCPUState(const AGXMachineContext *const context) {
    return !isContextForCurrentThread(context) || isSignalContext(context);
}

bool agx_mc_hasValidExceptionRegisters(const AGXMachineContext *const context) {
    return agx_mc_canHaveCPUState(context) && agx_mc_isCrashedContext(context);
}
