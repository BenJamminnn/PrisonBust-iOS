//
//  PBBackground.m
//  Prison Bust
//
//  Created by Mac Admin on 4/23/14.
//  Copyright (c) 2014 Ben Gabay. All rights reserved.
//

#import "PBBackground.h"

static NSInteger backgroundZPosition = 1;
static NSInteger midgroundZPosition = 2;
static NSInteger foregroundZPosition = 3;
static NSString *midgroundImageName = @"prison_break_middleground_V02";
static NSString *backgroundImageName = @"prison_break_background_v02";
static NSString *foregroundImageName = @"prison_break_foreground_V02";
static NSString *midgroundNameShooter = @"midgroundWithShooter";


@interface PBBackground()
@property (strong, nonatomic) NSMutableArray *backgroundWithShooterFrames;

@end
@implementation PBBackground
+ (instancetype)backgroundNode {
    
    PBBackground *backgroundNode = [[PBBackground alloc] initWithImageNamed:backgroundImageName];

    //deal with this after getting images=====================================================================
    backgroundNode.yScale = 0.3;
    backgroundNode.xScale = 0.4;
    backgroundNode.anchorPoint = CGPointMake(0, 0);
    backgroundNode.position = CGPointMake(0, 190);
    //========================================================================================================
    
    backgroundNode.name = backgroundName;
    backgroundNode.zPosition = backgroundZPosition;
    
 
    return backgroundNode;
}

+ (instancetype)midgroundNode {
    PBBackground *midgroundNode = [[PBBackground alloc]initWithImageNamed:midgroundImageName];

    
    //========================================================================================================
    midgroundNode.xScale = 0.45;
    midgroundNode.yScale = 0.35;
    midgroundNode.position = CGPointMake(0, 204);
    midgroundNode.anchorPoint = CGPointMake(0, 0);
    //========================================================================================================
    
    midgroundNode.name = midgroundName;
    midgroundNode.zPosition = midgroundZPosition;
    return midgroundNode;
    
}

//add texture and animation to this background. helper methods for texture atlas.
- (instancetype)initMidgroundNodeWithShooter {
    if(self = [super init]) {
        
    
    PBBackground *midgroundNodeShooter = [[PBBackground alloc]initWithImageNamed:midgroundImageName];

    //=================================================================
    midgroundNodeShooter.position = CGPointMake(0, 190);
    midgroundNodeShooter.anchorPoint = CGPointMake(0, 0);
    //=================================================================
    [self setUpBackgroundShooterAtlas];
    [self runBackgroundShooterAnimation];
    
    midgroundNodeShooter.zPosition = midgroundZPosition;
    midgroundNodeShooter.name = @"placeholder";
    return midgroundNodeShooter;
    }
    return nil;
}


+ (instancetype)foregroundNode {
    PBBackground *foreground = [[PBBackground alloc]initWithImageNamed:foregroundImageName];
    foreground.zPosition = foregroundZPosition;
    foreground.yScale = .27;
    foreground.xScale = 0.5;
    foreground.name = foregroundName;
    foreground.position = CGPointMake(0, 192);
    foreground.anchorPoint = CGPointMake(0, 0);
    return foreground;
}

- (void)runBackgroundShooterAnimation {
    [self runAction:[SKAction repeatAction:[SKAction animateWithTextures:self.backgroundWithShooterFrames timePerFrame:0.05 resize:YES restore:NO]count:1]withKey:@"runBackgroundAnimation"];
}

- (void)setUpBackgroundShooterAtlas {
    self.backgroundWithShooterFrames = [NSMutableArray new];
    SKTextureAtlas *backgroundwithShooterAtlas = [SKTextureAtlas atlasNamed:@"backgroundWithShooter"];
    for(int i = 0; i < backgroundwithShooterAtlas.textureNames.count; i++) {
        NSString *tempName = [NSString stringWithFormat:@"backgroundWithShooter%.3d" , i ];
        SKTexture *tempTexture = [backgroundwithShooterAtlas textureNamed:tempName];
        if(tempTexture) {
            [self.backgroundWithShooterFrames addObject:tempTexture];
        }
    }
}


@end
