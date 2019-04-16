//
//  AGXLabel.h
//  AGXWidget
//
//  Created by Char Aznable on 2016/2/25.
//  Copyright © 2016 github.com/CharLemAznable. All rights reserved.
//

#ifndef AGXWidget_AGXLabel_h
#define AGXWidget_AGXLabel_h

#import <UIKit/UIKit.h>
#import <AGXCore/AGXCore/AGXArc.h>

@interface AGXLabel : UILabel
@property (nonatomic, assign, getter=canCopy) BOOL canCopy;
@end

#endif /* AGXWidget_AGXLabel_h */
