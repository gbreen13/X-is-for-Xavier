//
//  RHBook.m
//  X is for Xavier
//
//  Created by George Breen on 12/13/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "RHBook.h"
#import "RHOverlay.h"

#import "PDFRendererView.h"

@implementation NSMutableArray (stack)
// could also use class_addMethod to alias push & top
-(void)push:(id)object {
    [self addObject:object];
}
-(id)pop {
    id last = [self lastObject];
    if(last != nil)
        [self removeLastObject];
    return last;
}
-(id)top {
    return [self lastObject];
}

-(id)getPage:(NSInteger)pageno
{
    for(id next in self) {
        if(![next isKindOfClass:[RHPage class]])
            return nil; // bad array
        RHPage *p = (RHPage *)next;
        if([[p pageNo] intValue] == pageno)
            return p;
    }
    return nil;
}

@end

@implementation RHBook
@synthesize previousElement;
@synthesize pages;
@synthesize xmlStack;
@synthesize pdfName;
@synthesize isFrozen;
@synthesize orientationIsHorizontal;
@synthesize numberOfPages, curPage;
@synthesize musicPlayer;
@synthesize effectVolume ,musicVolume;


- (id)initWithFrame:(CGRect)frame andXMLFileNSURL:(NSURL *)url 
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        pages = [[NSMutableArray alloc]init];
        xmlStack = [[NSMutableArray alloc] init];

        NSXMLParser* parser = [[NSXMLParser alloc] initWithContentsOfURL:url];
        [parser setDelegate:self];
        
        [parser parse];
        
        CGPDFDocumentRef pdfD = CGPDFDocumentCreateWithURL((__bridge CFURLRef) [NSURL fileURLWithPath:
                                                               [[NSBundle mainBundle] pathForResource:pdfName ofType:@"pdf"]]);
        
        numberOfPages = CGPDFDocumentGetNumberOfPages(pdfD);
        
        CGPDFDocumentRelease(pdfD);
        
        if(self.bounds.size.width > self.bounds.size.height)
            orientationIsHorizontal = YES;
    }
    
    return self;
}

-(void) setMusicVolume:(CGFloat)volume
{
    musicVolume = volume;
    if(musicPlayer != nil)
        musicPlayer.volume = volume;
}
-(void) setEffectVolume:(CGFloat)volume
{
    effectVolume = volume;
    RHPage *p = [pages getPage:curPage];
    if(p != nil){
        for(RHOverlay *ov in [p pageOverlays]) {
        if(ov.player)
            ov.player.volume = volume;
        }
    }
    p = [pages getPage:curPage+1];
    if(p == nil) return;
    for(RHOverlay *ov in [p pageOverlays]) {
        if(ov.player)
            ov.player.volume = volume;
    }
}

#pragma mark -
#pragma mark Data source implementation


- (NSInteger) numberOfPagesForPageFlipper:(AFKPageFlipper *)pageFlipper {
	return self.bounds.size.width > self.bounds.size.height ? ceil((float) numberOfPages / 2) : numberOfPages;
}


-(void) addOverlays: (PDFRendererView *)view andPage: (NSInteger) page
{
    CGRect screenRect = view.bounds;
    CGFloat w, h;
    if(screenRect.size.width > screenRect.size.height) {
        h = screenRect.size.width;
        w = screenRect.size.height;
    } else {
        h = screenRect.size.height;
        w = screenRect.size.width;
    }

    if(orientationIsHorizontal) {
        CGPoint offset = CGPointMake(0,(h==1024)?43:0);
        CGFloat scale = (h/2/8.5);
        page &= ~1;     // force even page for left side.
        RHPage *p = [pages getPage:page];
        if(p != nil) {
            for(RHOverlay *ov in [p pageOverlays]) {
                [ov setAndScaleOverlay:(CGPoint) offset andScale:(CGFloat)scale];
                [view addSubview:ov];
            }
        }
        p = [pages getPage:page+1];
        offset.x = h/2;
        for(RHOverlay *ov in [p pageOverlays]) {
            [ov setAndScaleOverlay:(CGPoint) offset andScale:scale];
            [view addSubview:ov];
        }
    } else {
        CGPoint offset = CGPointMake(0,0);
        CGFloat scale = h/11;
        RHPage *p = [pages getPage:page];
        if(p != nil) {
            for(RHOverlay *ov in [p pageOverlays]) {
                [ov setAndScaleOverlay:(CGPoint) offset andScale:scale];
                [view addSubview:ov];
            }
        }
    }     
}
//
//  if the orienttion changes.
//
-(void) adjustOverlays: (PDFRendererView *) view
{
    for(id ov in view.subviews) {
        if([ov isKindOfClass:[RHOverlay class]])
            [(RHOverlay *)ov removeFromSuperview];
    }
    [self addOverlays:view andPage:view.pageNumber];
}
//
//  This is a request from the flipper to create the PDF view.  The page number
//  is either the left page (must always be even.  0 in the case of the first blank page and page
//  1 would start on the right.  (if in landscape mode) or the actual page if portrait.
//
//  This function creates a PDFRender view and then overlays the RHOverlay animals if any for this
//  page.  If this is a landscape mode, the overlays for the next page are also overlaid.
//
- (UIView *) viewForPage:(NSInteger) page inFlipper:(AFKPageFlipper *) pageFlipper {
	PDFRendererView *result = [[PDFRendererView alloc] initWithFrame:pageFlipper.bounds];
	result.pdfName = pdfName;
	
    [result setUserInteractionEnabled:YES];
    [self addOverlays:result andPage:page];
	result.pageNumber = page;
	return result;
}

//
//  Note that the starting of a new page is driven from the Flipper, not the other way around.
//  The Book handles the ;pgic for the pages and the XML file  but not the rendering and not the page flips.
//


-(void) startNewPage:(NSInteger)page
{
    RHPage *p = [pages getPage:page];
    curPage = page;


    for(RHOverlay *ov in [p pageOverlays]) {
        if((ov.soundFname != nil) && (ov.player == nil)) {
            NSString *soundFilePath =
            [[NSBundle mainBundle] pathForResource: ov.soundFname
                                            ofType: @"caf"];
            NSURL *fileURL = [[NSURL alloc] initFileURLWithPath: soundFilePath];
        
            ov.player = [[AVAudioPlayer alloc] initWithContentsOfURL: fileURL
                                               error: nil];
            [ov.player prepareToPlay];
            [ov.player setDelegate: ov];
        }
        if(ov.player != nil)
            [ov.player setVolume:effectVolume];
    }
    p = [pages getPage:page+1];     // prime the next page.
    for(RHOverlay *ov in [p pageOverlays]) {
        if((ov.soundFname != nil) && (ov.player == nil)) {
            NSString *soundFilePath =
            [[NSBundle mainBundle] pathForResource: ov.soundFname
                                            ofType: @"caf"];
            NSURL *fileURL = [[NSURL alloc] initFileURLWithPath: soundFilePath];
            
            ov.player = [[AVAudioPlayer alloc] initWithContentsOfURL: fileURL
                                                               error: nil];
            [ov.player prepareToPlay];
            [ov.player setDelegate: ov];
        }
        if(ov.player != nil)
            [ov.player setVolume:effectVolume];
    }

//
//  Now do the music for this page if there is any.  Note in the horizontal case, check the next page for
//  music too.  This happens on the first page in horizontal mode.
//
    p = [pages getPage:page];    

    if((!p.hasBackgroundAudio) && orientationIsHorizontal && !(page & 1))  // if side by side and left side and
        // right side has audio, use that.
        p = [pages getPage:page+1];
    
    if(p.hasBackgroundAudio) {
        if(musicPlayer != nil) {
            [musicPlayer stop];
            musicPlayer = nil;
        }
        NSString *soundFilePath =
        [[NSBundle mainBundle] pathForResource: p.soundFileName
                                        ofType: @"caf"];
        
        NSURL *fileURL = [[NSURL alloc] initFileURLWithPath: soundFilePath];
        
        musicPlayer =
        [[AVAudioPlayer alloc] initWithContentsOfURL: fileURL
                                               error: nil];
        
        [musicPlayer prepareToPlay];
        [musicPlayer setDelegate: self];
        musicPlayer.volume = musicVolume;
        [musicPlayer play];
    }
}

-(BOOL)okToFlipPage:(NSInteger)page
{
    RHPage *p = [pages getPage:page];
    if(isFrozen) 
        return NO;
    if (p.hasBackgroundAudio && p.blockPageTurn && p.player.playing)
        return NO;
    return YES;
}

-(void) shutDownPage:(NSInteger)page
{
    
}

-(BOOL) getOrientation
{
    return orientationIsHorizontal;
}

-(void) setOrientation:(UIInterfaceOrientation)orientation
{
    if((orientation == UIInterfaceOrientationLandscapeLeft) || (orientation == UIInterfaceOrientationLandscapeRight))
        orientationIsHorizontal = YES;
    else
        orientationIsHorizontal = NO;
}

#pragma mark -
#pragma mark Overlay Helper implementation

-(void) freezePage:(BOOL)freeze
{
    isFrozen = freeze;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

//***** PARSE XML FILE - START ELEMENT CALLBACK *****
- (void)parser:(NSXMLParser *)parser
didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)nameSpaceURI
 qualifiedName:(NSString *)qName
    attributes:(NSDictionary *)attributeDict
{
	if (!xmlString)
		xmlString = [[NSMutableString alloc] init];
	else
		[xmlString setString:@""];
    
	if ([elementName isEqualToString:@"pages"])
	{
        for (RHPage *arr in pages) {
            [arr.pageOverlays removeAllObjects];
        }
        [pages removeAllObjects];
	}
    else if([previousElement isEqualToString:@"pages"]) {
        if([elementName isEqualToString:@"doc"]) {
            pdfName = [[NSString alloc]initWithString:[attributeDict objectForKey:@"fname"]];
        }
        else if([elementName isEqualToString:@"page"]) {
            newPage = [[RHPage alloc]init];
            newPage.pageNo=[[NSString alloc] initWithString:[attributeDict objectForKey:@"pageno"]];
        }
   }
    else if([previousElement isEqualToString:@"page"]) {
 

        if([elementName isEqualToString:@"overlay"]) {

            CGRect r = CGRectMake([[attributeDict objectForKey:@"locx"] floatValue],
                                  [[attributeDict objectForKey:@"locy"] floatValue],
                                  [[attributeDict objectForKey:@"width"] floatValue],
                                  [[attributeDict objectForKey:@"height"] floatValue]);

            NSString *fname = [[NSString alloc] initWithString:[attributeDict objectForKey:@"fname"]];  
            newOverlay = nil;
            if([attributeDict objectForKey:@"type"] != nil) {
                NSString *type = [[NSString alloc] initWithString:[attributeDict objectForKey:@"type"]]; 

                if([type isEqualToString:@"Vanish"])
                    newOverlay = [[RHOverlayVanish alloc] initWithImage:[UIImage imageNamed:fname]];
                else if([type isEqualToString:@"Sparkle"])
                    newOverlay = [[RHOverlaySparkle alloc] initWithImage:[UIImage imageNamed:fname]];
                else if([type isEqualToString:@"Animation"]) {
                    NSTimeInterval time = [[attributeDict objectForKey:@"duration"] floatValue];
                    NSString *animation = [[NSString alloc] initWithString:[attributeDict objectForKey:@"images"]];
                    newOverlay = [[RHOverlayAnimation alloc] initWithImage:[UIImage imageNamed:fname] andAnimationName: animation andTimeInterval:time];
                }
           }
            if(newOverlay == nil)
                 newOverlay = [[RHOverlay alloc] initWithImage:[UIImage imageNamed:fname]];

            [newOverlay setFileName:fname];
            if([attributeDict objectForKey:@"sname"] != nil)
                [newOverlay setSoundFname:[[NSString alloc] initWithString:[attributeDict objectForKey:@"sname"]]];

            [newOverlay setLocation:r];
            [newOverlay setUserInteractionEnabled:YES];
            [newOverlay setDelegate:self];

        }

        else if([elementName isEqualToString:@"bgmusic"]) {
            NSString *fname = [attributeDict objectForKey:@"fname"];
            if(fname != nil) {
                newPage.soundFileName =fname;
                newPage.hasBackgroundAudio = YES;
                NSString *blocked;
                
                if((blocked = [attributeDict objectForKey:@"block"])!= nil) {
                    newPage.blockPageTurn = ([blocked isEqualToString:@"YES"]) ? YES: NO;
                }
                if((blocked = [attributeDict objectForKey:@"loop"])!= nil) {
                    newPage.loopAudioBackground = ([blocked isEqualToString:@"YES"]) ? YES: NO;
                }
            }
        }

    }
    if(previousElement != nil)
        [xmlStack push:previousElement];
    
    previousElement = elementName;
}

//***** PARSE XML FILE - MORE CHARACTERS CALLBACK *****
- (void)parser:(NSXMLParser *)parser
foundCharacters:(NSString *)string
{
	[xmlString appendString:string];
}

//***** PARSE XML FILE - END ELEMENT CALLBACK *****
- (void)parser:(NSXMLParser *)parser
 didEndElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName
{
    previousElement = [xmlStack pop];
    
	if ([elementName isEqual:@"overlay"])
	{
        [newPage.pageOverlays addObject:newOverlay];
    }
 	else if ([elementName isEqual:@"page"]) {
        [pages addObject:newPage];
    }
   
}


- (void)dealloc {
	CGPDFDocumentRelease(pdfDocument);
}

-(void) freeMemory {
    
    NSLog(@"freeing up memory");
    for (int i= 1; i < (curPage -2); i++) {
        RHPage *p = [pages getPage:i];
        if(p.player != Nil) 
            p.player = Nil;
        for(RHOverlay *ov in [p pageOverlays]) {
            if((ov.player != nil)) {
                ov.player = Nil;
            }
        }
    }
}


@end
