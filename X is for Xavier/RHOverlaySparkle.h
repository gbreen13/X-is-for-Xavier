//
//  RHOverlaySparkle.h
//  X is for Xavier
//
//  Created by George Breen on 1/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//


#import "RHOverlay.h"


#ifdef SPARKLE
#import "SparkleView.h"
#endif

@interface RHOverlaySparkle : RHOverlay {
#ifdef SPARKLE
    SparkleView *sparkleView;
#endif
    UIImage *nextImage;
    UIImageView *overlayImage;
    CGRect originalSize;
    CGPoint scaledOrigin;
}
-(void) sparkle: (CGPoint)p;

#ifdef SPARKLE
@property (nonatomic, strong) SparkleView *sparkleView;
#endif
@end
