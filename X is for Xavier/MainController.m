    //
//  MainController.m
//  AFKPageFlipper
//
//  Created by Marco Tabini on 10-10-11.
//  Copyright 2010 AFK Studio Partnership. All rights reserved.
//

#import "MainController.h"
#import "RHBookViewControllerData.h"
#import "PDFRendererView.h"
//#import "Reachability.h"

@implementation MainController

@synthesize lastOrientation, menuLaunch, menuView, musicVolume, effectVolume, menuIsOn, menuCancel, menuTimer;
@synthesize musicLevel, soundLevel, pageScroll, pMenu;

#pragma mark -
#pragma mark View management

-(IBAction)menuCancelHit:(id)sender
{
    [self menuOff];
}

-(IBAction)sliderUpdate:(UISlider *)sender
{
    menuTimerCount = kMenuInactiveTimer;
    RHBookViewControllerData *book = [RHBookViewControllerData sharedInstance];
    if(sender == effectVolume) {
        [book setEffectVolume:soundLevel = sender.value];
        [[NSUserDefaults standardUserDefaults] setFloat:sender.value forKey:kEffectVolume];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    if(sender == musicVolume) {
        [book setMusicVolume:musicLevel = sender.value];
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
    [flipper setCurrentPage:button.tag];
}

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
    for (int i = 0; i < [book numberOfPages]; i++) {
        NSString *imageName = [NSString stringWithFormat:@"pg-%d.png", (i + 1)];
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
        
        CGRect rect = btn.frame;
        rect.size.height = kThumbnailHeight;
        rect.size.width = kThumbnailWidth;
        rect.origin.x = cx;
        rect.origin.y = 0;
        
        btn.frame = rect;
        btn.tag = i+1;
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

- (void)buttonPressed:(UIButton *)button
{
    if(self.menuIsOn) return;
    CGRect r = menuView.frame;
        
    [effectVolume setValue:soundLevel];
    [musicVolume setValue:musicLevel];
    
   r.origin.y = self.view.bounds.size.height;  //just to see it for now
 
    if([menuView superview] == nil) {
        r.size.width = self.view.bounds.size.width;
        menuView.frame = r;
        [self.view addSubview:menuView];
    }
    [UIView beginAnimations:@"MenuAnimation" context:Nil];
    [UIView setAnimationDuration:.5];
        
    r.origin.y -= menuView.frame.size.height;
    menuView.frame = r;
    self.menuIsOn = YES;
    [UIView commitAnimations];
    menuTimerCount = kMenuInactiveTimer;
    menuTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(step) userInfo:nil repeats:YES];

}

- (void)removeMenu {
    menuIsOn = NO;
}
    
-(void) menuOff
{
    if(self.menuIsOn == NO) return;

    [UIView beginAnimations:@"MenuAnimationOff" context:Nil];
    [UIView setAnimationDuration:.5];
    
    CGRect r = menuView.frame;
    r.origin.y += menuView.frame.size.height;
    menuView.frame = r;
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(removeMenu)];
    [UIView commitAnimations];
    [menuTimer invalidate];
    menuTimer = nil;
}

-(IBAction)restart:(id)sender
{
    menuTimerCount = kMenuInactiveTimer;
   [flipper setCurrentPage:1 animated:YES];
}
                  

- (void) viewDidLoad
{
	[super viewDidLoad];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setupHorizontalScrollView) name:kFullBookUpgradeComplete object:nil];

    self.view.autoresizesSubviews = YES;
	self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	
    book = [[RHBookViewController alloc] initWithFrame:self.view.bounds andXMLFileNSURL:
            [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"pages" ofType:@"xml"]]];
    [book setMusicVolume:musicLevel];
    [book setEffectVolume:soundLevel];
    
	self.dataSource = book; // Book will create the view controllers for current, previous and next pages
	
//	[self.view addSubview:flipper];
    
    [[NSBundle mainBundle] loadNibNamed:@"MenuView" owner:self options:nil];
 
    UIDevice *device = [UIDevice currentDevice];					//Get the device object
	[device beginGeneratingDeviceOrientationNotifications];			//Tell it to start monitoring the accelerometer for orientation
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];	//Get the notification centre for the app
	[nc addObserver:self											//Add yourself as an observer
		   selector:@selector(orientationChanged:)
			   name:UIDeviceOrientationDidChangeNotification
			 object:device];
    menuLaunch = [UIButton buttonWithType:UIButtonTypeCustom];
	[menuLaunch setBackgroundImage:[UIImage imageNamed:@"gear.png"] forState:UIControlStateNormal]; //sets the Background image 
    
	[menuLaunch setImage:[UIImage imageNamed:@"gearselected.png"] forState:UIControlStateHighlighted]; //sets the ima    
    menuLaunch.frame = CGRectMake(10, self.view.bounds.size.height-50, 26, 26);
    menuLaunch.autoresizingMask = 0;
    menuLaunch.backgroundColor = [UIColor clearColor];
    [menuLaunch setAlpha:.5];
    [menuLaunch addTarget:self action:@selector(buttonPressed:) 
         forControlEvents:UIControlEventTouchUpInside];    
    [self.view addSubview:menuLaunch];
    
    pMenu = [[PurchaseMenu alloc]initWithNibName:@"PurchaseView" bundle:nil];
    [self.view addSubview:pMenu.view];
    
}

- (void)viewWillAppear:(BOOL)animated {
    

//    Reachability *reach = [Reachability reachabilityForInternetConnection];	
//    NetworkStatus netStatus = [reach currentReachabilityStatus]; 
#ifdef USES_IAP
//    if (netStatus == NotReachable) {        
//        NSLog(@"No internet connection!");        
//    } else {   
//    }
#endif
    [self setupHorizontalScrollView];
    [super viewWillAppear:animated];
}


#pragma mark -
#pragma mark Initialization and memory management


- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
	return YES;
}

- (void)orientationChanged:(NSNotification *)note
{
    [self adjustViewsForOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
}
- (void) adjustViewsForOrientation:(UIInterfaceOrientation) orientation {
  
    
    if(lastOrientation != orientation) {

        if(menuIsOn) 
            [self menuOff];
        
        [book setOrientation: orientation];
        [flipper setOrientation: orientation];
        lastOrientation = orientation;
        CGRect r = menuLaunch.frame;
        CGFloat h;
        if((orientation == UIInterfaceOrientationPortrait) || (orientation == UIInterfaceOrientationPortraitUpsideDown) )
            h = MAX(self.view.bounds.size.height, self.view.bounds.size.width);
        else
            h = MIN(self.view.bounds.size.height, self.view.bounds.size.width);
        
        r.origin.y = h-50;
        r.origin.x = 10;
        menuLaunch.frame = r;

        r = menuView.frame;
        r.origin.y = self.view.frame.size.height;
        menuView.frame = r;
        
    }
}

- (id) init {
	if ((self = [super init])) {
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults]; 
        if ([defaults objectForKey:kMusicVolume] != nil) 
            musicLevel = [defaults floatForKey:kMusicVolume];
        else
            musicLevel = kDefaultMusicLevel;

        if ([defaults objectForKey:kEffectVolume] != nil) 
            soundLevel = [defaults floatForKey:kEffectVolume];
        else
            soundLevel = kDefaultSoundLevel;
		
		[self loadView];
	}
	
	return self;
}


-(void) freeMemory
{
    [book freeMemory];
}


@end
