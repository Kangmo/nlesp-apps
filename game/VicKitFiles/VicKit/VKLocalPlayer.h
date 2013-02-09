//
//  VKLocalPlayer.h
//

#ifndef __O_VK_LOCALPLAYER_H__
#define __O_VK_LOCALPLAYER_H__ (1)

#include <VicKit/Basement.h>
#include <VicKit/VKPlayer.h>
#include <VicKit/VKDefines.h>

VK_EXTERN_CLASS class VKLocalPlayer : public VKPlayer {

public :
	VKLocalPlayer();
	virtual ~VKLocalPlayer();
// Obtain the VKLocalPlayer object.
// The player is only available for offline play until logged in.
// A temporary player is created if no account is set up.
public :
	static VKLocalPlayer & localPlayer();

private :
	bool authenticated_; // Authentication state
	bool underage_;		// Underage state
public :
	bool authenticated() const   { return authenticated_; };
	bool isAuthenticated() const { return authenticated_; };
	bool isUnderage() const		 { return underage_; };

// Authenticate the player for access to player details and game statistics. This may present UI to the user if necessary to login or create an account. The user must be authenticated in order to use other APIs. This should be called for each launch of the application as soon as the UI is ready.
// Authentication happens automatically on return to foreground, and the completion handler will be called again. Game Center UI may be presented during this authentication as well. Apps should check the local player's authenticated and player ID properties to determine if the local player has changed.
// Possible reasons for error:
// 1. Communications problem
// 2. User credentials invalid
// 3. User cancelled
	class AuthenticateCompletionHandler {
    public :
        virtual void onCompleteAuthenticate( TxError * error ) = 0;
    };
	void authenticate(AuthenticateCompletionHandler * handler);

private :
	TxStringArray friends_;
public :
	// Array of player identifiers of friends for the local player. Not valid until loadFriendsWithCompletionHandler: has completed.
	const TxStringArray & friends() const { return friends_; };

// Asynchronously load the friends list as an array of player identifiers. Calls completionHandler when finished. Error will be nil on success.
// Possible reasons for error:
// 1. Communications problem
// 2. Unauthenticated player
	class LoadFriendsCompletionHandler {
    public :
        virtual void onCompleteLoadFriends(const TxStringArray & friends, TxError * error) = 0;
    };

	void loadFriends(LoadFriendsCompletionHandler * handler);
    
public :
    class AuthenticateChangeHandler {
    public:
        virtual void onChangeAuthentication() = 0;
    };

private :
    AuthenticateChangeHandler * authChangeHandler_;

public :    
    // Notification will be posted whenever authentication status changes.
    AuthenticateChangeHandler * authChangeHandler() { return authChangeHandler_; };
    void authChangeHandler(AuthenticateChangeHandler * arg) { authChangeHandler_ = arg; };
    // authChangeHandler replaces VKPlayerAuthenticationDidChangeNotificationName.
    //    VK_EXTERN TxString VKPlayerAuthenticationDidChangeNotificationName;

};


#endif /* __O_VK_LOCALPLAYER_H__ */