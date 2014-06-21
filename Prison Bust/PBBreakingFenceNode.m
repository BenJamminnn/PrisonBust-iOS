//
//  PBBreakingFenceNode.m
//  Prison Bust
//
//  Created by Mac Admin on 6/3/14.
//  Copyright (c) 2014 Ben Gabay. All rights reserved.
//

#import "PBBreakingFenceNode.h"
@interface PBBreakingFenceNode()
@property (strong, nonatomic) NSMutableArray *fencePartAFrames;
@property (strong, nonatomic) NSMutableArray *fencePartBFrames;
@end
@implementation PBBreakingFenceNode

- (instancetype)initbreakingFence {
    PBBreakingFenceNode *breakingFence = [PBBreakingFenceNode node];
    breakingFence.name = @"breakingFence";
    SKSpriteNode *fencePartA = [SKSpriteNode spriteNodeWithImageNamed:@"fence_break_1A"];
    fencePartA.name = @"FenceA";
    fencePartA.position = CGPointMake(0, 5);
    fencePartA.hidden = NO;
    fencePartA.xScale = 0.3;
    fencePartA.yScale = 0.3;
    fencePartA.zPosition = 3.9;
    
    
    [breakingFence addChild:fencePartA];
    SKSpriteNode *fencePartB = [SKSpriteNode spriteNodeWithImageNamed:@"fence_break_1B"];
    fencePartB.name = @"FenceB";
    fencePartB.xScale = 0.25;
    fencePartB.yScale = 0.25;
    fencePartB.position = CGPointMake(fencePartB.size.width/2 + 20, -20);
    fencePartB.hidden = NO;
    fencePartB.zPosition = 4.1;
    
    
    [breakingFence addChild:fencePartB];
    NSLog(@"breaking fence created");
    return breakingFence;
}

- (void)animateFenceBreak {
    [self animateFencePartA];
    [self animateFencePartB];
}

- (void) animateFencePartA {
    [self enumerateChildNodesWithName:@"FenceA" usingBlock:^(SKNode *node, BOOL *stop) {
        node.hidden = NO;
        [node runAction: [SKAction animateWithTextures:self.fencePartAFrames timePerFrame:0.015 resize:NO restore:NO]];
    }];
    NSLog(@"part a destroyed");
}

- (void )animateFencePartB {
    [self enumerateChildNodesWithName:@"FenceB" usingBlock:^(SKNode *node, BOOL *stop) {
        node.hidden = NO;
        [node runAction:[SKAction animateWithTextures:self.fencePartBFrames timePerFrame:0.02 resize:NO restore:NO]];
    }];
    NSLog(@"part b destroyed");
}

#pragma mark - loading fence break frames

- (NSMutableArray *)fencePartBFrames {
    
    if(!_fencePartBFrames) {
        _fencePartBFrames = [NSMutableArray array];
        SKTextureAtlas *atlasB = [SKTextureAtlas atlasNamed:@"fenceB"];
        for (int i = 0; i < atlasB.textureNames.count; i++) {
            NSString *tempString = [NSString stringWithFormat:@"fence_break_%dB" , i+1];
            SKTexture *tempTexture = [atlasB textureNamed:tempString];
            if(tempTexture) {
                [_fencePartBFrames addObject:tempTexture];
            }
        }
    }
    
    return _fencePartBFrames;
}

- (NSMutableArray *)fencePartAFrames {
    if(!_fencePartAFrames) {
        _fencePartAFrames = [NSMutableArray array];
        SKTextureAtlas *atlas = [SKTextureAtlas atlasNamed:@"fenceANew"];
        for (int i = 0; i < atlas.textureNames.count; i++) {
            NSString *tempString = [NSString stringWithFormat:@"fence_break_%dA" , i+1];
            SKTexture *tempTexture = [atlas textureNamed:tempString];
            if(tempTexture) {
                [_fencePartAFrames addObject:tempTexture];
            }
        }
    }
    return _fencePartAFrames;
}
@end
