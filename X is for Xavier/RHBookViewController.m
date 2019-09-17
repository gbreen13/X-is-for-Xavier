//
//  RHBookViewController.m
//  X is for Xavier
//
//  Created by George Breen on 1/12/15.
//
//

#import "PurchaseMenu.h"
#import "RHBookViewController.h"
#import "RHBookViewControllerData.h"


@implementation RHBookViewController

@synthesize isFrozen, curPage, orientation, pdfRenderView;

+ (RHBookViewController *)rhBookViewControllerForPageIndex:(NSInteger)pageIndex andOrientation:(UIDeviceOrientation)orientation
{
    if ((pageIndex >= 0) && (pageIndex < [[RHBookViewControllerData sharedInstance] getPageCount]))
    {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
        RHBookViewController *rhBookViewController = [storyboard instantiateViewControllerWithIdentifier:@"RHBookViewController"];
        rhBookViewController.curPage = pageIndex;
        rhBookViewController.orientation = orientation;
        return rhBookViewController;
    }
    return nil;
}

-(void) viewWillAppear:(BOOL)animated
{
    [pdfRenderView setPageNumber:(int)curPage];
    [self adjustOverlays:(PDFRendererView *)self.view];
//    [[RHBookViewControllerData sharedInstance] setPageNo: curPage];
    RHPage *p;
    
    
    //
    //  Now do the music for this page if there is any.  Note in the horizontal case, check the next page for
    //  music too.  This happens on the first page in horizontal mode.
    //
    p = [[RHBookViewControllerData sharedInstance] getPage:curPage];
    if(p.hasBackgroundAudio) {
        NSString *soundFilePath =
        [[NSBundle mainBundle] pathForResource: p.soundFileName
                                        ofType: @"caf"];
        
        NSURL *fileURL = [[NSURL alloc] initFileURLWithPath: soundFilePath];
        [[AudioController sharedInstance] playMusic:fileURL];
    }
    if(UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation)) {
        p = [[RHBookViewControllerData sharedInstance] getPage:curPage+1];
        if(p != nil && p.hasBackgroundAudio) {
            NSString *soundFilePath =
            [[NSBundle mainBundle] pathForResource: p.soundFileName
                                            ofType: @"caf"];
            
            NSURL *fileURL = [[NSURL alloc] initFileURLWithPath: soundFilePath];
            [[AudioController sharedInstance] queueMusic:fileURL];
        }
    }
}

-(void) addOverlays: (PDFRendererView *)view
{
    CGRect screenRect = view.bounds;
    CGFloat w, h;
    if( UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation)) {
        h = MIN(screenRect.size.width,screenRect.size.height);
        w = MAX(screenRect.size.width,screenRect.size.height)/2;
    } else {
        h = MAX(screenRect.size.width,screenRect.size.height);
        w = MIN(screenRect.size.width,screenRect.size.height);
    }
    
    CGFloat nw = w/8.5;
    CGFloat nh = h/11;
    CGFloat scale;
    CGFloat xoff = 0, yoff = 0;
    
    if (nw > nh) {
        scale = nh;
        CGFloat xsize = nh*w/nw;      
        xoff = w/2 - xsize/2;
    } else {
        scale = nw;
        CGFloat ysize = h*nw/nh;
        yoff = h/2 - ysize/2;
    }
        
    CGPoint offset = CGPointMake(xoff, yoff);
   
    if(UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation)) {
         RHPage *p = [[RHBookViewControllerData sharedInstance] getPage:curPage];
        if(p != nil) {
            for(RHOverlay *ov in [p pageOverlays]) {
                [ov setAndScaleOverlay:(CGPoint) offset andScale:(CGFloat)scale];
                [view addSubview:ov];
            }
        }
        p = [[RHBookViewControllerData sharedInstance] getPage:curPage+1];
        offset.x += view.bounds.size.width/2;
        for(RHOverlay *ov in [p pageOverlays]) {
            [ov setAndScaleOverlay:(CGPoint) offset andScale:scale];
            [view addSubview:ov];
        }
    } else {
      
        CGPoint offset = CGPointMake(xoff, yoff);
        RHPage *p = [[RHBookViewControllerData sharedInstance] getPage:curPage];
        if(p != nil) {
            for(RHOverlay *ov in [p pageOverlays]) {
                [ov setAndScaleOverlay:(CGPoint) offset andScale:scale];
                [view addSubview:ov];
            }
        }
    }
}


-(void) changeOrientation:(UIDeviceOrientation)orient
{
    int pg = (int)curPage;
    
    if(UIDeviceOrientationIsLandscape(orient)) {
        if((pg > 0) && (!(pg & 1)))  // if going to landscape and on the right side (even) go to left side.
            pg--;
    }
    
    [pdfRenderView setPageNumber:curPage=pg];
 
    if(orient != UIDeviceOrientationUnknown) {
        [self adjustOverlays:(PDFRendererView *)self.view];
        orientation = orient;
    }
}

-(void) adjustOverlays: (PDFRendererView *) view
{
    orientation = [UIDevice currentDevice].orientation;
    for(id ov in view.subviews) {
        if([ov isKindOfClass:[RHOverlay class]])
            [(RHOverlay *)ov removeFromSuperview];
    }
    [self addOverlays:view];
}

- (void)viewDidLoad {

    pdfRenderView = [[PDFRendererView alloc] initWithFrame:self.view.bounds];
    
    [pdfRenderView setUserInteractionEnabled:YES];
    
    self.view = pdfRenderView;
}

-(void) freezePage:(BOOL)freeze
{
    isFrozen = freeze;
}


@end
