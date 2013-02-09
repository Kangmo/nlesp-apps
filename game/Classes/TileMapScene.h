//
//  HelloWorldLayer.h
//  Tilemap
//
//  Created by Steffen Itterheim on 28.08.10.
//  Copyright Steffen Itterheim 2010. All rights reserved.
//

#import "cocos2d.h"

#import "Player.h"
#import "GameKitHelper.h"

enum
{
	TileMapNode = 0,
};

typedef enum
{
	MoveDirectionNone = 0,
	MoveDirectionUpperLeft,
	MoveDirectionLowerLeft,
	MoveDirectionUpperRight,
	MoveDirectionLowerRight,
	
	MAX_MoveDirections,
} EMoveDirection;

@interface TileMapLayer : CCLayer <GameKitHelperProtocol>
{
	CGPoint playableAreaMin, playableAreaMax;

	Player* player;

	CGPoint screenCenter;
	CGRect upperLeft, lowerLeft, upperRight, lowerRight;
	CGPoint moveOffsets[MAX_MoveDirections];
	EMoveDirection currentMoveDirection;
	
	ccTime totalTime;
	
	int bogusScore;
	CGPoint previousTilePos;
    
    // ** added by Minkyoung Jang
    Player* opponent;

    uint32_t inactiveMineId;
    uint32_t activeMineId;
    uint32_t shoesId;
    uint32_t goalId;

    int speedUp;
    CCLabelAtlas *mineNumLabel;
    
    CGPoint targetPosition;
    CGPoint moveTilemapPositionOffsets[MAX_MoveDirections];
    
    UITouch* currentTouch;
    // ** end
}

+(id) scene;

@end
