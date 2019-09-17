//
//  AudioController.m
//  X is for Xavier
//
//  Created by George Breen on 1/17/15.
//
//

#import "AudioController.h"

@implementation AudioController

@synthesize allPlayers, musicVolume, effectVolume, nextMusic;

+ (AudioController *)sharedInstance
{
    static dispatch_once_t onceToken;
    static AudioController *sSharedInstance;
    
    dispatch_once(&onceToken, ^{
        sSharedInstance = [[AudioController alloc] init];
    });
    return sSharedInstance;
}

-(id) init
{
    if(self = [super init]) {
        // create the array of players and set the first one for music.
        allPlayers = [[NSMutableArray alloc]initWithObjects: nil];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        if ([defaults objectForKey:kMusicVolume] != nil)
            musicVolume = [defaults floatForKey:kMusicVolume];
        else
            musicVolume = kDefaultMusicLevel;
        
        if ([defaults objectForKey:kEffectVolume] != nil)
            effectVolume = [defaults floatForKey:kEffectVolume];
        else
            effectVolume = kDefaultSoundLevel;
        // TBD set music volume
    }
    return self;
}

-(void) setMusicVolume:(CGFloat)volume
{
    musicVolume = volume;
    if([allPlayers count] && ([allPlayers objectAtIndex:0] != nil))
        [[allPlayers objectAtIndex:0] setVolume:volume];
}

-(void) setEffectVolume:(CGFloat)volume
{
    effectVolume = volume;
    
    int i = 1;  // effect players start at 1 if there are any
    while(i < [allPlayers count])
        [(AVAudioPlayer *)[allPlayers objectAtIndex:i++] setVolume:volume];
}

-(CGFloat) getMusicVolume
{
    return musicVolume;
}
-(CGFloat) getEffectVolume
{
    return effectVolume;
}


-(void) playMusic: (NSURL *)filePath
{
    AVAudioPlayer *musicPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL: filePath error: nil];
    if(musicPlayer != nil)
        musicPlayer.delegate = self;
    else
        return;
    
    if([allPlayers count] > 0) {
        AVAudioPlayer *mPlayer = [allPlayers objectAtIndex:0];
        if(mPlayer.volume > 0.1) {  // if playing, fade out
            mPlayer.volume -= 0.1;
            [self performSelector:@selector(playMusic:) withObject:filePath afterDelay:0.1];
            return;
        } else {
            [allPlayers replaceObjectAtIndex:0 withObject:musicPlayer];
        }
    }
    else {
            [allPlayers insertObject:musicPlayer atIndex:0];
    }
    [self setMusicVolume:musicVolume];
    [(AVAudioPlayer *)[allPlayers objectAtIndex:0] play];
    
}

-(void) queueMusic: (NSURL *)filePath
{
    if([(AVAudioPlayer *)[allPlayers objectAtIndex:0] isPlaying])
        nextMusic = filePath;
    else
        [self playMusic:filePath];
}


-(void) playEffect:(NSURL *) filePath    // will make a new player for this effect & kill it after it
{
    AVAudioPlayer *effectPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL: filePath error: nil];
    if(effectPlayer != nil) {
        effectPlayer.delegate = self;
        [allPlayers addObject:effectPlayer];
        [self setEffectVolume:effectVolume];
        [effectPlayer play];
    }
}
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player
                       successfully:(BOOL)flag
{
    if(player == [allPlayers objectAtIndex:0]) {
        if(nextMusic) {
            [self playMusic:nextMusic];     // if another music is queue'd up play that (landscape mode)
            nextMusic = nil;
        }
    }
    else        // onloy removing effect players, not the music player which should be at slot 0;
        [allPlayers removeObject:player];
}
@end
