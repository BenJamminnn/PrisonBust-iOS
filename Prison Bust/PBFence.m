//
//  PBFence.m
//  Prison Bust
//
//  Created by Mac Admin on 4/24/14.
//  Copyright (c) 2014 Ben Gabay. All rights reserved.
//

#import "PBFence.h"
@interface PBFence()

@property (strong, nonatomic) SKEmitterNode *sparksEmitter;
@end
@implementation PBFence
- (id)init {
    if(self = [super initWithImageNamed:@"electricFence.png"]) {
        self.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(140, 150)];
        self.physicsBody.categoryBitMask = enemyCategory;
        self.xScale = 2.0;
        self.physicsBody.dynamic = NO;
        self.enemyType = enemyTypeFence;
        self.name = fenceIdentifier;
        self.sparksEmitter = [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle]pathForResource:@"Spark" ofType:@"sks"]];
        self.sparksEmitter.position = CGPointMake(0,90);
        self.sparksEmitter.name = @"sparkEmitter";
        [self.sparksEmitter runAction:[SKAction rotateToAngle:-0.25 duration:0]];
        self.sparksEmitter.physicsBody.collisionBitMask = 32;
        [self addChild:self.sparksEmitter];
        [self loadDeathAnimationImages];
        
    }
    return self;
}

- (void)loadDeathAnimationImages {
    self.contactFrames = [NSMutableArray array];
    SKTextureAtlas *deathAtlas = [SKTextureAtlas atlasNamed:@"FenceDeathAnimation"];
    for(int i = 0; i < deathAtlas.textureNames.count; i++) {
        NSString *tempName = [NSString stringWithFormat:@"Electro_%d" , i + 1];
        SKTexture *tempTexture = [deathAtlas textureNamed:tempName];
        if(tempTexture) {
            [self.contactFrames addObject:tempTexture];
        }
    }
}




- (SKAction *)deathAnimation {
    return [SKAction repeatAction:[SKAction animateWithTextures:self.contactFrames timePerFrame:0.05] count:20];
}

- (SKAction *)fenceBreakAnimation {
    SKAction *fenceBreak;
    return fenceBreak;
}
@end
