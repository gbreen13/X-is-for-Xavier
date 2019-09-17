//
//  MainController.h
//  AFKPageFlipper
//
//  Created by Marco Tabini on 10-10-11.
//  Copyright 2010 AFK Studio Partnership. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AFKPageFlipper.h"
#import "RHBookViewController.h"
#import "PurchaseMenu.h"


#define kDefaultMusicLevel 1.0
#define kDefaultSoundLevel 1.0
#define kMenuInactiveTimer 5
#define kThumbnailWidth 57
#define kThumbnailHeight 74

#define kEffectVolume @"EffectVolume"
#define kMusicVolume @"MusicVolume"

@interface MainController : UIPageViewController  <UIScrollViewDelegate> {
    IBOutlet UIView *menuView;
    IBOutlet UISlider *effectVolume;
    IBOutlet UISlider *musicVolume;
    UIInterfaceOrientation lastOrientation;
    UIButton *menuLaunch;
    IBOutlet UIButton *menuCancel;
    BOOL menuISOn;
    CGFloat musicLevel, soundLevel;
    int menuTimerCount;
    NSTimer *menuTimer;
    IBOutlet UIScrollView *pageScroll;
    PurchaseMenu *pMenu;
}

@property (nonatomic, strong) RHBookViewController *book;
@property (nonatomic, assign) UIInterfaceOrientation lastOrientation;
@property (nonatomic, assign) BOOL menuIsOn;
@property (nonatomic, assign) CGFloat musicLevel, soundLevel;
@property (nonatomic, strong) IBOutlet UIView *menuView;
@property (nonatomic, strong) UIButton *menuLaunch;
@property (nonatomic, strong) UIButton *menuCancel;
@property (nonatomic, strong) IBOutlet UISlider *effectVolume, *musicVolume;
@property (nonatomic, strong) NSTimer *menuTimer;
@property (nonatomic, strong) IBOutlet UIScrollView *pageScroll;
@property (nonatomic, strong) PurchaseMenu *pMenu;

-(void) freeMemory;
-(void) menuOff;
-(IBAction)menuCancelHit:(id)sender;
-(IBAction)sliderUpdate:(UISlider *)sender;
-(IBAction)restart:(id)sender;
- (void)setupHorizontalScrollView;
- (void)thumbPressed:(UIButton *)button;



@end
