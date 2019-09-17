//
//  RHPage.m
//  X is for Xavier
//
//  Created by George Breen on 12/14/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "RHPage.h"

@implementation RHPage
@synthesize pageNo;
@synthesize pageOverlays;
@synthesize player;
@synthesize soundFileName;
@synthesize blockPageTurn, hasBackgroundAudio, loopAudioBackground;

-(id) init
{
    if(self = [super init]) {
        pageOverlays = [[NSMutableArray alloc]init];
        soundFileName = nil;
        player = nil;
        blockPageTurn = hasBackgroundAudio = loopAudioBackground =  NO;
    }
    return self;
}

-(void) addOverlay:(RHOverlay *)overlay
{
    [pageOverlays addObject:overlay];
}

-(void) dealloc
{
    [pageOverlays removeAllObjects];
}

@end
