//
//  PBPlayer.h
//  Prison Bust
//
//  Created by Mac Admin on 4/23/14.
//  Copyright (c) 2014 Ben Gabay. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "PBEnemy.h"
typedef NS_ENUM(NSInteger, PBPlayerAnimationState) {
    running,
    jumping,
    sliding,
    dying,
};

static NSString *playerName = @"player";

@interface PBPlayer : SKSpriteNode
@property (nonatomic) BOOL isInvulnerable;
@property (nonatomic) BOOL deathDispatched;

@property (nonatomic) PBPlayerAnimationState playerState;

- (void)playerDied;
- (void)startJumpingAnimations;
- (void)slideAnimation;
- (void)executeDeathAnimationWithEnemy:(enemyType)enemyType;
+ (SKSpriteNode *)deadPlayerSpriteNode;
- (void)powerUpPickedUp;
- (void)InvulnerableToRegular;



@end
