//
//  PBSpikePit.m
//  Prison Bust
//
//  Created by Mac Admin on 5/29/14.
//  Copyright (c) 2014 Ben Gabay. All rights reserved.
//

#import "PBSpikePit.h"

static NSString *spikeImageName = @"spike_pit";
@interface PBSpikePit ()
@property (nonatomic, strong) NSMutableArray *spikePitDeathFrames;
@end
@implementation PBSpikePit {
    BOOL _deathDispatched;
}
- (id)init {
    if(self = [super initWithImageNamed:spikeImageName]) {
        self.enemyType = enemyTypeSpikePit;
        self.name = spikePitIdentifier;
        self.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(170, 50)];
        self.physicsBody.categoryBitMask = enemyCategory;
        self.physicsBody.usesPreciseCollisionDetection = YES;
        self.physicsBody.affectedByGravity = NO;
        self.physicsBody.dynamic = NO;
        self.zPosition = 3.5;
        self.xScale = 0.35;
        self.yScale = 0.3;
        
        SKSpriteNode *bottomHalfNode = [[SKSpriteNode alloc]initWithImageNamed:@"spikepit_front"];
        bottomHalfNode.zPosition = 4.5;
        bottomHalfNode.position = CGPointMake(4, -15);
        [self addChild:bottomHalfNode];
        _deathDispatched = NO;
        [self setUpContactFrames];
    }
    return self;
}


- (SKAction *)deathAnimation {
    if(!_deathDispatched) {
        SKAction *spikePitDeathFrames = [SKAction animateWithTextures:self.spikePitDeathFrames timePerFrame:0.1 resize:YES restore:NO];
        SKAction *deathAnimation = [SKAction sequence:@[spikePitDeathFrames , [SKAction setTexture:[self.spikePitDeathFrames lastObject]]]];
        _deathDispatched = YES;
        return deathAnimation;
    }
    return nil;
}

- (void)setUpContactFrames {
    self.spikePitDeathFrames = [NSMutableArray array];
    SKTextureAtlas *spikePitAtlas = [SKTextureAtlas atlasNamed:@"pitDeathFrames"];
    for(int i = 0; i < spikePitAtlas.textureNames.count; i++) {
        NSString *tempName = [NSString stringWithFormat:@"pit_death_%d" , i + 1];
        SKTexture *tempTexture = [spikePitAtlas textureNamed:tempName];
        if(tempTexture) {
            [self.spikePitDeathFrames addObject:tempTexture];
        }
    }
}


@end
