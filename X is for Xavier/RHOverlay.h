//
//  RHOverlay.h
//  X is for Xavier
//
//  Created by George Breen on 12/14/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <Foundation/Foundation.h>
#import "AudioController.h"


@protocol RHOverlayDelegate 
- (void) freezePage: (BOOL) freeze;
@end

typedef enum {
    OVMove,
    OVVanish
} RHOverlayType;

@interface RHOverlay : UIImageView <AVAudioPlayerDelegate>{
    CGRect location;
    CGPoint origin;
    NSString *fileName;
    NSString *soundFname;
    CGPoint starttap;
	NSObject <RHOverlayDelegate> *delegate;
    UIImage *original;
    RHOverlayType type;
}
@property (nonatomic, copy) NSString *fileName;
@property (nonatomic, strong) NSObject <RHOverlayDelegate> *delegate;
@property (nonatomic, copy) NSString *soundFname;
-(void) setLocation:(CGRect) r;
-(CGRect) getLocation;
- (UIImage*)imageWithShadow: (UIImage *)source;
-(void)setAndScaleOverlay:(CGPoint) offset andScale:(CGFloat)scale;

@property (nonatomic, strong) UITapGestureRecognizer *tapRecognizer;
@property (nonatomic, strong) UIPanGestureRecognizer *panRecognizer;
@property (nonatomic, strong) UIImage *original;

@end
