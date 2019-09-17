//
//  AFKPageFlipper.m
//  AFKPageFlipper
//
//  Created by Marco Tabini on 10-10-12.
//  Copyright 2010 AFK Studio Partnership. All rights reserved.
//

#import "AFKPageFlipper.h"
#import "RHBook.h"
#import "PurchaseMenu.h"


#pragma mark -
#pragma mark UIView helpers


@interface UIView(Extended) 

- (UIImage *) imageByRenderingView;

@end


@implementation UIView(Extended)


- (UIImage *) imageByRenderingView {
    CGFloat oldAlpha = self.alpha;
    self.alpha = 1;
    UIGraphicsBeginImageContext(self.bounds.size);
	[self.layer renderInContext:UIGraphicsGetCurrentContext()];
	UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
    self.alpha = oldAlpha;
	return resultingImage;
}

@end


#pragma mark -
#pragma mark Private interface


@interface AFKPageFlipper()

#if 1
@property (nonatomic,unsafe_unretained) UIView *currentView;
@property (nonatomic,unsafe_unretained) UIView *nextView;
#else
@property (nonatomic,weak) UIView *currentView;
@property (nonatomic,weak) UIView *nextView;
#endif
@end


@implementation AFKPageFlipper

@synthesize tapRecognizer = _tapRecognizer;
@synthesize panRecognizer = _panRecognizer;


#pragma mark -
#pragma mark Flip functionality


- (void) initFlip {
	
	// Create screenshots of view
	
	UIImage *currentImage = [self.currentView imageByRenderingView];
	UIImage *newImage = [self.nextView imageByRenderingView];
	
	// Hide existing views
	
	self.currentView.alpha = 0;
	self.nextView.alpha = 0;
	
	// Create representational layers
	
	CGRect rect = self.bounds;
	rect.size.width /= 2;
	
	backgroundAnimationLayer = [CALayer layer];
	backgroundAnimationLayer.frame = self.bounds;
	backgroundAnimationLayer.zPosition = -300000;
	
	CALayer *leftLayer = [CALayer layer];
	leftLayer.frame = rect;
	leftLayer.masksToBounds = YES;
	leftLayer.contentsGravity = kCAGravityLeft;
	
	[backgroundAnimationLayer addSublayer:leftLayer];
	
	rect.origin.x = rect.size.width;
	
	CALayer *rightLayer = [CALayer layer];
	rightLayer.frame = rect;
	rightLayer.masksToBounds = YES;
	rightLayer.contentsGravity = kCAGravityRight;
	
	[backgroundAnimationLayer addSublayer:rightLayer];
	
	if (flipDirection == AFKPageFlipperDirectionRight) {
		leftLayer.contents = (id) [newImage CGImage];
		rightLayer.contents = (id) [currentImage CGImage];
	} else {
		leftLayer.contents = (id) [currentImage CGImage];
		rightLayer.contents = (id) [newImage CGImage];
	}

	[self.layer addSublayer:backgroundAnimationLayer];
	
	rect.origin.x = 0;
	
	flipAnimationLayer = [CATransformLayer layer];
	flipAnimationLayer.anchorPoint = CGPointMake(1.0, 0.5);
	flipAnimationLayer.frame = rect;
	
	[self.layer addSublayer:flipAnimationLayer];
	
	CALayer *backLayer = [CALayer layer];
	backLayer.frame = flipAnimationLayer.bounds;
	backLayer.doubleSided = NO;
	backLayer.masksToBounds = YES;
	
	[flipAnimationLayer addSublayer:backLayer];
	
	CALayer *frontLayer = [CALayer layer];
	frontLayer.frame = flipAnimationLayer.bounds;
	frontLayer.doubleSided = NO;
	frontLayer.masksToBounds = YES;
	frontLayer.transform = CATransform3DMakeRotation(M_PI, 0, 1.0, 0);
	
	[flipAnimationLayer addSublayer:frontLayer];
	
	if (flipDirection == AFKPageFlipperDirectionRight) {
		backLayer.contents = (id) [currentImage CGImage];
		backLayer.contentsGravity = kCAGravityLeft;
		
		frontLayer.contents = (id) [newImage CGImage];
		frontLayer.contentsGravity = kCAGravityRight;
		
		CATransform3D transform = CATransform3DMakeRotation(0.0, 0.0, 1.0, 0.0);
		transform.m34 = 1.0f / 2500.0f;
		
		flipAnimationLayer.transform = transform;
		
		currentAngle = startFlipAngle = 0;
		endFlipAngle = -M_PI;
	} else {
		backLayer.contentsGravity = kCAGravityLeft;
		backLayer.contents = (id) [newImage CGImage];
		
		frontLayer.contents = (id) [currentImage CGImage];
		frontLayer.contentsGravity = kCAGravityRight;
		
		CATransform3D transform = CATransform3DMakeRotation(-M_PI / 1.1, 0.0, 1.0, 0.0);
		transform.m34 = 1.0f / 2500.0f;
		
		flipAnimationLayer.transform = transform;
		
		currentAngle = startFlipAngle = -M_PI;
		endFlipAngle = 0;
	}
}


- (void) cleanupFlip {
	[backgroundAnimationLayer removeFromSuperlayer];
	[flipAnimationLayer removeFromSuperlayer];
	
	backgroundAnimationLayer = Nil;
	flipAnimationLayer = Nil;
	
	animating = NO;
	
	if (setNextViewOnCompletion) {
		[self.currentView removeFromSuperview];
		self.currentView = self.nextView;
		self.nextView = Nil;
	} else {
		[self.nextView removeFromSuperview];
		self.nextView = Nil;
	}

	self.currentView.alpha = 1;
    
//
//  Start animating, audio for the new page(s)
//
    [dataSource startNewPage:currentPage];

}


- (void) setFlipProgress:(float) progress setDelegate:(BOOL) setDelegate animate:(BOOL) animate {
    if (animate) {
        animating = YES;
    }
    
	float newAngle = startFlipAngle + progress * (endFlipAngle - startFlipAngle);
	
	float duration = animate ? 0.5 * fabs((newAngle - currentAngle) / (endFlipAngle - startFlipAngle)) : 0;
	
	currentAngle = newAngle;
	
	CATransform3D endTransform = CATransform3DIdentity;
	endTransform.m34 = 1.0f / 2500.0f;
	endTransform = CATransform3DRotate(endTransform, newAngle, 0.0, 1.0, 0.0);	
	
	[flipAnimationLayer removeAllAnimations];
							
	[CATransaction begin];
	[CATransaction setAnimationDuration:duration];
	
	flipAnimationLayer.transform = endTransform;
	
	[CATransaction commit];
	
	if (setDelegate) {
		[self performSelector:@selector(cleanupFlip) withObject:Nil afterDelay:duration];
	}
}


- (void) flipPage {
	[self setFlipProgress:1.0 setDelegate:YES animate:YES];
}


#pragma mark -
#pragma mark Animation management


- (void)animationDidStop:(NSString *) animationID finished:(NSNumber *) finished context:(void *) context {
	[self cleanupFlip];
}


#pragma mark -
#pragma mark Properties

@synthesize currentView;


- (void) setCurrentView:(UIView *) value {
	
	currentView = value;
}

@synthesize orientationIsHorizontal;

-(void) setOrientation:(NSInteger)orientation
{
     
    if((orientation == UIDeviceOrientationLandscapeLeft) || (orientation == UIDeviceOrientationLandscapeRight))
        orientationIsHorizontal = YES;
    if((orientation == UIDeviceOrientationPortrait) || (orientation == UIDeviceOrientationPortraitUpsideDown))
        orientationIsHorizontal = NO;
    
    if(orientationIsHorizontal)
        currentPage &= ~1;
    else
        if(currentPage < 1) currentPage = 1;
   
    if(currentView) 
        [dataSource adjustOverlays:(PDFRendererView *)currentView];
    if(nextView) 
        [dataSource adjustOverlays:(PDFRendererView *)nextView];
}

@synthesize nextView;


- (void) setNextView:(UIView *) value {
	
	nextView = value;
}


@synthesize currentPage;


- (BOOL) doSetCurrentPage:(NSInteger) value {
	if (value == currentPage) {
		return FALSE;
	}
    
#ifdef USES_IAP
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults]; 
    BOOL fullBookPurchased = [defaults boolForKey:kXavierProductIdentifier];
   if ((value > kNumFreePages) && (!fullBookPurchased)) {
    
        [[NSNotificationCenter defaultCenter] postNotificationName:kInAppPurchaseManagerStartMenu object:nil];
        return FALSE;
   }
#endif
	flipDirection = value < currentPage ? AFKPageFlipperDirectionRight : AFKPageFlipperDirectionLeft;
	
    currentPage = value;
    if(orientationIsHorizontal)
        currentPage &= ~1;
    else
        if(currentPage < 1) currentPage = 1;
	
	self.nextView = [self.dataSource viewForPage:value inFlipper:self];
	[self addSubview:self.nextView];
	
	return TRUE;
}	

- (void) setCurrentPage:(NSInteger) value {
	if (![self doSetCurrentPage:value]) {
		return;
	}
	
	setNextViewOnCompletion = YES;
	animating = YES;
	
	self.nextView.alpha = 0;
	
	[UIView beginAnimations:@"" context:Nil];
	[UIView setAnimationDuration:0.5];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
	
	self.nextView.alpha = 1;
	
	[UIView commitAnimations];
} 


- (void) setCurrentPage:(NSInteger) value animated:(BOOL) animated {
	if (![self doSetCurrentPage:value]) {
		return;
	}
	
	setNextViewOnCompletion = YES;
	animating = YES;
	
	if (animated) {
		[self initFlip];
		[self performSelector:@selector(flipPage) withObject:Nil afterDelay:0.001];
	} else {
		[self animationDidStop:Nil finished:[NSNumber numberWithBool:NO] context:Nil];
	}

}


@synthesize dataSource;


- (void) setDataSource:(NSObject <AFKPageFlipperDataSource>*) value {
	
	dataSource = value;
	numberOfPages = [dataSource numberOfPagesForPageFlipper:self];
 //   [dataSource startNewPage:1];
	self.currentPage = (self.bounds.size.width > self.bounds.size.height)?0:1;

}


@synthesize disabled;


- (void) setDisabled:(BOOL) value {
	disabled = value;
	
	self.userInteractionEnabled = !value;
	
	for (UIGestureRecognizer *recognizer in self.gestureRecognizers) {
		recognizer.enabled = !value;
	}
}


#pragma mark -
#pragma mark Touch management


- (void) tapped:(UITapGestureRecognizer *) recognizer {
	if (animating || self.disabled) {
		return;
	}
    
    if (![dataSource okToFlipPage:currentPage])
        return;
    
       int pageincrement = (self.currentView.bounds.size.width > self.currentView.bounds.size.height)?2:1;
        
	
	if (recognizer.state == UIGestureRecognizerStateRecognized) {
		NSInteger newPage;
		
		if ([recognizer locationInView:self].x < (self.bounds.size.width - self.bounds.origin.x) / 2) {
			newPage = MAX(0, self.currentPage - pageincrement);
            if(newPage == 0 && currentPage == 1) return;
		} else {
			newPage = MIN(self.currentPage + pageincrement, numberOfPages);
		}
        [self setCurrentPage:newPage animated:YES];
	}
}


- (void) panned:(UIPanGestureRecognizer *) recognizer {

    if (animating) {
        return;
    }

    if (![dataSource okToFlipPage:currentPage])
        return;
	static BOOL hasFailed;
	static BOOL initialized;
	
	static NSInteger oldPage;

	float translation = [recognizer translationInView:self].x;
	
	float progress = translation / self.bounds.size.width;
	
	if (flipDirection == AFKPageFlipperDirectionLeft) {
		progress = MIN(progress, 0);
	} else {
		progress = MAX(progress, 0);
	}
	
    int pageincrement = (self.currentView.bounds.size.width > self.currentView.bounds.size.height)?2:1;

	switch (recognizer.state) {
		case UIGestureRecognizerStateBegan:
			hasFailed = FALSE;
			initialized = FALSE;
			animating = NO;
			setNextViewOnCompletion = NO;
			break;
			
			
		case UIGestureRecognizerStateChanged:
			
			if (hasFailed) {
				return;
			}
			
			if (!initialized) {
				oldPage = self.currentPage;
				
				if (translation > 0) {
					if (self.currentPage > 1) {
						if([self doSetCurrentPage:self.currentPage - pageincrement] == FALSE) {
                            hasFailed = TRUE;
                            return;
                        }
					} else {
						hasFailed = TRUE;
						return;
					}
				} else {
					if (self.currentPage < numberOfPages) {
						if([self doSetCurrentPage:self.currentPage + pageincrement] == FALSE) {
                            hasFailed = TRUE;
                            return;
                        }
					} else {
						hasFailed = TRUE;
						return;
					}
				}
				
				hasFailed = NO;
				initialized = TRUE;
				setNextViewOnCompletion = NO;
				
				[self initFlip];
			}
			
			[self setFlipProgress:fabs(progress) setDelegate:NO animate:NO];
			
			break;
			
			
		case UIGestureRecognizerStateFailed:
			[self setFlipProgress:0.0 setDelegate:YES animate:YES];
			currentPage = oldPage;
			break;
			
		case UIGestureRecognizerStateRecognized:
			if (hasFailed) {
				[self setFlipProgress:0.0 setDelegate:YES animate:YES];
				currentPage = oldPage;
				
				return;
			}
			
			if (fabs((translation + [recognizer velocityInView:self].x / 4) / self.bounds.size.width) > 0.5) {
				setNextViewOnCompletion = YES;
				[self setFlipProgress:1.0 setDelegate:YES animate:YES];
			} else {
				[self setFlipProgress:0.0 setDelegate:YES animate:YES];
				currentPage = oldPage;
			}

			break;
		default:
			break;
	}
}


#pragma mark -
#pragma mark Frame management


- (void) setFrame:(CGRect) value {
	super.frame = value;

	numberOfPages = [dataSource numberOfPagesForPageFlipper:self];
	
	if (self.currentPage > numberOfPages) {
		self.currentPage = numberOfPages;
	}
	
}


#pragma mark -
#pragma mark Initialization and memory management


+ (Class) layerClass {
	return [CATransformLayer class];
}

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
		_tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
		_panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panned:)];
		
		[_tapRecognizer requireGestureRecognizerToFail:_panRecognizer];
		
        [self addGestureRecognizer:_tapRecognizer];
		[self addGestureRecognizer:_panRecognizer];
    }
    return self;
}


- (void)dealloc {
	self.dataSource = Nil;
	self.currentView = Nil;
	self.nextView = Nil;
}


@end
