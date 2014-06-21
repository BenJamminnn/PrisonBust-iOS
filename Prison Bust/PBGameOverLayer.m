//
//  PBGameOverLayer.m
//  Prison Bust
//
//  Created by Mac Admin on 4/25/14.
//  Copyright (c) 2014 Ben Gabay. All rights reserved.
//

#import "PBGameOverLayer.h"
#import "PBMyScene.h"
#import "PBGameStartScene.h"
#import "PBHighScoresScene.h"
#import "PBHighScoreObject.h"

static NSString *sceneBackgroundImageName = @"prison_break_GAME_END_clean";
static NSString *startGameButtonName = @"play_again";
static NSString *mainMenuButtonName = @"main_menu";
static NSString *yourHighScoreLabelName = @"yourscore";
static NSString *highestScoreLabelName = @"highscore";

@interface PBGameOverLayer ()

@property (strong, nonatomic) SKSpriteNode *playAgainButton;
@property (strong, nonatomic) SKSpriteNode *mainMenuButton;

@end

@implementation PBGameOverLayer

/*

*/

- (id)initWithScore:(PBHighScoreObject *)playerScore {
    if(self = [super init]) {
        [self addButton:mainMenuButtonName atPosition:CGPointMake(0.84, 0.3) withScale:0.0009];
        [self addButton:startGameButtonName atPosition:CGPointMake(0.15, 0.3) withScale:0.0009];
        [self addChild:[self addButton:yourHighScoreLabelName atPosition:CGPointMake(0.23, 0.72) withScale:0.0009]];
        [self addChild:[self addButton:highestScoreLabelName atPosition:CGPointMake(0.23, 0.65) withScale:0.0009]];
        if(playerScore) {
            self.playerScore = playerScore;
            [self postNewHighScore];
            [self addPlayerScoreNode];
            [self displayHighestScore];
        }
    }
    return self;
}


- (void)displayHighestScore {
    PBHighScoresScene *highScoreRef = [PBHighScoresScene highScoresScene];
    PBHighScoreObject *obj = [highScoreRef.highScores firstObject];
    NSInteger highestScore = obj.score;
    SKLabelNode *highestScoreLabel = [SKLabelNode labelNodeWithFontNamed:@"Verdana"];
    highestScoreLabel.position = CGPointMake(self.size.width/2, self.size.height/1.6);
    highestScoreLabel.zPosition = 50;
    highestScoreLabel.text = [NSString stringWithFormat:@" %li" , (long)highestScore];
    highestScoreLabel.fontColor = [SKColor colorWithRed:1 green:0.15 blue:0.3 alpha:1.0];
    highestScoreLabel.fontSize = 30;
    highestScoreLabel.hidden = NO;
    highestScoreLabel.xScale = 0.002;
    highestScoreLabel.yScale = 0.002;
    highestScoreLabel.name = @"highestScoreLabel";
    [self addChild:highestScoreLabel];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    //we will present a button to the user, sense if the button has been touched. if yes...
    UITouch *touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInNode:self];
    
    if ([self.playAgainButton containsPoint:touchLocation]) {
        NSLog(@"play again touched");
        [self presentGamePlayScene];
    } else if([self.mainMenuButton containsPoint:touchLocation]) {
        NSLog(@"main menu touched");
        [self presentMainMenu];
    }
}

+ (instancetype)gameOverLayerWithScore:(PBHighScoreObject *)playerScore {
    PBGameOverLayer *gameOverLayer = [[PBGameOverLayer alloc]initWithScore:playerScore];
    SKSpriteNode *backgroundImageNode = [PBGameOverLayer backgroundImage];
    backgroundImageNode.position = CGPointMake(gameOverLayer.size.width/2, gameOverLayer.size.height/2);
    [gameOverLayer addChild:backgroundImageNode];
    return gameOverLayer;
}

+ (SKSpriteNode *)backgroundImage {
    SKSpriteNode *backgroundImageNode = [[SKSpriteNode alloc]initWithImageNamed:sceneBackgroundImageName];
    backgroundImageNode.xScale = 0.0009;
    backgroundImageNode.yScale = 0.00085;
    backgroundImageNode.name = @"backgroundImage";
    return backgroundImageNode;
}

- (SKSpriteNode *)addButton:(NSString *)buttonName atPosition:(CGPoint)position withScale:(CGFloat)scale {
    SKSpriteNode *button = [SKSpriteNode spriteNodeWithImageNamed:buttonName];
    button.name = buttonName;
    button.position = position;
    button.zPosition = 8;
    if(scale > 0) {
        button.xScale = scale;
        button.yScale = scale;
    }
    
    NSLog(@"Button: %@ position: %@" , buttonName , NSStringFromCGPoint(button.position));
    if([buttonName isEqualToString:startGameButtonName]) {
        self.playAgainButton = button;
        [self addChild:self.playAgainButton];
        return nil;
    } else if([buttonName isEqualToString:mainMenuButtonName]) {
        self.mainMenuButton = button;
        [self addChild:button];
        return nil;
    }
    return button;
}

- (void)presentGamePlayScene {
    PBMyScene *newGamePlay = [[PBMyScene alloc]initWithSize:CGSizeMake(320, 568)];
    newGamePlay.scaleMode = SKSceneScaleModeAspectFill;
    [self.view presentScene:newGamePlay];
}
- (void)presentMainMenu {
    PBGameStartScene *gameStartScene = [PBGameStartScene gameStartScene];
    gameStartScene.scaleMode = SKSceneScaleModeAspectFill;
    [self.view presentScene:gameStartScene];
}

- (void)postNewHighScore {
    [[NSNotificationCenter defaultCenter]postNotificationName:@"newHighScoreAdded" object:self.playerScore];
}

- (void)addPlayerScoreNode {
    SKLabelNode *playerScoreLabelNode = [[SKLabelNode alloc]initWithFontNamed:@"Verdana"];
    playerScoreLabelNode.position = CGPointMake(self.size.width/2, self.size.height/1.43);
    playerScoreLabelNode.zPosition = 50 ;
    int score = self.playerScore.score;
    playerScoreLabelNode.text = [NSString stringWithFormat:@" %d", score];
    playerScoreLabelNode.fontColor = [SKColor colorWithRed:1 green:0.15 blue:0.3 alpha:1.0];
    playerScoreLabelNode.fontSize = 30;
    playerScoreLabelNode.hidden = NO;
    playerScoreLabelNode.xScale = 0.002;
    playerScoreLabelNode.yScale = 0.002;
    playerScoreLabelNode.name = @"playerScoreNode";
    [self addChild:playerScoreLabelNode];
    NSLog(@"player score label added");
    NSLog(@"score label location: %@" , NSStringFromCGPoint(playerScoreLabelNode.position));
}
@end
