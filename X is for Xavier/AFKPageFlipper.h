//
//  AFKPageFlipper.h
//  AFKPageFlipper
//
//  Created by Marco Tabini on 10-10-11.
//  Copyright 2010 AFK Studio Partnership. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "PDFRendererView.h"



@class AFKPageFlipper;



@protocol AFKPageFlipperDataSource

- (NSInteger) numberOfPagesForPageFlipper:(AFKPageFlipper *) pageFlipper;
- (UIView *) viewForPage:(NSInteger) page inFlipper:(AFKPageFlipper *) pageFlipper;
- (void) startNewPage: (NSInteger) page;
- (BOOL) okToFlipPage: (NSInteger) page;
- (void) shutDownPage: (NSInteger) page;
- (BOOL) getOrientation;
- (void) adjustOverlays: (PDFRendererView *)view;
@end


typedef enum {
	AFKPageFlipperDirectionLeft,
	AFKPageFlipperDirectionRight,
} AFKPageFlipperDirection;



@interface AFKPageFlipper : UIView {
	NSObject <AFKPageFlipperDataSource> *dataSource;
	NSInteger currentPage;
	NSInteger numberOfPages;
#if 1	
	UIView *__unsafe_unretained currentView;
	UIView *__unsafe_unretained nextView;
#else    
	UIView *__weak currentView;
	UIView *__weak nextView;
#endif	
	CALayer *backgroundAnimationLayer;
	CALayer *flipAnimationLayer;
	
	AFKPageFlipperDirection flipDirection;
	float startFlipAngle;
	float endFlipAngle;
	float currentAngle;

	BOOL setNextViewOnCompletion;
	BOOL animating;
	
	BOOL disabled;
    BOOL orientationIsHorizontal;
}

@property (nonatomic,strong) NSObject <AFKPageFlipperDataSource> *dataSource;

@property (nonatomic, strong) UITapGestureRecognizer *tapRecognizer;
@property (nonatomic, strong) UIPanGestureRecognizer *panRecognizer;
@property (nonatomic, assign) NSInteger currentPage;
@property (nonatomic, assign) BOOL disabled, orientationIsHorizontal;

- (void) setCurrentPage:(NSInteger) value animated:(BOOL) animated;
- (void) setOrientation: (NSInteger) orientation;

@end
