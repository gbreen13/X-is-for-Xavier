//
//  RHBookViewController.h
//  X is for Xavier
//
//  Created by George Breen on 1/12/15.
//
//// analagous: PhotoViewController.  handles all of the page specific classes for a book.
//

#import <UIKit/UIKit.h>

//
//  RHBook.h
//  X is for Xavier
//
//  Created by George Breen on 12/13/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RHOverlay.h"
#import "RHOverlayVanish.h"
#import "RHOverlaySparkle.h"
#import "RHOverlayAnimation.h"
#import "PDFRendererView.h"
#import "AudioController.h"

//#define USES_IAP 1            // define to compile for purchase
//#define SPARKLE 1               // define to add the particle strings

#ifdef USES_IAP
#define kNumFreePages 13
#else
#define kNumFreePages 99999
#endif


@interface RHBookViewController : UIViewController <RHOverlayDelegate, AVAudioPlayerDelegate> {
    BOOL isFrozen;
    PDFRendererView *pdfRenderView;
    UIDeviceOrientation orientation;
    NSInteger curPage;
}

+ (RHBookViewController *)rhBookViewControllerForPageIndex:(NSInteger)pageIndex andOrientation:(UIDeviceOrientation) orientation;

- (void) changeOrientation: (UIDeviceOrientation) orientation;

@property (nonatomic, assign) BOOL isFrozen;
@property (nonatomic, assign) NSInteger curPage;
@property (nonatomic, assign) UIDeviceOrientation orientation;
@property (nonatomic, strong) PDFRendererView *pdfRenderView;

@end
/* category to add aliases for stack operations
 to NSMutableArray
 */


