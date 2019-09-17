//
//  PDFRendererView.m
//  AFKPageFlipper
//
//  Created by Marco Tabini on 10-10-11.
//  Copyright 2010 AFK Studio Partnership. All rights reserved.
//

#import "PDFRendererView.h"


@implementation PDFRendererView


#pragma mark -
#pragma mark Property management

@synthesize pdfName;

- (void) setPdfDocument:(NSString *) value {
    pdfName = value;
}


@synthesize pageNumber;


- (void) setPageNumber:(int) value {
	pageNumber = value+1;       // in PDF land, pages start with 1, not 0
	
	[self setNeedsDisplay];
}


#pragma mark -
#pragma mark Drawing


- (void) setFrame:(CGRect) value {
	[super setFrame:value];
	
	[self setNeedsDisplay];
}


- (void) drawPDFPage:(CGPDFPageRef) pdfPage inRect:(CGRect) rect usingContext:(CGContextRef) context {
	CGContextSaveGState(context);
	
	// Draw PDF
    
	CGContextTranslateCTM(context, 0.0, self.bounds.size.height);
	CGContextScaleCTM(context, 1.0, -1.0);
	
	CGRect boundingBox = CGPDFPageGetBoxRect(pdfPage, kCGPDFCropBox);
	
	float ratio = MIN(rect.size.width / boundingBox.size.width, rect.size.height / boundingBox.size.height);
	
	CGAffineTransform pdfTransform = CGAffineTransformMakeTranslation(rect.origin.x + (rect.size.width - boundingBox.size.width * ratio) / 2, rect.origin.y + (rect.size.height - boundingBox.size.height * ratio) / 2);
	pdfTransform = CGAffineTransformScale(pdfTransform, ratio, ratio);
	
	CGContextConcatCTM(context, pdfTransform);
	CGContextDrawPDFPage(context, pdfPage);
	CGContextRestoreGState(context);
}


- (void)drawRect:(CGRect)rect {
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	// Clear background

	CGContextClearRect(context, self.bounds);
	
	CGContextSaveGState(context);
	
	CGContextSetRGBFillColor(context, 0.0, 0.0, 0.0, 0.0);
	CGContextFillRect(context, self.bounds);
	
	CGContextRestoreGState(context);
	
	// Load PDF page

	CGPDFDocumentRef     pdfD;
    
    pdfD = CGPDFDocumentCreateWithURL((__bridge CFURLRef) [NSURL fileURLWithPath:
                                                           [[NSBundle mainBundle] pathForResource:pdfName ofType:@"pdf"]]);

    
	if (self.bounds.size.width > self.bounds.size.height) {
		
		// If the width of the view's bounds is greater than the height,
		// we display two pages side-by-side
        
		pageNumber &= ~1;      // force even page on left in case of rotation
        CGRect rect = self.bounds;
		rect.size.width /= 2;
		
		[self drawPDFPage:CGPDFDocumentGetPage(pdfD, pageNumber ) inRect:rect usingContext:context];
		
		rect.origin.x = rect.size.width;
		
		[self drawPDFPage:CGPDFDocumentGetPage(pdfD, pageNumber  + 1) inRect:rect usingContext:context];
	} else {
        if(pageNumber < 1) pageNumber = 1;
		[self drawPDFPage:CGPDFDocumentGetPage(pdfD, pageNumber) inRect:self.bounds usingContext:context];
	}
    
    CGPDFDocumentRelease(pdfD);
}


#pragma mark -
#pragma mark Initialization and memory management


- (id) initWithFrame:(CGRect) frame {
	if ((self = [super initWithFrame:frame])) {
		self.backgroundColor = [UIColor clearColor];
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        pageNumber = 1;
	}
	
	return self;
}



@end
