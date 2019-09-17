//
//  MenuViewController.h
//  X is for Xavier
//
//  Created by George Breen on 1/18/15.
//
//

#import <UIKit/UIKit.h>
#import "PurchaseMenu.h"

#define kMenuHeight 193

@protocol PageTurnDelegate <NSObject>
@required
- (void) pageTurn: (int) page;
@end

@interface MenuViewController : UIViewController <UIScrollViewDelegate> {
    IBOutlet UIButton *menuCancel;
    IBOutlet UISlider *effectVolume;
    IBOutlet UISlider *musicVolume;
    IBOutlet UIScrollView *pageScroll;
    BOOL menuOn;
    CGFloat musicLevel, soundLevel;
    int menuTimerCount;
    NSTimer *menuTimer;
    id <PageTurnDelegate> delegate;

}
@property (nonatomic, assign) BOOL menuOn;
@property (nonatomic, assign) CGFloat musicLevel, soundLevel;
@property (nonatomic, strong) UIButton *menuCancel;
@property (nonatomic, strong) IBOutlet UISlider *effectVolume, *musicVolume;
@property (nonatomic, strong) NSTimer *menuTimer;
@property (nonatomic, strong) IBOutlet UIScrollView *pageScroll;
@property (nonatomic, strong) PurchaseMenu *pMenu;
@property (retain) id delegate;

+ (MenuViewController *)sharedInstance;
- (void) adjustViewForOrientation:(UIDeviceOrientation) orientation;
-(void) menuOff;
-(IBAction)menuCancelHit:(id)sender;
-(IBAction)sliderUpdate:(UISlider *)sender;
-(IBAction)restart:(id)sender;
- (void)setupHorizontalScrollView;
- (void)thumbPressed:(UIButton *)button;
-(void) launchMenu;
-(BOOL) menuIsOn;

@end
