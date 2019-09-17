//
//  RHPage.h
//  X is for Xavier
//
//  Created by George Breen on 12/14/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <Foundation/Foundation.h>
#include "RHOverlay.h"

@interface RHPage : NSObject {
    NSString *pageNo;
    NSMutableArray *pageOverlays;
    NSString *soundFileName;
    BOOL blockPageTurn;
    BOOL hasBackgroundAudio;
    BOOL loopAudioBackground;
}

@property (nonatomic, copy) NSString *pageNo;
@property (nonatomic, strong) NSMutableArray *pageOverlays;
@property (nonatomic, strong) AVAudioPlayer *player;
@property (nonatomic, assign) BOOL blockPageTurn, hasBackgroundAudio, loopAudioBackground;
@property (nonatomic, copy) NSString *soundFileName;
-(void) addOverlay:(RHOverlay *)overlay;

@end
