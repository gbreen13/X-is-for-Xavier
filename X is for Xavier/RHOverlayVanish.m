//
//  RHOverlayVanish.m
//  X is for Xavier
//
//  Created by George Breen on 1/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RHOverlayVanish.h"

@implementation RHOverlayVanish
-(void) vanish
{
	[UIView beginAnimations:@"Vanish" context:Nil];
	[UIView setAnimationDuration:1];
	
	self.alpha = 0;
	
	[UIView commitAnimations];
    NSString *soundFilePath =
    [[NSBundle mainBundle] pathForResource: soundFname
                                    ofType: @"caf"];
    [[AudioController sharedInstance] playEffect:[[NSURL alloc] initFileURLWithPath: soundFilePath]];
   
}

- (void) tapped:(UITapGestureRecognizer *) recognizer {
    [self vanish];
}

- (void) panned:(UIPanGestureRecognizer *) recognizer {
    
    switch (recognizer.state) {
            
		case UIGestureRecognizerStateBegan:
            [self vanish];
            break;
        default:
            break;
    }
}

- (id) initWithImage:(UIImage *)image {
	
    return[ super initWithImage:image];
}
@end
