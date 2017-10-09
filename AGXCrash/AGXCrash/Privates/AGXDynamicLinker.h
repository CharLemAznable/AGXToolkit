//
//  AGXDynamicLinker.h
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

#ifndef AGXCrash_AGXDynamicLinker_h
#define AGXCrash_AGXDynamicLinker_h

#ifdef __cplusplus
extern "C" {
#endif

#include <dlfcn.h>
#include <stdbool.h>
#include <stdint.h>

typedef struct {
    uint64_t address;
    uint64_t vmAddress;
    uint64_t size;
    const char *name;
    const uint8_t *uuid;
    int cpuType;
    int cpuSubType;
    uint64_t majorVersion;
    uint64_t minorVersion;
    uint64_t revisionVersion;
} AGXBinaryImage;

/** Get the number of loaded binary images.
 */
int agx_dl_imageCount(void);

/** Get information about a binary image.
 *
 * @param index The binary index.
 *
 * @param buffer A structure to hold the information.
 *
 * @return True if the image was successfully queried.
 */
bool agx_dl_getBinaryImage(int index, AGXBinaryImage *buffer);

/** Find a loaded binary image with the specified name.
 *
 * @param imageName The image name to look for.
 *
 * @param exactMatch If true, look for an exact match instead of a partial one.
 *
 * @return the index of the matched image, or UINT32_MAX if not found.
 */
uint32_t agx_dl_imageNamed(const char *const imageName, bool exactMatch);

/** Get the UUID of a loaded binary image with the specified name.
 *
 * @param imageName The image name to look for.
 *
 * @param exactMatch If true, look for an exact match instead of a partial one.
 *
 * @return A pointer to the binary (16 byte) UUID of the image, or NULL if it
 *         wasn't found.
 */
const uint8_t *agx_dl_imageUUID(const char *const imageName, bool exactMatch);

/** async-safe version of dladdr.
 *
 * This method searches the dynamic loader for information about any image
 * containing the specified address. It may not be entirely successful in
 * finding information, in which case any fields it could not find will be set
 * to NULL.
 *
 * Unlike dladdr(), this method does not make use of locks, and does not call
 * async-unsafe functions.
 *
 * @param address The address to search for.
 * @param info Gets filled out by this function.
 * @return true if at least some information was found.
 */
bool agx_dl_dladdr(const uintptr_t address, Dl_info *const info);

#ifdef __cplusplus
}
#endif

#endif /* AGXCrash_AGXDynamicLinker_h */
