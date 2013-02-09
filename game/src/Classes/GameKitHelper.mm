//
//  GameKitHelper.m
//
//  Created by Steffen Itterheim on 05.10.10.
//  Copyright 2010 Steffen Itterheim. All rights reserved.
//

#import "GameKitHelper.h"
#import "TargetConditionals.h"

/*
// Not supported on R0
static NSString* kCachedAchievementsFile = @"CachedAchievements.archive";
*/

GameKitHelper & GameKitHelper::sharedGameKitHelper() 
{
    static GameKitHelper * theGameKitHelper = NULL;
    
    if ( theGameKitHelper == NULL ) 
    {
// BUGBUG Need to initialize GameKitHelper        
        theGameKitHelper = new GameKitHelper();
    }
    return *theGameKitHelper;
}

GameKitHelper::GameKitHelper()
{
    isVicDataCenterAvailable_ = YES;
    
    registerForLocalPlayerAuthChange();
    
    // Not supported on R0
    //initCachedAchievements();
    
    // comment by MKJANG
    /*
    // init match
    currentMatch_ = new VKMatch();
    currentMatch_->delegate(this);
     */
    
    // initialize VikKitSystem
    VicKitSystem::initialize();
}

// BUGBUG : This destructor is never called.
GameKitHelper::~GameKitHelper()
{
//	[[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark setLastError

void GameKitHelper::setLastError(VKError * error)
{
	lastError_ = error;
	
	if (lastError_)
	{
		NSLog(@"GameKitHelper ERROR: %s", lastError_->errorMessage().c_str() );
	}
}

#pragma mark Player Authentication

//from VKLocalPlayer::AuthenticateCompletionHandler
void GameKitHelper::onAuthenticate( VKError * error )
{
    setLastError(error);
    
    if (error == NULL)
    {
        NSLog(@"GameKitHelper::onAuthenticate: authenticated sucessfully.");
        initMatchInvitationHandler();
        // Not supported on R0
        /*
        reportCachedAchievements();
        loadAchievements();
        */
//#if (TARGET_IPHONE_SIMULATOR)
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        {
        // request match
        NSString *friendUserID = @"10026";
        VKMatchRequest matchRequest;
        TxStringArray array(1);
        array[0] = friendUserID.UTF8String;
        matchRequest.playersToInvite(array);
        findMatch(matchRequest);
        }
//#endif
    }
}

void GameKitHelper::authenticateLocalPlayer()
{
	if (! isVicDataCenterAvailable() )
		return;

	VKLocalPlayer * localPlayer = VKLocalPlayer::localPlayer();
	if (! localPlayer->authenticated() )
	{
		// Authenticate player, using a block object. See Apple's Block Programming guide for more info about Block Objects:
		// http://developer.apple.com/library/mac/#documentation/Cocoa/Conceptual/Blocks/Articles/00_Introduction.html
//		localPlayer.authenticate(this);
        
        NSString *email;
        NSString *pw;
//#if (TARGET_IPHONE_SIMULATOR)
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        {
        email = @"gamer3";
        pw = @"gamer3";
        }
        else
        {
        email = @"gamer4";
        pw = @"gamer4";
        }
        localPlayer->authenticate(email.UTF8String, pw.UTF8String, this);
	}
}

// From VKLocalPlayer::LocalPlayerAuthenticationChangeHandler
void GameKitHelper::onChangeAuthentication()
{
	[delegate_ onLocalPlayerAuthenticationChanged];
}

void GameKitHelper::registerForLocalPlayerAuthChange()
{
	if (! isVicDataCenterAvailable() )
		return;

	VKLocalPlayer * localPlayer = VKLocalPlayer::localPlayer();
    localPlayer->authChangeHandler(this);
}

// From VKLocalPlayer::LoadFriendsCompletionHandler
void GameKitHelper::onLoadFriends(const TxStringArray & friends, VKError * error)
{
    setLastError(error);
    [delegate_ onFriendListReceived:friends];
}

void GameKitHelper::getLocalPlayerFriends()
{
	if (! isVicDataCenterAvailable() )
		return;
	
	VKLocalPlayer * localPlayer = VKLocalPlayer::localPlayer();
	if ( localPlayer->authenticated() )
	{
		// First, get the list of friends (player IDs)
		localPlayer->loadFriends(this);
	}
}

/*
// From VKPlayer::LoadPlayersCompletionHandler
void GameKitHelper::onCompleteLoadPlayers(const TxStringArray & players, TxError * error)
{
    setLastError(error);
    
    [delegate_ onPlayerInfoReceived:players];
}

void GameKitHelper::getPlayerInfo(const TxStringArray & playerList)
{
	if (! isVicDataCenterAvailable() )
		return;

	// Get detailed information about a list of players
	if (playerList.size() > 0)
	{
        VKPlayer::loadPlayers(playerList, this);
	}
}
*/
// Not Supported on R0.
/*
#pragma mark Scores & Leaderboard

-(void) submitScore:(int64_t)score category:(NSString*)category
{
	if (isGameCenterAvailable == NO)
		return;

	GKScore* gkScore = [[[GKScore alloc] initWithCategory:category] autorelease];
	gkScore.value = score;

	[gkScore reportScoreWithCompletionHandler:^(NSError* error)
	{
		[self setLastError:error];
		
		bool success = (error == nil);
		[delegate onScoresSubmitted:success];
	}];
}

-(void) retrieveScoresForPlayers:(NSArray*)players
						category:(NSString*)category 
						   range:(NSRange)range
					 playerScope:(GKLeaderboardPlayerScope)playerScope 
					   timeScope:(GKLeaderboardTimeScope)timeScope 
{
	if (isGameCenterAvailable == NO)
		return;
	
	GKLeaderboard* leaderboard = nil;
	if ([players count] > 0)
	{
		leaderboard = [[[GKLeaderboard alloc] initWithPlayerIDs:players] autorelease];
	}
	else
	{
		leaderboard = [[[GKLeaderboard alloc] init] autorelease];
		leaderboard.playerScope = playerScope;
	}
	
	if (leaderboard != nil)
	{
		leaderboard.timeScope = timeScope;
		leaderboard.category = category;
		leaderboard.range = range;
		[leaderboard loadScoresWithCompletionHandler:^(NSArray* scores, NSError* error)
		{
			[self setLastError:error];
			[delegate onScoresReceived:scores];
		}];
	}
}

-(void) retrieveTopTenAllTimeGlobalScores
{
	[self retrieveScoresForPlayers:nil
						  category:nil 
							 range:NSMakeRange(1, 10)
					   playerScope:GKLeaderboardPlayerScopeGlobal 
						 timeScope:GKLeaderboardTimeScopeAllTime];
}

#pragma mark Achievements

-(void) loadAchievements
{
	if (isGameCenterAvailable == NO)
		return;

	[GKAchievement loadAchievementsWithCompletionHandler:^(NSArray* loadedAchievements, NSError* error)
	{
		[self setLastError:error];
		 
		if (achievements == nil)
		{
			achievements = [[NSMutableDictionary alloc] init];
		}
		else
		{
			[achievements removeAllObjects];
		}
		
		for (GKAchievement* achievement in loadedAchievements)
		{
			[achievements setObject:achievement forKey:achievement.identifier];
		}
		 
		[delegate onAchievementsLoaded:achievements];
	}];
}

-(GKAchievement*) getAchievementByID:(NSString*)identifier
{
	if (isGameCenterAvailable == NO)
		return nil;
		
	// Try to get an existing achievement with this identifier
	GKAchievement* achievement = [achievements objectForKey:identifier];
	
	if (achievement == nil)
	{
		// Create a new achievement object
		achievement = [[[GKAchievement alloc] initWithIdentifier:identifier] autorelease];
		[achievements setObject:achievement forKey:achievement.identifier];
	}
	
	return [[achievement retain] autorelease];
}

-(void) reportAchievementWithID:(NSString*)identifier percentComplete:(float)percent
{
	if (isGameCenterAvailable == NO)
		return;

	GKAchievement* achievement = [self getAchievementByID:identifier];
	if (achievement != nil && achievement.percentComplete < percent)
	{
		achievement.percentComplete = percent;
		[achievement reportAchievementWithCompletionHandler:^(NSError* error)
		{
			[self setLastError:error];
			
			bool success = (error == nil);
			if (success == NO)
			{
				// Keep achievement to try to submit it later
				[self cacheAchievement:achievement];
			}
			
			[delegate onAchievementReported:achievement];
		}];
	}
}

-(void) resetAchievements
{
	if (isGameCenterAvailable == NO)
		return;
	
	[achievements removeAllObjects];
	[cachedAchievements removeAllObjects];
	
	[GKAchievement resetAchievementsWithCompletionHandler:^(NSError* error)
	{
		[self setLastError:error];
		bool success = (error == nil);
		[delegate onResetAchievements:success];
	}];
}

-(void) reportCachedAchievements
{
	if (isGameCenterAvailable == NO)
		return;
	
	if ([cachedAchievements count] == 0)
		return;

	for (GKAchievement* achievement in [cachedAchievements allValues])
	{
		[achievement reportAchievementWithCompletionHandler:^(NSError* error)
		{
			bool success = (error == nil);
			if (success == YES)
			{
				[self uncacheAchievement:achievement];
			}
		}];
	}
}

-(void) initCachedAchievements
{
	NSString* file = [NSHomeDirectory() stringByAppendingPathComponent:kCachedAchievementsFile];
	id object = [NSKeyedUnarchiver unarchiveObjectWithFile:file];
	
	if ([object isKindOfClass:[NSMutableDictionary class]])
	{
		NSMutableDictionary* loadedAchievements = (NSMutableDictionary*)object;
		cachedAchievements = [[NSMutableDictionary alloc] initWithDictionary:loadedAchievements];
	}
	else
	{
		cachedAchievements = [[NSMutableDictionary alloc] init];
	}
}

-(void) saveCachedAchievements
{
	NSString* file = [NSHomeDirectory() stringByAppendingPathComponent:kCachedAchievementsFile];
	[NSKeyedArchiver archiveRootObject:cachedAchievements toFile:file];
}

-(void) cacheAchievement:(GKAchievement*)achievement
{
	[cachedAchievements setObject:achievement forKey:achievement.identifier];
	
	// Save to disk immediately, to keep achievements around even if the game crashes.
	[self saveCachedAchievements];
}

-(void) uncacheAchievement:(GKAchievement*)achievement
{
	[cachedAchievements removeObjectForKey:achievement.identifier];
	
	// Save to disk immediately, to keep the removed cached achievement from being loaded again
	[self saveCachedAchievements];
}
*/

#pragma mark Matchmaking

void GameKitHelper::disconnectCurrentMatch()
{
    assert(currentMatch_);
    currentMatch_->disconnect();
    currentMatch_->delegate(NULL);
    delete currentMatch_;
    currentMatch_ = NULL;
}

void GameKitHelper::setCurrentMatch(VKMatch * match)
{
// BUGBUG : Make sure replacing isEqual to pointer comparison
//	if ([currentMatch isEqual:match] == NO)
    if ( currentMatch_ != match )
	{
        // comment by MKJANG
		/*
        disconnectCurrentMatch();
        assert(currentMatch_ == NULL);
        */
		currentMatch_ = match;
		currentMatch_->delegate(this);
	}
}


// From VKMatchmaker::InviteHandler
void GameKitHelper::onInvite(VKInvite * acceptedInvite, TxStringArray * playersToInvite)
{
    // comment by MKJANG
    //disconnectCurrentMatch();
    
    if (acceptedInvite)
    {
        // Not supported on R0
        // BUGBUG : Is it OK not to show the Matchmaker?
        
        //[self showMatchmakerWithInvite:acceptedInvite];
        
        // get match
        VKMatchmaker::sharedMatchmaker()->matchForInvite(acceptedInvite, this);
    }
    else if (playersToInvite)
    {
        VKMatchRequest request;
        request.minPlayers(2);
        request.maxPlayers(4);
        request.playersToInvite(*playersToInvite);
        
        // Not supported on R0
        // BUGBUG : Is it OK not to show the Matchmaker?
        //[self showMatchmakerWithRequest:request];
    }
}


void GameKitHelper::initMatchInvitationHandler()
{
	if (! isVicDataCenterAvailable() )
		return;

    VKMatchmaker::sharedMatchmaker()->inviteHandler(this);
}

// From VKMatchmaker::FindMatchCompletionHandler
void GameKitHelper::onFindMatch(VKMatch *match, VKError *error)
{
    setLastError(error);
    NSLog(@"GameKitHelper::onFindMatch");
    
    if (match != nil)
    {
        setCurrentMatch(match);
        [delegate_ onMatchFound:match];
    }
}


void GameKitHelper::findMatch(const VKMatchRequest & request)
{
	if (! isVicDataCenterAvailable() )
		return;
	
	VKMatchmaker::sharedMatchmaker()->findMatch(request, this);
}

void GameKitHelper::onMatchForInvite(VKMatch *match, VKError *error)
{
    setLastError(error);
    NSLog(@"GameKitHelper::onMatchForInvite");
    
    if (match != nil)
    {
        setCurrentMatch(match);
        [delegate_ onMatchFound:match];
    }
}

/*
// From VKMatchmaker::AddPlayersCompletionHandler
void GameKitHelper::onCompleteAddPlayers(TxError * error)
{
    setLastError(error);
    
    bool success = (error == NULL);
    [delegate_ onPlayersAddedToMatch:success];
}

void GameKitHelper::addPlayersToMatch(const VKMatchRequest & request)
{
	if (! isVicDataCenterAvailable() )
		return;

	if (currentMatch_ == NULL)
		return;
	
	VKMatchmaker::sharedMatchmaker().addPlayers(currentMatch_, request, this);
}

void GameKitHelper::cancelMatchmakingRequest()
{
	if (! isVicDataCenterAvailable() )
		return;

	VKMatchmaker::sharedMatchmaker().cancel();
}

// From VKMatchmaker::QueryActivityCompletionHandler
void GameKitHelper::onCompleteQueryActivity(int activity, TxError * error)
{
    setLastError(error);
    
    if (error == NULL)
    {
        [delegate_ onReceivedMatchmakingActivity:activity];
    }
}

void GameKitHelper::queryMatchmakingActivity()
{
	if (! isVicDataCenterAvailable() )
		return;

	VKMatchmaker::sharedMatchmaker().queryActivity(this);
}
*/
#pragma mark Match Connection

// The player state changed (eg. connected or disconnected)
void GameKitHelper::onChangeState( VKMatch * match, const TxString & playerID, VKPlayerConnectionState state )
{
	switch ((int)state)
	{
		case VKPlayerStateConnected:
			[delegate_ onPlayerConnected:playerID];
			break;
		case VKPlayerStateDisconnected:
			[delegate_ onPlayerDisconnected:playerID];
			break;
	}
	
	if (matchStarted_ == NO && match->expectedPlayerCount() == 0)
	{
		matchStarted_ = YES;
		[delegate_ onStartMatch];
	}
}

void GameKitHelper::sendDataToAllPlayers(void * data, unsigned int length)
{
	if (! isVicDataCenterAvailable() )
		return;
	
	VKError* error = NULL;
	
    TxData packet(data, length);
    
    assert(currentMatch_);
	currentMatch_->sendDataToAllPlayers(packet, VKMatchSendDataUnreliable, &error);
	
    setLastError(error);
}

// The match received data sent from the player.
void GameKitHelper::onReceiveData( VKMatch * match, const TxData & data, const TxString & playerID )
{
	[delegate_ onReceivedData:data fromPlayer:playerID];
}

/*
 // Not supported on R0

#pragma mark Views (Leaderboard, Achievements)

// Helper methods

-(UIViewController*) getRootViewController
{
	return [UIApplication sharedApplication].keyWindow.rootViewController;
}

-(void) presentViewController:(UIViewController*)vc
{
	UIViewController* rootVC = [self getRootViewController];
	[rootVC presentModalViewController:vc animated:YES];
}

-(void) dismissModalViewController
{
	UIViewController* rootVC = [self getRootViewController];
	[rootVC dismissModalViewControllerAnimated:YES];
}

// Leaderboards
-(void) showLeaderboard
{
	if (isGameCenterAvailable == NO)
		return;
	
	GKLeaderboardViewController* leaderboardVC = [[[GKLeaderboardViewController alloc] init] autorelease];
	if (leaderboardVC != nil)
	{
		leaderboardVC.leaderboardDelegate = self;
		[self presentViewController:leaderboardVC];
	}
}

-(void) leaderboardViewControllerDidFinish:(GKLeaderboardViewController*)viewController
{
	[self dismissModalViewController];
	[delegate onLeaderboardViewDismissed];
}

// Achievements

-(void) showAchievements
{
	if (isGameCenterAvailable == NO)
		return;
	
	GKAchievementViewController* achievementsVC = [[[GKAchievementViewController alloc] init] autorelease];
	if (achievementsVC != nil)
	{
		achievementsVC.achievementDelegate = self;
		[self presentViewController:achievementsVC];
	}
}

-(void) achievementViewControllerDidFinish:(GKAchievementViewController*)viewController
{
	[self dismissModalViewController];
	[delegate onAchievementsViewDismissed];
}
// Matchmaking

-(void) showMatchmakerWithInvite:(GKInvite*)invite
{
	GKMatchmakerViewController* inviteVC = [[[GKMatchmakerViewController alloc] initWithInvite:invite] autorelease];
	if (inviteVC != nil)
	{
		inviteVC.matchmakerDelegate = self;
		[self presentViewController:inviteVC];
	}
}

-(void) showMatchmakerWithRequest:(GKMatchRequest*)request
{
	GKMatchmakerViewController* hostVC = [[[GKMatchmakerViewController alloc] initWithMatchRequest:request] autorelease];
	if (hostVC != nil)
	{
		hostVC.matchmakerDelegate = self;
		[self presentViewController:hostVC];
	}
}

-(void) matchmakerViewControllerWasCancelled:(GKMatchmakerViewController*)viewController
{
	[self dismissModalViewController];
	[delegate onMatchmakingViewDismissed];
}

-(void) matchmakerViewController:(GKMatchmakerViewController*)viewController didFailWithError:(NSError*)error
{
	[self dismissModalViewController];
	[self setLastError:error];
	[delegate onMatchmakingViewError];
}

-(void) matchmakerViewController:(GKMatchmakerViewController*)viewController didFindMatch:(GKMatch*)match
{
	[self dismissModalViewController];
	[self setCurrentMatch:match];
	[delegate onMatchFound:match];
}
 */

