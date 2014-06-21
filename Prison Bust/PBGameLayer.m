//
//  PBGameLayer.m
//  
//
//  Created by Mac Admin on 5/19/14.
//
//
#import "PBGameLayer.h"

@implementation PBGameLayer
- (SKSpriteNode *)addButton:(NSString *)buttonName atPosition:(CGPoint)position withScale:(CGFloat)scale {
    SKSpriteNode *button = [SKSpriteNode spriteNodeWithImageNamed:buttonName];
    button.position = position;
    button.zPosition = 8;
    if(scale > 0) {
        button.xScale = scale;
        button.yScale = scale;
    }
    return button;
}
@end
