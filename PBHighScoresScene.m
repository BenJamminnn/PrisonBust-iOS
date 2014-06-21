
//
//  PBHighScoresScene.m
//  Prison Bust
//
//  Created by Mac Admin on 5/19/14.
//  Copyright (c) 2014 Ben Gabay. All rights reserved.
//

#import "PBHighScoresScene.h"
#import "PBGameStartScene.h"
#import "PBHighScoreObject.h"

static NSString *highScoresButtonName = @"prison_break_highscores";
static NSString *mainMenuButtonName = @"main_menu";
static NSString *highScoresBackgroundNodeName = @"prison_break_GAME_Highscores";
@interface PBHighScoresScene ()
@property (strong, nonatomic, readwrite) NSMutableArray *highScores;
@end
@implementation PBHighScoresScene {
    SKSpriteNode *_mainMenuButton;
}

- (id)init {
    if(self = [super init]) {
        [self listenForNewScore];
        [self addMainMenuButton];
        self.highScores = [self loadScores];
        self.highScores = [PBHighScoreObject compareHighScores:self.highScores];
        [self presentScores:self.highScores];
      //  [self addChild:[self highScoresLabel]];
        
    }
    return self;
}

+ (instancetype)highScoresScene {
    PBHighScoresScene *highScoresScene = [PBHighScoresScene new];
    SKSpriteNode *backgroundImageNode = [PBHighScoresScene backgroundImageNode];
    backgroundImageNode.position = CGPointMake(0.5, 0.5);
    [highScoresScene addChild:backgroundImageNode];
    
    return highScoresScene;
}

+ (SKSpriteNode *)backgroundImageNode {
    SKSpriteNode *backgroundImageNode = [SKSpriteNode spriteNodeWithImageNamed:highScoresBackgroundNodeName];
    backgroundImageNode.xScale = 0.001;
    backgroundImageNode.yScale = 0.001;
    return backgroundImageNode;
}

- (void)addMainMenuButton {
    SKSpriteNode *mainMenuButton = [SKSpriteNode spriteNodeWithImageNamed:mainMenuButtonName];
    mainMenuButton.position = CGPointMake(0.5, 0.28);
    mainMenuButton.xScale = 0.0008;
    mainMenuButton.yScale = 0.0008;
    mainMenuButton.zPosition = 10;
    mainMenuButton.alpha = 0.8;
    _mainMenuButton = mainMenuButton;
    [self addChild:mainMenuButton];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event    {
    UITouch *touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInNode:self];
    
    if([_mainMenuButton containsPoint:touchLocation]) {
        NSLog(@"main menu pressed");
        [self presentMainMenu];
    }
}

- (void)presentMainMenu {
    PBGameStartScene *gameStartScene = [PBGameStartScene gameStartScene];
    gameStartScene.scaleMode = SKSceneScaleModeAspectFill;
    [self.view presentScene:gameStartScene];
}

- (void)presentScores:(NSMutableArray *)scoresArray {
    
    if(scoresArray.count < 6) {
        for(int i = 0; i < scoresArray.count; i++) {
            SKLabelNode *scoreLabel = [SKLabelNode labelNodeWithFontNamed:@"EuphemiaUCAS-Bold"];
            scoreLabel.text = [NSString stringWithFormat:@"%@" , scoresArray[i]];
            scoreLabel.position = CGPointMake(0.5, 0.65 - (i * .07));
            scoreLabel.xScale = 0.001;
            scoreLabel.yScale = 0.001;
            scoreLabel.zPosition = 11;
            [self addChild:scoreLabel];
        }
    } else {
        scoresArray = [PBHighScoreObject compareHighScores:scoresArray];
        [self presentScores:scoresArray];
    }
}

- (void)addHighScore:(PBHighScoreObject *)highScoreObj {
    [self.highScores addObject:highScoreObj];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *highScoreData = [NSKeyedArchiver archivedDataWithRootObject:self.highScores];
    [defaults setObject:highScoreData forKey:@"highScores"];
    [defaults synchronize];
}

- (NSMutableArray *)loadScores {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *scoreData = [defaults objectForKey:@"highScores"];
    NSMutableArray *scoreArr = [NSMutableArray arrayWithArray:[NSKeyedUnarchiver unarchiveObjectWithData:scoreData]];
    return scoreArr;
}

- (SKSpriteNode *)highScoresLabel {
    SKSpriteNode *highScoresNode = [SKSpriteNode spriteNodeWithImageNamed:highScoresButtonName];
    highScoresNode.position = CGPointMake(0.5, 0.75);
    highScoresNode.xScale = 0.001;
    highScoresNode.yScale = 0.0009;
    highScoresNode.zPosition = 11;
    highScoresNode.name = @"highScoreNode";
    return highScoresNode;
}


- (void)listenForNewScore {
    NSNotificationCenter *notifyCenter = [NSNotificationCenter defaultCenter];
    [notifyCenter addObserverForName:@"newHighScoreAdded" object:nil queue:nil usingBlock:^(NSNotification *note) {
        [self addHighScore:note.object];
    }];
}

#pragma mark - lazy loading

- (NSMutableArray *)highScores  {
    if (!_highScores) {
        _highScores = [NSMutableArray array];
    }
    return _highScores;
}

@end
