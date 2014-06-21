//
//  PBGameLayer.h
//  
//
//  Created by Mac Admin on 5/19/14.
//
//

@import SpriteKit;

@interface PBGameLayer : SKScene
- (SKSpriteNode *)addButton:(NSString *)buttonName atPosition:(CGPoint)position withScale:(CGFloat)scale;
@end
