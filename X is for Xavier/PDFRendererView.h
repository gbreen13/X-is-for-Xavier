//
//  PDFRendererView.h
//  AFKPageFlipper
//
//  Created by Marco Tabini on 10-10-11.
//  Copyright 2010 AFK Studio Partnership. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface PDFRendererView : UIView {
    NSString *pdfName;
	
	int pageNumber;         // current display page if portrait or left page if landscape;
    BOOL isLandscape;       //
}


@property (nonatomic,copy) NSString *pdfName;

@property (nonatomic,assign) int pageNumber;


@end
