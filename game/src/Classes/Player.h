//
//  Player.h
//  Tilemap
//
//  Created by Steffen Itterheim on 08.09.10.
//  Copyright 2010 Steffen Itterheim. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface Player : CCSprite 
{
    int mineNum;
    float freezeTime;
    bool shoesOn;
    CGPoint relativePosition;
    CGPoint targetPosition;
}

@property int mineNum;
@property float freezeTime;
@property bool shoesOn;
@property CGPoint relativePosition;
@property CGPoint targetPosition;

+(id) player;
+(id) opponent;
-(void) updateVertexZ:(CGPoint)tilePos tileMap:(CCTMXTiledMap*)tileMap;

@end
