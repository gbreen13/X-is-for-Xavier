//
//  PurchaseMenu.h
//  X is for Xavier
//
//  Created by George Breen on 1/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StoreKit/StoreKit.h"
#import <AVFoundation/AVFoundation.h>

#define kXavierProductIdentifier         @"com.rabbithillsolutions.xisforxavier.upgrade"
#define kInAppPurchaseManagerTransactionFailedNotification @"kInAppPurchaseManagerTransactionFailedNotification"
#define kInAppPurchaseManagerTransactionSucceededNotification @"kInAppPurchaseManagerTransactionSucceededNotification"
#define kInAppPurchaseManagerStartMenu @"kInAppPurchaseManagerStartMenu"
#define kPurchaseMenuInactiveTimer 15
#define kFullBookUpgradeComplete @"kFullBookUpgradeComplete"

@interface PurchaseMenu : UIViewController <SKProductsRequestDelegate, SKPaymentTransactionObserver> {
    IBOutlet UIButton *purchaseButton;
    IBOutlet UIButton *restoreButton;
    IBOutlet UIButton *cancelButton;
    SKProduct *fullBookUpgrade;
    SKProductsRequest *productsRequest;
    int menuTimerCount;
    AVAudioPlayer *player;
    NSTimer *menuTimer;
    BOOL menuIsOn;
}
@property (nonatomic, strong) AVAudioPlayer *player;
@property (nonatomic, strong) NSTimer *menuTimer;
@property (nonatomic, strong) IBOutlet UIButton *purchaseButton, *restoreButton, *cancelButton;
@property (nonatomic, strong) SKProduct *fullBookUpgrade;
@property (nonatomic, strong) SKProductsRequest *productsRequest;
@property (nonatomic, assign) BOOL menuIsOn;
-(void) PurchaseMenuOn;
-(IBAction) PurchaseMenuOff: (id)sender;
-(IBAction) buyBookPressed: (id)sender;
-(IBAction) restoreBookPressed: (id)sender;
@end
