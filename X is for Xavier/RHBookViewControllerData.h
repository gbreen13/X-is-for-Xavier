//
//  RHBookViewControllerData.h
//  X is for Xavier
//
//  Created by George Breen on 1/12/15.
//
//  analygous: PageVIewControllerData
//  Handles all of the shared aspects of the book.  The PDF is attached here.

#import <UIKit/UIKit.h>
#import "RHPage.h"
#import "RHOverlayVanish.h"
#import "RHOverlaySparkle.h"
#import "RHOverlayAnimation.h"

@interface RHBookViewControllerData : NSObject <NSXMLParserDelegate, RHOverlayDelegate, AVAudioPlayerDelegate> {
    CGPDFDocumentRef pdfDocument;
    NSString *pdfName;
    NSMutableString *xmlString;
    NSInteger numberOfPages;
    NSMutableArray *pages;
    NSMutableArray *xmlStack;
    NSString *previousElement;
    NSString *docname;                  // name of the pdf file to be used as a base.
    BOOL isFrozen;
    BOOL orientationIsHorizontal;
    RHOverlay *newOverlay;
    RHPage *newPage;
    NSInteger curPage;

}

@property (nonatomic, copy) NSString *previousElement;
@property (nonatomic, strong) NSMutableArray *pages, *xmlStack;
@property (nonatomic, copy) NSString *pdfName;
@property (nonatomic, assign) BOOL isFrozen;
@property (nonatomic, assign) BOOL orientationIsHorizontal;
@property (nonatomic, assign) NSInteger numberOfPages, curPage;

+ (RHBookViewControllerData *)sharedInstance;
- (BOOL) loadBook:(NSURL *)url;
- (RHPage *) getPage:(NSInteger)pageNo;
-(NSInteger) getPageCount;
-(NSInteger) getCurrentPageNo;
-(void) setPageNo: (NSInteger)pageNo;


@end

@interface NSMutableArray (stack)
-(void)push:(id)object;
-(id)pop;
-(id)top;
-(id)getPage:(NSInteger)pageno;
@end