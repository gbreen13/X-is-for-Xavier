//
//  AudioController.h
//  X is for Xavier
//
//  Created by George Breen on 1/17/15.
//
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

#define kDefaultMusicLevel 1.0
#define kDefaultSoundLevel 1.0
#define kMenuInactiveTimer 5
#define kThumbnailWidth 57
#define kThumbnailHeight 74

#define kEffectVolume @"EffectVolume"
#define kMusicVolume @"MusicVolume"

@interface AudioController : NSObject <AVAudioPlayerDelegate> {
    CGFloat musicVolume, effectVolume;
    NSMutableArray *allPlayers;
    NSURL *nextMusic;
}

+ (AudioController *)sharedInstance;
-(void) setEffectVolume:(CGFloat)volume;
-(void) setMusicVolume:(CGFloat)volume;
-(void) queueMusic:(NSURL *)file; // will stop other music if playing
-(void) playMusic:(NSURL *)file; // will stop other music if playing
-(void) playEffect:(NSURL *) file;   // will make a new player for this effect & kill it after it plays
-(CGFloat) getMusicVolume;
-(CGFloat) getEffectVolume;

@property (nonatomic, strong) NSMutableArray *allPlayers;
@property (nonatomic, assign) CGFloat musicVolume, effectVolume;
@property (nonatomic, strong) NSURL *nextMusic;
@end
