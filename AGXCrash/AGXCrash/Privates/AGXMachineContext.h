//
//  AGXMachineContext.h
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

#ifndef AGXCrash_AGXMachineContext_h
#define AGXCrash_AGXMachineContext_h

#ifdef __cplusplus
extern "C" {
#endif

#include <stdbool.h>
#include "AGXThread.h"

/** Suspend the runtime environment.
 */
void agx_mc_suspendEnvironment(void);

/** Resume the runtime environment.
 */
void agx_mc_resumeEnvironment(void);

/** Create a new machine context on the stack.
 * This macro creates a storage object on the stack, as well as a pointer of type
 * struct AGXMachineContext* in the current scope, which points to the storage object.
 *
 * Example usage: AGX_MC_NEW_CONTEXT(a_context);
 * This creates a new pointer at the current scope that behaves as if:
 *     struct AGXMachineContext* a_context = some_storage_location;
 *
 * @param NAME The C identifier to give the pointer.
 */
#define AGX_MC_NEW_CONTEXT(NAME) \
char agx_mc_##NAME##_storage[agx_mc_contextSize()]; \
struct AGXMachineContext* NAME = (struct AGXMachineContext*)agx_mc_##NAME##_storage

struct AGXMachineContext;

/** Get the internal size of a machine context.
 */
int agx_mc_contextSize(void);

/** Fill in a machine context from a thread.
 *
 * @param thread The thread to get information from.
 * @param destinationContext The context to fill.
 * @param isCrashedContext Used to indicate that this is the thread that crashed,
 *
 * @return true if successful.
 */
bool agx_mc_getContextForThread(AGXThread thread, struct AGXMachineContext *destinationContext, bool isCrashedContext);

/** Fill in a machine context from a signal handler.
 * A signal handler context is always assumed to be a crashed context.
 *
 * @param signalUserContext The signal context to get information from.
 * @param destinationContext The context to fill.
 *
 * @return true if successful.
 */
bool agx_mc_getContextForSignal(void *signalUserContext, struct AGXMachineContext *destinationContext);

/** Get the thread associated with a machine context.
 *
 * @param context The machine context.
 *
 * @return The associated thread.
 */
AGXThread agx_mc_getThreadFromContext(const struct AGXMachineContext *const context);

/** Get the number of threads stored in a machine context.
 *
 * @param context The machine context.
 *
 * @return The number of threads.
 */
int agx_mc_getThreadCount(const struct AGXMachineContext *const context);

/** Get a thread from a machine context.
 *
 * @param context The machine context.
 * @param index The index of the thread to retrieve.
 *
 * @return The thread.
 */
AGXThread agx_mc_getThreadAtIndex(const struct AGXMachineContext *const context, int index);

/** Get the index of a thread.
 *
 * @param context The machine context.
 * @param thread The thread.
 *
 * @return The thread's index, or -1 if it couldn't be determined.
 */
int agx_mc_indexOfThread(const struct AGXMachineContext *const context, AGXThread thread);

/** Check if this is a crashed context.
 */
bool agx_mc_isCrashedContext(const struct AGXMachineContext *const context);

/** Check if this context can have stored CPU state.
 */
bool agx_mc_canHaveCPUState(const struct AGXMachineContext *const context);

/** Check if this context has valid exception registers.
 */
bool agx_mc_hasValidExceptionRegisters(const struct AGXMachineContext *const context);

/** Add a thread to the reserved threads list.
 *
 * @param thread The thread to add to the list.
 */
void agx_mc_addReservedThread(AGXThread thread);

#ifdef __cplusplus
}
#endif

#endif /* AGXCrash_AGXMachineContext_h */
