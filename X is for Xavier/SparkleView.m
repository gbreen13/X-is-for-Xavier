//
//  SparkleView.m
//  X is for Xavier
//
//  Created by George Breen on 1/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
#import "SparkleView.h"
#ifdef SPARKLE


@implementation SparkleView
+ (Class) layerClass //3
{
    //configure the UIView to have emitter layer
    return [CAEmitterLayer class];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        sparkleLayer = (CAEmitterLayer *)self.layer;
//        sparkleLayer = [CAEmitterLayer layer];
        CGPoint p = CGPointMake(frame.origin.x + frame.size.width/2, frame.origin.y + frame.size.height/2);
        sparkleLayer.emitterPosition = p;
        sparkleLayer.emitterSize = CGSizeMake(16, 16);
        sparkleLayer.emitterZPosition = 10;
        CAEmitterCell *sparkle = [CAEmitterCell emitterCell];
        sparkle.contents = (id)[[UIImage imageNamed:@"sparklestar.png"] CGImage];
        sparkle.birthRate = 50;
        sparkle.lifetime = .5;
        sparkle.lifetimeRange = .2;
        sparkle.scale = 0.6;
        sparkle.velocity = 120;
        sparkle.alphaRange = -2;
        sparkle.blueRange = sparkle.redRange = sparkle.greenRange = .5;
        sparkle.emissionRange = 2 * M_PI;
        sparkle.duration = .2;
        sparkle.spin = 2;
        [sparkle setName:@"sparkle"];
        sparkleLayer.emitterCells = [NSArray arrayWithObject:sparkle];
        sparkleLayer.birthRate = 0;
 //       [self.layer addSublayer:sparkleLayer];
        
    }
    return self;
}

-(void) turnOffSparkle
{
    sparkleLayer.birthRate = 0;
    timer = nil;
}

-(void)startEmitterFromPoint: (CGPoint)p
{
    //change the emitter's position
    sparkleLayer.emitterPosition = p;
    sparkleLayer.birthRate = 10;
    timer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(turnOffSparkle) userInfo:nil repeats:NO];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
#endif