//
//  PBPlayer.m
//  Prison Bust
//
//  Created by Mac Admin on 4/23/14.
//  Copyright (c) 2014 Ben Gabay. All rights reserved.
//

#import "PBPlayer.h"
#import "PBFence.h"
#import "PBMissle.h"
#import "PBSpikePit.h"
static NSInteger playerMass = 50;
static NSInteger playerZPosition = 4;
static NSString *characterImageName = @"prison_break_character_RUN_PLACEHOLDER";
static NSInteger timeForInvulnerability = 10;
@interface PBPlayer()

//basic frames
@property (strong, nonatomic) NSMutableArray *runFrames;
@property (strong, nonatomic) NSMutableArray *jumpFrames;
@property (strong, nonatomic) NSMutableArray *slideFrames;

//invulnerable frames
@property (strong, nonatomic) NSMutableArray *invulnerableRunFrames;
@property (strong, nonatomic) NSMutableArray *invulnerableJumpFrames;
@property (strong, nonatomic) NSMutableArray *invulnerableSlideFrames;

//invulnerable transformations
@property (strong, nonatomic) NSMutableArray *regToInvulnerable;
@property (strong, nonatomic) NSMutableArray *invulnerableToReg;


@end

@implementation PBPlayer {
    BOOL _isSliding;
}

#pragma mark - lifeCycle

- (instancetype)init {
    self = [super initWithImageNamed:characterImageName];
    self.name = playerName;
    self.zPosition = playerZPosition;
    self.physicsBody = [PBPlayer originalPhysicsBody];

    [self addObserver:self forKeyPath:@"invulnerabilityKeyPath" options:0 context:NULL];
    self.xScale = 0.5;
    self.yScale = 0.5;
    self.isInvulnerable = NO;
    [self setUpAnimations];
    self.playerState = running;
    _deathDispatched = NO;
    
    
    
    
    return self;
}

- (void)dealloc {
    [self removeObserver:self forKeyPath:@"invulnerabilityKeyPath"];
}


#pragma mark - player death and powerUp

- (void)playerDied {
    if(self.isInvulnerable) {
        return;
    }
    self.hidden = YES;
    [[NSNotificationCenter defaultCenter]postNotificationName:@"playerDiedNotification" object:nil];
}

- (void)powerUpPickedUp {
    if(!self.isInvulnerable) {
        self.isInvulnerable = YES;
        self.playerState = running;
    }
}

#pragma mark - setup Animations



- (void)setUpRegToInvulnerable {
    NSMutableArray *frames = [NSMutableArray array];
    SKTextureAtlas *atlas = [SKTextureAtlas atlasNamed:@"regToInvulenerable"];
    for(int i = 0; i < atlas.textureNames.count; i++) {
        NSString *tempString = [NSString stringWithFormat:@"transformation_%d" , i + 1];
        SKTexture *tempTexture = [atlas textureNamed:tempString];
        if(tempTexture) {
            [frames addObject:tempTexture];
        }
    }
    self.regToInvulnerable = frames;
}

- (void)setUpInvulnerableToReg {
    NSMutableArray *frames = [NSMutableArray array];
    SKTextureAtlas *atlas = [SKTextureAtlas atlasNamed:@"regToInvulenerable"];
    for(NSInteger i = atlas.textureNames.count; i > 0; i--) {
        NSString *tempString = [NSString stringWithFormat:@"transformation_%ld" , (long)i];
        SKTexture *tempTexture = [atlas textureNamed:tempString];
        if(tempTexture) {
            [frames addObject:tempTexture];
        }
    }
    self.invulnerableToReg = frames;
}

- (void)setUpRunFrames {
    //load running frames
    SKTextureAtlas *runningAtlas = [SKTextureAtlas atlasNamed:@"running"];
    self.runFrames = [[NSMutableArray alloc] init];
    for(int i = 1; i < runningAtlas.textureNames.count; i++) {
        NSString *tempString;
        if (i < 10) {
            tempString = [NSString stringWithFormat:@"Run_Cycle_0%d" , i];
        } else {
            tempString = [NSString stringWithFormat:@"Run_Cycle_%d" , i];
        }
        SKTexture *runningTemp = [runningAtlas textureNamed:tempString];
        if(runningTemp) {
            [self.runFrames addObject:runningTemp];
        }
    }
}

- (void)setUpJumpFrames {
    self.jumpFrames = [NSMutableArray new];
    SKTextureAtlas *jumpAtlas = [SKTextureAtlas atlasNamed:@"jumping"];

    for(int i = 0; i < jumpAtlas.textureNames.count; i++) {
        NSString *tempName = [NSString stringWithFormat:@"jump_%d" , i];
        SKTexture *jumpTemp = [jumpAtlas textureNamed:tempName];
        if(jumpTemp) {
            [self.jumpFrames addObject:jumpTemp];
        }
    }
}

- (void)setUpSlidingFrames {
    self.slideFrames = [NSMutableArray array];
    SKTextureAtlas *slideAtlas = [SKTextureAtlas atlasNamed:@"sliding"];
    for(int i = 0; i < [slideAtlas.textureNames count];i++) {
        NSString *tempName = [NSString stringWithFormat:@"slide_%d", i];
        SKTexture *tempTexture = [slideAtlas textureNamed:tempName];
        if(tempTexture) {
            [self.slideFrames addObject:tempTexture];
        }
    }
    for(NSInteger i = [slideAtlas.textureNames count] -1; i > -1 ; i--) {
        NSString *tempName = [NSString stringWithFormat:@"slide_%ld" , (long)i];
        SKTexture *tempText = [slideAtlas textureNamed:tempName];
        if(tempText) {
            [self.slideFrames addObject:tempText];
        }
    }
}

- (void)setUpRunningInvulnerableAnimation {
    self.invulnerableRunFrames = [[NSMutableArray alloc]init];
    SKTextureAtlas *invulnerableRunAtlas = [SKTextureAtlas atlasNamed:@"runningInvulnerable"];
    for(int i = 0; i < invulnerableRunAtlas.textureNames.count; i++) {
        NSString *tempName = [NSString stringWithFormat:@"powerup_run_%d" , i + 1];
        SKTexture *tempTexture = [invulnerableRunAtlas textureNamed:tempName];
        if(tempTexture) {
            [self.invulnerableRunFrames addObject:tempTexture];
        }
    }
}

- (void)setUpAnimations {
    [self setUpRunFrames];
    [self setUpJumpFrames];
    [self setUpSlidingFrames];
    [self setUpInvulnerableToReg];
    [self setUpRegToInvulnerable];
    [self setUpRunningInvulnerableAnimation];
}



#pragma mark - basic and invulnerable animations


- (void)startRunningAnimation {
    if(![self actionForKey:@"running"]) {
        [self runAction:[SKAction repeatActionForever:[SKAction animateWithTextures:self.runFrames timePerFrame:0.08 resize:NO restore:NO]]withKey:@"running"];
    }
}

- (void) stopRunningAnimation {
    [self removeActionForKey:@"running"];
}

- (void) startJumpingAnimations {
    if(![self actionForKey:@"jumping"]) {
        [self runAction:[SKAction animateWithTextures:self.jumpFrames timePerFrame:0.35 resize:NO restore:NO] withKey:@"jumping"];
    }
}

- (void) startJumpingInvulnerable {
    if(![self actionForKey:@"jumping_invulnerable"]) {
        
        [self runAction:[SKAction sequence:@[[SKAction animateWithTextures:self.invulnerableJumpFrames timePerFrame:.03 resize:YES restore:NO] , [SKAction runBlock:^{
        }]]]withKey:@"jumping_invulnerable"];
    }
}


- (void) slideAnimation {
    _isSliding = YES;
    self.physicsBody = [PBPlayer slidingPhysicsBody];
    [self slide];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.9 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self runAction:[SKAction runBlock:^{
            if(!_deathDispatched) {
                self.physicsBody = [PBPlayer physicsBodyAfterSlide];
                _isSliding = NO;
                self.playerState = running;
            }
        }]withKey:@"physicsBodyChange"];
    });
    
}

- (void)slide {
    [self runAction:[SKAction animateWithTextures:self.slideFrames timePerFrame:0.15 resize:YES restore:YES] withKey:@"sliding"];
}

- (void) stopSlidingAnimation {
    [self removeActionForKey:@"sliding"];
}

- (void) slideInvulnerableAnimation {
    if(![self actionForKey:@"sliding_invulnerable"]) {
        [self runAction:[SKAction sequence:@[[SKAction animateWithTextures:self.invulnerableSlideFrames timePerFrame:.03 resize:YES restore:NO] , [SKAction runBlock:^{
            //set animation state
        }]]]withKey:@"sliding_invulnerable"];
    }
}

- (void) stopInvulnerableSlideAnimation {

    [self removeActionForKey:@"sliding_invulnerable"];
    
}

- (void) startRunningInvulnerableAnimation {
    if(![self actionForKey:@"running_invulnerable"]) {
        self.physicsBody.allowsRotation = NO;
        [self runAction:
            [SKAction group:@[
                        [SKAction scaleBy:2.0 duration:0.3] ,
                        [SKAction repeatActionForever:[SKAction animateWithTextures:self.invulnerableRunFrames timePerFrame:.08 resize:NO restore:YES]]
                        ]]];
    }
}



- (void)InvulnerableToRegular {
    self.physicsBody.allowsRotation = NO;
    SKAction *invulnerableToReg = [SKAction sequence:@[
                      [SKAction repeatAction:[self colorizeSpriteNodeWithColor:[SKColor redColor]] count:3],
                      [SKAction scaleBy:0.5 duration:0.5] ,
                      [SKAction repeatActionForever:[SKAction animateWithTextures:self.runFrames timePerFrame:0.08 resize:NO restore:YES]]
                      ]];
    [self runAction:invulnerableToReg];

}



- (void) stopRunningInvulnerableAnimation {
    [self removeActionForKey:@"running_invulnerable"];
}

#pragma mark - player state

- (void)setPlayerState:(PBPlayerAnimationState)playerState {

    if(self.isInvulnerable) {
        switch (playerState) {
            case running:
                [self startRunningInvulnerableAnimation];
                break;
            case jumping:
                if(_playerState == running) {
                    [self stopRunningInvulnerableAnimation];
                    [self startJumpingInvulnerable];
                    [self startRunningInvulnerableAnimation];
                } else if(_playerState == sliding) {
                    [self stopInvulnerableSlideAnimation];
                    [self startJumpingInvulnerable];
                    self.playerState = running;
                }
                break;
            case sliding:
                if(_playerState == jumping) {
                    break;
                } else if(_playerState == running) {
                    [self stopRunningInvulnerableAnimation];
                    [self slideInvulnerableAnimation];
                }
                break;
            default:
                break;
        }
    } else {
        switch (playerState) {
            case running:
                [self startRunningAnimation];
                
                break;
            case jumping:
                if(_playerState == running) {
                    [self stopRunningAnimation];
                    [self startJumpingAnimations];
                    [self startRunningAnimation];
                } else if(_playerState == sliding) {
                    [self stopSlidingAnimation];
                    [self startJumpingAnimations];
                }
                break;
            case sliding:
                if(_playerState == running) {
                    [self slideAnimation];
                    [self stopSlidingAnimation];
                    self.playerState = running;
                }
                break;
            case dying:
                [self removeAllActions];
            default:
                break;
        }
    }
    
    _playerState = playerState;
}


#pragma mark - reactions and other



-(SKAction*)colorizeSpriteNodeWithColor:(SKColor*)color
{
    SKAction *changeColorAction = [SKAction colorizeWithColor:color colorBlendFactor:0.65 duration:0.2];
    SKAction *waitAction = [SKAction waitForDuration:0.2];
    SKAction *startingColorAction = [SKAction colorizeWithColorBlendFactor:0.0 duration:0.3];
    SKAction *selectAction = [SKAction sequence:@[changeColorAction, waitAction, startingColorAction]];
    return selectAction;
}

- (void)executeDeathAnimationWithEnemy:(enemyType)enemyType {
    NSLog(@"calling player execution");
    SKAction *dyingAction;
    if(!_deathDispatched) {
        if(self.isInvulnerable) {
            if(enemyType == enemyTypeFence) {
                
            } else if(enemyType == enemyTypeMissle) {
                PBMissle *missile = [PBMissle new];
                [missile deathAnimation];
            }
            
            
        } else {
            _deathDispatched = YES;
            if(enemyType == enemyTypeFence) {
                PBFence *fence = [PBFence new];
                dyingAction = [fence deathAnimation];
                [self runAction:dyingAction completion:^{
                    self.hidden = YES;
                }];
            } else if(enemyType == enemyTypeMissle) {
                PBMissle *missile = [PBMissle new];
                self.playerState = dying;
                dyingAction = [missile deathAnimation];
                [self runAction:dyingAction completion:^{
                    self.hidden = YES;
                }];
            } else if(enemyType == enemyTypeSpikePit) {
                PBSpikePit *spikePit = [PBSpikePit new];
                dyingAction = [spikePit deathAnimation];
                self.physicsBody = nil;
                self.xScale = 0.3;
                self.yScale = 0.3;
                if(_isSliding) {
                    self.playerState = dying;
                    [self runAction:[SKAction group:@[dyingAction , [self dropInSpikePitAtLocation:CGPointMake(self.position.x + 10, self.position.y + 10) WithDuration:0.3]]]completion:^{
                        [self addBloodEmitter];
                    }];
                } else {
                    self.playerState = dying;
                    
                    [self runAction:[SKAction group:@[dyingAction , [self dropInSpikePitAtLocation:self.position WithDuration:0.3]]] completion:^{
                        [self addBloodEmitter];
                    }];
                }
            }
        }
    }
}

+ (SKSpriteNode *)deadPlayerSpriteNode {
    SKSpriteNode *node = [SKSpriteNode spriteNodeWithImageNamed:@"blown_up"];
    node.zPosition = playerZPosition;
    return node;
}

- (SKAction *)dropInSpikePitAtLocation:(CGPoint)location WithDuration:(NSTimeInterval)duration {
    SKAction *drop = [SKAction group:@[[SKAction moveToX:location.x + 22
                                            duration:duration] , [SKAction moveToY:location.y - 22 duration:duration]]];

    return drop;
}

- (void)addBloodEmitter {
    SKEmitterNode *bloodEmitter = [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle]pathForResource:@"blood" ofType:@"sks"]];
    bloodEmitter.position = CGPointMake(10, 10);
    bloodEmitter.zPosition = self.zPosition + 1;
    bloodEmitter.name = @"bloodEmitter";
    bloodEmitter.xScale = 0.6;
    bloodEmitter.yScale = 0.6;
    [self addChild:bloodEmitter];
}


#pragma mark - different physics bodies for player state

+ (SKPhysicsBody *)originalPhysicsBody {
    SKPhysicsBody *orginalBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(30, 60)];
    orginalBody.dynamic = YES;
    orginalBody.mass = playerMass;
    orginalBody.contactTestBitMask = enemyCategory | powerUpCategory;
    orginalBody.categoryBitMask = playerCategory;
    orginalBody.collisionBitMask = groundBitMask;
    orginalBody.allowsRotation = NO;
    
    return orginalBody;
}

+ (SKPhysicsBody *)physicsBodyAfterSlide {
    SKPhysicsBody *orginalBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(15, 30)];
    orginalBody.dynamic = YES;
    orginalBody.mass = playerMass;
    orginalBody.contactTestBitMask = enemyCategory | powerUpCategory;
    orginalBody.categoryBitMask = playerCategory;
    orginalBody.collisionBitMask = groundBitMask;
    orginalBody.allowsRotation = NO;
    
    return orginalBody;
}

+ (SKPhysicsBody *)slidingPhysicsBody {
    SKPhysicsBody *slidingBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(35, 15)];
    slidingBody.dynamic = YES;
    slidingBody.mass = playerMass;
    slidingBody.contactTestBitMask = enemyCategory | powerUpCategory;
    slidingBody.categoryBitMask = playerCategory;
    slidingBody.collisionBitMask = groundBitMask;
    slidingBody.allowsRotation = NO;
    return slidingBody;
}


@end
