//
//  RHOverlaySparkle.m
//  X is for Xavier
//
//  Created by George Breen on 1/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RHOverlaySparkle.h"

@implementation RHOverlaySparkle


#ifdef SPARKLE
@synthesize sparkleView;
#endif

-(NSString *) getRandomAnimal
{
    int n = rand() % 23;
    NSString *rets = [NSString stringWithFormat:@"%c" ,n + 'a'];
    return rets;
}
-(void) animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    self.image = nextImage;
    self.alpha = 1;
    self.frame = overlayImage.frame;
    [overlayImage removeFromSuperview];
    overlayImage = nil;
    nextImage = nil;
#ifdef SPARKLE
    [sparkleView removeFromSuperview];
#endif
}

-(void)setAndScaleOverlay:(CGPoint) offset andScale:(CGFloat)scale
{
    self.image = [UIImage imageNamed:self.fileName];    // replace original
    [super setAndScaleOverlay:offset andScale:scale];
    scaledOrigin = self.frame.origin;
}

-(void) sparkle: (CGPoint)p
{
#ifdef SPARKLE
#endif
//
//  Now change the animal.
//
     
    nextImage = [UIImage imageNamed:[self getRandomAnimal]];
    overlayImage = [[UIImageView alloc]initWithImage:nextImage];
	float actualHeight = overlayImage.frame.size.height;
	float actualWidth = overlayImage.frame.size.width;
 
    overlayImage.frame = originalSize;
	float imgRatio = actualWidth/actualHeight;
	float maxRatio = 1;	// square format

 	if(imgRatio!=maxRatio){
		if(imgRatio < maxRatio){
			imgRatio = originalSize.size.height / actualHeight;
			actualWidth = imgRatio * actualWidth;
			actualHeight = originalSize.size.height;
		}
		else{
			imgRatio = originalSize.size.width / actualWidth;
			actualHeight = imgRatio * actualHeight;
			actualWidth = originalSize.size.width;
		}
    }
    CGRect r = overlayImage.frame;
    
    r.origin = scaledOrigin;
    
    r.size = CGSizeMake(actualWidth, actualHeight); 
    r.origin.x = r.origin.x+ (originalSize.size.width/2 - actualWidth/2);
    r.origin.y = r.origin.y +(originalSize.size.height/2 - actualHeight/2);
    overlayImage.frame = r;
    overlayImage.alpha = 0;
    [[self superview] addSubview:overlayImage];
#ifdef SPARKLE
    if(sparkleView != nil) {
        r.origin.x = r.origin.y=0;
        sparkleView.frame = r;
        [[self superview] addSubview:sparkleView];
        CGPoint p2 = CGPointMake(r.size.width/2, r.size.height/2);
        [sparkleView  startEmitterFromPoint: (CGPoint)p2];
    }
#endif

	[UIView beginAnimations:@"replace" context:Nil];
	[UIView setAnimationDuration:1];
    overlayImage.alpha = 1;
    self.alpha = 0;
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:)];
    [UIView commitAnimations];
    
    NSString *soundFilePath =
    [[NSBundle mainBundle] pathForResource: soundFname
                                    ofType: @"caf"];
    [[AudioController sharedInstance] playEffect:[[NSURL alloc] initFileURLWithPath: soundFilePath]];
}

- (void) tapped:(UITapGestureRecognizer *) recognizer {
    [self sparkle:[recognizer locationInView:self]];
}

- (void) panned:(UIPanGestureRecognizer *) recognizer {
    
    switch (recognizer.state) {
            
		case UIGestureRecognizerStateBegan:
            [self sparkle:[recognizer translationInView:self]];
            break;
        default:
            break;
            
    }
}

- (id) initWithImage:(UIImage *)image {
	
    self = [super initWithImage:image];
    
    if(self) {
#ifdef SPARKLE
        if([[[UIDevice currentDevice] systemVersion] floatValue] >= 5.0) {
            sparkleView = [[SparkleView alloc]initWithFrame:self.frame];
        }
#endif
        originalSize = self.frame;
    }
    
    return self;
}
@end
