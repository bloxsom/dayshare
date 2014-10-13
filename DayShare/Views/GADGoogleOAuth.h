//
//  GADGoogleOAuth.h
//  GoogleAuthDemo
//
//  Created by Honghao on 7/20/14.
//  Copyright (c) 2014 org-honghao. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    httpMethod_GET,
    httpMethod_POST,
    httpMethod_DELETE,
    httpMethod_PUT
} HTTP_Method;

@protocol GoogleOAuthDelegate
// It will be used after a successful authorization, meaning after having obtained a valid access token.
-(void)authorizationWasSuccessful;
// This delegate method will be used when the user revokes all the granted permissions.
-(void)accessTokenWasRevoked;
// This method will be called every time that a response to an API call is received.
-(void)responseFromServiceWasReceived:(NSString *)responseJSONAsString andResponseJSONAsData:(NSData *)responseJSONAsData;
// Called when a general error occurs.
-(void)errorOccuredWithShortDescription:(NSString *)errorShortDescription andErrorDetails:(NSString *)errorDetails;
// This delegate method will be called when an error in the HTTP response exists.
-(void)errorInResponseWithBody:(NSString *)errorMessage;
@end

@interface GADGoogleOAuth : UIWebView <UIWebViewDelegate, NSURLConnectionDataDelegate>

@property (nonatomic, strong) id<GoogleOAuthDelegate> gOAuthDelegate;

-(void)authorizeUserWithClienID:(NSString *)client_ID
                andClientSecret:(NSString *)client_Secret
                  andParentView:(UIView *)parent_View
                      andScopes:(NSArray *)scopes;

-(void)revokeAccessToken;

-(void)callAPI:(NSString *)apiURL withHttpMethod:(HTTP_Method)httpMethod postParameterNames:(NSArray *)params postParameterValues:(NSArray *)values;

@end

