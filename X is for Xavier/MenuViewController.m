//
//  MenuViewController.m
//  X is for Xavier
//
//  Created by George Breen on 1/18/15.
//
//

#import "MenuViewController.h"
#import "RHPageViewController.h"
#import "RHBookViewController.h"
#import "RHBookViewControllerData.h"

@implementation MenuViewController

@synthesize musicVolume, effectVolume, musicLevel, pMenu,soundLevel, menuCancel, menuTimer, pageScroll, menuOn, delegate;

+ (MenuViewController *)sharedInstance
{
    static dispatch_once_t onceToken;
    static MenuViewController *sSharedInstance;
    
    dispatch_once(&onceToken, ^{
        sSharedInstance = [[MenuViewController alloc] init];
    });
    return sSharedInstance;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupHorizontalScrollView];
    // Do any additional setup after loading the view.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setupHorizontalScrollView) name:kFullBookUpgradeComplete object:nil];
}



//- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
//    return YES;
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark View management

-(void)buyPressed: (NSNotification *)notification
{
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kInAppPurchaseManagerStartMenu object:notification];
    [self menuOff];
}

- (void)setupHorizontalScrollView
{
#ifdef USES_IAP
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL fullBookPurchased = [defaults boolForKey:kXavierProductIdentifier];
    int rollover = 0;
    
#endif
    pageScroll.delegate = self;
    
    [pageScroll setCanCancelContentTouches:NO];
    
    pageScroll.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    pageScroll.clipsToBounds = YES;
    pageScroll.scrollEnabled = YES;
    pageScroll.pagingEnabled = NO;
    
    
    CGFloat cx = 0;
    for (int i = 0; i < [[RHBookViewControllerData sharedInstance] getPageCount]; i++) {
        NSString *imageName = [NSString stringWithFormat:@"pg-%d.png", (i + 1)];
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
        
        CGRect rect = btn.frame;
        rect.size.height = kThumbnailHeight;
        rect.size.width = kThumbnailWidth;
        rect.origin.x = cx;
        rect.origin.y = 0;
        
        btn.frame = rect;
        btn.tag = i;
#ifdef USES_IAP
        if ((i >= kNumFreePages) && (!fullBookPurchased)) {
            [btn setAlpha:.5];
            CGRect r = CGRectMake(0,kThumbnailHeight/2 - 10, kThumbnailWidth, 20);
            [btn addTarget:self action:@selector(buyPressed:) forControlEvents:UIControlEventTouchUpInside];
            UILabel *pButtonText = [[UILabel alloc]initWithFrame:r];
            pButtonText.font = [UIFont systemFontOfSize:12];
            [pButtonText setBackgroundColor:[UIColor blackColor]];
            [pButtonText setTextColor:[UIColor whiteColor]];
            pButtonText.textAlignment=UITextAlignmentCenter;
            switch (rollover++ % 4) {
                case 0: [pButtonText setText:@"Buy"]; break;
                case 1: [pButtonText setText:@"Full"]; break;
                case 2: [pButtonText setText:@"Version"]; break;
                case 3: [pButtonText setText:@""]; break;
            }
            [btn addSubview:pButtonText];
            
        }
        else
        {
#endif
            [btn addTarget:self action:@selector(thumbPressed:) forControlEvents:UIControlEventTouchUpInside];
#ifdef USES_IAP
        }
#endif
        [pageScroll addSubview:btn];
        
        cx += btn.frame.size.width+5;
    }
    
    [pageScroll setContentSize:CGSizeMake(cx, [pageScroll bounds].size.height)];
}


- (void)removeMenu {
    menuOn = NO;
}

-(void) menuOff
{
    if(menuOn == NO) return;
    
    [UIView beginAnimations:@"MenuAnimationOff" context:Nil];
    [UIView setAnimationDuration:.5];
    
    CGRect r = self.view.frame;
    r.origin.y += kMenuHeight;
    self.view.frame = r;
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(removeMenu)];
    [UIView commitAnimations];
    [menuTimer invalidate];
    menuTimer = nil;
    menuOn= NO;
}

-(IBAction)restart:(id)sender
{
    menuTimerCount = kMenuInactiveTimer;
    [delegate pageTurn:0];
    /*
     ** TBD [flipper setCurrentPage:1 animated:YES];
     */
}
-(IBAction)menuCancelHit:(id)sender
{
    [self menuOff];
}

-(IBAction)sliderUpdate:(UISlider *)sender
{
    menuTimerCount = kMenuInactiveTimer;
    
    if(sender == effectVolume) {
        [[AudioController sharedInstance] setEffectVolume:sender.value];
        [[NSUserDefaults standardUserDefaults] setFloat:sender.value forKey:kEffectVolume];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    if(sender == musicVolume) {
        [[AudioController sharedInstance] setMusicVolume:sender.value];
        [[NSUserDefaults standardUserDefaults] setFloat:sender.value forKey:kMusicVolume];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

-(void) step
{
    if( menuTimerCount > 0 ) {
        if(--menuTimerCount == 0)
            [self menuOff];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    menuTimerCount = kMenuInactiveTimer;
}
- (void)thumbPressed:(UIButton *)button
{
    menuTimerCount = kMenuInactiveTimer;
    [delegate pageTurn:(int)button.tag];
}
-(BOOL) menuIsOn
{
    return menuOn;
}

-(void) launchMenu
{
    CGRect r = self.view.frame;
    
    [effectVolume setValue:[[AudioController sharedInstance] getEffectVolume]];
    [musicVolume setValue:[[AudioController sharedInstance] getMusicVolume]];
    
    [UIView beginAnimations:@"MenuAnimation" context:Nil];
    [UIView setAnimationDuration:.5];
    
    r.origin.y -= kMenuHeight;
    self.view.frame = r;
    menuOn = YES;
    [UIView commitAnimations];
    menuTimerCount = kMenuInactiveTimer;
    menuTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(step) userInfo:nil repeats:YES];
}

//
//  Move the menu to jsut off the bottom
//
- (void) adjustViewForOrientation:(UIDeviceOrientation) orientation
{
    if(self.isViewLoaded) {
        CGRect r = self.view.frame;
        CGRect sr = [[UIScreen mainScreen] bounds];
        if( UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation))
            r.origin.y = MIN(sr.size.height,sr.size.width);
        else
            r.origin.y = MAX(sr.size.height,sr.size.width);

        [self menuOff];
        self.view.frame = r;
        
    }
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
