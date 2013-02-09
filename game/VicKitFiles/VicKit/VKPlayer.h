//
//  VKPlayer.h
//  GameKit
//
//  Copyright 2010 Apple Inc. All rights reserved.
//

#ifndef __O_VK_PLAYER_H__
#define __O_VK_PLAYER_H__ (1)

#include <VicKit/Basement.h>
#include <VicKit/VKDefines.h>
#include <VicKit/VKError.h>

VK_EXTERN_CLASS class VKPlayer {

// Load the players for the identifiers provided. Error will be nil on success.
// Possible reasons for error:
// 1. Unauthenticated local player
// 2. Communications failure
// 3. Invalid player identifier
public :
	class LoadPlayersCompletionHandler {   
    public :
        virtual void onCompleteLoadPlayers(const TxStringArray & players, TxError * error) = 0;
    };
	static void loadPlayers(const TxStringArray & identifiers, LoadPlayersCompletionHandler * handler);

private :
	TxString playerID_;
	TxString alias_;
	bool isFriend_;

public:
	const TxString & playerID() const { return playerID_; };	// Invariant player identifier.
	const TxString & alias() const { return alias_; };		// The player's alias
	bool isFriend() const { return isFriend_; };		// True if this player is a friend of the local player

	// Available photo sizes.  Actual pixel dimensions will vary on different devices.
    typedef enum {
	    VKPhotoSizeSmall = 0,
	    VKPhotoSizeNormal,
	} VKPhotoSize;

// Asynchronously load the player's photo. Error will be nil on success.
// Possible reasons for error:
// 1. Communications failure
    class LoadPhotoCompletionHandler {
    public :
        virtual void onCompleteLoadPhoto(const TxImage & photo, TxError *error) = 0;
    };
	void loadPhoto(VKPhotoSize size, LoadPhotoCompletionHandler * handler);

public :
    class ChangeHandler {
    public:
        virtual void onChangePlayer() = 0;
    };

private :
    
    ChangeHandler * changeHandler_;
    
public :    
    // Notification will be posted whenever authentication status changes.
    ChangeHandler * authChangeHandler() { return changeHandler_; };
    void authChangeHandler(ChangeHandler * arg) { changeHandler_ = arg; };
    // Notification will be posted whenever the player details changes. The object of the notification will be the player.
    // VK_EXTERN_WEAK TxString VKPlayerDidChangeNotificationName;
};


#endif /* __O_VK_PLAYER_H__ */