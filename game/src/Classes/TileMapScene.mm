//
//  HelloWorldLayer.m
//  Tilemap
//
//  Created by Steffen Itterheim on 28.08.10.
//  Copyright Steffen Itterheim 2010. All rights reserved.
//

#import "TileMapScene.h"
#import "Player.h"

#import "NetworkPackets.h"
#import "SimpleAudioEngine.h"


@interface TileMapLayer (PrivateMethods)
-(CGPoint) tilePosFromLocation:(CGPoint)location tileMap:(CCTMXTiledMap*)tileMap;
-(void) centerTileMapOnTileCoord:(CGPoint)tilePos tileMap:(CCTMXTiledMap*)tileMap;

- (bool)hasGoalAt:(CGPoint)tilePos tileMap:(CCTMXTiledMap *)tileMap;
- (bool)hasInactiveMineAt:(CGPoint)tilePos tileMap:(CCTMXTiledMap *)tileMap;
- (bool)hasActiveMineAt:(CGPoint)tilePos tileMap:(CCTMXTiledMap *)tileMap;
- (bool)hasShoesAt:(CGPoint)tilePos tileMap:(CCTMXTiledMap *)tileMap; 
- (void)setItemIds;

- (void)removeItemAt:(CGPoint)tilePos;

@end


@implementation TileMapLayer

+(id) scene
{
	CCScene *scene = [CCScene node];
	TileMapLayer *layer = [TileMapLayer node];
	[scene addChild: layer];
	return scene;
}

-(id) init
{
	if ((self = [super init]))
	{
		GameKitHelper& gkHelper = GameKitHelper::sharedGameKitHelper();

        gkHelper.delegate(self);
        
        gkHelper.authenticateLocalPlayer();
		
		CCTMXTiledMap* tileMap = [CCTMXTiledMap tiledMapWithTMXFile:@"isometric-with-border.tmx"];
		//CCTMXTiledMap* tileMap = [CCTMXTiledMap tiledMapWithTMXFile:@"map.tmx"];
		[self addChild:tileMap z:-1 tag:TileMapNode];
		
		CCTMXLayer* layer = [tileMap layerNamed:@"Collisions"];
		layer.visible = NO;
        		
		// Use a negative offset to set the tilemap's start position
		tileMap.position = CGPointMake(-500, -500);
        targetPosition = CGPointMake(-500, -500);
        
		self.isTouchEnabled = YES;

		// define the extents of the playable area in tile coordinates
		const int borderSize = 10;
		playableAreaMin = CGPointMake(borderSize, borderSize);
		playableAreaMax = CGPointMake(tileMap.mapSize.width - 1 - borderSize, tileMap.mapSize.height - 1 - borderSize);
		
		CGSize screenSize = [[CCDirector sharedDirector] winSize];
		
		// Create the player and add it
		player = [Player player];
		player.position = CGPointMake(screenSize.width / 2, screenSize.height / 2);
		// approximately position player's texture to best match the tile center position
		player.anchorPoint = CGPointMake(0.3f, 0.1f);
        player.relativePosition = CGPointMake(0, 0);
		[self addChild:player];
        
        // create and add the opponent
        opponent = [Player opponent];
        opponent.position = CGPointMake(screenSize.width / 2, screenSize.height / 2);
        opponent.anchorPoint = CGPointMake(0.3f, 0.1f);
        opponent.relativePosition = CGPointMake(0, 0);
        opponent.targetPosition = CGPointMake(0, 0);
        [self addChild:opponent];
        
        // create and add the mine button
        CCMenuItemImage *mineButton = [CCMenuItemImage itemFromNormalImage:@"bomb64.png" selectedImage:@"bomb64.png" target:self selector:@selector(mineButtonPressed:)];
        CCMenu* menu = [CCMenu menuWithItems:mineButton, nil];
        menu.position = CGPointMake(screenSize.width - 30, 30);
        [self addChild:menu];
        
        // create and add the mine number label
        mineNumLabel = [[CCLabelAtlas labelWithString:@"0" charMapFile:@"fps_images.png" itemWidth:16 itemHeight:24 startCharMap:'.'] retain];
        mineNumLabel.position = CGPointMake(20,10);
        [mineButton addChild:mineNumLabel];

        // init item IDs
        [self setItemIds];
        
        // how much faster when shoes on
        speedUp = 2;
        
		// divide the screen into 4 areas
		screenCenter = CGPointMake(screenSize.width / 2, screenSize.height / 2);
		upperLeft = CGRectMake(0, screenCenter.y, screenCenter.x, screenCenter.y);
		lowerLeft = CGRectMake(0, 0, screenCenter.x, screenCenter.y);
		upperRight = CGRectMake(screenCenter.x, screenCenter.y, screenCenter.x, screenCenter.y);
		lowerRight = CGRectMake(screenCenter.x, 0, screenCenter.x, screenCenter.y);

		// to move in any of these directions means to add/subtract 1 to/from the current tile coordinate
		moveOffsets[MoveDirectionNone] = CGPointZero;
		moveOffsets[MoveDirectionUpperLeft] = CGPointMake(-1, 0);
		moveOffsets[MoveDirectionLowerLeft] = CGPointMake(0, 1);
		moveOffsets[MoveDirectionUpperRight] = CGPointMake(0, -1);
		moveOffsets[MoveDirectionLowerRight] = CGPointMake(1, 0);

		currentMoveDirection = MoveDirectionNone;
        
		moveTilemapPositionOffsets[MoveDirectionNone] = CGPointZero;
		moveTilemapPositionOffsets[MoveDirectionUpperLeft] = CGPointMake(26, -13);
		moveTilemapPositionOffsets[MoveDirectionLowerLeft] = CGPointMake(26, 13);
		moveTilemapPositionOffsets[MoveDirectionUpperRight] = CGPointMake(-26, -13);
		moveTilemapPositionOffsets[MoveDirectionLowerRight] = CGPointMake(-26, 13);
        
		
		// continuously check for walking
		[self scheduleUpdate];
	}

	return self;
}

-(void) dealloc
{
	[super dealloc];
}

#pragma mark GameKitHelper delegate methods
-(void) onLocalPlayerAuthenticationChanged
{
	VKLocalPlayer * localPlayer = VKLocalPlayer::localPlayer();
	CCLOG(@"LocalPlayer isAuthenticated changed to: %@", localPlayer->authenticated() ? @"YES" : @"NO");
	
	if (localPlayer->authenticated())
	{
        GameKitHelper& gkHelper = GameKitHelper::sharedGameKitHelper();
		gkHelper.getLocalPlayerFriends();
		//[gkHelper resetAchievements];
	}	
}

-(void) onFriendListReceived:(const TxStringArray &)friends
{
    // comment by MKJANG
    // to remove build error
    /*
	CCLOG(@"onFriendListReceived: %s", friends.toString().c_str());

    GameKitHelper& gkHelper = GameKitHelper::sharedGameKitHelper();
	gkHelper.getPlayerInfo(friends);
     */
}

-(void) onPlayerInfoReceived:(const TxStringArray &)players
{
//	CCLOG(@"onPlayerInfoReceived: %s", players.toString().c_str());
    
    GameKitHelper& gkHelper = GameKitHelper::sharedGameKitHelper();

    /*
    // Not supported Yet on R0
	[gkHelper submitScore:1234 category:@"Playtime"];
	*/
     
	//[gkHelper showLeaderboard];
	
	VKMatchRequest request;
	request.minPlayers(2);
	request.maxPlayers(4);
	
	//GameKitHelper* gkHelper = [GameKitHelper sharedGameKitHelper];
    
    
    /*
     // Not supported Yet on R0
	[gkHelper showMatchmakerWithRequest:request];
     */
    // BUGBUG : Not tested yet.
    gkHelper.findMatch(request);

    // comment by MKJANG
    // to remove build error
//    gkHelper.queryMatchmakingActivity();
}

/* 
    // Not supported on R0
-(void) onScoresSubmitted:(bool)success
{
	CCLOG(@"onScoresSubmitted: %@", success ? @"YES" : @"NO");
}

-(void) onScoresReceived:(NSArray*)scores
{
	CCLOG(@"onScoresReceived: %@", [scores description]);
}

-(void) onAchievementReported:(GKAchievement*)achievement
{
	CCLOG(@"onAchievementReported: %@", achievement);
}

-(void) onAchievementsLoaded:(NSDictionary*)achievements
{
	CCLOG(@"onLocalPlayerAchievementsLoaded: %@", [achievements description]);
}

-(void) onResetAchievements:(bool)success
{
	CCLOG(@"onResetAchievements: %@", success ? @"YES" : @"NO");
}

-(void) onLeaderboardViewDismissed
{
	CCLOG(@"onLeaderboardViewDismissed");
}

-(void) onAchievementsViewDismissed
{
	CCLOG(@"onAchievementsViewDismissed");
}
*/
-(void) onReceivedMatchmakingActivity:(int)activity
{
	CCLOG(@"receivedMatchmakingActivity: %i", activity);
}

-(void) onMatchFound:(VKMatch*)match
{
	CCLOG(@"onMatchFound: %x", match);
}

-(void) onPlayersAddedToMatch:(bool)success
{
	CCLOG(@"onPlayersAddedToMatch: %@", success ? @"YES" : @"NO");
}

-(void) onMatchmakingViewDismissed
{
	CCLOG(@"onMatchmakingViewDismissed");
}
-(void) onMatchmakingViewError
{
	CCLOG(@"onMatchmakingViewError");
}

-(void) onPlayerConnected:(const TxString &)playerID
{
	CCLOG(@"onPlayerConnected: %s", playerID.c_str());
}

-(void) onPlayerDisconnected:(const TxString &)playerID
{
	CCLOG(@"onPlayerDisconnected: %s", playerID.c_str());
}

-(void) onStartMatch
{
	CCLOG(@"onStartMatch");
}

// TM16: handles receiving of data, determines packet type and based on that executes certain code
-(void) onReceivedData:(const TxData &)data fromPlayer:(const TxString &)playerID
{
	SBasePacket* basePacket = (SBasePacket*) data.bytes();
//	CCLOG(@"onReceivedData: %s fromPlayer: %s - Packet type: %i", data.toString().c_str(), playerID.c_str(), basePacket->type);
	
    if (playerID != VKLocalPlayer::localPlayer()->playerID())
    {
        switch (basePacket->type)
        {
            case kPacketTypeScore:
            {
                SScorePacket* scorePacket = (SScorePacket*)basePacket;
                CCLOG(@"\tscore = %i", scorePacket->score);
                break;
            }

            case kPacketTypePosition:
            {
                SPositionPacket* positionPacket = (SPositionPacket*)basePacket;
                CCLOG(@"\tposition = (%.1f, %.1f)", positionPacket->position.x, positionPacket->position.y);
                
                opponent.targetPosition = ccpMult(positionPacket->position, -1.0);
                break;
            }

            case kPacketTypeItem:
            {
                SItemPacket *itemPacket = (SItemPacket *)basePacket;
                switch (itemPacket->itemType) {
                    case kItemTypeMine:
                    {
                        switch (itemPacket->actionType)
                        {
                            case kActionTypeMineGet:
                            case kActionTypeMineStepOn:
                            {
                                [self removeItemAt:itemPacket->position];
                                break;
                            }
                            case kActionTypeMinePut:
                            {
                                [self putMineAt:itemPacket->position];
                                break;
                            }
                            default:
                            {
                                NSAssert1(NO, @"unknown mine action type: %d", itemPacket->actionType);
                                break;
                            }
                        }
                        break;
                    }
                        
                    case kItemTypeShoes:
                    {
                        switch (itemPacket->actionType) {
                            case kActionTypeShoesGet:
                            {
                                [self removeItemAt:itemPacket->position];
                                break;
                            }
                            case kActionTypeShoesOn:
                            {
                                break;
                            }
                            case kActionTypeShoesOff:
                            {
                                break;
                            }
                            default:
                            {
                                NSAssert1(NO, @"unknown shoes action type: %d", itemPacket->actionType);
                                break;
                            }
                        }
                        break;
                    }
                        
                    default:
                    {
                        NSAssert1(NO, @"unknown item type: %d", itemPacket->itemType);
                        break;
                    }
                }
                break;
            }
                
            case kPacketTypeEvent:
            {
                
                break;
            }
                
            default:
                CCLOG(@"unknown packet type %i", basePacket->type);
                break;
        }
    }
}

// TM16: send a bogus score (simply an integer increased every time it is sent)
-(void) sendScore
{
	if (GameKitHelper::sharedGameKitHelper().currentMatch() != NULL)
	{
		bogusScore++;
		
		SScorePacket packet;
		packet.type = kPacketTypeScore;
		packet.score = bogusScore;
		
		GameKitHelper::sharedGameKitHelper().sendDataToAllPlayers(&packet, sizeof(packet));
	}
}

// TM16: send a tile coordinate
-(void) sendPosition:(CGPoint)tilePos
{
    if (GameKitHelper::sharedGameKitHelper().currentMatch() != NULL)
	{
		SPositionPacket packet;
		packet.type = kPacketTypePosition;
		packet.position = tilePos;
		
		GameKitHelper::sharedGameKitHelper().sendDataToAllPlayers(&packet, sizeof(packet));
	}
}

- (void)sendItemPacket:(EItemTypes)itemType withAction:(EActionTypes)actionType withPosition:(CGPoint)position
{
    if (GameKitHelper::sharedGameKitHelper().currentMatch() != NULL)
    {
        SItemPacket packet;
        packet.type = kPacketTypeItem;
        packet.itemType = itemType;
        packet.actionType = actionType;
        packet.position = position;
        
        GameKitHelper::sharedGameKitHelper().sendDataToAllPlayers(&packet, sizeof(packet));
    }
}

- (void)sendEventPacket:(EEventTypes)eventType
{
    if (GameKitHelper::sharedGameKitHelper().currentMatch() != NULL)
    {
        SEventPacket packet;
        packet.type = kPacketTypeEvent;
        packet.eventType = eventType;
        
        GameKitHelper::sharedGameKitHelper().sendDataToAllPlayers(&packet, sizeof(packet));
    }
}

#pragma mark methods from previous chapters

-(CGPoint) locationFromTouch:(UITouch*)touch
{
	CGPoint touchLocation = [touch locationInView: [touch view]];
	return [[CCDirector sharedDirector] convertToGL:touchLocation];
}

-(CGPoint) locationFromTouches:(NSSet*)touches
{
	return [self locationFromTouch:[touches anyObject]];
}

-(bool) isTilePosBlocked:(CGPoint)tilePos tileMap:(CCTMXTiledMap*)tileMap
{
	CCTMXLayer* layer = [tileMap layerNamed:@"Collisions"];
	NSAssert(layer != nil, @"Collisions layer not found!");
	
	bool isBlocked = NO;
	unsigned int tileGID = [layer tileGIDAt:tilePos];
	if (tileGID > 0)
	{
		NSDictionary* tileProperties = [tileMap propertiesForGID:tileGID];
		id blocks_movement = [tileProperties objectForKey:@"blocks_movement"];
		isBlocked = (blocks_movement != nil);
	}

	return isBlocked;
}

- (bool)hasGoalAt:(CGPoint)tilePos tileMap:(CCTMXTiledMap *)tileMap
{
    CCTMXLayer *layer = [tileMap layerNamed:@"Objects"];
    NSAssert(layer != nil, @"Objects layer not found!");
    
    bool hasItem = NO;
    unsigned int tileGID = [layer tileGIDAt:tilePos];
    
    if (tileGID == goalId)
    {
        hasItem = YES;
    }
    
    /*
     if (tileGID > 0)
     {
     NSDictionary *tileProperties = [tileMap propertiesForGID:tileGID];
     id property = [tileProperties objectForKey:@"goal"];
     hasItem = (property != nil);
     }
     */
    return hasItem;
 
}

- (bool)hasInactiveMineAt:(CGPoint)tilePos tileMap:(CCTMXTiledMap*)tileMap
{
    CCTMXLayer *layer = [tileMap layerNamed:@"Objects"];
    NSAssert(layer != nil, @"Objects layer not found!");
                           
    bool hasItem = NO;
    unsigned int tileGID = [layer tileGIDAt:tilePos];

    if (tileGID == inactiveMineId)
    {
        hasItem = YES;
    }

/*
    if (tileGID > 0)
    {
        NSDictionary *tileProperties = [tileMap propertiesForGID:tileGID];
        id property = [tileProperties objectForKey:@"inactiveMine"];
        hasItem = (property != nil);
    }
*/
    return hasItem;
}

- (bool)hasActiveMineAt:(CGPoint)tilePos tileMap:(CCTMXTiledMap*)tileMap
{
    CCTMXLayer *layer = [tileMap layerNamed:@"Objects"];
    NSAssert(layer != nil, @"Objects layer not found!");
    
    bool hasItem = NO;
    unsigned int tileGID = [layer tileGIDAt:tilePos];
    
    if (tileGID == activeMineId)
    {
        hasItem = YES;
    }
    
    /*
     if (tileGID > 0)
     {
     NSDictionary *tileProperties = [tileMap propertiesForGID:tileGID];
     id property = [tileProperties objectForKey:@"activeMine"];
     hasItem = (property != nil);
     }
     */
    return hasItem;
}

- (bool)hasShoesAt:(CGPoint)tilePos tileMap:(CCTMXTiledMap*)tileMap
{
    CCTMXLayer *layer = [tileMap layerNamed:@"Objects"];
    NSAssert(layer != nil, @"Objects layer not found!");
    
    bool hasItem = NO;
    unsigned int tileGID = [layer tileGIDAt:tilePos];
    
    if (tileGID == shoesId)
    {
        hasItem = YES;
    }
    
    /*
     if (tileGID > 0)
     {
     NSDictionary *tileProperties = [tileMap propertiesForGID:tileGID];
     id property = [tileProperties objectForKey:@"shoes"];
     hasItem = (property != nil);
     }
     */
    return hasItem;
}

- (void)removeItemAt:(CGPoint)tilePos
{
    CCNode* node = [self getChildByTag:TileMapNode];
    NSAssert([node isKindOfClass:[CCTMXTiledMap class]], @"not a CCTMXTiledMap");
    CCTMXTiledMap* tileMap = (CCTMXTiledMap*)node;
 
    CCTMXLayer *layer = [tileMap layerNamed:@"Objects"];
    NSAssert(layer != nil, @"Objects layer not found!");
    [layer removeTileAt:tilePos];
}

-(CGPoint) ensureTilePosIsWithinBounds:(CGPoint)tilePos
{
	// make sure coordinates are within bounds of the playable area
	tilePos.x = MAX(playableAreaMin.x, tilePos.x);
	tilePos.x = MIN(playableAreaMax.x, tilePos.x);
	tilePos.y = MAX(playableAreaMin.y, tilePos.y);
	tilePos.y = MIN(playableAreaMax.y, tilePos.y);

	return tilePos;
}

-(CGPoint) floatingTilePosFromLocation:(CGPoint)location tileMap:(CCTMXTiledMap*)tileMap
{
	// Tilemap position must be added as an offset, in case the tilemap position is not at 0,0 due to scrolling
	CGPoint pos = ccpSub(location, tileMap.position);
	
	float halfMapWidth = tileMap.mapSize.width * 0.5f;
	float mapHeight = tileMap.mapSize.height;
	float tileWidth = tileMap.tileSize.width;
	float tileHeight = tileMap.tileSize.height;
	
	CGPoint tilePosDiv = CGPointMake(pos.x / tileWidth, pos.y / tileHeight);
	float mapHeightDiff = mapHeight - tilePosDiv.y;
	
	// Cast to int makes sure that result is in whole numbers, tile coordinates will be used as array indices
	float posX = (mapHeightDiff + tilePosDiv.x - halfMapWidth);
	float posY = (mapHeightDiff - tilePosDiv.x + halfMapWidth);

	return CGPointMake(posX, posY);
}

-(CGPoint) tilePosFromLocation:(CGPoint)location tileMap:(CCTMXTiledMap*)tileMap
{
	CGPoint pos = [self floatingTilePosFromLocation:location tileMap:tileMap];

	// make sure coordinates are within bounds of the playable area, and cast to int
	pos = [self ensureTilePosIsWithinBounds:CGPointMake((int)pos.x, (int)pos.y)];
	
	//CCLOG(@"touch at (%.0f, %.0f) is at tileCoord (%i, %i)", location.x, location.y, (int)pos.x, (int)pos.y);
	
	return pos;
}

-(void) centerTileMapOnTileCoord:(CGPoint)tilePos tileMap:(CCTMXTiledMap*)tileMap
{
	// get the ground layer
	CCTMXLayer* layer = [tileMap layerNamed:@"Ground"];
	NSAssert(layer != nil, @"Ground layer not found!");

	// internally tile Y coordinates seem to be off by 1, this fixes the returned pixel coordinates
	tilePos.y -= 1;
	
	// get the pixel coordinates for a tile at these coordinates
	CGPoint scrollPosition = [layer positionAt:tilePos];
	// negate the position for scrolling
	scrollPosition = ccpMult(scrollPosition, -1);
	// add offset to screen center
	scrollPosition = ccpAdd(scrollPosition, screenCenter);
	
	CCLOG(@"tilePos: (%i, %i) moveTo: (%.0f, %.0f)", (int)tilePos.x, (int)tilePos.y, scrollPosition.x, scrollPosition.y);
	
	CCAction* move = [CCMoveTo actionWithDuration:0.2f position:scrollPosition];
	[tileMap stopAllActions];
	[tileMap runAction:move];
}

-(void) ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	// get the position in tile coordinates from the touch location
	CGPoint touchLocation = [self locationFromTouches:touches];
	// check on which screen quadrant the touch was and set the move direction accordingly
	if (CGRectContainsPoint(upperLeft, touchLocation))
	{
		currentMoveDirection = MoveDirectionUpperLeft;
	}
	else if (CGRectContainsPoint(lowerLeft, touchLocation))
	{
		currentMoveDirection = MoveDirectionLowerLeft;
	}
	else if (CGRectContainsPoint(upperRight, touchLocation))
	{
		currentMoveDirection = MoveDirectionUpperRight;
	}
	else if (CGRectContainsPoint(lowerRight, touchLocation))
	{
		currentMoveDirection = MoveDirectionLowerRight;
	}
    
    currentTouch = [[touches anyObject] retain];
}

-(void) ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (currentTouch == [touches anyObject])
    {
        currentMoveDirection = MoveDirectionNone;
        [currentTouch release];
        currentTouch = nil;
    }
}

- (void)putMineAt:(CGPoint)tilePos
{
    CCNode* node = [self getChildByTag:TileMapNode];
    NSAssert([node isKindOfClass:[CCTMXTiledMap class]], @"not a CCTMXTiledMap");
    CCTMXTiledMap* tileMap = (CCTMXTiledMap*)node;
    CCTMXLayer *layer = [tileMap layerNamed:@"Objects"];
    NSAssert(layer != nil, @"Objects layer not found!");

    [layer setTileGID:activeMineId at:tilePos];
}

-(void) mineButtonPressed:(id)sender
{
    if (player.mineNum > 0)
    {
        CCNode* node = [self getChildByTag:TileMapNode];
        NSAssert([node isKindOfClass:[CCTMXTiledMap class]], @"not a CCTMXTiledMap");
        CCTMXTiledMap* tileMap = (CCTMXTiledMap*)node;
 
        CGPoint tilePos = [self tilePosFromLocation:screenCenter tileMap:tileMap];
        if (![self hasInactiveMineAt:tilePos tileMap:tileMap] &&
            ![self hasActiveMineAt:tilePos tileMap:tileMap] &&
            ![self hasShoesAt:tilePos tileMap:tileMap])
        {
            [self putMineAt:tilePos];
            player.mineNum--;
            [mineNumLabel setString:[NSString stringWithFormat:@"%d", player.mineNum]];
            
            // send item packet
            [self sendItemPacket:kItemTypeMine withAction:kActionTypeMinePut withPosition:tilePos];
        }
    }
}

-(void) update:(ccTime)delta
{
    static int sendPositionCount = 0;
    
    if (player.freezeTime > 0)
    {
        player.freezeTime -= delta;
        if (player.freezeTime < 0)
        {
            player.freezeTime = 0;
        }
    }
    else 
    { 
        CCNode* node = [self getChildByTag:TileMapNode];
        NSAssert([node isKindOfClass:[CCTMXTiledMap class]], @"not a CCTMXTiledMap");
        CCTMXTiledMap* tileMap = (CCTMXTiledMap*)node;
        
        // if the tilemap is currently being moved, wait until it's done moving
        if (ccpDistance(tileMap.position, targetPosition) <= 0)
        {
            if (currentMoveDirection != MoveDirectionNone)
            {
                // player is always standing on the tile which is centered on the screen
                CGPoint currentTilePos = [self tilePosFromLocation:screenCenter tileMap:tileMap];
                
                // get the tile coordinate offset for the direction we're moving to
                NSAssert(currentMoveDirection < MAX_MoveDirections, @"invalid move direction!");
                CGPoint offset = moveOffsets[currentMoveDirection];
                
                // offset the tile position and then make sure it's within bounds of the playable area
                CGPoint tilePos = CGPointMake(currentTilePos.x + offset.x, currentTilePos.y + offset.y);
                tilePos = [self ensureTilePosIsWithinBounds:tilePos];
                
                // if player can move
                if ((ccpDistance(currentTilePos, tilePos) > 0) &&
                    ([self isTilePosBlocked:tilePos tileMap:tileMap] == NO))
                {
                    if ([self hasGoalAt:tilePos tileMap:tileMap])
                    {
                        CCSprite *clear = [[[CCSprite alloc] initWithFile:@"clear.png"] autorelease];
                        
                        CGSize screenSize = [[CCDirector sharedDirector] winSize];
                        clear.position = CGPointMake(screenSize.width / 2, screenSize.height / 2);
                        //[self addChild:clear];
                        
                        // send event packet
                        [self sendEventPacket:kEventTypeAtGoal];
                    }
                    else if ([self hasInactiveMineAt:tilePos tileMap:tileMap])
                    {
                        // remove inactive mine
                        [self removeItemAt:tilePos];
                        
                        // decrease mine num
                        player.mineNum++;
                        [mineNumLabel setString:[NSString stringWithFormat:@"%d", player.mineNum]];
                        
                        // send item packet
                        [self sendItemPacket:kItemTypeMine withAction:kActionTypeMineGet withPosition:tilePos];
                    }
                    else if ([self hasActiveMineAt:tilePos tileMap:tileMap])
                    {
                        // remove active mine
                        [self removeItemAt:tilePos];
                        
                        // play sound
                        [[SimpleAudioEngine sharedEngine] playEffect:@"808_120bpm.wav"];
                        
                        // freeze player for 3 seconds
                        CCBlink *blinkAction = [CCBlink actionWithDuration:3.0 blinks:10];
                        [player runAction:blinkAction];
                        player.freezeTime = 3.0;
                        
                        // send item packet
                        [self sendItemPacket:kItemTypeMine withAction:kActionTypeMineStepOn withPosition:tilePos];
                    }
                    else if ([self hasShoesAt:tilePos tileMap:tileMap])
                    {
                        player.shoesOn = YES;
                        
                        // remove shoes
                        [self removeItemAt:tilePos];
                        
                        // send item packet
                        [self sendItemPacket:kItemTypeShoes withAction:kActionTypeShoesGet withPosition:tilePos];
                    }
                
                    // set target position
                    targetPosition = ccpAdd(tileMap.position, moveTilemapPositionOffsets[currentMoveDirection]);
                    
                    // TM16: update remote devices with the new position
                    //[self sendPosition:tilePos];
                    
                    sendPositionCount = 0;
                }
            }
        }
        // move tilemap
        else
        {
            CGFloat offsetX = 2;
            CGFloat offsetY = 1;
            if (player.shoesOn)
            {
                offsetX = offsetX * speedUp;
                offsetY = offsetY * speedUp;
            }

            CGFloat newX, newY;
            if (targetPosition.x > tileMap.position.x)
            {
                newX = MIN(targetPosition.x, tileMap.position.x + offsetX);
            }
            else
            {
                newX = MAX(targetPosition.x, tileMap.position.x - offsetX);
            }
            offsetX = newX - tileMap.position.x;
            
            if (targetPosition.y > tileMap.position.y)
            {
                newY = MIN(targetPosition.y, tileMap.position.y + offsetY);
            }
            else
            {
                newY = MAX(targetPosition.y, tileMap.position.y - offsetY);
            }
            offsetY = newY - tileMap.position.y;
            
            // move tilemap
            tileMap.position = CGPointMake(newX, newY);
            
            if (offsetX != 0 || offsetY != 0)
            {
                CGPoint offset = CGPointMake(offsetX, offsetY);
                // change player's relative position
                player.relativePosition = ccpSub(player.relativePosition, offset);
               
                // send position
                if (sendPositionCount == 0 ||
                    ccpDistance(tileMap.position, targetPosition) == 0)
                {
                    [self sendPosition:player.relativePosition];
                }
                sendPositionCount = (sendPositionCount + 1) % 15;
            }
        }
        
        // change opponent's relative position toward target position
        if (ccpDistance(opponent.relativePosition, opponent.targetPosition) > 0)
        {
            CGFloat offsetX = 2;
            CGFloat offsetY = 1;
            if (opponent.targetPosition.x < opponent.relativePosition.x)
            {
                offsetX = -offsetX;
            }
            if (opponent.targetPosition.y < opponent.relativePosition.y)
            {
                offsetY = -offsetY;
            }
            opponent.relativePosition = ccpAdd
            (opponent.relativePosition, CGPointMake(offsetX, offsetY));
        }
        // move opponent
        CGPoint temp = ccpSub(player.position, opponent.relativePosition);
        opponent.position = ccpSub(temp, player.relativePosition);
        
        // continuously fix the player's Z position
        CGPoint tilePos = [self floatingTilePosFromLocation:screenCenter tileMap:tileMap];
        [player updateVertexZ:tilePos tileMap:tileMap];
        
        // TM16: send a score update to remote devices every frame
        //[self sendScore];
    }
}

- (void)setItemIds
{
    /*
    CCNode* node = [self getChildByTag:TileMapNode];
    NSAssert([node isKindOfClass:[CCTMXTiledMap class]], @"not a CCTMXTiledMap");
    CCTMXTiledMap* tileMap = (CCTMXTiledMap*)node;
    CCTMXLayer *layer = [tileMap layerNamed:@"Objects"];
    uint32_t treeId = [layer tileGIDAt:CGPointMake(13, 33)];
    NSLog(@"treeid: %d", treeId); // 54
    */
    
    inactiveMineId = 54;
    activeMineId = 39;
    shoesId = 49;
    goalId = 55;
}

@end
