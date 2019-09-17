//
//  RHBookViewControllerData.m
//  X is for Xavier
//
//  Created by George Breen on 1/12/15.
//
//

//  This sharedInstance class handles all of the non view oriented aspects of the Book.
//  Since there is only one PDF, that is handled here
//

#import "RHBookViewControllerData.h"

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
@implementation RHBookViewControllerData
@synthesize previousElement;
@synthesize pages;
@synthesize xmlStack;
@synthesize pdfName;
@synthesize isFrozen;
@synthesize orientationIsHorizontal;
@synthesize numberOfPages, curPage;

+ (RHBookViewControllerData *)sharedInstance
{
    static dispatch_once_t onceToken;
    static RHBookViewControllerData *sSharedInstance;
    
    dispatch_once(&onceToken, ^{
        sSharedInstance = [[RHBookViewControllerData alloc] init];
    });
    return sSharedInstance;
}

-(void) freezePage:(BOOL)freeze
{
    isFrozen = freeze;
}

- (BOOL)loadBook:(NSURL *)url
{
    
    pages = [[NSMutableArray alloc]init];
    xmlStack = [[NSMutableArray alloc] init];
        
    NSXMLParser* parser = [[NSXMLParser alloc] initWithContentsOfURL:url];
    [parser setDelegate:self];
    
    [parser parse];
        
    CGPDFDocumentRef pdfD = CGPDFDocumentCreateWithURL((__bridge CFURLRef) [NSURL fileURLWithPath:
                                                                                [[NSBundle mainBundle] pathForResource:pdfName ofType:@"pdf"]]);
        
    numberOfPages = CGPDFDocumentGetNumberOfPages(pdfD);
        
    CGPDFDocumentRelease(pdfD);
    return TRUE;

}

- (RHPage *) getPage:(NSInteger)pageNo
{
    return [pages getPage:pageNo];
}

-(NSInteger) getPageCount
{
    return numberOfPages;
}
-(NSInteger) getCurrentPageNo
{
    return curPage;
}
-(void) setPageNo: (NSInteger)pageNo
{
    curPage = pageNo;
}


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

@end
