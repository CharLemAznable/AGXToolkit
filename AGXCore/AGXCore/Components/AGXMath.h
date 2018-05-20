//
//  AGXMath.h
//  AGXCore
//
//  Created by Char Aznable on 2016/4/2.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#ifndef AGXCore_AGXMath_h
#define AGXCore_AGXMath_h

#import <CoreGraphics/CoreGraphics.h>
#import "AGXC.h"

AGX_EXTERN CGFloat cgfabs(CGFloat v);
AGX_EXTERN CGFloat cgceil(CGFloat v);
AGX_EXTERN CGFloat cgfloor(CGFloat v);
AGX_EXTERN CGFloat cground(CGFloat v);
AGX_EXTERN long int cglround(CGFloat v);

AGX_EXTERN CGFloat cgsin(CGFloat a);
AGX_EXTERN CGFloat cgcos(CGFloat a);
AGX_EXTERN CGFloat cgtan(CGFloat a);
AGX_EXTERN CGFloat cgasin(CGFloat a);
AGX_EXTERN CGFloat cgacos(CGFloat a);
AGX_EXTERN CGFloat cgatan(CGFloat a);

AGX_EXTERN CGFloat cgpow(CGFloat a, CGFloat b);
AGX_EXTERN CGFloat cgsqrt(CGFloat a);

#endif /* AGXCore_AGXMath_h */
