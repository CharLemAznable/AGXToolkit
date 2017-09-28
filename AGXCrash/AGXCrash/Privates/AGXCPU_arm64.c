//
//  AGXCPU_arm64.c
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

#if defined (__arm64__)

#include <stdlib.h>
#include "AGXCPU.h"
#include "AGXCPU_Apple.h"
#include "AGXMachineContext.h"
#include "AGXMachineContext_Apple.h"
#include "AGXCrashLogger.h"

static const char *g_registerNames[] = {
    "x0",  "x1",  "x2",  "x3",  "x4",  "x5",  "x6",  "x7",
    "x8",  "x9", "x10", "x11", "x12", "x13", "x14", "x15",
    "x16", "x17", "x18", "x19", "x20", "x21", "x22", "x23",
    "x24", "x25", "x26", "x27", "x28", "x29",
    "fp", "lr", "sp", "pc", "cpsr"
};
static const int g_registerNamesCount = sizeof(g_registerNames) / sizeof(*g_registerNames);

static const char *g_exceptionRegisterNames[] = {
    "exception", "esr", "far"
};
static const int g_exceptionRegisterNamesCount = sizeof(g_exceptionRegisterNames) / sizeof(*g_exceptionRegisterNames);

uintptr_t agx_cpu_framePointer(const AGXMachineContext *const context) {
    return context->machineContext.__ss.__fp;
}

uintptr_t agx_cpu_stackPointer(const AGXMachineContext *const context) {
    return context->machineContext.__ss.__sp;
}

uintptr_t agx_cpu_instructionAddress(const AGXMachineContext *const context) {
    return context->machineContext.__ss.__pc;
}

uintptr_t agx_cpu_linkRegister(const AGXMachineContext *const context) {
    return context->machineContext.__ss.__lr;
}

void agx_cpu_getState(AGXMachineContext *context) {
    thread_t thread = context->thisThread;
    STRUCT_MCONTEXT_L *const machineContext = &context->machineContext;

    agx_cpu_i_fillState(thread, (thread_state_t)&machineContext->__ss, ARM_THREAD_STATE64, ARM_THREAD_STATE64_COUNT);
    agx_cpu_i_fillState(thread, (thread_state_t)&machineContext->__es, ARM_EXCEPTION_STATE64, ARM_EXCEPTION_STATE64_COUNT);
}

int agx_cpu_numRegisters(void) {
    return g_registerNamesCount;
}

const char *agx_cpu_registerName(const int regNumber) {
    if (regNumber < agx_cpu_numRegisters()) return g_registerNames[regNumber];
    return NULL;
}

uint64_t agx_cpu_registerValue(const AGXMachineContext *const context, const int regNumber) {
    if (regNumber <= 29) return context->machineContext.__ss.__x[regNumber];

    switch (regNumber) {
        case 30: return context->machineContext.__ss.__fp;
        case 31: return context->machineContext.__ss.__lr;
        case 32: return context->machineContext.__ss.__sp;
        case 33: return context->machineContext.__ss.__pc;
        case 34: return context->machineContext.__ss.__cpsr;
    }

    AGXCrashLogger_ERROR("Invalid register number: %d", regNumber);
    return 0;
}

int agx_cpu_numExceptionRegisters(void) {
    return g_exceptionRegisterNamesCount;
}

const char *agx_cpu_exceptionRegisterName(const int regNumber) {
    if (regNumber < agx_cpu_numExceptionRegisters()) return g_exceptionRegisterNames[regNumber];
    AGXCrashLogger_ERROR("Invalid register number: %d", regNumber);
    return NULL;
}

uint64_t agx_cpu_exceptionRegisterValue(const AGXMachineContext *const context, const int regNumber) {
    switch(regNumber) {
        case 0: return context->machineContext.__es.__exception;
        case 1: return context->machineContext.__es.__esr;
        case 2: return context->machineContext.__es.__far;
    }

    AGXCrashLogger_ERROR("Invalid register number: %d", regNumber);
    return 0;
}

uintptr_t agx_cpu_faultAddress(const AGXMachineContext *const context) {
    return context->machineContext.__es.__far;
}

int agx_cpu_stackGrowDirection(void) {
    return -1;
}

#endif /* (__arm64__) */
