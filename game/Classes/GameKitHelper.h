//
//  GameKitHelper.h
//
//  Created by Steffen Itterheim on 05.10.10.
//  Copyright 2010 Steffen Itterheim. All rights reserved.
//

#import "cocos2d.h"
#import <VicKit/VicKit.h>

@protocol GameKitHelperProtocol

-(void) onLocalPlayerAuthenticationChanged;

-(void) onFriendListReceived:(const TxStringArray &)friends;
-(void) onPlayerInfoReceived:(const TxStringArray &)players;

-(void) onMatchFound:(VKMatch*)match;
-(void) onPlayersAddedToMatch:(bool)success;
-(void) onReceivedMatchmakingActivity:(int)activity;

-(void) onPlayerConnected:(const TxString &)playerID;
-(void) onPlayerDisconnected:(const TxString &)playerID;
-(void) onStartMatch;
-(void) onReceivedData:(const TxData &)data fromPlayer:(const TxString &)playerID;

/* 
 // Not supported on R0 
-(void) onScoresSubmitted:(bool)success;
-(void) onScoresReceived:(NSArray*)scores;

-(void) onAchievementReported:(GKAchievement*)achievement;
-(void) onAchievementsLoaded:(NSDictionary*)achievements;
-(void) onResetAchievements:(bool)success;

-(void) onMatchmakingViewDismissed;
-(void) onMatchmakingViewError;
-(void) onLeaderboardViewDismissed;
-(void) onAchievementsViewDismissed;
*/
@end


class GameKitHelper : public VKMatchDelegate, 
                             VKLocalPlayer::AuthenticateCompletionHandler, 
                             VKLocalPlayer::AuthenticateChangeHandler, 
                             VKLocalPlayer::LoadFriendsCompletionHandler,
                             VKPlayer::LoadPlayersCompletionHandler,
                             VKMatchmaker::InviteHandler,
                             VKMatchmaker::FindMatchCompletionHandler,
                             VKMatchmaker::AddPlayersCompletionHandler,
                             VKMatchmaker::QueryActivityCompletionHandler
//: NSObject<GKLeaderboardViewControllerDelegate, GKAchievementViewControllerDelegate, GKMatchmakerViewControllerDelegate, GKMatchDelegate>
{
public :
    GameKitHelper();
    virtual ~GameKitHelper();

private :    
	id<GameKitHelperProtocol> delegate_;
	bool isVicDataCenterAvailable_;
	TxError* lastError_;
/*    
	// Not supported on R0
	NSMutableDictionary* achievements;
	NSMutableDictionary* cachedAchievements;
*/	
	VKMatch* currentMatch_;
	bool matchStarted_;
    
private :
    void setCurrentMatch(VKMatch * match);
    void registerForLocalPlayerAuthChange();
    void setLastError(TxError * error);
    // Not Supported on R0.
    /*
     -(void) initCachedAchievements;
     -(void) cacheAchievement:(GKAchievement*)achievement;
     -(void) uncacheAchievement:(GKAchievement*)achievement;
     -(void) loadAchievements;
     */
    void initMatchInvitationHandler();
    UIViewController* getRootViewController();

public:
    id<GameKitHelperProtocol> delegate() { return delegate_; };
    void delegate(id<GameKitHelperProtocol> arg) { delegate_ = arg; };
    bool isVicDataCenterAvailable() const { return isVicDataCenterAvailable_; };
    
    TxError* lastError() { return lastError_; };
	// Not supported on R0
//    @property (nonatomic, readonly) NSMutableDictionary* achievements;
    VKMatch* currentMatch() { return currentMatch_; };
    bool matchStarted() { return matchStarted_; };

    /** returns the singleton object, like this: GameKitHelper::sharedGameKitHelper */
    static GameKitHelper & sharedGameKitHelper();

    
    // Player authentication, info
    void authenticateLocalPlayer();
    void getLocalPlayerFriends();
    void getPlayerInfo( const TxStringArray & players );
    
    /*
     // Not supported on R0
     // Scores
     -(void) submitScore:(int64_t)score category:(NSString*)category;
     
     -(void) retrieveScoresForPlayers:(NSArray*)players
     category:(NSString*)category 
     range:(NSRange)range
     playerScope:(GKLeaderboardPlayerScope)playerScope 
     timeScope:(GKLeaderboardTimeScope)timeScope;
     -(void) retrieveTopTenAllTimeGlobalScores;
     
     // Achievements
     -(GKAchievement*) getAchievementByID:(NSString*)identifier;
     -(void) reportAchievementWithID:(NSString*)identifier percentComplete:(float)percent;
     -(void) resetAchievements;
     -(void) reportCachedAchievements;
     -(void) saveCachedAchievements;
     
     // Game Center Views
     -(void) showLeaderboard;
     -(void) showAchievements;
     -(void) showMatchmakerWithInvite:(GKInvite*)invite;
     -(void) showMatchmakerWithRequest:(GKMatchRequest*)request;
     */
    
    // Matchmaking
    void disconnectCurrentMatch();
    void findMatch(const VKMatchRequest & request);
    void addPlayersToMatch( const VKMatchRequest & request);
    void cancelMatchmakingRequest();
    void queryMatchmakingActivity();
    
    void sendDataToAllPlayers(void* data, unsigned int length);

private :    
    // Handlers
    // from VKLocalPlayer::AuthenticateCompletionHandler
    virtual void onCompleteAuthenticate( TxError * error );
    
    // From VKLocalPlayer::AuthenticateChangeHandler 
    virtual void onChangeAuthentication();
    
    // From VKLocalPlayer::LoadFriendsCompletionHandler
    virtual void onCompleteLoadFriends(const TxStringArray & friends, TxError * error);

    // From VKPlayer::LoadPlayersCompletionHandler 
    virtual void onCompelteLoadPlayers(const TxStringArray & players, TxError * error);
    
    // From VKMatchmaker::InviteHandler
    virtual void onInvite(VKInvite * acceptedInvite, TxStringArray * playersToInvite);
    
    // From VKMatchmaker::FindMatchCompletionHandler
    virtual void onCompleteFindMatch(VKMatch * match, TxError * error);
    
    // From VKMatchmaker::AddPlayersCompletionHandler
    virtual void onCompleteAddPlayers(TxError * error);
    
    // From VKMatchmaker::QueryActivityCompletionHandler
    virtual void onCompleteQueryActivity(int activity, TxError * error);
    
    // From VKMatchDelegate
    virtual void onChangeState( VKMatch * match, const TxString & playerID, VKPlayerConnectionState state );
    virtual void onReceiveData( VKMatch * match, const TxData & data, const TxString & playerID );
};

