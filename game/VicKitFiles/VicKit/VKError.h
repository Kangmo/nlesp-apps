/*
 *  VKError.h
 */

#ifndef __O_VK_ERROR_H__
#define __O_VK_ERROR_H__ (1)

#import <VicKit/Basement.h>
#import <VicKit/VKDefines.h>

// TODO : Investigate what this is.
VK_EXTERN_WEAK TxString VKErrorDomain;

typedef enum {
    VKErrorUnknown                              = 1,
    VKErrorCancelled                            = 2,
    VKErrorCommunicationsFailure                = 3,
    VKErrorUserDenied                           = 4,
    VKErrorInvalidCredentials                   = 5,
    VKErrorNotAuthenticated                     = 6,
    VKErrorAuthenticationInProgress             = 7,
    VKErrorInvalidPlayer                        = 8,
    VKErrorScoreNotSet                          = 9,
    VKErrorParentalControlsBlocked              = 10,
    VKErrorPlayerStatusExceedsMaximumLength     = 11,
    VKErrorPlayerStatusInvalid                  = 12,
    VKErrorMatchRequestInvalid                  = 13,
    VKErrorUnderage                             = 14,
    VKErrorGameUnrecognized                     = 15,
    VKErrorNotSupported                         = 16,
    VKErrorInvalidParameter                     = 17,
    VKErrorUnexpectedConnection                 = 18,
} VKErrorCode;

#endif /* __O_VK_ERROR_H__ */