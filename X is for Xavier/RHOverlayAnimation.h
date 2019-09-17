//
//  RHOverlayAnimation.h
//  X is for Xavier
//
//  Created by George Breen on 2/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RHOverlay.h"

@interface RHOverlayAnimation : RHOverlay {
    BOOL animating;
    NSTimer *timer;
}
- (id) initWithImage:(UIImage *)image andAnimationName: (NSString *)name andTimeInterval:(NSTimeInterval)time;
@property (nonatomic, assign) BOOL animating;
@property (nonatomic, strong) NSTimer *timer;
@end
