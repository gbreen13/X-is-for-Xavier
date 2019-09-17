//
//  MainViewController.m
//  X is for Xavier
//
//  Created by George Breen on 1/16/15.
//
//

#import "MainViewController.h"

@implementation MainViewController

@synthesize menuLaunch, menuView;
@synthesize lastOrientation, pageViewController;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Create the data model
    
    // Create page view controller
    self.pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PageViewController"];
//    self.pageViewController.orientation = [[UIDevice currentDevice] orientation];
//    [self.view addSubview: self.pageViewController.view];

    // Do any additional setup after loading the view.
    [menuLaunch setAlpha:.5];

    self.menuView = [self.storyboard instantiateViewControllerWithIdentifier:@"MenuView"];
    menuView.delegate = self;

    UIDevice *device = [UIDevice currentDevice];					//Get the device object
    [device beginGeneratingDeviceOrientationNotifications];			//Tell it to start monitoring the accelerometer for         orientation

    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];	//Get the notification centre for the app
    [nc addObserver:self											//Add yourself as an observer
           selector:@selector(orientationChanged:)
               name:UIDeviceOrientationDidChangeNotification
             object:device];
}

-(void) viewWillAppear:(BOOL)animated
{
    self.pageViewController.orientation = [UIDevice currentDevice].orientation;
    [self.view addSubview: self.pageViewController.view];
    CGRect r = menuView.view.frame;
    CGRect sr = [[UIScreen mainScreen] bounds];
    if( UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation))
        r.origin.y = MIN(sr.size.height,sr.size.width);
    else
        r.origin.y = MAX(sr.size.height,sr.size.width);
    
    r.size.height = 193;
    menuView.view.frame = r;
    [self.view addSubview:menuView.view];
    [self.view bringSubviewToFront:menuLaunch];     // put in front of the programmatic PDF view
    pMenu = [[PurchaseMenu alloc]initWithNibName:@"PurchaseView" bundle:nil];
    [pMenu.view setHidden: YES];

    [self.view addSubview:pMenu.view];
}

- (void)orientationChanged:(NSNotification *)note
{
    [self adjustViewsForOrientation:[UIDevice currentDevice].orientation];
}

- (void) adjustViewsForOrientation:(UIDeviceOrientation) orientation
{
    if(orientation == UIInterfaceOrientationUnknown)
        return;
    [menuView adjustViewForOrientation:orientation];
    [pageViewController changeOrientation:orientation];
    [self.view bringSubviewToFront:menuView.view];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}
- (IBAction)buttonPressed:(UIButton *)button
{
    if([menuView menuIsOn]) return;
    [menuView launchMenu];
}

-(void) pageTurn:(int)page
{
    [self.pageViewController flipToPage:page];
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
