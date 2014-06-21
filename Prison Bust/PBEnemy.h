//
//  PBEnemy.h
//  Prison Bust
//
//  Created by Mac Admin on 4/24/14.
//  Copyright (c) 2014 Ben Gabay. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
typedef NS_ENUM(NSInteger, enemyType) {
    enemyTypeFence,
    enemyTypeGuard,
    enemyTypeMissle,
    enemyTypeDogs,
    enemyTypeSpikePit,
    enemyTypeDefault
};
@interface PBEnemy : SKSpriteNode
@property (nonatomic) enemyType enemyType;
@property (nonatomic, strong) NSMutableArray *contactFrames;

//privately set up animations in init
- (void)executeDeathAnimation;
+ (instancetype)enemyWithType:(enemyType)enemyType;
@end
