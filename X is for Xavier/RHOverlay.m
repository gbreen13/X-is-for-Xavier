//
//  RHOverlay.m
//  X is for Xavier
//
//  Created by George Breen on 12/14/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "RHOverlay.h"

@implementation RHOverlay
@synthesize soundFname;
@synthesize fileName;
@synthesize delegate, original;

-(void) setLocation: (CGRect) r
{
    location = r;
}
-(CGRect) getLocation
{
    return location;
}
-(void)setAndScaleOverlay:(CGPoint) offset andScale:(CGFloat)scale
{
    CGRect r = self.frame;
    CGRect ir = [self getLocation];
    r.origin.x = offset.x + ir.origin.x * scale;
    r.origin.y = offset.y + ir.origin.y * scale;
    r.size.width = ir.size.width * scale;
    r.size.height = ir.size.height * scale;
    self.frame = r;
    self.alpha = 1;
}

#pragma mark -
#pragma mark Touch management

@synthesize tapRecognizer = _tapRecognizer;
@synthesize panRecognizer = _panRecognizer;

- (void) tapped:(UITapGestureRecognizer *) recognizer {
}

- (UIImage*)imageWithShadow: (UIImage *)source {
    CGColorSpaceRef colourSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef shadowContext = CGBitmapContextCreate(NULL,source.size.width + 10, source.size.height + 10, CGImageGetBitsPerComponent(source.CGImage), 0,
                                                       colourSpace, kCGImageAlphaPremultipliedLast);
    CGColorSpaceRelease(colourSpace);
    
    CGContextSetShadowWithColor(shadowContext, CGSizeMake(8, -8), 8, [UIColor colorWithRed:0 green:0 blue:0 alpha:.5].CGColor);
    CGContextDrawImage(shadowContext, CGRectMake(0, 10, source.size.width, source.size.height), source.CGImage);
    
    CGImageRef shadowedCGImage = CGBitmapContextCreateImage(shadowContext);
    CGContextRelease(shadowContext);
    
    UIImage * shadowedImage = [UIImage imageWithCGImage:shadowedCGImage];
    CGImageRelease(shadowedCGImage);
    
    return shadowedImage;
}

- (void) panned:(UIPanGestureRecognizer *) recognizer {

    CGPoint newloc;
    
    switch (recognizer.state) {

		case UIGestureRecognizerStateBegan:
        {
            starttap = [recognizer translationInView:self];
            origin = self.frame.origin;
            original = self.image;
            self.image =  [self imageWithShadow:self.image];           if(delegate != nil)
                [delegate freezePage:YES];

            NSString *soundFilePath =
            [[NSBundle mainBundle] pathForResource: soundFname
                                            ofType: @"caf"];
            
           [[AudioController sharedInstance] playEffect:[[NSURL alloc] initFileURLWithPath: soundFilePath]];
        }
        break;

        case UIGestureRecognizerStateEnded:
            if(delegate != nil)
                [delegate freezePage:NO];
            self.image = original;
            break;

		case UIGestureRecognizerStateChanged:
            
            newloc = CGPointMake([recognizer translationInView:self].x, [recognizer translationInView:self].y);
            CGRect r = self.frame;
            r.origin.x = origin.x + newloc.x-starttap.x;
            r.origin.y = origin.y + newloc.y-starttap.y;
            self.frame = r;
            break;

 		case UIGestureRecognizerStateFailed:
        case UIGestureRecognizerStatePossible:           
        case UIGestureRecognizerStateCancelled:           
            break;
          
    }
 
}

- (BOOL)isPixelTransparent: (CGPoint)point {
    

    unsigned char pixel[4] = {0};
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGContextRef context = CGBitmapContextCreate(pixel, 1, 1, 8, 4, colorSpace, kCGImageAlphaPremultipliedLast);
    
    CGContextTranslateCTM(context, -point.x, -point.y);
    
    [self.layer renderInContext:context];
    
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    return (pixel[3] < 0xf);
}
//
//  Override hittest to check for transparent pixels and only move if non transparent.
//

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *hitView = [super hitTest:point withEvent:event];
    
    // If the hitView is THIS view, return nil and allow hitTest:withEvent: to
    // continue traversing the hierarchy to find the underlying view.
    if (hitView == self) {
//
//  If they hit me, then check for pixel
        if([self isPixelTransparent:point]) {
            return nil;
        }
    }
    // Else return the hitView (as it could be one of this view's buttons):
    return hitView;
}


- (id) initWithImage:(UIImage *)image {
	
    if ((self = [super initWithImage:image])) {
		_tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
		_panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panned:)];
		
		[_tapRecognizer requireGestureRecognizerToFail:_panRecognizer];
		
        [self addGestureRecognizer:_tapRecognizer];
		[self addGestureRecognizer:_panRecognizer];
        self.userInteractionEnabled = YES;
	}
	
	return self;
}
@end
