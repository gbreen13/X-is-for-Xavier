//
//  PurchaseMenu.m
//  X is for Xavier
//
//  Created by George Breen on 1/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PurchaseMenu.h"

@implementation PurchaseMenu

@synthesize purchaseButton, restoreButton, cancelButton;
@synthesize fullBookUpgrade, productsRequest, menuIsOn, menuTimer;
@synthesize player;

+ (NSString*) encode:(const uint8_t*) input length:(NSInteger) length {
    static char table[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
    
    NSMutableData* data = [NSMutableData dataWithLength:((length + 2) / 3) * 4];
    uint8_t* output = (uint8_t*)data.mutableBytes;
    
    for (NSInteger i = 0; i < length; i += 3) {
        NSInteger value = 0;
        for (NSInteger j = i; j < (i + 3); j++) {
            value <<= 8;
            
            if (j < length) {
                value |= (0xFF & input[j]);
            }
        }
        
        NSInteger index = (i / 3) * 4;
        output[index + 0] =                    table[(value >> 18) & 0x3F];
        output[index + 1] =                    table[(value >> 12) & 0x3F];
        output[index + 2] = (i + 1) < length ? table[(value >> 6)  & 0x3F] : '=';
        output[index + 3] = (i + 2) < length ? table[(value >> 0)  & 0x3F] : '=';
    }
    
    return [[NSString alloc] initWithData:data
                                  encoding:NSASCIIStringEncoding];
}

- (void)requestFullBookUpgradeProductData
{
NSSet *productIdentifiers = [NSSet setWithObject:kXavierProductIdentifier];
productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:productIdentifiers];
productsRequest.delegate = self;
[productsRequest start];

// we will release the request object in the delegate callback
}

#pragma mark -
#pragma mark SKProductsRequestDelegate methods

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    NSArray *products = response.products;
    fullBookUpgrade = [products count] == 1 ? [products objectAtIndex:0] : nil;
    if (fullBookUpgrade)
    {
        NSLog(@"Product title: %@" , fullBookUpgrade.localizedTitle);
        NSLog(@"Product description: %@" , fullBookUpgrade.localizedDescription);
        NSLog(@"Product price: %@" , fullBookUpgrade.price);
        NSLog(@"Product id: %@" , fullBookUpgrade.productIdentifier);
    }
    
    for (NSString *invalidProductId in response.invalidProductIdentifiers)
    {
        NSLog(@"Invalid product id: %@" , invalidProductId);
    }
    
    // finally release the reqest we alloc/init’ed in requestProUpgradeProductData
    productsRequest = nil;
}

//
// call this method once on startup
//
- (void)loadStore
{
    // restarts any purchases if they were interrupted last time the app was open
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    
    // get the product description (defined in early sections)
    [self requestFullBookUpgradeProductData];
}

//
// call this before making a purchase
//
- (BOOL)canMakePurchases
{
    return [SKPaymentQueue canMakePayments];
}

//
// kick off the upgrade transaction
//
- (void)purchaseFullBookUpgrade
{
    SKPayment *payment = [SKPayment paymentWithProductIdentifier:kXavierProductIdentifier];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}
//
// kick off the restore transaction
//
- (void)restoreFullBookUpgrade
{
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

#pragma -
#pragma Purchase helpers

//
// saves a record of the transaction by storing the receipt to disk
//
- (void)recordTransaction:(SKPaymentTransaction *)transaction
{
    if ([transaction.payment.productIdentifier isEqualToString:kXavierProductIdentifier])
    {
//        NSString* jsonObjectString = [PurchaseMenu encode: (uint8_t*)[[transaction transactionReceipt] bytes]  length: [[transaction transactionReceipt] length]];
//        NSLog(@"%@", jsonObjectString);                              
#if 0 
        NSString* completeString = [NSString stringWithFormat: @"http://rabbithillsolutions.com/yourValidationScript.php?receipt=%@", jsonObjectString];
                                      
        NSURL* urlForValidation = [NSURL URLWithString: completeString];
        
        NSString *ret = [[NSString alloc] initWithContentsOfURL:urlForValidation];
                                     
        NSMutableURLRequest* validationRequest = [[NSMutableURLRequest alloc] initWithURL: urlForValidation];
                                      
        [validationRequest setHTTPMethod: @"GET"];
                                      
        NSData* responseData = [NSURLConnection sendRequest: validationRequest  returningResponse: nil  error: nil];
                                      
        NSString* responseString = [[NSString alloc] initWithData: responseData encoding: NSUTF8StringEncoding];
                                      
        int success = [responseString intValue];        // save the transaction receipt to disk
#endif
        [[NSUserDefaults standardUserDefaults] setValue:transaction.transactionReceipt forKey:@"FullBookUpgradeTransactionReceipt" ];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

//
// enable pro features
//
- (void)provideContent:(NSString *)productId
{
    if ([productId isEqualToString:kXavierProductIdentifier])
    {
        // enable the pro features
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kXavierProductIdentifier ];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

-(IBAction)buyBookPressed:(id)sender
{
    if([self canMakePurchases])
        [self purchaseFullBookUpgrade];    

    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!" 
                                                    message:@"Can't purchase now" 
                                                   delegate:nil 
                                          cancelButtonTitle:nil 
                                          otherButtonTitles:@"OK", nil];
    
        [alert show];
    }
}

-(IBAction)restoreBookPressed:(id)sender
{
    if([self canMakePurchases])
        [self restoreFullBookUpgrade];    
    
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!" 
                                                        message:@"Can't restore purchase now" 
                                                       delegate:nil 
                                              cancelButtonTitle:nil 
                                              otherButtonTitles:@"OK", nil];
        
        [alert show];
    }
}
//
// removes the transaction from the queue and posts a notification with the transaction result
//
- (void)finishTransaction:(SKPaymentTransaction *)transaction wasSuccessful:(BOOL)wasSuccessful
{
    // remove the transaction from the payment queue.
    
    UIAlertView *alert;
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    
    //    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:transaction, @"transaction" , nil];
    if (wasSuccessful)
    {
        alert = [[UIAlertView alloc] initWithTitle:@"Congratulations!" 
                                           message:@"You can now read the rest of the book!" 
                                          delegate:nil 
                                 cancelButtonTitle:nil 
                                 otherButtonTitles:@"OK", nil];
        // tell MainController to reload the sliding menu
        [[NSNotificationCenter defaultCenter] postNotificationName:kFullBookUpgradeComplete object:nil];
        [player play];    
    }
    else {
        alert = [[UIAlertView alloc] initWithTitle:@"Error!" 
                                           message:transaction.error.localizedDescription 
                                          delegate:nil 
                                 cancelButtonTitle:nil 
                                 otherButtonTitles:@"OK", nil];
        
    }
    [alert show];
    [self PurchaseMenuOff:nil];

}

//
// called when the transaction was successful
//
- (void)completeTransaction:(SKPaymentTransaction *)transaction
{
    [self recordTransaction:transaction];
    [self provideContent:transaction.payment.productIdentifier];
    [self finishTransaction:transaction wasSuccessful:YES];
}

//
// called when a transaction has been restored and and successfully completed
//
- (void)restoreTransaction:(SKPaymentTransaction *)transaction
{
    [self recordTransaction:transaction.originalTransaction];
    [self provideContent:transaction.originalTransaction.payment.productIdentifier];
    [self finishTransaction:transaction wasSuccessful:YES];
}

//
// called when a transaction has failed
//
- (void)failedTransaction:(SKPaymentTransaction *)transaction
{
    if (transaction.error.code != SKErrorPaymentCancelled)
    {
        // error!
        [self finishTransaction:transaction wasSuccessful:NO];
    }
    else
    {
        // this is fine, the user just cancelled, so don’t notify
        [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    }
}

#pragma mark -
#pragma mark SKPaymentTransactionObserver methods

//
// called when the transaction status is updated
//
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction *transaction in transactions)
    {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
                break;
            default:
                break;
        }
    }
}
////////

- (void)launchPurchase:(NSNotification *)notification {
    [self PurchaseMenuOn];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(launchPurchase:) name:kInAppPurchaseManagerStartMenu object:nil];
        [self loadStore];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    CGRect r = self.view.frame;
    NSString *soundFilePath =
    [[NSBundle mainBundle] pathForResource: @"u"
                                    ofType: @"caf"];
    NSURL *fileURL = [[NSURL alloc] initFileURLWithPath: soundFilePath];
    
    player = [[AVAudioPlayer alloc] initWithContentsOfURL: fileURL
                                                       error: nil];
    [player prepareToPlay];    
    r.origin.y = 1024;
    self.view.frame =r;
}

-(void) viewWillAppear:(BOOL)animated
{
    CGRect r = CGRectMake([self.view superview].bounds.size.width/2 - self.view.bounds.size.width/2, [self.view superview].bounds.size.height, self.view.bounds.size.width, self.view.bounds.size.height);
    
    self.view.frame = r;
    [self loadStore];
    [super viewWillAppear:animated];
}


-(IBAction)PurchaseMenuOff:(id)sender
{
    if(self.menuIsOn == NO)
        return;
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options:UIViewAnimationCurveEaseInOut
                     animations:^{
                         CGRect r = self.view.frame;
                         int mx = MAX([self.view superview].bounds.size.height, [self.view superview].bounds.size.width);
                         r.origin.y = mx;
                         self.view.frame = r;
                     }
                     completion:^(BOOL finished) {
                         self.menuIsOn = NO;
                         [menuTimer invalidate];
                         menuTimer = nil;
                         [self.view setHidden: YES];
                     }]; 
}

-(void) PurchaseMenuOn
{
    
    if(self.menuIsOn)
        return;


    if(fullBookUpgrade) {
        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
        [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
        [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
        [numberFormatter setLocale:fullBookUpgrade.priceLocale];
        NSString *formattedString = [numberFormatter stringFromNumber:fullBookUpgrade.price];
        [purchaseButton setTitle:formattedString forState:UIControlStateNormal];
    }
    CGRect r;
    r = self.view.frame;
    int mx = MAX([self.view superview].bounds.size.height, [self.view superview].bounds.size.width);
    r.origin.y = mx;
    self.view.frame = r;
    [UIView setAnimationsEnabled:YES];
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options:UIViewAnimationCurveEaseInOut
                     animations:^{
                         CGRect r;
                         r = self.view.frame;
                         r.origin.y = [self.view superview].bounds.size.height/2 - self.view.bounds.size.height/2;
                         self.view.frame = r;
                         [self.view setHidden: NO];
                     }
                     completion:^(BOOL finished) {
                         self.menuIsOn = YES;

                         menuTimerCount = kPurchaseMenuInactiveTimer;
                         if(menuTimer == nil)
                             menuTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(step) userInfo:nil repeats:YES];

                      }]; 
}

-(void) step
{
    if( menuTimerCount > 0 ) {
        if(--menuTimerCount == 0)
            [self PurchaseMenuOff:nil];
    }
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
