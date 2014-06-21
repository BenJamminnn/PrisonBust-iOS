//
//  PBViewController.m
//  Prison Bust
//
//  Created by Mac Admin on 4/23/14.
//  Copyright (c) 2014 Ben Gabay. All rights reserved.
//

#import "PBViewController.h"
#import "PBMyScene.h"
#import "PBGameOverLayer.h"
#import "PBGameStartScene.h"
@implementation PBViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Configure the view.
    SKView * skView = (SKView *)self.view;
    skView.showsFPS = YES;
    skView.showsNodeCount = YES;
 //   skView.showsPhysics = YES;
    // Create and configure the scene.
    SKScene * scene = [PBGameStartScene gameStartScene];
    //SKScene *scene = [PBGameStartScene gameStartScene];
   // PBMyScene *sceneGame = [[PBMyScene alloc]initWithSize:skView.frame.size];
    //PBGameOverLayer *scene = [PBGameOverLayer gameOverLayer];
    scene.scaleMode = SKSceneScaleModeAspectFill;
    // Present the scene.
    [skView presentScene:scene];
    
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

@end
