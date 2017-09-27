//
//  AGXCrashLogger.h
//  AGXCrash
//
//  Created by Char Aznable on 17/9/26.
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

/**
 * AGXCrashLogger
 * ========
 *
 * Prints log entries to the console consisting of:
 * - Level (Error, Warn, Info, Debug, Trace)
 * - File
 * - Line
 * - Function
 * - Message
 *
 * Allows setting the minimum logging level in the preprocessor.
 *
 * Works in C or Objective-C contexts, with or without ARC, using CLANG or GCC.
 *
 *
 * =====
 * USAGE
 * =====
 *
 * Set the log level in your "Preprocessor Macros" build setting. You may choose
 * TRACE, DEBUG, INFO, WARN, ERROR. If nothing is set, it defaults to INFO.
 *
 * Example: AGXCrashLogger_Level=WARN
 *
 * Anything below the level specified for AGXCrashLogger_Level will not be compiled
 * or printed.
 *
 *
 * Next, include the header file:
 *
 * #include "AGXCrashLogger.h"
 *
 *
 * Next, call the logger functions from your code (using objective-c strings
 * in objective-C files and regular strings in regular C files):
 *
 * Code:
 *    AGXCrashLogger_ERROR(@"Some error message");
 *
 * Prints:
 *    2011-07-16 05:41:01.379 TestApp[4439:f803] ERROR: SomeClass.m (21): -[SomeFunction]: Some error message
 *
 * Code:
 *    AGXCrashLogger_INFO(@"Info about %@", someObject);
 *
 * Prints:
 *    2011-07-16 05:44:05.239 TestApp[4473:f803] INFO : SomeClass.m (20): -[SomeFunction]: Info about <NSObject: 0xb622840>
 *
 *
 * The "BASIC" versions of the macros behave exactly like NSLog() or printf(),
 * except they respect the AGXCrashLogger_Level setting:
 *
 * Code:
 *    AGXCrashLogger_BASIC_ERROR(@"A basic log entry");
 *
 * Prints:
 *    2011-07-16 05:44:05.916 TestApp[4473:f803] A basic log entry
 *
 *
 * NOTE: In C files, use "" instead of @"" in the format field. Logging calls
 *       in C files do not print the NSLog preamble:
 *
 * Objective-C version:
 *    AGXCrashLogger_ERROR(@"Some error message");
 *
 *    2011-07-16 05:41:01.379 TestApp[4439:f803] ERROR: SomeClass.m (21): -[SomeFunction]: Some error message
 *
 * C version:
 *    AGXCrashLogger_ERROR("Some error message");
 *
 *    ERROR: SomeClass.c (21): SomeFunction(): Some error message
 *
 *
 * =============
 * LOCAL LOGGING
 * =============
 *
 * You can control logging messages at the local file level using the
 * "AGXCrashLogger_LocalLevel" define. Note that it must be defined BEFORE
 * including AGXCrashLogger.h
 *
 * The AGXCrashLogger_XX() and AGXCrashLogger_BASIC_XX() macros will print out based on the LOWER
 * of AGXCrashLogger_Level and AGXCrashLogger_LocalLevel, so if AGXCrashLogger_Level is DEBUG
 * and AGXCrashLogger_LocalLevel is TRACE, it will print all the way down to the trace
 * level for the local file where AGXCrashLogger_LocalLevel was defined, and to the
 * debug level everywhere else.
 *
 * Example:
 *
 * // AGXCrashLogger_LocalLevel, if defined, MUST come BEFORE including AGXCrashLogger.h
 * #define AGXCrashLogger_LocalLevel TRACE
 * #import "AGXCrashLogger.h"
 *
 *
 * ===============
 * IMPORTANT NOTES
 * ===============
 *
 * The C logger changes its behavior depending on the value of the preprocessor
 * define AGXCrashLogger_CBufferSize.
 *
 * If AGXCrashLogger_CBufferSize is > 0, the C logger will behave in an async-safe
 * manner, calling write() instead of printf(). Any log messages that exceed the
 * length specified by AGXCrashLogger_CBufferSize will be truncated.
 *
 * If AGXCrashLogger_CBufferSize == 0, the C logger will use printf(), and there will
 * be no limit on the log message length.
 *
 * AGXCrashLogger_CBufferSize can only be set as a preprocessor define, and will
 * default to 1024 if not specified during compilation.
 */

#ifndef AGXCrash_AGXCrashLogger_h
#define AGXCrash_AGXCrashLogger_h

#ifdef __cplusplus
extern "C" {
#endif

#include <stdbool.h>

// ============================================================================
#pragma mark - (internal) -
// ============================================================================

#ifdef __OBJC__

#import <CoreFoundation/CoreFoundation.h>
void i_agxcrash_log_logObjC(const char *level, const char *file, int line, const char *function, CFStringRef fmt, ...);
void i_agxcrash_log_logObjCBasic(CFStringRef fmt, ...);
#define i_AGXCRASH_LOG_FULL(LEVEL, FILE, LINE, FUNCTION, FMT, ...) i_agxcrash_log_logObjC(LEVEL, FILE, LINE, FUNCTION, (__bridge CFStringRef)FMT, ##__VA_ARGS__)
#define i_AGXCRASH_LOG_BASIC(FMT, ...) i_agxcrash_log_logObjCBasic((__bridge CFStringRef)FMT, ##__VA_ARGS__)

#else // __OBJC__

void i_agxcrash_log_logC(const char *level, const char *file, int line, const char *function, const char *fmt, ...);
void i_agxcrash_log_logCBasic(const char* fmt, ...);
#define i_AGXCRASH_LOG_FULL     i_agxcrash_log_logC
#define i_AGXCRASH_LOG_BASIC    i_agxcrash_log_logCBasic

#endif // __OBJC__

/* Back up any existing defines by the same name */
#ifdef   NONE
# define AGXCrashLogger_BAK_NONE    NONE
# undef  NONE
#endif
#ifdef   ERROR
# define AGXCrashLogger_BAK_ERROR   ERROR
# undef  ERROR
#endif
#ifdef   WARN
# define AGXCrashLogger_BAK_WARN    WARN
# undef  WARN
#endif
#ifdef   INFO
# define AGXCrashLogger_BAK_INFO    INFO
# undef  INFO
#endif
#ifdef   DEBUG
# define AGXCrashLogger_BAK_DEBUG   DEBUG
# undef  DEBUG
#endif
#ifdef   TRACE
# define AGXCrashLogger_BAK_TRACE   TRACE
# undef  TRACE
#endif

#define AGXCrashLogger_Level_None    0
#define AGXCrashLogger_Level_Error  10
#define AGXCrashLogger_Level_Warn   20
#define AGXCrashLogger_Level_Info   30
#define AGXCrashLogger_Level_Debug  40
#define AGXCrashLogger_Level_Trace  50

#define NONE                        AGXCrashLogger_Level_None
#define ERROR                       AGXCrashLogger_Level_Error
#define WARN                        AGXCrashLogger_Level_Warn
#define INFO                        AGXCrashLogger_Level_Info
#define DEBUG                       AGXCrashLogger_Level_Debug
#define TRACE                       AGXCrashLogger_Level_Trace

#ifndef  AGXCrashLogger_Level
# define AGXCrashLogger_Level       AGXCrashLogger_Level_Info
#endif

#ifndef  AGXCrashLogger_LocalLevel
# define AGXCrashLogger_LocalLevel  AGXCrashLogger_Level_None
#endif

#define a_AGXCRASH_LOG_FULL(LEVEL, FMT, ...)    \
i_AGXCRASH_LOG_FULL(LEVEL, __FILE__, __LINE__,  \
__PRETTY_FUNCTION__, FMT, ##__VA_ARGS__)

// ============================================================================
#pragma mark - API -
// ============================================================================

/** Set the filename to log to.
 *
 * @param filename The file to write to (NULL = write to stdout).
 *
 * @param overwrite If true, overwrite the log file.
 */
bool agxcrash_log_setLogFilename(const char *filename, bool overwrite);

/** Clear the log file. */
bool agxcrash_log_clearLogFile();

/** Tests if the logger would print at the specified level.
 *
 * @param LEVEL The level to test for. One of:
 *            AGXCrashLogger_Level_Error,
 *            AGXCrashLogger_Level_Warn,
 *            AGXCrashLogger_Level_Info,
 *            AGXCrashLogger_Level_Debug,
 *            AGXCrashLogger_Level_Trace,
 *
 * @return TRUE if the logger would print at the specified level.
 */
#define AGXCRASH_LOG_PRINTS_AT_LEVEL(LEVEL) \
(AGXCrashLogger_Level >= LEVEL || AGXCrashLogger_LocalLevel >= LEVEL)

/** Log a message regardless of the log settings.
 * Normal version prints out full context. Basic version prints directly.
 *
 * @param FMT The format specifier, followed by its arguments.
 */
#define AGXCrashLogger_ALWAYS(FMT, ...)         a_AGXCRASH_LOG_FULL("FORCE", FMT, ##__VA_ARGS__)
#define AGXCrashLogger_BASIC_ALWAYS(FMT, ...)   i_AGXCRASH_LOG_BASIC(FMT, ##__VA_ARGS__)

/** Log an error.
 * Normal version prints out full context. Basic version prints directly.
 *
 * @param FMT The format specifier, followed by its arguments.
 */
#if AGXCRASH_LOG_PRINTS_AT_LEVEL(AGXCrashLogger_Level_Error)
# define AGXCrashLogger_ERROR(FMT, ...)         a_AGXCRASH_LOG_FULL("ERROR", FMT, ##__VA_ARGS__)
# define AGXCrashLogger_BASIC_ERROR(FMT, ...)   i_AGXCRASH_LOG_BASIC(FMT, ##__VA_ARGS__)
#else
# define AGXCrashLogger_ERROR(FMT, ...)
# define AGXCrashLogger_BASIC_ERROR(FMT, ...)
#endif

/** Log a warning.
 * Normal version prints out full context. Basic version prints directly.
 *
 * @param FMT The format specifier, followed by its arguments.
 */
#if AGXCRASH_LOG_PRINTS_AT_LEVEL(AGXCrashLogger_Level_Warn)
# define AGXCrashLogger_WARN(FMT, ...)          a_AGXCRASH_LOG_FULL("WARN ", FMT, ##__VA_ARGS__)
# define AGXCrashLogger_BASIC_WARN(FMT, ...)    i_AGXCRASH_LOG_BASIC(FMT, ##__VA_ARGS__)
#else
# define AGXCrashLogger_WARN(FMT, ...)
# define AGXCrashLogger_BASIC_WARN(FMT, ...)
#endif

/** Log an info message.
 * Normal version prints out full context. Basic version prints directly.
 *
 * @param FMT The format specifier, followed by its arguments.
 */
#if AGXCRASH_LOG_PRINTS_AT_LEVEL(AGXCrashLogger_Level_Info)
# define AGXCrashLogger_INFO(FMT, ...)          a_AGXCRASH_LOG_FULL("INFO ", FMT, ##__VA_ARGS__)
# define AGXCrashLogger_BASIC_INFO(FMT, ...)    i_AGXCRASH_LOG_BASIC(FMT, ##__VA_ARGS__)
#else
# define AGXCrashLogger_INFO(FMT, ...)
# define AGXCrashLogger_BASIC_INFO(FMT, ...)
#endif

/** Log a debug message.
 * Normal version prints out full context. Basic version prints directly.
 *
 * @param FMT The format specifier, followed by its arguments.
 */
#if AGXCRASH_LOG_PRINTS_AT_LEVEL(AGXCrashLogger_Level_Debug)
# define AGXCrashLogger_DEBUG(FMT, ...)         a_AGXCRASH_LOG_FULL("DEBUG", FMT, ##__VA_ARGS__)
# define AGXCrashLogger_BASIC_DEBUG(FMT, ...)   i_AGXCRASH_LOG_BASIC(FMT, ##__VA_ARGS__)
#else
# define AGXCrashLogger_DEBUG(FMT, ...)
# define AGXCrashLogger_BASIC_DEBUG(FMT, ...)
#endif

/** Log a trace message.
 * Normal version prints out full context. Basic version prints directly.
 *
 * @param FMT The format specifier, followed by its arguments.
 */
#if AGXCRASH_LOG_PRINTS_AT_LEVEL(AGXCrashLogger_Level_Trace)
# define AGXCrashLogger_TRACE(FMT, ...)         a_AGXCRASH_LOG_FULL("TRACE", FMT, ##__VA_ARGS__)
# define AGXCrashLogger_BASIC_TRACE(FMT, ...)   i_AGXCRASH_LOG_BASIC(FMT, ##__VA_ARGS__)
#else
# define AGXCrashLogger_TRACE(FMT, ...)
# define AGXCrashLogger_BASIC_TRACE(FMT, ...)
#endif

// ============================================================================
#pragma mark - (internal) -
// ============================================================================

/* Put everything back to the way we found it. */
#undef   ERROR
#ifdef   AGXCrashLogger_BAK_ERROR
# define ERROR AGXCrashLogger_BAK_ERROR
# undef  AGXCrashLogger_BAK_ERROR
#endif
#undef   WARNING
#ifdef   AGXCrashLogger_BAK_WARN
# define WARNING AGXCrashLogger_BAK_WARN
# undef  AGXCrashLogger_BAK_WARN
#endif
#undef   INFO
#ifdef   AGXCrashLogger_BAK_INFO
# define INFO AGXCrashLogger_BAK_INFO
# undef  AGXCrashLogger_BAK_INFO
#endif
#undef   DEBUG
#ifdef   AGXCrashLogger_BAK_DEBUG
# define DEBUG AGXCrashLogger_BAK_DEBUG
# undef  AGXCrashLogger_BAK_DEBUG
#endif
#undef   TRACE
#ifdef   AGXCrashLogger_BAK_TRACE
# define TRACE AGXCrashLogger_BAK_TRACE
# undef  AGXCrashLogger_BAK_TRACE
#endif

#ifdef __cplusplus
}
#endif

#endif /* AGXCrash_AGXCrashLogger_h */
