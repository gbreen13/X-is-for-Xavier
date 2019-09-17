//
//  RHBook.h
//  X is for Xavier
//
//  Created by George Breen on 12/13/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AFKPageFlipper.h"
#import "RHPage.h"
#import "RHOverlay.h"
#import "RHOverlayVanish.h"
#import "RHOverlaySparkle.h"
#import "RHOverlayAnimation.h"

//#define USES_IAP 1            // define to compile for purchase
//#define SPARKLE 1               // define to add the particle strings

#ifdef USES_IAP
#define kNumFreePages 13
#else
#define kNumFreePages 99999
#endif


@interface RHBook : UIView <UIPageViewControllerDataSource, NSXMLParserDelegate, RHOverlayDelegate, AVAudioPlayerDelegate>{
    CGPDFDocumentRef pdfDocument;

    NSString *pdfName;
    NSMutableString *xmlString;
    RHPage *newPage;
    NSInteger numberOfPages;
    NSMutableArray *pages;
    NSMutableArray *xmlStack;
    NSString *previousElement;
    NSString *docname;                  // name of the pdf file to be used as a base.
    BOOL isFrozen;
    BOOL orientationIsHorizontal;
    NSInteger curPage;
    AVAudioPlayer *musicPlayer;
    CGFloat musicVolume, effectVolume;
}


- (id)initWithFrame:(CGRect)frame andXMLFileNSURL:(NSURL *)url;
- (void) setOrientation: (UIInterfaceOrientation) orientation;
@property (nonatomic, copy) NSString *previousElement;
@property (nonatomic, strong) NSMutableArray *pages, *xmlStack;
@property (nonatomic, copy) NSString *pdfName;
@property (nonatomic, assign) BOOL isFrozen;
@property (nonatomic, assign) BOOL orientationIsHorizontal;
@property (nonatomic, assign) NSInteger numberOfPages, curPage;
@property (nonatomic, strong) AVAudioPlayer *musicPlayer;
@property (nonatomic, assign) CGFloat musicVolume, effectVolume;
-(void)freeMemory;

@end
/* category to add aliases for stack operations
 to NSMutableArray
 */
@interface NSMutableArray (stack)
-(void)push:(id)object;
-(id)pop;
-(id)top;
-(id)getPage:(NSInteger)pageno;
@end

