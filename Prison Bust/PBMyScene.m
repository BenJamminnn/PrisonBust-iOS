////
////  PBMyScene.m
////  Prison Bust
////
////  Created by Mac Admin on 4/23/14.
////  Copyright (c) 2014 Ben Gabay. All rights reserved.
////
//
#import "PBEnemy.h"
#import "PBMyScene.h"
#import "PBBackground.h"
#import "PBPlayer.h"
#import "PBDog.h"
#import "PBFence.h"
#import "PBMissle.h"
#import "PBGuards.h"
#import "PBBreakingFenceNode.h"
#import "PBPowerUp.h"
#import "PBSpikePit.h"
#import "PBMyScene+PBMyScene_Additions.h"
#import "PBGameOverLayer.h"
#import "PBHighScoresScene.h"
@import AVFoundation;
//move speeds

/*
Beta 1.2
- missile only explodes once upon contact
- highest score displayed in game over scene
- player colorizes with red before going back to reg (warns player better)
 
*/


static NSInteger missileSpeed = 13;
static NSInteger midgroundMoveSpeed = 1; //experiment
static NSInteger backgroundMoveSpeed = 9;

static NSInteger midgroundMoveSpeedInvulnerable = 6;
static NSInteger backgroundMoveSpeedInvulnerable = 2;

static NSInteger globalGravity = -4.8;


@interface PBMyScene() <SKPhysicsContactDelegate>

//background vars
@property (nonatomic, strong) PBBackground *currentBackground;
@property (nonatomic, strong) PBBackground *currentMidground;
@property (nonatomic, strong) PBBackground *currentForeGround;

//player
@property (nonatomic, strong) PBPlayer *player;

//current enemies holders
@property (nonatomic, strong) PBMissle *currentMissile;
@property (nonatomic, strong) PBFence *currentFence;
@property (nonatomic, strong) PBSpikePit *currentSpikePit;

//powerUp holder
@property (nonatomic, strong) PBPowerUp *currentPowerUp;

//score label
@property (nonatomic, strong) SKLabelNode *scoreLabel;

//gesture recognizers
@property (nonatomic, strong) UISwipeGestureRecognizer *downwardSwipeRecognizer;
@property (nonatomic, strong) UISwipeGestureRecognizer *upwardSwipeRecognizer;

//delta time
@property (nonatomic) CFTimeInterval lastUpdateTimeInterval;

//music niggie
@property (nonatomic, strong) AVAudioPlayer *musicPlayer;

@property (nonatomic, strong) NSArray *enemyTypes;

@end
@implementation PBMyScene {
    int _score;
    BOOL _stopMovingBackgrounds;
    CGPoint _playerFreezePoint;
    NSTimer *_powerDown;
    NSTimer *_enemyDispatchTimer;
    NSTimer *_powerUpDispatchTimer;
    NSTimer *_blinkRedTimer;
    SKPhysicsBody *_basePhysicsBody;
    
}

/*
init ============
    init background
    init midground
    init player
    init gravity , set contact delegate
    init HUD
    init music
    add observer to know when player died
    add gesture recognizers (slide down)
    (add pause label hidden)
==================
 
update ==========
    _dt calculation
    enumerate over background node to move it and set a new one if needed
    enumerate over midground node to move it and set a new one at random (with shooter/without)
    update score
    enumerate over enemies and move accordingly
=================

did begin contact=============
    check category bit masks to see if enemy collided with player
    if so == are we invulnerable?
    if not == we die - begin dying animations [player playerDied]
    check category bit masks to see if player collided with powerUp
    if so == are we invulnerable
    if not == playerState = invulnerable
 
==============================

 5/30============================================================
 TO DO
- change power up frame rate
- change to invulnerable state
- change back to vulnerable state
--->>>>>>>>>>>>>>>
enemy production/powerUp algo
1 : 5 powerUp:Enemy

Problem: 
we need to produce 5 enemies and 1 powerUp per unit of "distance"
- generate random Enemy
   > Call [enemyGenObj newEnemy] using NSTimer, producing an enemy, addChild: enemy
   > @implementation
   > hold an array of enemy types
   > get random index and call instance
 

*/



-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        
        //set background
        self.currentBackground = [PBBackground backgroundNode];
        [self addChild:self.currentBackground];
        
        //set midground - normal
        self.currentMidground = [PBBackground midgroundNode];
        [self addChild:self.currentMidground];
        
        //set foreground
        self.currentForeGround = [PBBackground foregroundNode];
        [self addChild:self.currentForeGround];
        
        //set edge colliders
        [self addChild:[self topCollider]];
        [self addChild:[self bottomCollider]];
        //[self addChild:[self leftCollider]];

        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(gameOver) name:@"playerDiedNotification" object:nil];
        
        self.player = [self playerInstance];
        [self addChild:self.player];
        
        [self enemyDispatchTimer];
        [self powerUpDispatchTimer];
        
        
//        self.currentFence = [self fenceInstance];
//        [self addChild:self.currentFence];
//        
//        self.currentMissile = [self missileInstance];
//        [self addChild:self.currentMissile];
//  
//        self.currentSpikePit = [self spikePitInstance];
//        [self addChild:self.currentSpikePit];
//        
//        self.currentPowerUp = [self powerUpInstance];
//        [self addChild:self.currentPowerUp];
//        
        //  [self setUpMusicAndPlay];
  
        _score = 0;
        [self initializeScoreLabelNode];
        
        //set gravity
        self.physicsWorld.gravity = CGVectorMake(0, globalGravity);
        self.physicsWorld.contactDelegate = self;
        
        [self loadPlayerExplosionSprites];
        
        PBHighScoresScene *scene = [PBHighScoresScene highScoresScene];
    }
    return self;
}


#pragma mark - handling contact



- (void)didBeginContact:(SKPhysicsContact *)contact {
    //detect for player and enemy
    if(contact.bodyA.categoryBitMask == playerCategory && contact.bodyB.categoryBitMask == enemyCategory) {
        NSLog(@"Enemy: %@" , contact.bodyB.node);
        NSLog(@"Player: %@" , contact.bodyA.node);
        NSLog(@"contact point: %@" , NSStringFromCGPoint(contact.contactPoint));
        if([contact.bodyB.node isKindOfClass:[PBFence class]]) {
            if(self.player.isInvulnerable) {
                [contact.bodyB.node removeFromParent];
                PBBreakingFenceNode *node = [[PBBreakingFenceNode alloc]initbreakingFence];
                node.position = contact.contactPoint;
                [self addChild:node];
                [node animateFenceBreak];
                
            } else {
                [self.player executeDeathAnimationWithEnemy:enemyTypeFence];
                self.player.position = contact.bodyA.node.position = _playerFreezePoint;
                self.player.deathDispatched = YES;
                _stopMovingBackgrounds = YES;
                [self runAction:[SKAction sequence:@[[SKAction waitForDuration:2.0] , [SKAction runBlock:^{
                    [self gameOver];
                }]]]];
            }
            
        } else if ([contact.bodyB.node isKindOfClass:[PBSpikePit class]]) {
            if(self.player.isInvulnerable) {
                //do something different if we're invulnerable
            } else {
                _stopMovingBackgrounds = YES;
                [self.player executeDeathAnimationWithEnemy:enemyTypeSpikePit];
                self.player.deathDispatched = YES;
                [self runAction:[SKAction sequence:@[[SKAction waitForDuration:2.0] , [SKAction runBlock:^{
                    [self gameOver];
                }]]]];
                
            }
        
           
        } else if([contact.bodyB.node isKindOfClass:[PBMissle class]]) {
            NSLog(@"missile hit player");
            if(self.player.isInvulnerable) {
                PBMissle *missile = (PBMissle *)contact.bodyB.node;
                missile.physicsBody.dynamic = NO;
                [missile runAction:[missile deathAnimationForInvulnerability]];
               
            } else {
            
                [self.player executeDeathAnimationWithEnemy:enemyTypeMissle];
                self.player.position = _playerFreezePoint = contact.contactPoint;
                
                
                self.player.deathDispatched = YES;

                [self explosionReactionAtPoint:contact.contactPoint];
                [contact.bodyB.node removeFromParent];
                
                _stopMovingBackgrounds = YES;
                [self runAction:[SKAction sequence:@[[SKAction waitForDuration:3.0] , [SKAction runBlock:^{
                    [self gameOver];
                }]]]];
            }

        } else if([contact.bodyB.node isKindOfClass:[PBSpikePit class]]) {
            [self.player executeDeathAnimationWithEnemy:enemyTypeSpikePit];
            _stopMovingBackgrounds = YES;
        }
        
      //  [[NSNotificationCenter defaultCenter]postNotificationName:@"playerDiedNotification" object:nil];

  
    } else if(contact.bodyB.categoryBitMask == playerCategory && contact.bodyA.categoryBitMask == enemyCategory) {
        NSLog(@"Enemy: %@" , contact.bodyA.node);
        NSLog(@"Player: %@" , contact.bodyB.node);

    }
    
    //detect for player and powerup
    if(contact.bodyB.categoryBitMask == playerCategory && contact.bodyA.categoryBitMask == powerUpCategory) {
        [contact.bodyA.node removeFromParent];
        [self.player powerUpPickedUp];
        [self beginInvulnerableCounter];
        
    } else if(contact.bodyB.categoryBitMask == powerUpCategory && contact.bodyA.categoryBitMask == playerCategory) {
        [contact.bodyB.node removeFromParent];
        [self.player powerUpPickedUp];
        [self beginInvulnerableCounter];
    }
}


-(void)update:(CFTimeInterval)currentTime {
    if(_stopMovingBackgrounds) {
        return;
    }
    
    if(self.player.isInvulnerable) {
        backgroundMoveSpeed = backgroundMoveSpeedInvulnerable;
        midgroundMoveSpeed = midgroundMoveSpeedInvulnerable;
    } else {
        backgroundMoveSpeed = 1;
        midgroundMoveSpeed = 3;
    }
    
    //adjusting time interval accordingly to compensate for currentTime
    CFTimeInterval timeSinceLast = currentTime - self.lastUpdateTimeInterval;
    self.lastUpdateTimeInterval = currentTime;
    if (timeSinceLast > 1) { // more than a second since last update
        timeSinceLast = 1.0 / 60.0;
        self.lastUpdateTimeInterval = currentTime;
    }
    
    
    [self enumerateOverPlayer:timeSinceLast];
    
    [self enumerateOverForeground:timeSinceLast];
    
    [self enumerateOverBackground:timeSinceLast];

    [self enumerateOverMidground:timeSinceLast];

    [self enumerateOverFences:timeSinceLast];

    [self enumerateOverMissiles:timeSinceLast];
    
    [self enumerateSpikePit:timeSinceLast];
    
    [self enumerateOverPowerUps:timeSinceLast];
    
    [self enumerateBreakingFence:timeSinceLast];
    
   //update score
    [self updateScore];
}

- (void)executeSlide {
    if(self.player.isInvulnerable) {
        return;
    } else {
        if(!self.player.deathDispatched || !self.player.playerState == dying) {
            [self.player slideAnimation];
        }
    }
}

- (void)displaceBody:(SKSpriteNode *)body withVector:(CGVector)vector duration:(NSTimeInterval)duration {
    if([self.children containsObject:body]) {
        [body runAction:[SKAction moveBy:vector duration:duration]];
    }
    if([body.name isEqualToString:playerName]) {
        
    }
}


- (void)didMoveToView:(SKView *)view {
    //set sliding gesture recognizer here
    self.downwardSwipeRecognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(executeSlide)];
    self.downwardSwipeRecognizer.direction = UISwipeGestureRecognizerDirectionDown;
    [view addGestureRecognizer:self.downwardSwipeRecognizer];
    self.upwardSwipeRecognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(jumpAction)];
    self.upwardSwipeRecognizer.direction = UISwipeGestureRecognizerDirectionUp;
    [view addGestureRecognizer:self.upwardSwipeRecognizer];
}

- (void)jumpAction {
    if(!self.player.playerState == dying || !self.player.deathDispatched) {
        if(self.player.position.y < 250 && self.player.position.y > 220) {
            [self.player startJumpingAnimations];
            [self.player runAction:[SKAction runBlock:^{
                self.player.physicsBody.mass = 50;
                [self.player.physicsBody applyImpulse:CGVectorMake(0, 250 * self.player.physicsBody.mass)];
            }]];
        }
    }
    
}
- (void)willMoveFromView:(SKView *)view {
    [view removeGestureRecognizer:self.downwardSwipeRecognizer];
    [view removeGestureRecognizer:self.upwardSwipeRecognizer];
    [_powerUpDispatchTimer invalidate];
    [_enemyDispatchTimer invalidate];
}
- (void)gameOver {
    
    _stopMovingBackgrounds = YES;
    [self presentGameOverScene];
}

#pragma mark - score label setup
- (void) initializeScoreLabelNode {
    SKLabelNode *scoreNode = [SKLabelNode labelNodeWithFontNamed:@"Verdana"];
    scoreNode.position = CGPointMake(self.size.width/6 , self.size.height/2 + 60);
    scoreNode.zPosition = self.player.zPosition + 1;
    scoreNode.text = [NSString stringWithFormat:@"Score : %d", _score];
    scoreNode.fontColor = [SKColor blackColor];
    scoreNode.fontSize = 11;
    [self addChild:scoreNode];
    self.scoreLabel = scoreNode;
}


#pragma mark - enumeration over nodes
- (void)enumerateOverPlayer:(CFTimeInterval)timeSinceLast {
    [self enumerateChildNodesWithName:playerName usingBlock:^(SKNode *node, BOOL *stop) {
        if(self.player.deathDispatched) {
            self.player.position = _playerFreezePoint;
        }
    }];
}

- (void)enumerateOverForeground:(CFTimeInterval)timeSinceLast {
    [self enumerateChildNodesWithName:foregroundName usingBlock:^(SKNode *node, BOOL *stop) {
        node.position = CGPointMake(node.position.x - midgroundMoveSpeed + timeSinceLast , node.position.y);
    }];
    if(self.currentForeGround.position.x < -self.size.width + 100) {
        PBBackground *newForeground = [PBBackground foregroundNode];
        newForeground.position = CGPointMake(self.currentForeGround.position.x + self.currentForeGround.frame.size.width, self.currentForeGround.position.y);
        [self addChild:newForeground];
        self.currentForeGround = newForeground;
    }
}

- (void)enumerateOverBackground: (CFTimeInterval) timeSinceLast{
    [self enumerateChildNodesWithName:backgroundName usingBlock:^(SKNode *node, BOOL *stop) {
        node.position = CGPointMake(node.position.x - backgroundMoveSpeed + timeSinceLast, node.position.y);
        
    }];
    if (self.currentBackground.position.x < -self.size.width + 100) {
        PBBackground *newBackground = [PBBackground backgroundNode];
        newBackground.position = CGPointMake(self.currentBackground.position.x + self.currentBackground.frame.size.width, self.currentBackground.position.y);
        [self addChild:newBackground];
        self.currentBackground = newBackground;
    }
}

- (void)enumerateOverMidground:(CFTimeInterval)timeSinceLast {
    [self enumerateChildNodesWithName:midgroundName usingBlock:^(SKNode *node, BOOL *stop) {
        node.position = CGPointMake(node.position.x - midgroundMoveSpeed + timeSinceLast, node.position.y);
        
    }];
    if(self.currentMidground.position.x < -self.size.width + 500) {
        PBBackground *newParallaxBackground = [PBBackground midgroundNode];
        newParallaxBackground.position = CGPointMake(self.currentMidground.position.x + self.currentMidground.frame.size.width,self.currentMidground.position.y);
        [self addChild:newParallaxBackground];
        self.currentMidground = newParallaxBackground;
    }
}

- (void)enumerateOverMissiles:(CFTimeInterval)timeSinceLast {
    [self enumerateChildNodesWithName:missileIdentifier usingBlock:^(SKNode *node, BOOL *stop) {
        node.position = CGPointMake(node.position.x - midgroundMoveSpeed + timeSinceLast, node.position.y);
        if(node.position.x < - self.size.width) {
            [node removeFromParent];
        }
    }];
    
}

- (void)enumerateOverFences:(CFTimeInterval)timeSinceLast {
    [self enumerateChildNodesWithName:fenceIdentifier usingBlock:^(SKNode *node, BOOL *stop) {
        node.position = CGPointMake(node.position.x - midgroundMoveSpeed + timeSinceLast, node.position.y);

   
        if(node.position.x < - self.size.width) {
            [node removeFromParent];
        }
    }];
}

- (void)enumerateOverPowerUps:(CFTimeInterval)timeSinceLast {
    [self enumerateChildNodesWithName:@"powerUp" usingBlock:^(SKNode *node, BOOL *stop) {
        node.position = CGPointMake(node.position.x - midgroundMoveSpeed + timeSinceLast, node.position.y);
        if(node.position.x < - self.size.width) {
            [node removeFromParent];
        }
    }];
}

- (void)enumerateSpikePit:(CFTimeInterval)timeSinceLast {
    [self enumerateChildNodesWithName:spikePitIdentifier usingBlock:^(SKNode *node, BOOL *stop) {
        node.position = CGPointMake(node.position.x - midgroundMoveSpeed + timeSinceLast, node.position.y);
        if(node.position.x < - self.size.width) {
            [node removeFromParent];
        }
    }];
    
}

- (void)enumerateBreakingFence:(CFTimeInterval)timeSinceLast {
    [self enumerateChildNodesWithName:@"breakingFence" usingBlock:^(SKNode *node, BOOL *stop) {
        node.position = CGPointMake(node.position.x - midgroundMoveSpeed, node.position.y);

    }];
}

- (void)updateScore {
    _score += midgroundMoveSpeed/2;
    self.scoreLabel.text = [NSString stringWithFormat:@"Score : %d", _score];
}

- (void)presentGameOverScene {
    PBHighScoreObject *playerScore = [[PBHighScoreObject alloc]scoreWithDate:[PBMyScene dateToString:[NSDate date]] andScore:_score];

    PBGameOverLayer *gameOverLayer = [PBGameOverLayer gameOverLayerWithScore:playerScore];
    gameOverLayer.scaleMode = SKSceneScaleModeAspectFill;
    SKTransition *transition = [SKTransition crossFadeWithDuration:2.0];
    [self.view presentScene:gameOverLayer transition:transition];
    
}



- (void)explosionReactionAtPoint:(CGPoint)point {
    [self runAction:[self explosionSpritesAtLocation:point]];
}

#pragma mark - invulnerability convinience methods

- (void)powerDown {
    self.player.isInvulnerable = NO;
}

- (void)beginInvulnerableCounter {
    if(self.player.isInvulnerable) {
        [_powerDown invalidate];
        [_blinkRedTimer invalidate];
        _powerDown = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(powerDown) userInfo:nil repeats:NO];
        _blinkRedTimer = [NSTimer scheduledTimerWithTimeInterval:8.0 target:self selector:@selector(colorizePlayer) userInfo:nil repeats:NO];
    } else {
        NSLog(@"calling beginInvulnerableCounter without invulnerability");
    }
}
- (void)colorizePlayer {
    [self.player InvulnerableToRegular];
}
- (void)enemyDispatchTimer {

    _enemyDispatchTimer = [NSTimer scheduledTimerWithTimeInterval:1.8 target:self selector:@selector(generateRandomEnemy) userInfo:nil repeats:YES];
    [_enemyDispatchTimer fire];
}

- (void)powerUpDispatchTimer {

    int randomSeconds = 10;
    //(arc4random() % 15) + 3;
    _powerUpDispatchTimer = [NSTimer scheduledTimerWithTimeInterval:randomSeconds target:self selector:@selector(generatePowerUp) userInfo:nil repeats:YES];
}


- (void)generatePowerUp {
    [self addChild:[self powerUpInstance]];
}

- (void)generateRandomEnemy {
    int randomIndex =  arc4random() % [self.enemyTypes count];
    
#define PBTypedKeyPath(type, keyPath)
#define PBSelfKeyPath(keyPath) PBTypedKeyPath(__typeof__(self), 
    
    static NSArray *enemies = @[@"fenceInstance"];
    
    switch (randomIndex) {
        case 0:
            [self addChild:[self fenceInstance]];
            NSLog(@"fence added");
            break;
        case 1:
            [self addChild: [self missileInstance]];
            NSLog(@"missile added");
            break;
        case 2:
            [self addChild: [self spikePitInstance]];
            NSLog(@"spikePit added");
        default:
            NSLog(@"enemy not returned correctly, %d" , randomIndex);
            break;
    }
}

- (void)dealloc {
    NSLog(@"main scene getting deallocated");
}

- (NSArray *)enemyTypes {
    if(!_enemyTypes) {
        _enemyTypes = @[[NSNumber numberWithInt:enemyTypeFence] ,[NSNumber numberWithInt:enemyTypeMissle] ,[NSNumber numberWithInt:enemyTypeSpikePit] ];
    }
    return _enemyTypes;
}
@end
