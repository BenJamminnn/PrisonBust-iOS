//
//  PBMissle.m
//  Prison Bust
//
//  Created by Mac Admin on 4/24/14.
//  Copyright (c) 2014 Ben Gabay. All rights reserved.
//

#import "PBMissle.h"
@interface PBMissle()
@property (strong, nonatomic) SKEmitterNode *fireEmitter;
@end
@implementation PBMissle
- (id)init{
    if(self = [super initWithImageNamed:@"rocket.png"]) {
        self.enemyType = enemyTypeMissle;
        self.name = missileIdentifier;
        [self setUpFrames];
        self.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(100, 20)];
        self.physicsBody.categoryBitMask = enemyCategory;
        self.physicsBody.affectedByGravity = NO;
        self.zPosition = 3.5;
        self.physicsBody.usesPreciseCollisionDetection = YES;
        self.fireEmitter = [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle] pathForResource: @"FireEmitterForMissle" ofType:@"sks"]];
        self.xScale = .6;
        self.yScale = .6;
        self.fireEmitter.position = CGPointMake(60,-5);
        self.fireEmitter.name = @"fireEmitter";

        [self addChild:self.fireEmitter];
    }
    return self;
}

- (SKAction *)deathAnimation {
    return [SKAction group:@[[SKAction animateWithTextures:self.contactFrames timePerFrame:0.03 resize:YES restore:YES] , [SKAction fadeOutWithDuration:2.0]]];
}

- (SKAction *)deathAnimationForInvulnerability {
    return [SKAction group:@[[SKAction animateWithTextures:self.contactFrames timePerFrame:0.03 resize:YES restore:YES] , [SKAction fadeOutWithDuration:0.7]]];
}
- (void)setUpFrames {
    self.contactFrames = [NSMutableArray array];
    SKTextureAtlas *missileAtlas = [SKTextureAtlas atlasNamed:@"missileExplosion"];
    for(int i = 1; i < missileAtlas.textureNames.count/2; i++) {
        NSString *tempName = [NSString stringWithFormat:@"untitled.%.3d.png" , i];
        SKTexture *tempTexture = [missileAtlas textureNamed:tempName];
        
        if(tempTexture) {
            [self.contactFrames addObject:tempTexture];
        }
    }
}



@end
