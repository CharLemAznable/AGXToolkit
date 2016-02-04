//
//  AGXGeometry.h
//  AGXCore
//
//  Created by Char Aznable on 16/2/4.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#ifndef AGXCore_AGXGeometry_h
#define AGXCore_AGXGeometry_h

#import <CoreGraphics/CGGeometry.h>
#import <UIKit/UIGeometry.h>
#import "AGXObjC.h"

AGX_EXTERN CGRect AGX_CGRectMake(CGPoint origin, CGSize size);
AGX_EXTERN CGSize AGX_CGSizeFromUIOffset(UIOffset offset);
AGX_EXTERN UIOffset AGX_UIOffsetFromCGSize(CGSize size);

#endif /* AGXCore_AGXGeometry_h */
