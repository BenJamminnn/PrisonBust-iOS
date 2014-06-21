//
//  PBGameStartScene.m
//  Prison Bust
//
//  Created by Mac Admin on 5/1/14.
//  Copyright (c) 2014 Ben Gabay. All rights reserved.
//

#import "PBGameStartScene.h"
#import "PBMyScene.h"
#import "PBHighScoresScene.h"

static NSString *backgroundImageName = @"prison_break_GAME_MAIN_clean";
static NSString *gameStartButtonImageName = @"prison_break_start_button";
static NSString *highScoreButtonImageName = @"prison_break_highscores";
static NSString *prisonBustLabelName = @"prisonbust";

@interface PBGameStartScene ()
@property (strong, nonatomic) SKSpriteNode *startGameButton;
@property (strong, nonatomic) SKSpriteNode *highScoresButton;
@end

@implementation PBGameStartScene

- (id)init{
    if(self = [super init]) {
        [self addButton:highScoreButtonImageName atPosition:CGPointMake(0.54,0.28) withScale:0.002];
        [self addButton:gameStartButtonImageName atPosition:CGPointMake(0.54, 0.38) withScale:0.002];
        [self addChild:[self addButton:prisonBustLabelName atPosition:CGPointMake(0.5, 0.7) withScale:0.002]];
        
    }
    return self;
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInNode:self];
    
    if ([self.highScoresButton containsPoint:touchLocation]) {
        NSLog(@"high score touched");
        [self presentHighScoresScene];
    } else if([self.startGameButton containsPoint:touchLocation]) {
        NSLog(@"start game button touched");
        [self presentGamePlayScene];
    }
}

+ (instancetype)gameStartScene{
    PBGameStartScene *gameStartScene = [PBGameStartScene new];
    SKSpriteNode *backgroundImageNode = [PBGameStartScene backgroundImage];
    backgroundImageNode.position = CGPointMake(backgroundImageNode.size.width/2, backgroundImageNode.size.height/2 + 0.22);
    [gameStartScene addChild:backgroundImageNode];
    return gameStartScene;
}

+ (SKSpriteNode *)backgroundImage {
    SKSpriteNode *backgroundSpriteNode = [SKSpriteNode spriteNodeWithImageNamed:backgroundImageName];
//    backgroundSpriteNode.anchorPoint = CGPointMake(backgroundSpriteNode.size.width/2, backgroundSpriteNode.size.height/2);
    backgroundSpriteNode.xScale = 0.00088;
    backgroundSpriteNode.yScale = 0.00088;
    return backgroundSpriteNode;
}

- (SKSpriteNode *)addButton:(NSString *)buttonName atPosition:(CGPoint)position withScale:(CGFloat)scale{
    SKSpriteNode *button = [SKSpriteNode spriteNodeWithImageNamed:buttonName];
    button.position = position;
    button.zPosition = 10;
    if(scale > 0) {
        button.xScale = scale;
        button.yScale = scale;
    }
    if([buttonName isEqualToString:gameStartButtonImageName]) {
        self.startGameButton = button;
        [self addChild:self.startGameButton];
    } else if([buttonName isEqualToString:highScoreButtonImageName]) {
        self.highScoresButton = button;
        [self addChild:self.highScoresButton];
    }
    
    return button;
    
}

- (void)presentHighScoresScene {
    PBHighScoresScene *highScoresScene = [PBHighScoresScene highScoresScene];
    highScoresScene.scaleMode = SKSceneScaleModeAspectFill;
    [self.view presentScene:highScoresScene];
}

- (void)presentGamePlayScene {
    PBMyScene *newGamePlay = [PBMyScene sceneWithSize:CGSizeMake(320, 568)];
    newGamePlay.scaleMode = SKSceneScaleModeAspectFill;
    [self.view presentScene:newGamePlay];
}

@end
