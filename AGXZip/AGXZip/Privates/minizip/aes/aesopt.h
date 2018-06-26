//
//  aesopt.h
//  AGXZip
//
//  Created by Char Aznable on 2018/5/11.
//  Copyright © 2018年 AI-CUC-EC. All rights reserved.
//

//
//  Modify from:
//  ZipArchive/ZipArchive
//  https://github.com/ZipArchive/ZipArchive
//

//  SSZipArchive MIT license
//
//  Copyright (c) 2010-2015, Sam Soffes, http://soff.es
//
//  Permission is hereby granted, free of charge, to any person obtaining
//  a copy of this software and associated documentation files (the
//  "Software"), to deal in the Software without restriction, including
//  without limitation the rights to use, copy, modify, merge, publish,
//  distribute, sublicense, and/or sell copies of the Software, and to
//  permit persons to whom the Software is furnished to do so, subject to
//  the following conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
//  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
//  LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
//  OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
//  WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

//  Zlib license
//
//  zlib.h -- interface of the 'zlib' general purpose compression library
//  version 1.2.11, January 15th, 2017
//
//  Copyright (C) 1995-2017 Jean-loup Gailly and Mark Adler
//
//  This software is provided 'as-is', without any express or implied
//  warranty.  In no event will the authors be held liable for any damages
//  arising from the use of this software.
//
//  Permission is granted to anyone to use this software for any purpose,
//  including commercial applications, and to alter it and redistribute it
//  freely, subject to the following restrictions:
//
//  1. The origin of this software must not be misrepresented; you must not
//  claim that you wrote the original software. If you use this software
//  in a product, an acknowledgment in the product documentation would be
//  appreciated but is not required.
//  2. Altered source versions must be plainly marked as such, and must not be
//  misrepresented as being the original software.
//  3. This notice may not be removed or altered from any source distribution.
//
//  Jean-loup Gailly        Mark Adler
//  jloup@gzip.org          madler@alumni.caltech.edu

//  minizip LICENSE
//
//  nmoinvaz/minizip
//
//  Condition of use and distribution are the same as zlib:
//
//  This software is provided 'as-is', without any express or implied
//  warranty.  In no event will the authors be held liable for any damages
//  arising from the use of this software.
//
//  Permission is granted to anyone to use this software for any purpose,
//  including commercial applications, and to alter it and redistribute it
//  freely, subject to the following restrictions:
//
//  1. The origin of this software must not be misrepresented; you must not
//  claim that you wrote the original software. If you use this software
//  in a product, an acknowledgement in the product documentation would be
//  appreciated but is not required.
//  2. Altered source versions must be plainly marked as such, and must not be
//  misrepresented as being the original software.
//  3. This notice may not be removed or altered from any source distribution.

/*
---------------------------------------------------------------------------
Copyright (c) 1998-2013, Brian Gladman, Worcester, UK. All rights reserved.

The redistribution and use of this software (with or without changes)
is allowed without the payment of fees or royalties provided that:

  source code distributions include the above copyright notice, this
  list of conditions and the following disclaimer;

  binary distributions include the above copyright notice, this list
  of conditions and the following disclaimer in their documentation.

This software is provided 'as is' with no explicit or implied warranties
in respect of its operation, including, but not limited to, correctness
and fitness for purpose.
---------------------------------------------------------------------------
Issue Date: 20/12/2007

 This file contains the compilation options for AES (Rijndael) and code
 that is common across encryption, key scheduling and table generation.

 OPERATION

 These source code files implement the AES algorithm Rijndael designed by
 Joan Daemen and Vincent Rijmen. This version is designed for the standard
 block size of 16 bytes and for key sizes of 128, 192 and 256 bits (16, 24
 and 32 bytes).

 This version is designed for flexibility and speed using operations on
 32-bit words rather than operations on bytes.  It can be compiled with
 either big or little endian internal byte order but is faster when the
 native byte order for the processor is used.

 THE CIPHER INTERFACE

 The cipher interface is implemented as an array of bytes in which lower
 AES bit sequence indexes map to higher numeric significance within bytes.

  uint8_t                 (an unsigned  8-bit type)
  uint32_t                (an unsigned 32-bit type)
  struct aes_encrypt_ctx  (structure for the cipher encryption context)
  struct aes_decrypt_ctx  (structure for the cipher decryption context)
  AES_RETURN                the function return type

  C subroutine calls:

  AES_RETURN aes_encrypt_key128(const unsigned char *key, aes_encrypt_ctx cx[1]);
  AES_RETURN aes_encrypt_key192(const unsigned char *key, aes_encrypt_ctx cx[1]);
  AES_RETURN aes_encrypt_key256(const unsigned char *key, aes_encrypt_ctx cx[1]);
  AES_RETURN aes_encrypt(const unsigned char *in, unsigned char *out,
                                                  const aes_encrypt_ctx cx[1]);

  AES_RETURN aes_decrypt_key128(const unsigned char *key, aes_decrypt_ctx cx[1]);
  AES_RETURN aes_decrypt_key192(const unsigned char *key, aes_decrypt_ctx cx[1]);
  AES_RETURN aes_decrypt_key256(const unsigned char *key, aes_decrypt_ctx cx[1]);
  AES_RETURN aes_decrypt(const unsigned char *in, unsigned char *out,
                                                  const aes_decrypt_ctx cx[1]);

 IMPORTANT NOTE: If you are using this C interface with dynamic tables make sure that
 you call aes_init() before AES is used so that the tables are initialised.

 C++ aes class subroutines:

     Class AESencrypt  for encryption

      Construtors:
          AESencrypt(void)
          AESencrypt(const unsigned char *key) - 128 bit key
      Members:
          AES_RETURN key128(const unsigned char *key)
          AES_RETURN key192(const unsigned char *key)
          AES_RETURN key256(const unsigned char *key)
          AES_RETURN encrypt(const unsigned char *in, unsigned char *out) const

      Class AESdecrypt  for encryption
      Construtors:
          AESdecrypt(void)
          AESdecrypt(const unsigned char *key) - 128 bit key
      Members:
          AES_RETURN key128(const unsigned char *key)
          AES_RETURN key192(const unsigned char *key)
          AES_RETURN key256(const unsigned char *key)
          AES_RETURN decrypt(const unsigned char *in, unsigned char *out) const
*/

#if !defined( _AGX_AESOPT_H )
#define _AGX_AESOPT_H

#if defined( __cplusplus )
#include "aescpp.h"
#else
#include "aes.h"
#endif

/*  PLATFORM SPECIFIC INCLUDES */

#include "brg_endian.h"

/*  CONFIGURATION - THE USE OF DEFINES

    Later in this section there are a number of defines that control the
    operation of the code.  In each section, the purpose of each define is
    explained so that the relevant form can be included or excluded by
    setting either 1's or 0's respectively on the branches of the related
    #if clauses.  The following local defines should not be changed.
*/

#define AGX_ENCRYPTION_IN_C     1
#define AGX_DECRYPTION_IN_C     2
#define AGX_ENC_KEYING_IN_C     4
#define AGX_DEC_KEYING_IN_C     8

#define AGX_NO_TABLES           0
#define AGX_ONE_TABLE           1
#define AGX_FOUR_TABLES         4
#define AGX_NONE                0
#define AGX_PARTIAL             1
#define AGX_FULL                2

/*  --- START OF USER CONFIGURED OPTIONS --- */

/*  1. BYTE ORDER WITHIN 32 BIT WORDS

    The fundamental data processing units in Rijndael are 8-bit bytes. The
    input, output and key input are all enumerated arrays of bytes in which
    bytes are numbered starting at zero and increasing to one less than the
    number of bytes in the array in question. This enumeration is only used
    for naming bytes and does not imply any adjacency or order relationship
    from one byte to another. When these inputs and outputs are considered
    as bit sequences, bits 8*n to 8*n+7 of the bit sequence are mapped to
    byte[n] with bit 8n+i in the sequence mapped to bit 7-i within the byte.
    In this implementation bits are numbered from 0 to 7 starting at the
    numerically least significant end of each byte (bit n represents 2^n).

    However, Rijndael can be implemented more efficiently using 32-bit
    words by packing bytes into words so that bytes 4*n to 4*n+3 are placed
    into word[n]. While in principle these bytes can be assembled into words
    in any positions, this implementation only supports the two formats in
    which bytes in adjacent positions within words also have adjacent byte
    numbers. This order is called big-endian if the lowest numbered bytes
    in words have the highest numeric significance and little-endian if the
    opposite applies.

    This code can work in either order irrespective of the order used by the
    machine on which it runs. Normally the internal byte order will be set
    to the order of the processor on which the code is to be run but this
    define can be used to reverse this in special situations

    WARNING: Assembler code versions rely on PLATFORM_BYTE_ORDER being set.
    This define will hence be redefined later (in section 4) if necessary
*/

#if 1
#  define AGX_ALGORITHM_BYTE_ORDER AGX_PLATFORM_BYTE_ORDER
#elif 0
#  define AGX_ALGORITHM_BYTE_ORDER AGX_IS_LITTLE_ENDIAN
#elif 0
#  define AGX_ALGORITHM_BYTE_ORDER AGX_IS_BIG_ENDIAN
#else
#  error The algorithm byte order is not defined
#endif

/*  2. Intel AES AND VIA ACE SUPPORT */

#if defined( __GNUC__ ) && defined( __i386__ ) \
 || defined( _WIN32 ) && defined( _M_IX86 ) && !(defined( _WIN64 ) \
 || defined( _WIN32_WCE ) || defined( _MSC_VER ) && ( _MSC_VER <= 800 ))
#  define AGX_VIA_ACE_POSSIBLE
#endif

#if (defined( _WIN64 ) && defined( _MSC_VER )) \
 || (defined( __GNUC__ ) && defined( __x86_64__ )) && !(defined( __APPLE__ ))\
 && !(defined( AGX_INTEL_AES_POSSIBLE ))
#  define AGX_INTEL_AES_POSSIBLE
#endif

/*  Define this option if support for the Intel AESNI is required
    If USE_INTEL_AES_IF_PRESENT is defined then AESNI will be used
    if it is detected (both present and enabled).

	AESNI uses a decryption key schedule with the first decryption
	round key at the high end of the key scedule with the following
	round keys at lower positions in memory.  So AES_REV_DKS must NOT
	be defined when AESNI will be used.  ALthough it is unlikely that
	assembler code will be used with an AESNI build, if it is then
	AES_REV_DKS must NOT be defined when the assembler files are
	built
*/

#if 1 && defined( AGX_INTEL_AES_POSSIBLE ) && !defined( AGX_USE_INTEL_AES_IF_PRESENT )
#  define AGX_USE_INTEL_AES_IF_PRESENT
#endif

/*  Define this option if support for the VIA ACE is required. This uses
    inline assembler instructions and is only implemented for the Microsoft,
    Intel and GCC compilers.  If VIA ACE is known to be present, then defining
    ASSUME_VIA_ACE_PRESENT will remove the ordinary encryption/decryption
    code.  If USE_VIA_ACE_IF_PRESENT is defined then VIA ACE will be used if
    it is detected (both present and enabled) but the normal AES code will
    also be present.

    When VIA ACE is to be used, all AES encryption contexts MUST be 16 byte
    aligned; other input/output buffers do not need to be 16 byte aligned
    but there are very large performance gains if this can be arranged.
    VIA ACE also requires the decryption key schedule to be in reverse
    order (which later checks below ensure).

	AES_REV_DKS must be set for assembler code used with a VIA ACE build
*/

#if 0 && defined( AGX_VIA_ACE_POSSIBLE ) && !defined( AGX_USE_VIA_ACE_IF_PRESENT )
#  define AGX_USE_VIA_ACE_IF_PRESENT
#endif

#if 0 && defined( AGX_VIA_ACE_POSSIBLE ) && !defined( AGX_ASSUME_VIA_ACE_PRESENT )
#  define AGX_ASSUME_VIA_ACE_PRESENT
#  endif

/*  3. ASSEMBLER SUPPORT

    This define (which can be on the command line) enables the use of the
    assembler code routines for encryption, decryption and key scheduling
    as follows:

    ASM_X86_V1C uses the assembler (aes_x86_v1.asm) with large tables for
                encryption and decryption and but with key scheduling in C
    ASM_X86_V2  uses assembler (aes_x86_v2.asm) with compressed tables for
                encryption, decryption and key scheduling
    ASM_X86_V2C uses assembler (aes_x86_v2.asm) with compressed tables for
                encryption and decryption and but with key scheduling in C
    ASM_AMD64_C uses assembler (aes_amd64.asm) with compressed tables for
                encryption and decryption and but with key scheduling in C

    Change one 'if 0' below to 'if 1' to select the version or define
    as a compilation option.
*/

#if 0 && !defined( AGX_ASM_X86_V1C )
#  define AGX_ASM_X86_V1C
#elif 0 && !defined( AGX_ASM_X86_V2  )
#  define AGX_ASM_X86_V2
#elif 0 && !defined( AGX_ASM_X86_V2C )
#  define AGX_ASM_X86_V2C
#elif 0 && !defined( AGX_ASM_AMD64_C )
#  define AGX_ASM_AMD64_C
#endif

#if defined( __i386 ) || defined( _M_IX86 )
#  define AGX_A32_
#elif defined( __x86_64__ ) || defined( _M_X64 )
#  define AGX_A64_
#endif

#if (defined ( AGX_ASM_X86_V1C ) || defined( AGX_ASM_X86_V2 ) || defined( AGX_ASM_X86_V2C )) \
       && !defined( AGX_A32_ )  || defined( AGX_ASM_AMD64_C ) && !defined( AGX_A64_ )
#  error Assembler code is only available for x86 and AMD64 systems
#endif

/*  4. FAST INPUT/OUTPUT OPERATIONS.

    On some machines it is possible to improve speed by transferring the
    bytes in the input and output arrays to and from the internal 32-bit
    variables by addressing these arrays as if they are arrays of 32-bit
    words.  On some machines this will always be possible but there may
    be a large performance penalty if the byte arrays are not aligned on
    the normal word boundaries. On other machines this technique will
    lead to memory access errors when such 32-bit word accesses are not
    properly aligned. The option SAFE_IO avoids such problems but will
    often be slower on those machines that support misaligned access
    (especially so if care is taken to align the input  and output byte
    arrays on 32-bit word boundaries). If SAFE_IO is not defined it is
    assumed that access to byte arrays as if they are arrays of 32-bit
    words will not cause problems when such accesses are misaligned.
*/
#if 1 && !defined( _MSC_VER )
#  define AGX_SAFE_IO
#endif

/*  5. LOOP UNROLLING

    The code for encryption and decrytpion cycles through a number of rounds
    that can be implemented either in a loop or by expanding the code into a
    long sequence of instructions, the latter producing a larger program but
    one that will often be much faster. The latter is called loop unrolling.
    There are also potential speed advantages in expanding two iterations in
    a loop with half the number of iterations, which is called partial loop
    unrolling.  The following options allow partial or full loop unrolling
    to be set independently for encryption and decryption
*/
#if 1
#  define AGX_ENC_UNROLL  AGX_FULL
#elif 0
#  define AGX_ENC_UNROLL  AGX_PARTIAL
#else
#  define AGX_ENC_UNROLL  AGX_NONE
#endif

#if 1
#  define AGX_DEC_UNROLL  AGX_FULL
#elif 0
#  define AGX_DEC_UNROLL  AGX_PARTIAL
#else
#  define AGX_DEC_UNROLL  AGX_NONE
#endif

#if 1
#  define AGX_ENC_KS_UNROLL
#endif

#if 1
#  define AGX_DEC_KS_UNROLL
#endif

/*  6. FAST FINITE FIELD OPERATIONS

    If this section is included, tables are used to provide faster finite
    field arithmetic (this has no effect if STATIC_TABLES is defined).
*/
#if 1
#  define AGX_FF_TABLES
#endif

/*  7. INTERNAL STATE VARIABLE FORMAT

    The internal state of Rijndael is stored in a number of local 32-bit
    word varaibles which can be defined either as an array or as individual
    names variables. Include this section if you want to store these local
    varaibles in arrays. Otherwise individual local variables will be used.
*/
#if 1
#  define AGX_ARRAYS
#endif

/*  8. FIXED OR DYNAMIC TABLES

    When this section is included the tables used by the code are compiled
    statically into the binary file.  Otherwise the subroutine aes_init()
    must be called to compute them before the code is first used.
*/
#if 1 && !(defined( _MSC_VER ) && ( _MSC_VER <= 800 ))
#  define AGX_STATIC_TABLES
#endif

/*  9. MASKING OR CASTING FROM LONGER VALUES TO BYTES

    In some systems it is better to mask longer values to extract bytes
    rather than using a cast. This option allows this choice.
*/
#if 0
#  define agx_to_byte(x)  ((uint8_t)(x))
#else
#  define agx_to_byte(x)  ((x) & 0xff)
#endif

/*  10. TABLE ALIGNMENT

    On some sytsems speed will be improved by aligning the AES large lookup
    tables on particular boundaries. This define should be set to a power of
    two giving the desired alignment. It can be left undefined if alignment
    is not needed.  This option is specific to the Microsft VC++ compiler -
    it seems to sometimes cause trouble for the VC++ version 6 compiler.
*/

#if 1 && defined( _MSC_VER ) && ( _MSC_VER >= 1300 )
#  define AGX_TABLE_ALIGN 32
#endif

/*  11.  REDUCE CODE AND TABLE SIZE

    This replaces some expanded macros with function calls if AES_ASM_V2 or
    AES_ASM_V2C are defined
*/

#if 1 && (defined( AGX_ASM_X86_V2 ) || defined( AGX_ASM_X86_V2C ))
#  define AGX_REDUCE_CODE_SIZE
#endif

/*  12. TABLE OPTIONS

    This cipher proceeds by repeating in a number of cycles known as 'rounds'
    which are implemented by a round function which can optionally be speeded
    up using tables.  The basic tables are each 256 32-bit words, with either
    one or four tables being required for each round function depending on
    how much speed is required. The encryption and decryption round functions
    are different and the last encryption and decrytpion round functions are
    different again making four different round functions in all.

    This means that:
      1. Normal encryption and decryption rounds can each use either 0, 1
         or 4 tables and table spaces of 0, 1024 or 4096 bytes each.
      2. The last encryption and decryption rounds can also use either 0, 1
         or 4 tables and table spaces of 0, 1024 or 4096 bytes each.

    Include or exclude the appropriate definitions below to set the number
    of tables used by this implementation.
*/

#if 1   /* set tables for the normal encryption round */
#  define AGX_ENC_ROUND   AGX_FOUR_TABLES
#elif 0
#  define AGX_ENC_ROUND   AGX_ONE_TABLE
#else
#  define AGX_ENC_ROUND   AGX_NO_TABLES
#endif

#if 1   /* set tables for the last encryption round */
#  define AGX_LAST_ENC_ROUND  AGX_FOUR_TABLES
#elif 0
#  define AGX_LAST_ENC_ROUND  AGX_ONE_TABLE
#else
#  define AGX_LAST_ENC_ROUND  AGX_NO_TABLES
#endif

#if 1   /* set tables for the normal decryption round */
#  define AGX_DEC_ROUND   AGX_FOUR_TABLES
#elif 0
#  define AGX_DEC_ROUND   AGX_ONE_TABLE
#else
#  define AGX_DEC_ROUND   AGX_NO_TABLES
#endif

#if 1   /* set tables for the last decryption round */
#  define AGX_LAST_DEC_ROUND  AGX_FOUR_TABLES
#elif 0
#  define AGX_LAST_DEC_ROUND  AGX_ONE_TABLE
#else
#  define AGX_LAST_DEC_ROUND  AGX_NO_TABLES
#endif

/*  The decryption key schedule can be speeded up with tables in the same
    way that the round functions can.  Include or exclude the following
    defines to set this requirement.
*/
#if 1
#  define AGX_KEY_SCHED   AGX_FOUR_TABLES
#elif 0
#  define AGX_KEY_SCHED   AGX_ONE_TABLE
#else
#  define AGX_KEY_SCHED   AGX_NO_TABLES
#endif

/*  ---- END OF USER CONFIGURED OPTIONS ---- */

/* VIA ACE support is only available for VC++ and GCC */

#if !defined( _MSC_VER ) && !defined( __GNUC__ )
#  if defined( AGX_ASSUME_VIA_ACE_PRESENT )
#    undef AGX_ASSUME_VIA_ACE_PRESENT
#  endif
#  if defined( AGX_USE_VIA_ACE_IF_PRESENT )
#    undef AGX_USE_VIA_ACE_IF_PRESENT
#  endif
#endif

#if defined( AGX_ASSUME_VIA_ACE_PRESENT ) && !defined( AGX_USE_VIA_ACE_IF_PRESENT )
#  define AGX_USE_VIA_ACE_IF_PRESENT
#endif

/* define to reverse decryption key schedule    */
#if 1 || defined( AGX_USE_VIA_ACE_IF_PRESENT ) && !defined ( AGX_AES_REV_DKS )
#  define AGX_AES_REV_DKS
#endif

/* Intel AESNI uses a decryption key schedule in the encryption order */
#if defined( AGX_USE_INTEL_AES_IF_PRESENT ) && defined ( AGX_AES_REV_DKS )
#  undef AGX_AES_REV_DKS
#endif

/* Assembler support requires the use of platform byte order */

#if ( defined( AGX_ASM_X86_V1C ) || defined( AGX_ASM_X86_V2C ) || defined( AGX_ASM_AMD64_C ) ) \
    && (AGX_ALGORITHM_BYTE_ORDER != AGX_PLATFORM_BYTE_ORDER)
#  undef  AGX_ALGORITHM_BYTE_ORDER
#  define AGX_ALGORITHM_BYTE_ORDER AGX_PLATFORM_BYTE_ORDER
#endif

/* In this implementation the columns of the state array are each held in
   32-bit words. The state array can be held in various ways: in an array
   of words, in a number of individual word variables or in a number of
   processor registers. The following define maps a variable name x and
   a column number c to the way the state array variable is to be held.
   The first define below maps the state into an array x[c] whereas the
   second form maps the state into a number of individual variables x0,
   x1, etc.  Another form could map individual state colums to machine
   register names.
*/

#if defined( AGX_ARRAYS )
#  define agx_s(x,c) x[c]
#else
#  define agx_s(x,c) x##c
#endif

/*  This implementation provides subroutines for encryption, decryption
    and for setting the three key lengths (separately) for encryption
    and decryption. Since not all functions are needed, masks are set
    up here to determine which will be implemented in C
*/

#if !defined( AGX_AES_ENCRYPT )
#  define AGX_EFUNCS_IN_C   0
#elif defined( AGX_ASSUME_VIA_ACE_PRESENT ) || defined( AGX_ASM_X86_V1C ) \
    || defined( AGX_ASM_X86_V2C ) || defined( AGX_ASM_AMD64_C )
#  define AGX_EFUNCS_IN_C   AGX_ENC_KEYING_IN_C
#elif !defined( AGX_ASM_X86_V2 )
#  define AGX_EFUNCS_IN_C   ( AGX_ENCRYPTION_IN_C | AGX_ENC_KEYING_IN_C )
#else
#  define AGX_EFUNCS_IN_C   0
#endif

#if !defined( AGX_AES_DECRYPT )
#  define AGX_DFUNCS_IN_C   0
#elif defined( AGX_ASSUME_VIA_ACE_PRESENT ) || defined( AGX_ASM_X86_V1C ) \
    || defined( AGX_ASM_X86_V2C ) || defined( AGX_ASM_AMD64_C )
#  define AGX_DFUNCS_IN_C   AGX_DEC_KEYING_IN_C
#elif !defined( AGX_ASM_X86_V2 )
#  define AGX_DFUNCS_IN_C   ( AGX_DECRYPTION_IN_C | AGX_DEC_KEYING_IN_C )
#else
#  define AGX_DFUNCS_IN_C   0
#endif

#define AGX_FUNCS_IN_C  ( AGX_EFUNCS_IN_C | AGX_DFUNCS_IN_C )

/* END OF CONFIGURATION OPTIONS */

#define AGX_RC_LENGTH   (5 * (AGX_AES_BLOCK_SIZE / 4 - 2))

/* Disable or report errors on some combinations of options */

#if AGX_ENC_ROUND == AGX_NO_TABLES && AGX_LAST_ENC_ROUND != AGX_NO_TABLES
#  undef  AGX_LAST_ENC_ROUND
#  define AGX_LAST_ENC_ROUND  AGX_NO_TABLES
#elif AGX_ENC_ROUND == AGX_ONE_TABLE && AGX_LAST_ENC_ROUND == AGX_FOUR_TABLES
#  undef  AGX_LAST_ENC_ROUND
#  define AGX_LAST_ENC_ROUND  AGX_ONE_TABLE
#endif

#if AGX_ENC_ROUND == AGX_NO_TABLES && AGX_ENC_UNROLL != AGX_NONE
#  undef  AGX_ENC_UNROLL
#  define AGX_ENC_UNROLL  AGX_NONE
#endif

#if AGX_DEC_ROUND == AGX_NO_TABLES && AGX_LAST_DEC_ROUND != AGX_NO_TABLES
#  undef  AGX_LAST_DEC_ROUND
#  define AGX_LAST_DEC_ROUND  AGX_NO_TABLES
#elif AGX_DEC_ROUND == AGX_ONE_TABLE && AGX_LAST_DEC_ROUND == AGX_FOUR_TABLES
#  undef  AGX_LAST_DEC_ROUND
#  define AGX_LAST_DEC_ROUND  AGX_ONE_TABLE
#endif

#if AGX_DEC_ROUND == AGX_NO_TABLES && AGX_DEC_UNROLL != AGX_NONE
#  undef  AGX_DEC_UNROLL
#  define AGX_DEC_UNROLL  AGX_NONE
#endif

#if defined( bswap32 )
#  define agx_aes_sw32    bswap32
#elif defined( bswap_32 )
#  define agx_aes_sw32    bswap_32
#else
#  define agx_brot(x,n)   (((uint32_t)(x) <<  n) | ((uint32_t)(x) >> (32 - n)))
#  define agx_aes_sw32(x) ((agx_brot((x),8) & 0x00ff00ff) | (agx_brot((x),24) & 0xff00ff00))
#endif

/*  upr(x,n):  rotates bytes within words by n positions, moving bytes to
               higher index positions with wrap around into low positions
    ups(x,n):  moves bytes by n positions to higher index positions in
               words but without wrap around
    bval(x,n): extracts a byte from a word

    WARNING:   The definitions given here are intended only for use with
               unsigned variables and with shift counts that are compile
               time constants
*/

#if ( AGX_ALGORITHM_BYTE_ORDER == AGX_IS_LITTLE_ENDIAN )
#  define agx_upr(x,n)      (((uint32_t)(x) << (8 * (n))) | ((uint32_t)(x) >> (32 - 8 * (n))))
#  define agx_ups(x,n)      ((uint32_t) (x) << (8 * (n)))
#  define agx_bval(x,n)     agx_to_byte((x) >> (8 * (n)))
#  define agx_bytes2word(b0, b1, b2, b3)  \
        (((uint32_t)(b3) << 24) | ((uint32_t)(b2) << 16) | ((uint32_t)(b1) << 8) | (b0))
#endif

#if ( AGX_ALGORITHM_BYTE_ORDER == AGX_IS_BIG_ENDIAN )
#  define agx_upr(x,n)      (((uint32_t)(x) >> (8 * (n))) | ((uint32_t)(x) << (32 - 8 * (n))))
#  define agx_ups(x,n)      ((uint32_t) (x) >> (8 * (n)))
#  define agx_bval(x,n)     agx_to_byte((x) >> (24 - 8 * (n)))
#  define agx_bytes2word(b0, b1, b2, b3)  \
        (((uint32_t)(b0) << 24) | ((uint32_t)(b1) << 16) | ((uint32_t)(b2) << 8) | (b3))
#endif

#if defined( AGX_SAFE_IO )
#  define agx_word_in(x,c)    agx_bytes2word(((const uint8_t*)(x)+4*c)[0], ((const uint8_t*)(x)+4*c)[1], \
                                   ((const uint8_t*)(x)+4*c)[2], ((const uint8_t*)(x)+4*c)[3])
#  define agx_word_out(x,c,v) { ((uint8_t*)(x)+4*c)[0] = agx_bval(v,0); ((uint8_t*)(x)+4*c)[1] = agx_bval(v,1); \
                          ((uint8_t*)(x)+4*c)[2] = agx_bval(v,2); ((uint8_t*)(x)+4*c)[3] = agx_bval(v,3); }
#elif ( AGX_ALGORITHM_BYTE_ORDER == AGX_PLATFORM_BYTE_ORDER )
#  define agx_word_in(x,c)    (*((uint32_t*)(x)+(c)))
#  define agx_word_out(x,c,v) (*((uint32_t*)(x)+(c)) = (v))
#else
#  define agx_word_in(x,c)    agx_aes_sw32(*((uint32_t*)(x)+(c)))
#  define agx_word_out(x,c,v) (*((uint32_t*)(x)+(c)) = agx_aes_sw32(v))
#endif

/* the finite field modular polynomial and elements */

#define AGX_WPOLY   0x011b
#define AGX_BPOLY     0x1b

/* multiply four bytes in GF(2^8) by 'x' {02} in parallel */

#define agx_gf_c1  0x80808080
#define agx_gf_c2  0x7f7f7f7f
#define agx_gf_mulx(x)  ((((x) & agx_gf_c2) << 1) ^ ((((x) & agx_gf_c1) >> 7) * AGX_BPOLY))

/* The following defines provide alternative definitions of gf_mulx that might
   give improved performance if a fast 32-bit multiply is not available. Note
   that a temporary variable u needs to be defined where gf_mulx is used.

#define gf_mulx(x) (u = (x) & gf_c1, u |= (u >> 1), ((x) & gf_c2) << 1) ^ ((u >> 3) | (u >> 6))
#define gf_c4  (0x01010101 * BPOLY)
#define gf_mulx(x) (u = (x) & gf_c1, ((x) & gf_c2) << 1) ^ ((u - (u >> 7)) & gf_c4)
*/

/* Work out which tables are needed for the different options   */

#if defined( AGX_ASM_X86_V1C )
#  if defined( AGX_ENC_ROUND )
#    undef  AGX_ENC_ROUND
#  endif
#  define AGX_ENC_ROUND   AGX_FOUR_TABLES
#  if defined( AGX_LAST_ENC_ROUND )
#    undef  AGX_LAST_ENC_ROUND
#  endif
#  define AGX_LAST_ENC_ROUND  AGX_FOUR_TABLES
#  if defined( AGX_DEC_ROUND )
#    undef  AGX_DEC_ROUND
#  endif
#  define AGX_DEC_ROUND   AGX_FOUR_TABLES
#  if defined( AGX_LAST_DEC_ROUND )
#    undef  AGX_LAST_DEC_ROUND
#  endif
#  define AGX_LAST_DEC_ROUND  AGX_FOUR_TABLES
#  if defined( AGX_KEY_SCHED )
#    undef  AGX_KEY_SCHED
#    define AGX_KEY_SCHED   AGX_FOUR_TABLES
#  endif
#endif

#if ( AGX_FUNCS_IN_C & AGX_ENCRYPTION_IN_C ) || defined( AGX_ASM_X86_V1C )
#  if AGX_ENC_ROUND == AGX_ONE_TABLE
#    define AGX_FT1_SET
#  elif AGX_ENC_ROUND == AGX_FOUR_TABLES
#    define AGX_FT4_SET
#  else
#    define AGX_SBX_SET
#  endif
#  if AGX_LAST_ENC_ROUND == AGX_ONE_TABLE
#    define AGX_FL1_SET
#  elif AGX_LAST_ENC_ROUND == AGX_FOUR_TABLES
#    define AGX_FL4_SET
#  elif !defined( AGX_SBX_SET )
#    define AGX_SBX_SET
#  endif
#endif

#if ( AGX_FUNCS_IN_C & AGX_DECRYPTION_IN_C ) || defined( AGX_ASM_X86_V1C )
#  if AGX_DEC_ROUND == AGX_ONE_TABLE
#    define AGX_IT1_SET
#  elif AGX_DEC_ROUND == AGX_FOUR_TABLES
#    define AGX_IT4_SET
#  else
#    define AGX_ISB_SET
#  endif
#  if AGX_LAST_DEC_ROUND == AGX_ONE_TABLE
#    define AGX_IL1_SET
#  elif AGX_LAST_DEC_ROUND == AGX_FOUR_TABLES
#    define AGX_IL4_SET
#  elif !defined(AGX_ISB_SET)
#    define AGX_ISB_SET
#  endif
#endif

#if !(defined( AGX_REDUCE_CODE_SIZE ) && (defined( AGX_ASM_X86_V2 ) || defined( AGX_ASM_X86_V2C )))
#  if ((AGX_FUNCS_IN_C & AGX_ENC_KEYING_IN_C) || (AGX_FUNCS_IN_C & AGX_DEC_KEYING_IN_C))
#    if AGX_KEY_SCHED == AGX_ONE_TABLE
#      if !defined( AGX_FL1_SET )  && !defined( AGX_FL4_SET )
#        define AGX_LS1_SET
#      endif
#    elif AGX_KEY_SCHED == AGX_FOUR_TABLES
#      if !defined( AGX_FL4_SET )
#        define AGX_LS4_SET
#      endif
#    elif !defined( AGX_SBX_SET )
#      define AGX_SBX_SET
#    endif
#  endif
#  if (AGX_FUNCS_IN_C & AGX_DEC_KEYING_IN_C)
#    if AGX_KEY_SCHED == AGX_ONE_TABLE
#      define AGX_IM1_SET
#    elif AGX_KEY_SCHED == AGX_FOUR_TABLES
#      define AGX_IM4_SET
#    elif !defined( AGX_SBX_SET )
#      define AGX_SBX_SET
#    endif
#  endif
#endif

/* generic definitions of Rijndael macros that use tables    */

#define agx_no_table(x,box,vf,rf,c) agx_bytes2word( \
    box[agx_bval(vf(x,0,c),rf(0,c))], \
    box[agx_bval(vf(x,1,c),rf(1,c))], \
    box[agx_bval(vf(x,2,c),rf(2,c))], \
    box[agx_bval(vf(x,3,c),rf(3,c))])

#define agx_one_table(x,op,tab,vf,rf,c) \
 (     tab[agx_bval(vf(x,0,c),rf(0,c))] \
  ^ op(tab[agx_bval(vf(x,1,c),rf(1,c))],1) \
  ^ op(tab[agx_bval(vf(x,2,c),rf(2,c))],2) \
  ^ op(tab[agx_bval(vf(x,3,c),rf(3,c))],3))

#define agx_four_tables(x,tab,vf,rf,c) \
 (  tab[0][agx_bval(vf(x,0,c),rf(0,c))] \
  ^ tab[1][agx_bval(vf(x,1,c),rf(1,c))] \
  ^ tab[2][agx_bval(vf(x,2,c),rf(2,c))] \
  ^ tab[3][agx_bval(vf(x,3,c),rf(3,c))])

#define agx_vf1(x,r,c)  (x)
#define agx_rf1(r,c)    (r)
#define agx_rf2(r,c)    ((8+r-c)&3)

/* perform forward and inverse column mix operation on four bytes in long word x in */
/* parallel. NOTE: x must be a simple variable, NOT an expression in these macros.  */

#if !(defined( AGX_REDUCE_CODE_SIZE ) && (defined( AGX_ASM_X86_V2 ) || defined( AGX_ASM_X86_V2C )))

#if defined( AGX_FM4_SET )      /* not currently used */
#  define agx_fwd_mcol(x)       agx_four_tables(x,agx_t_use(f,m),agx_vf1,agx_rf1,0)
#elif defined( AGX_FM1_SET )    /* not currently used */
#  define agx_fwd_mcol(x)       agx_one_table(x,agx_upr,agx_t_use(f,m),agx_vf1,agx_rf1,0)
#else
#  define agx_dec_fmvars        uint32_t g2
#  define agx_fwd_mcol(x)       (g2 = agx_gf_mulx(x), g2 ^ agx_upr((x) ^ g2, 3) ^ agx_upr((x), 2) ^ agx_upr((x), 1))
#endif

#if defined( AGX_IM4_SET )
#  define agx_inv_mcol(x)       agx_four_tables(x,agx_t_use(i,m),agx_vf1,agx_rf1,0)
#elif defined( AGX_IM1_SET )
#  define agx_inv_mcol(x)       agx_one_table(x,agx_upr,agx_t_use(i,m),agx_vf1,agx_rf1,0)
#else
#  define agx_dec_imvars        uint32_t g2, g4, g9
#  define agx_inv_mcol(x)       (g2 = agx_gf_mulx(x), g4 = agx_gf_mulx(g2), g9 = (x) ^ agx_gf_mulx(g4), g4 ^= g9, \
                                (x) ^ g2 ^ g4 ^ agx_upr(g2 ^ g9, 3) ^ agx_upr(g4, 2) ^ agx_upr(g9, 1))
#endif

#if defined( AGX_FL4_SET )
#  define agx_ls_box(x,c)       agx_four_tables(x,agx_t_use(f,l),agx_vf1,agx_rf2,c)
#elif defined( AGX_LS4_SET )
#  define agx_ls_box(x,c)       agx_four_tables(x,agx_t_use(l,s),agx_vf1,agx_rf2,c)
#elif defined( AGX_FL1_SET )
#  define agx_ls_box(x,c)       agx_one_table(x,agx_upr,t_use(f,l),agx_vf1,agx_rf2,c)
#elif defined( AGX_LS1_SET )
#  define agx_ls_box(x,c)       agx_one_table(x,agx_upr,t_use(l,s),agx_vf1,agx_rf2,c)
#else
#  define agx_ls_box(x,c)       agx_no_table(x,agx_t_use(s,box),agx_vf1,agx_rf2,c)
#endif

#endif

#if defined( AGX_ASM_X86_V1C ) && defined( AGX_AES_DECRYPT ) && !defined( AGX_ISB_SET )
#  define AGX_ISB_SET
#endif

#endif
