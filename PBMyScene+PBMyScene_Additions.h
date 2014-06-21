//
//  PBMyScene+PBMyScene_Additions.h
//  Prison Bust
//
//  Created by Mac Admin on 5/15/14.
//  Copyright (c) 2014 Ben Gabay. All rights reserved.
//

#import "PBMyScene.h"

@class PBFence, PBMissle, PBSpikePit, PBPowerUp, PBPlayer;
@interface PBMyScene (PBMyScene_Additions)

- (PBMissle *)missileInstance;
- (PBFence *)fenceInstance;
- (PBSpikePit *)spikePitInstance;

- (PBPowerUp *)powerUpInstance;

- (PBPlayer *)playerInstance;
//on screen edge colliders
- (SKNode *)bottomCollider;
- (SKNode *)leftCollider;
- (SKNode *)topCollider;


- (SKSpriteNode *)deadBodyNodeAtPosition:(CGPoint)position;

//exploding body parts
- (void)loadPlayerExplosionSprites;
- (SKAction *)explosionSpritesAtLocation:(CGPoint)location;


//convenience
+ (NSString *)dateToString:(NSDate *)date;

@end
