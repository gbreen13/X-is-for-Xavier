//
//  MainViewController.h
//  X is for Xavier
//
//  Created by George Breen on 1/16/15.
//
//

#import <UIKit/UIKit.h>
#import "MenuViewController.h"
#import "RHPageViewController.h"
#import "RHBookViewController.h"

@class MenuViewController;      // circular definition in headers.


@interface MainViewController : UIViewController <PageTurnDelegate> {
    UIDeviceOrientation lastOrientation;
    IBOutlet UIButton *menuLaunch;
    PurchaseMenu *pMenu;
   
    MenuViewController *menuView;
}

@property (strong, nonatomic) RHPageViewController *pageViewController;
@property (nonatomic, strong) UIButton *menuLaunch;
@property (strong, nonatomic) MenuViewController *menuView;
@property (nonatomic, assign) UIDeviceOrientation lastOrientation;

@end
