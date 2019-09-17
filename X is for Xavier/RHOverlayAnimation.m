//
//  RHOverlayAnimation.m
//  X is for Xavier
//
//  Created by George Breen on 2/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RHOverlayAnimation.h"

@implementation RHOverlayAnimation

@synthesize animating,timer;

-(int) getwidth
{
    UIView *x = [self superview];
    return MAX(x.bounds.size.width, x.bounds.size.height);
    
}
-(void) animationTimer
{
    static int count = 0;
    if(count++ == 0) {  // 1st time, move the zebra to the left.
        CGRect r = self.frame;
        r.origin.x -= [self getwidth] * 2;
        self.frame = r;
        [UIView beginAnimations:@"Animate2" context:Nil];
        [UIView setAnimationDuration:4];
        [UIView setAnimationCurve: UIViewAnimationCurveLinear];
        r.origin.x += [self getwidth] * 3;
        self.frame = r;
        [UIView commitAnimations];
        timer = [NSTimer scheduledTimerWithTimeInterval:4.0 target:self selector:@selector(animationTimer) userInfo:nil repeats:NO];
    } else {
        [self stopAnimating];
        count = 0;
        animating = NO;
        timer = nil;
    }
}

-(void) animate
{
    if(self.animating) return;
	[UIView beginAnimations:@"Animate" context:Nil];
	[UIView setAnimationDuration:1];
    [UIView setAnimationDelegate:self];
	
    CGRect r = self.frame;
    
    r.origin.x += 2*[self getwidth]/3; 

    self.frame = r;
    animating = YES;
	[self startAnimating];
	[UIView commitAnimations];
    timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(animationTimer) userInfo:nil repeats:NO];

    NSString *soundFilePath =
    [[NSBundle mainBundle] pathForResource: soundFname
                                    ofType: @"caf"];
    
    [[AudioController sharedInstance] playEffect:[[NSURL alloc] initFileURLWithPath: soundFilePath]];
}
- (void) tapped:(UITapGestureRecognizer *) recognizer {
    [self animate];
}

- (void) panned:(UIPanGestureRecognizer *) recognizer {
    
    switch (recognizer.state) {
            
		case UIGestureRecognizerStateBegan:
            [self animate];
            break;
        default:
            break;
    }
}

- (id) initWithImage:(UIImage *)image andAnimationName: (NSString *)name andTimeInterval:(NSTimeInterval)time {
	id ret;
    if((ret = [super initWithImage:image]) != nil) {
        NSArray *MyAnimation = [[NSArray alloc] initWithObjects:
                                [self imageWithShadow:[UIImage imageNamed:[NSString stringWithFormat:@"%@0",name]]],
                                [self imageWithShadow:[UIImage imageNamed:[NSString stringWithFormat:@"%@1",name]]],
                                [self imageWithShadow:[UIImage imageNamed:[NSString stringWithFormat:@"%@2",name]]],
                                [self imageWithShadow:[UIImage imageNamed:[NSString stringWithFormat:@"%@3",name]]],
                                [self imageWithShadow:[UIImage imageNamed:[NSString stringWithFormat:@"%@4",name]]],
                                [self imageWithShadow:[UIImage imageNamed:[NSString stringWithFormat:@"%@5",name]]],
                                [self imageWithShadow:[UIImage imageNamed:[NSString stringWithFormat:@"%@6",name]]],
                                [self imageWithShadow:[UIImage imageNamed:[NSString stringWithFormat:@"%@7",name]]],
                                [self imageWithShadow:[UIImage imageNamed:[NSString stringWithFormat:@"%@7",name]]],
                                nil]; // Array With Images

        self.animationImages = MyAnimation;
    }
    return ret;
}

@end
