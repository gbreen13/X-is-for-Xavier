//
//  SparkleView.h
//  X is for Xavier
//
//  Created by George Breen on 1/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
#import "RHOverlay.h"
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#ifdef SPARKLE

@interface SparkleView : UIView {
    NSTimer *timer;
    CAEmitterLayer *sparkleLayer;
}
-(void)startEmitterFromPoint: (CGPoint)p;

@end
#endif
