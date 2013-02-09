//
//  VKMatchmaker.h
//

#include <VicKit/Basement.h>

class VKPlayer;
class VKMatch;

class VKMatchRequest {
private:
    unsigned int minPlayers_;
    unsigned int maxPlayers_;
    unsigned int playerGroup_;
    unsigned int playerAttributes_;
    TxStringArray playersToInvite_;
public:
    unsigned int minPlayers() const { return minPlayers_; };            // Minimum number of players for the match
    unsigned int maxPlayers() const { return maxPlayers_; };            // Maximum number of players for the match
    unsigned int playerGroup() const { return playerGroup_; };          // The player group identifier. Matchmaking will only take place between players in the same group.
    unsigned int playerAttributes() const { return playerAttributes_; };// optional flags such that when all player flags are OR'ed together in a match they evaluate to 0xFFFFFFFF
    const TxStringArray & playersToInvite() const { return playersToInvite_; };        // Array of player IDs to invite, or nil if none

    void minPlayers(unsigned int arg) { minPlayers_ = arg; };
    void maxPlayers(unsigned int arg) { maxPlayers_ = arg; };
    void playerGroup(unsigned int arg) { playerGroup_ = arg; };
    void playerAttributes(unsigned int arg) { playerAttributes_ = arg; };
    void playersToInvite(const TxStringArray & arg) { playersToInvite_ = arg; };
};

// VKInvite represents an accepted game invite, it is used to create a VKMatchmakerViewController
class VKInvite  {
private :
    TxString inviter_;
    bool hosted_;
public :
    const TxString & inviter() { return inviter_; };
    bool isHosted() { return hosted_; };
};

// VKMatchmaker is a singleton object to manage match creation from invites and auto-matching.
class VKMatchmaker {
public :
// The shared matchmaker
    static VKMatchmaker & sharedMatchmaker();

// An inviteHandler must be set in order to receive game invites or respond to external requests to initiate an invite. The inviteHandler will be called when an invite or request is received. It may be called immediately if there is a pending invite or request when the application is launched. The inviteHandler may be called multiple times.
// Either acceptedInvite or playersToInvite will be present, but never both.

    class InviteHandler {
    public :
        virtual void onInvite(VKInvite * acceptedInvite, TxStringArray * playersToInvite) = 0;
    };
private : 
    InviteHandler * inviteHandler_;
public :
    InviteHandler * inviteHandler() { return inviteHandler_; };
    void inviteHandler(InviteHandler * arg) { inviteHandler_ = arg; };

// Auto-matching to find a peer-to-peer match for the specified request. Error will be nil on success:
// Possible reasons for error:
// 1. Communications failure
// 2. Unauthenticated player
// 3. Timeout

    class FindMatchCompletionHandler {
    public :
        virtual void onCompleteFindMatch(VKMatch * match, TxError * error) = 0;
    };
    void findMatch(const VKMatchRequest & request, FindMatchCompletionHandler * handler);

// Matchmaking for host-client match request. This returns a list of player identifiers to be included in the match. Determination and communication with the host is not part of this API.
// Possible reasons for error:
// 1. Communications failure
// 2. Unauthenticated player
// 3. Timeout
    class FindPlayersCompletionHandler {
    public :
        virtual void onCompleteFindPlayers(const TxStringArray & playerIDs, TxError * error) = 0;
    };
    void findPlayersForHostedMatchRequest(const VKMatchRequest & request, FindPlayersCompletionHandler * handler);

// Auto-matching to add additional players to a peer-to-peer match for the specified request. Error will be nil on success:
// Possible reasons for error:
// 1. Communications failure
// 2. Timeout
    class AddPlayersCompletionHandler {
    public :
        virtual void onCompleteAddPlayers(TxError * error) = 0;
    };
    void addPlayers(VKMatch * match, const VKMatchRequest & matchRequest, AddPlayersCompletionHandler * handler);

// Cancel matchmaking
    void cancel();

// Query the server for recent activity in the specified player group. A larger value indicates that a given group has seen more recent activity. Error will be nil on success.
// Possible reasons for error:
// 1. Communications failure
    class QueryPlayerGroupActivityCompletionHandler {
    public :
        virtual void onCompleteQueryPlayerGroupActivity(int activity, TxError * error) = 0;
    };
    void queryPlayerGroupActivity(unsigned int playerGroup, QueryPlayerGroupActivityCompletionHandler * handler);

// Query the server for recent activity for all the player groups of that game. Error will be nil on success.
// Possible reasons for error:
// 1. Communications failure
    class QueryActivityCompletionHandler {
    public :
        virtual void onCompleteQueryActivity(int activity, TxError * error) = 0;
    };
    void queryActivity(QueryActivityCompletionHandler * handler);
};
