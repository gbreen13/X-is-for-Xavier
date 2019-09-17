//
//  RHPageViewController.m
//  X is for Xavier
//
//  Created by George Breen on 1/12/15.
//
//

#import "RHPageViewController.h"

@interface RHPageViewController ()

@end

@implementation RHPageViewController

@synthesize orientation, delegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.delegate = self;

    self.view.autoresizesSubviews = YES;
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    RHBookViewController *bookController;

    RHBookViewControllerData *bookData = [RHBookViewControllerData sharedInstance];
    [bookData loadBook:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"pages" ofType:@"xml"]]];
    
    
    bookController = [RHBookViewController rhBookViewControllerForPageIndex:0 andOrientation:orientation];
    
    if(bookController != nil) {

        [self setViewControllers:@[bookController]
                       direction:UIPageViewControllerNavigationDirectionForward
                        animated:NO
                      completion:NULL];
    
        self.dataSource = self;     // Book will create the view controllers for current, previous and next pages
        self.delegate = self;


    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIPageViewControllerDelegate

- (UIViewController *)pageViewController:(UIPageViewController *)pvc viewControllerBeforeViewController:(RHBookViewController *)bc
{
    orientation = [UIDevice currentDevice].orientation;
    NSInteger index = bc.curPage;
    int delta = 1;
    if(index > 1 && (UIDeviceOrientationIsLandscape(orientation))) ++delta;
    index -= delta;
    return [RHBookViewController rhBookViewControllerForPageIndex:(index) andOrientation:orientation];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pvc viewControllerAfterViewController:(RHBookViewController *)bc
{
    orientation = [UIDevice currentDevice].orientation;
    NSInteger index = bc.curPage;
    int delta = 1;
    if(index > 0 && (UIDeviceOrientationIsLandscape(orientation))) ++delta;
    index += delta;
#ifdef USES_IAP
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL fullBookPurchased = [defaults boolForKey:kXavierProductIdentifier];
    if ((index >= kNumFreePages) && (!fullBookPurchased)) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kInAppPurchaseManagerStartMenu object:nil];
        return nil;
    }
#endif
    return [RHBookViewController rhBookViewControllerForPageIndex:(index) andOrientation:orientation];
}

- (UIPageViewControllerSpineLocation)pageViewController:(UIPageViewController  *)pageViewController
                   spineLocationForInterfaceOrientation:(UIInterfaceOrientation)orient
{
    if(UIInterfaceOrientationIsPortrait(orient))
    {
           return UIPageViewControllerSpineLocationMin;
    } else {
        return UIPageViewControllerSpineLocationMid;
    }
}
    
- (RHBookViewController *) viewControllerAtIndex:(NSUInteger)x
{
    if(x < [self.viewControllers count])
        return [self.viewControllers objectAtIndex:x];
    return nil;
}

-(void) flipToPage:(int) x
{
    
    int dir = 0;
//
//  Called from the menu.  If landscape, force to even.
//
    RHBookViewController *bookController =(RHBookViewController *)self.viewControllers[0];
    
    if(UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation)) {
        if((!(x & 1)) && (x > 0))           // if the new orientation is landscape and the page we are flipping
                                            // is even (right hand side) and greater than page 0, the go to the
                                            // page before which represents the left side of the screen.
            --x;
    }
    
    if(x > bookController.curPage) dir=1;
    if(x < bookController.curPage) dir = -1;

    bookController = [RHBookViewController rhBookViewControllerForPageIndex:x andOrientation:orientation];
    
    if(bookController != nil) {
        
        if(dir ==1)
            [self setViewControllers:@[bookController]
                       direction:UIPageViewControllerNavigationDirectionForward
                        animated:YES
                      completion:NULL];
        if(dir == -1)
            [self setViewControllers:@[bookController]
                           direction:UIPageViewControllerNavigationDirectionReverse
                            animated:YES
                          completion:NULL];
       
        
    }
}


- (void)viewWillAppear:(BOOL)animated {
/*
    
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
*/
}


#pragma mark -
#pragma mark Initialization and memory management


- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}

-(void) changeOrientation: (UIDeviceOrientation)toInterfaceOrientation
{
    RHBookViewController *curView = (RHBookViewController *)self.viewControllers[0];
    [curView changeOrientation: toInterfaceOrientation];
}


- (id) init {
    if ((self = [super init])) {
        
        [self loadView];
    }
    
    return self;
}


@end
