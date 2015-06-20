//
//  Branch_SDK.m
//  Branch-SDK
//
//  Created by Alex Austin on 6/5/14.
//  Copyright (c) 2014 Branch Metrics. All rights reserved.
//

#import "Branch.h"
#import "BNCPreferenceHelper.h"
#import "BNCServerRequest.h"
#import "BNCServerResponse.h"
#import "BNCSystemObserver.h"
#import "BNCServerRequestQueue.h"
#import "BNCConfig.h"
#import "BNCError.h"
#import "BNCLinkData.h"
#import "BNCLinkCache.h"
#import "BNCEncodingUtils.h"
#import "BranchSetIdentityRequest.h"
#import "BranchLogoutRequest.h"
#import "BranchLoadActionsRequest.h"
#import "BranchUserCompletedActionRequest.h"
#import "BranchLoadRewardsRequest.h"
#import "BranchRedeemRewardsRequest.h"
#import "BranchCreditHistoryRequest.h"
#import "BranchGetPromoCodeRequest.h"
#import "BranchValidatePromoCodeRequest.h"
#import "BranchApplyPromoCodeRequest.h"
#import "BranchShortUrlRequest.h"
#import "BranchShortUrlSyncRequest.h"
#import "BranchCloseRequest.h"
#import "BranchGetAppListRequest.h"
#import "BranchUpdateAppListRequest.h"
#import "BranchOpenRequest.h"
#import "BranchInstallRequest.h"
#import "BranchConnectDebugRequest.h"
#import "BranchDisconnectDebugRequest.h"
#import "BranchLogRequest.h"

NSString * const BRANCH_FEATURE_TAG_SHARE = @"share";
NSString * const BRANCH_FEATURE_TAG_REFERRAL = @"referral";
NSString * const BRANCH_FEATURE_TAG_INVITE = @"invite";
NSString * const BRANCH_FEATURE_TAG_DEAL = @"deal";
NSString * const BRANCH_FEATURE_TAG_GIFT = @"gift";

NSString * const BRANCH_INIT_KEY_CHANNEL = @"~channel";
NSString * const BRANCH_INIT_KEY_FEATURE = @"~feature";
NSString * const BRANCH_INIT_KEY_TAGS = @"~tags";
NSString * const BRANCH_INIT_KEY_CAMPAIGN = @"~campaign";
NSString * const BRANCH_INIT_KEY_STAGE = @"~stage";
NSString * const BRANCH_INIT_KEY_CREATION_SOURCE = @"~creation_source";
NSString * const BRANCH_INIT_KEY_REFERRER = @"+referrer";
NSString * const BRANCH_INIT_KEY_PHONE_NUMBER = @"+phone_number";
NSString * const BRANCH_INIT_KEY_IS_FIRST_SESSION = @"+is_first_session";
NSString * const BRANCH_INIT_KEY_CLICKED_BRANCH_LINK = @"+clicked_branch_link";

static int BNCDebugTriggerDuration = 3;
static int BNCDebugTriggerFingers = 4;
static int BNCDebugTriggerFingersSimulator = 2;

@interface Branch() <UIGestureRecognizerDelegate>

@property (strong, nonatomic) BNCServerInterface *bServerInterface;

@property (strong, nonatomic) NSTimer *sessionTimer;
@property (strong, nonatomic) BNCServerRequestQueue *requestQueue;
@property (strong, nonatomic) dispatch_semaphore_t processing_sema;
@property (strong, nonatomic) callbackWithParams sessionInitWithParamsCallback;
@property (assign, nonatomic) NSInteger networkCount;
@property (assign, nonatomic) BOOL isInitialized;
@property (assign, nonatomic) BOOL shouldCallSessionInitCallback;
@property (assign, nonatomic) BOOL appListCheckEnabled;
@property (strong, nonatomic) BNCLinkCache *linkCache;
@property (strong, nonatomic) UILongPressGestureRecognizer *debugGestureRecognizer;
@property (strong, nonatomic) NSTimer *debugHeartbeatTimer;
@property (strong, nonatomic) NSString *branchKey;

@end

@implementation Branch

#pragma mark - Public methods


#pragma mark - GetInstance methods

+ (Branch *)getInstance {
    // If no Branch Key
    NSString *branchKey = [BNCPreferenceHelper getBranchKey:YES];
    NSString *keyToUse = branchKey;
    if (!branchKey) {
        // If no app key
        NSString *appKey = [BNCPreferenceHelper getAppKey];
        if (!appKey) {
            NSLog(@"Branch Warning: Please enter your branch_key in the plist!");
            return nil;
        }
        else {
            keyToUse = appKey;
            NSLog(@"Usage of App Key is deprecated, please move toward using a Branch key");
        }
    }

    return [Branch getInstanceInternal:keyToUse];
}

+ (Branch *)getTestInstance {
    // If no Branch Key
    NSString *branchKey = [BNCPreferenceHelper getBranchKey:NO];
    NSString *keyToUse = branchKey;
    if (!branchKey) {
        // If no app key
        NSString *appKey = [BNCPreferenceHelper getAppKey];
        if (!appKey) {
            NSLog(@"Branch Warning: Please enter your branch_key in the plist!");
            return nil;
        }
        // If they did provide an app key, show them a warning. Shouldn't use app key with a test instance.
        else {
            NSLog(@"Branch Warning: You requested the test instance, but provided an app key. App Keys cannot be used for test instances. Additionally, usage of App Key is deprecated, please move toward using a Branch key");
            keyToUse = appKey;
        }
    }

    return [Branch getInstanceInternal:keyToUse];
}

+ (Branch *)getInstance:(NSString *)branchKey {
    if ([branchKey rangeOfString:@"key_"].location != NSNotFound) {
        [BNCPreferenceHelper setBranchKey:branchKey];
    }
    else {
        [BNCPreferenceHelper setAppKey:branchKey];
    }
    
    return [Branch getInstanceInternal:branchKey];
}

- (id)initWithInterface:(BNCServerInterface *)interface queue:(BNCServerRequestQueue *)queue cache:(BNCLinkCache *)cache key:(NSString *)key {
    if (self = [super init]) {
        _bServerInterface = interface;
        _requestQueue = queue;
        _linkCache = cache;
        _branchKey = key;
        
        _isInitialized = NO;
        _shouldCallSessionInitCallback = YES;
        _appListCheckEnabled = YES;
        _processing_sema = dispatch_semaphore_create(1);
        _networkCount = 0;
        
        NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
        [notificationCenter addObserver:self selector:@selector(applicationWillResignActive) name:UIApplicationWillResignActiveNotification object:nil];
        [notificationCenter addObserver:self selector:@selector(applicationDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
    }

    return self;
}


#pragma mark - BrachActivityItemProvider methods

+ (BranchActivityItemProvider *)getBranchActivityItemWithParams:(NSDictionary *)params
                                                     andTags:(NSArray *)tags
                                                  andFeature:(NSString *)feature
                                                    andStage:(NSString *)stage
                                                    andAlias:(NSString *)alias {
    return [[BranchActivityItemProvider alloc] initWithParams:params andTags:tags andFeature:feature andStage:stage andAlias:alias];
}

+ (BranchActivityItemProvider *)getBranchActivityItemWithParams:(NSDictionary *)params {
    
    return [[BranchActivityItemProvider alloc] initWithParams:params andTags:nil andFeature:nil andStage:nil andAlias:nil];
}

+ (BranchActivityItemProvider *)getBranchActivityItemWithParams:(NSDictionary *)params
                                                         andFeature:(NSString *)feature {
    
    return [[BranchActivityItemProvider alloc] initWithParams:params andTags:nil andFeature:feature andStage:nil andAlias:nil];
}

+ (BranchActivityItemProvider *)getBranchActivityItemWithParams:(NSDictionary *)params
                                                         andFeature:(NSString *)feature
                                                           andStage:(NSString *)stage {
    
    return [[BranchActivityItemProvider alloc] initWithParams:params andTags:nil andFeature:feature andStage:stage andAlias:nil];
}

+ (BranchActivityItemProvider *)getBranchActivityItemWithParams:(NSDictionary *)params
                                                         andFeature:(NSString *)feature
                                                           andStage:(NSString *)stage
                                                            andTags:(NSArray *)tags {
    
    return [[BranchActivityItemProvider alloc] initWithParams:params andTags:tags andFeature:feature andStage:stage andAlias:nil];
}

+ (BranchActivityItemProvider *)getBranchActivityItemWithParams:(NSDictionary *)params
                                                            andFeature:(NSString *)feature
                                                           andStage:(NSString *)stage
                                                           andAlias:(NSString *)alias {
    
    return [[BranchActivityItemProvider alloc] initWithParams:params andTags:nil andFeature:feature andStage:stage andAlias:alias];
}


#pragma mark - Configuration methods

+ (void)setDebug {
    [[Branch getInstance] setDebug];
}

- (void)setDebug {
    [BNCPreferenceHelper setDebug:YES];
}

- (void)resetUserSession {
    self.isInitialized = NO;
}

- (BOOL)isUserIdentified {
    return [BNCPreferenceHelper getUserIdentity] != nil;
}

- (void)setNetworkTimeout:(NSInteger)timeout {
    [BNCPreferenceHelper setTimeout:timeout];
}

- (void)setMaxRetries:(NSInteger)maxRetries {
    [BNCPreferenceHelper setRetryCount:maxRetries];
}

- (void)setRetryInterval:(NSInteger)retryInterval {
    [BNCPreferenceHelper setRetryInterval:retryInterval];
}


#pragma mark - InitSession methods

- (void)initSession {
    [self initSessionAndRegisterDeepLinkHandler:nil];
}

- (void)initSessionWithLaunchOptions:(NSDictionary *)options {
    if (![options objectForKey:UIApplicationLaunchOptionsURLKey]) {
        [self initSessionAndRegisterDeepLinkHandler:nil];
    }
}

- (void)initSession:(BOOL)isReferrable {
    [self initSession:isReferrable andRegisterDeepLinkHandler:nil];
}

- (void)initSessionWithLaunchOptions:(NSDictionary *)options andRegisterDeepLinkHandler:(callbackWithParams)callback {
    self.sessionInitWithParamsCallback = callback;

    if (![BNCSystemObserver getUpdateState] && ![self hasUser]) {
        [BNCPreferenceHelper setIsReferrable];
    } else {
        [BNCPreferenceHelper clearIsReferrable];
    }
    
    if (![options objectForKey:UIApplicationLaunchOptionsURLKey]) {
        [self initUserSessionAndCallCallback:YES];
    }
}

- (void)initSessionWithLaunchOptions:(NSDictionary *)options isReferrable:(BOOL)isReferrable {
    if (![options objectForKey:UIApplicationLaunchOptionsURLKey]) {
        [self initSession:isReferrable andRegisterDeepLinkHandler:nil];
    }
}

- (void)initSession:(BOOL)isReferrable andRegisterDeepLinkHandler:(callbackWithParams)callback {
    self.sessionInitWithParamsCallback = callback;

    if (isReferrable) {
        [BNCPreferenceHelper setIsReferrable];
    } else {
        [BNCPreferenceHelper clearIsReferrable];
    }
    
    [self initUserSessionAndCallCallback:YES];
}

- (void)initSessionWithLaunchOptions:(NSDictionary *)options isReferrable:(BOOL)isReferrable andRegisterDeepLinkHandler:(callbackWithParams)callback {
    self.sessionInitWithParamsCallback = callback;

    if (![options objectForKey:UIApplicationLaunchOptionsURLKey]) {
        [self initSession:isReferrable andRegisterDeepLinkHandler:callback];
    }
}

- (void)initSessionAndRegisterDeepLinkHandler:(callbackWithParams)callback {
    self.sessionInitWithParamsCallback = callback;

    if (![BNCSystemObserver getUpdateState] && ![self hasUser]) {
        [BNCPreferenceHelper setIsReferrable];
    } else {
        [BNCPreferenceHelper clearIsReferrable];
    }
    
    [self initUserSessionAndCallCallback:YES];
}

- (BOOL)handleDeepLink:(NSURL *)url {
    BOOL handled = NO;
    if (url) {
        NSString *query = [url fragment];
        if (!query) {
            query = [url query];
        }

        NSDictionary *params = [BNCEncodingUtils decodeQueryStringToDictionary:query];
        if ([params objectForKey:@"link_click_id"]) {
            handled = YES;
            [BNCPreferenceHelper setLinkClickIdentifier:[params objectForKey:@"link_click_id"]];
        }
    }
 
    [BNCPreferenceHelper setIsReferrable];

    [self initUserSessionAndCallCallback:YES];

    return handled;
}


#pragma mark - Identity methods

- (void)setIdentity:(NSString *)userId {
    [self setIdentity:userId withCallback:NULL];
}

- (void)setIdentity:(NSString *)userId withCallback:(callbackWithParams)callback {
    if (!userId || [[BNCPreferenceHelper getUserIdentity] isEqualToString:userId]) {
        if (callback) {
            callback([self getFirstReferringParams], nil);
        }
        return;
    }
    
    if (!self.isInitialized) {
        [self initUserSessionAndCallCallback:NO];
    }
    

    BranchSetIdentityRequest *req = [[BranchSetIdentityRequest alloc] initWithUserId:userId callback:callback];
    [self.requestQueue enqueue:req];
    [self processNextQueueItem];
}

- (void)logout {
    if (!self.isInitialized) {
        NSLog(@"Branch is not initialized, cannot logout");
        return;
    }

    BranchLogoutRequest *req = [[BranchLogoutRequest alloc] init];
    [self.requestQueue enqueue:req];
    [self processNextQueueItem];
}


#pragma mark - User Action methods

- (void)loadActionCountsWithCallback:(callbackWithStatus)callback {
    if (!self.isInitialized) {
        [self initUserSessionAndCallCallback:NO];
    }

    BranchLoadActionsRequest *req = [[BranchLoadActionsRequest alloc] initWithCallback:callback];
    [self.requestQueue enqueue:req];
    [self processNextQueueItem];
}

- (NSInteger)getTotalCountsForAction:(NSString *)action {
    return [BNCPreferenceHelper getActionTotalCount:action];
}

- (NSInteger)getUniqueCountsForAction:(NSString *)action {
    return [BNCPreferenceHelper getActionUniqueCount:action];
}

- (void)userCompletedAction:(NSString *)action {
    [self userCompletedAction:action withState:nil];
}

- (void)userCompletedAction:(NSString *)action withState:(NSDictionary *)state {
    if (!action) {
        return;
    }
    
    if (!self.isInitialized) {
        [self initUserSessionAndCallCallback:NO];
    }
    
    BranchUserCompletedActionRequest *req = [[BranchUserCompletedActionRequest alloc] initWithAction:action state:state];
    [self.requestQueue enqueue:req];
    [self processNextQueueItem];
}


#pragma mark - Credit methods

- (void)loadRewardsWithCallback:(callbackWithStatus)callback {
    if (!self.isInitialized) {
        [self initUserSessionAndCallCallback:NO];
    }

    BranchLoadRewardsRequest *req = [[BranchLoadRewardsRequest alloc] initWithCallback:callback];
    [self.requestQueue enqueue:req];
    [self processNextQueueItem];
}

- (NSInteger)getCredits {
    return [BNCPreferenceHelper getCreditCount];
}

- (void)redeemRewards:(NSInteger)count {
    [self redeemRewards:count forBucket:@"default" callback:NULL];
}

- (void)redeemRewards:(NSInteger)count callback:(callbackWithStatus)callback {
    [self redeemRewards:count forBucket:@"default" callback:callback];
}

- (NSInteger)getCreditsForBucket:(NSString *)bucket {
    return [BNCPreferenceHelper getCreditCountForBucket:bucket];
}

- (void)redeemRewards:(NSInteger)count forBucket:(NSString *)bucket {
    [self redeemRewards:count forBucket:bucket callback:NULL];
}

- (void)redeemRewards:(NSInteger)count forBucket:(NSString *)bucket callback:(callbackWithStatus)callback {
    if (count == 0) {
        if (callback) {
            callback(false, [NSError errorWithDomain:BNCErrorDomain code:BNCRedeemCreditsError userInfo:@{ NSLocalizedDescriptionKey: @"Cannot redeem zero credits." }]);
        }
        else {
            NSLog(@"Branch Warning: Cannot redeem zero credits");
        }
        return;
    }

    NSInteger totalAvailableCredits = [BNCPreferenceHelper getCreditCountForBucket:bucket];
    if (count > totalAvailableCredits) {
        if (callback) {
            callback(false, [NSError errorWithDomain:BNCErrorDomain code:BNCRedeemCreditsError userInfo:@{ NSLocalizedDescriptionKey: @"You're trying to redeem more credits than are available. Have you loaded rewards?" }]);
        }
        else {
            NSLog(@"Branch Warning: You're trying to redeem more credits than are available. Have you loaded rewards?");
        }
        return;
    }
    
    if (!self.isInitialized) {
        [self initUserSessionAndCallCallback:NO];
    }

    BranchRedeemRewardsRequest *req = [[BranchRedeemRewardsRequest alloc] initWithAmount:count bucket:bucket callback:callback];
    [self.requestQueue enqueue:req];
    [self processNextQueueItem];
}

- (void)getCreditHistoryWithCallback:(callbackWithList)callback {
    [self getCreditHistoryForBucket:nil after:nil number:100 order:BranchMostRecentFirst andCallback:callback];
}

- (void)getCreditHistoryForBucket:(NSString *)bucket andCallback:(callbackWithList)callback {
    [self getCreditHistoryForBucket:bucket after:nil number:100 order:BranchMostRecentFirst andCallback:callback];
}

- (void)getCreditHistoryAfter:(NSString *)creditTransactionId number:(NSInteger)length order:(BranchCreditHistoryOrder)order andCallback:(callbackWithList)callback {
    [self getCreditHistoryForBucket:nil after:creditTransactionId number:length order:order andCallback:callback];
}

- (void)getCreditHistoryForBucket:(NSString *)bucket after:(NSString *)creditTransactionId number:(NSInteger)length order:(BranchCreditHistoryOrder)order andCallback:(callbackWithList)callback {
    if (!self.isInitialized) {
        [self initUserSessionAndCallCallback:NO];
    }

    BranchCreditHistoryRequest *req = [[BranchCreditHistoryRequest alloc] initWithBucket:bucket creditTransactionId:creditTransactionId length:length order:order callback:callback];
    [self.requestQueue enqueue:req];
    [self processNextQueueItem];
}

- (NSDictionary *)getFirstReferringParams {
    NSString *storedParam = [BNCPreferenceHelper getInstallParams];
    return [BNCEncodingUtils decodeJsonStringToDictionary:storedParam];
}

- (NSDictionary *)getLatestReferringParams {
    NSString *storedParam = [BNCPreferenceHelper getSessionParams];
    return [BNCEncodingUtils decodeJsonStringToDictionary:storedParam];
}


#pragma mark - ContentUrl methods

- (NSString *)getContentUrlWithParams:(NSDictionary *)params andChannel:(NSString *)channel {
    return [self generateShortUrl:nil andAlias:nil andType:BranchLinkTypeUnlimitedUse andMatchDuration:0 andChannel:channel andFeature:BRANCH_FEATURE_TAG_SHARE andStage:nil andParams:params ignoreUAString:nil];
}

- (NSString *)getContentUrlWithParams:(NSDictionary *)params andTags:(NSArray *)tags andChannel:(NSString *)channel {
    return [self generateShortUrl:tags andAlias:nil andType:BranchLinkTypeUnlimitedUse andMatchDuration:0 andChannel:channel andFeature:BRANCH_FEATURE_TAG_SHARE andStage:nil andParams:params ignoreUAString:nil];
}

- (void)getContentUrlWithParams:(NSDictionary *)params andTags:(NSArray *)tags andChannel:(NSString *)channel andCallback:(callbackWithUrl)callback {
    [self generateShortUrl:tags andAlias:nil andType:BranchLinkTypeUnlimitedUse andMatchDuration:0 andChannel:channel andFeature:BRANCH_FEATURE_TAG_SHARE andStage:nil andParams:params andCallback:callback];
}

- (void)getContentUrlWithParams:(NSDictionary *)params andChannel:(NSString *)channel andCallback:(callbackWithUrl)callback {
    [self generateShortUrl:nil andAlias:nil andType:BranchLinkTypeUnlimitedUse andMatchDuration:0 andChannel:channel andFeature:BRANCH_FEATURE_TAG_SHARE andStage:nil andParams:params andCallback:callback];
}


#pragma mark - ShortUrl methods

- (NSString *)getShortURL {
    return [self generateShortUrl:nil andAlias:nil andType:BranchLinkTypeUnlimitedUse andMatchDuration:0 andChannel:nil andFeature:nil andStage:nil andParams:nil ignoreUAString:nil];
}

- (NSString *)getShortURLWithParams:(NSDictionary *)params {
    return [self generateShortUrl:nil andAlias:nil andType:BranchLinkTypeUnlimitedUse andMatchDuration:0 andChannel:nil andFeature:nil andStage:nil andParams:params ignoreUAString:nil];
}

- (NSString *)getShortURLWithParams:(NSDictionary *)params andTags:(NSArray *)tags andChannel:(NSString *)channel andFeature:(NSString *)feature andStage:(NSString *)stage {
    return [self generateShortUrl:tags andAlias:nil andType:BranchLinkTypeUnlimitedUse andMatchDuration:0 andChannel:channel andFeature:feature andStage:stage andParams:params ignoreUAString:nil];
}

- (NSString *)getShortURLWithParams:(NSDictionary *)params andTags:(NSArray *)tags andChannel:(NSString *)channel andFeature:(NSString *)feature andStage:(NSString *)stage andAlias:(NSString *)alias {
    return [self generateShortUrl:tags andAlias:alias andType:BranchLinkTypeUnlimitedUse andMatchDuration:0 andChannel:channel andFeature:feature andStage:stage andParams:params ignoreUAString:nil];
}

- (NSString *)getShortURLWithParams:(NSDictionary *)params andTags:(NSArray *)tags andChannel:(NSString *)channel andFeature:(NSString *)feature andStage:(NSString *)stage andAlias:(NSString *)alias ignoreUAString:(NSString *)ignoreUAString {
    return [self generateShortUrl:tags andAlias:alias andType:BranchLinkTypeUnlimitedUse andMatchDuration:0 andChannel:channel andFeature:feature andStage:stage andParams:params ignoreUAString:ignoreUAString];
}

- (NSString *)getShortURLWithParams:(NSDictionary *)params andTags:(NSArray *)tags andChannel:(NSString *)channel andFeature:(NSString *)feature andStage:(NSString *)stage andType:(BranchLinkType)type {
    return [self generateShortUrl:tags andAlias:nil andType:type andMatchDuration:0 andChannel:channel andFeature:feature andStage:stage andParams:params ignoreUAString:nil];
}

- (NSString *)getShortURLWithParams:(NSDictionary *)params andTags:(NSArray *)tags andChannel:(NSString *)channel andFeature:(NSString *)feature andStage:(NSString *)stage andMatchDuration:(NSUInteger)duration {
    return [self generateShortUrl:tags andAlias:nil andType:BranchLinkTypeUnlimitedUse andMatchDuration:duration andChannel:channel andFeature:feature andStage:stage andParams:params ignoreUAString:nil];
}

- (NSString *)getShortURLWithParams:(NSDictionary *)params andChannel:(NSString *)channel andFeature:(NSString *)feature andStage:(NSString *)stage {
    return [self generateShortUrl:nil andAlias:nil andType:BranchLinkTypeUnlimitedUse andMatchDuration:0 andChannel:channel andFeature:feature andStage:stage andParams:params ignoreUAString:nil];
}

- (NSString *)getShortURLWithParams:(NSDictionary *)params andChannel:(NSString *)channel andFeature:(NSString *)feature andStage:(NSString *)stage andAlias:(NSString *)alias {
    return [self generateShortUrl:nil andAlias:alias andType:BranchLinkTypeUnlimitedUse andMatchDuration:0 andChannel:channel andFeature:feature andStage:stage andParams:params ignoreUAString:nil];
}

- (NSString *)getShortURLWithParams:(NSDictionary *)params andChannel:(NSString *)channel andFeature:(NSString *)feature andStage:(NSString *)stage andType:(BranchLinkType)type {
    return [self generateShortUrl:nil andAlias:nil andType:type andMatchDuration:0 andChannel:channel andFeature:feature andStage:stage andParams:params ignoreUAString:nil];
}

- (NSString *)getShortURLWithParams:(NSDictionary *)params andChannel:(NSString *)channel andFeature:(NSString *)feature andStage:(NSString *)stage andMatchDuration:(NSUInteger)duration {
    return [self generateShortUrl:nil andAlias:nil andType:BranchLinkTypeUnlimitedUse andMatchDuration:duration andChannel:channel andFeature:feature andStage:stage andParams:params ignoreUAString:nil];
}

- (NSString *)getShortURLWithParams:(NSDictionary *)params andChannel:(NSString *)channel andFeature:(NSString *)feature {
    return [self generateShortUrl:nil andAlias:nil andType:BranchLinkTypeUnlimitedUse andMatchDuration:0 andChannel:channel andFeature:feature andStage:nil andParams:params ignoreUAString:nil];
}

- (void)getShortURLWithCallback:(callbackWithUrl)callback {
    [self generateShortUrl:nil andAlias:nil andType:BranchLinkTypeUnlimitedUse andMatchDuration:0 andChannel:nil andFeature:nil andStage:nil andParams:nil andCallback:callback];
}

- (void)getShortURLWithParams:(NSDictionary *)params andCallback:(callbackWithUrl)callback {
    [self generateShortUrl:nil andAlias:nil andType:BranchLinkTypeUnlimitedUse andMatchDuration:0 andChannel:nil andFeature:nil andStage:nil andParams:params andCallback:callback];
}

- (void)getShortURLWithParams:(NSDictionary *)params andTags:(NSArray *)tags andChannel:(NSString *)channel andFeature:(NSString *)feature andStage:(NSString *)stage andCallback:(callbackWithUrl)callback {
    [self generateShortUrl:tags andAlias:nil andType:BranchLinkTypeUnlimitedUse andMatchDuration:0 andChannel:channel andFeature:feature andStage:stage andParams:params andCallback:callback];
}

- (void)getShortURLWithParams:(NSDictionary *)params andTags:(NSArray *)tags andChannel:(NSString *)channel andFeature:(NSString *)feature andStage:(NSString *)stage andAlias:(NSString *)alias andCallback:(callbackWithUrl)callback {
    [self generateShortUrl:tags andAlias:alias andType:BranchLinkTypeUnlimitedUse andMatchDuration:0 andChannel:channel andFeature:feature andStage:stage andParams:params andCallback:callback];
}

- (void)getShortURLWithParams:(NSDictionary *)params andTags:(NSArray *)tags andChannel:(NSString *)channel andFeature:(NSString *)feature andStage:(NSString *)stage andType:(BranchLinkType)type andCallback:(callbackWithUrl)callback {
    [self generateShortUrl:tags andAlias:nil andType:type andMatchDuration:0 andChannel:channel andFeature:feature andStage:stage andParams:params andCallback:callback];
}

- (void)getShortURLWithParams:(NSDictionary *)params andTags:(NSArray *)tags andChannel:(NSString *)channel andFeature:(NSString *)feature andStage:(NSString *)stage andMatchDuration:(NSUInteger)duration andCallback:(callbackWithUrl)callback {
    [self generateShortUrl:tags andAlias:nil andType:BranchLinkTypeUnlimitedUse andMatchDuration:duration andChannel:channel andFeature:feature andStage:stage andParams:params andCallback:callback];
}

- (void)getShortURLWithParams:(NSDictionary *)params andChannel:(NSString *)channel andFeature:(NSString *)feature andStage:(NSString *)stage andCallback:(callbackWithUrl)callback {
    [self generateShortUrl:nil andAlias:nil andType:BranchLinkTypeUnlimitedUse andMatchDuration:0 andChannel:channel andFeature:feature andStage:stage andParams:params andCallback:callback];
}

- (void)getShortURLWithParams:(NSDictionary *)params andChannel:(NSString *)channel andFeature:(NSString *)feature andStage:(NSString *)stage andAlias:(NSString *)alias andCallback:(callbackWithUrl)callback {
    [self generateShortUrl:nil andAlias:alias andType:BranchLinkTypeUnlimitedUse andMatchDuration:0 andChannel:channel andFeature:feature andStage:stage andParams:params andCallback:callback];
}

- (void)getShortURLWithParams:(NSDictionary *)params andChannel:(NSString *)channel andFeature:(NSString *)feature andStage:(NSString *)stage andType:(BranchLinkType)type andCallback:(callbackWithUrl)callback {
    [self generateShortUrl:nil andAlias:nil andType:type andMatchDuration:0 andChannel:channel andFeature:feature andStage:stage andParams:params andCallback:callback];
}

- (void)getShortURLWithParams:(NSDictionary *)params andChannel:(NSString *)channel andFeature:(NSString *)feature andStage:(NSString *)stage andMatchDuration:(NSUInteger)duration andCallback:(callbackWithUrl)callback {
    [self generateShortUrl:nil andAlias:nil andType:BranchLinkTypeUnlimitedUse andMatchDuration:duration andChannel:channel andFeature:feature andStage:stage andParams:params andCallback:callback];
}

- (void)getShortURLWithParams:(NSDictionary *)params andChannel:(NSString *)channel andFeature:(NSString *)feature andCallback:(callbackWithUrl)callback {
    [self generateShortUrl:nil andAlias:nil andType:BranchLinkTypeUnlimitedUse andMatchDuration:0 andChannel:channel andFeature:feature andStage:nil andParams:params andCallback:callback];
}

#pragma mark - LongUrl methods
- (NSString *)getLongURLWithParams:(NSDictionary *)params andChannel:(NSString *)channel andTags:(NSArray *)tags andFeature:(NSString *)feature andStage:(NSString *)stage andAlias:(NSString *)alias {
    return [self generateLongURLWithParams:params andChannel:channel andTags:tags andFeature:feature andStage:stage andAlias:alias];
}

- (NSString *)getLongURLWithParams:(NSDictionary *)params {
    return [self generateLongURLWithParams:params andChannel:nil andTags:nil andFeature:nil andStage:nil andAlias:nil];
}

- (NSString *)getLongURLWithParams:(NSDictionary *)params andFeature:(NSString *)feature {
    return [self generateLongURLWithParams:params andChannel:nil andTags:nil andFeature:feature andStage:nil andAlias:nil];
}

- (NSString *)getLongURLWithParams:(NSDictionary *)params andFeature:(NSString *)feature andStage:(NSString *)stage {
    return [self generateLongURLWithParams:params andChannel:nil andTags:nil andFeature:feature andStage:stage andAlias:nil];
}

- (NSString *)getLongURLWithParams:(NSDictionary *)params andFeature:(NSString *)feature andStage:(NSString *)stage andTags:(NSArray *)tags {
    return [self generateLongURLWithParams:params andChannel:nil andTags:tags andFeature:feature andStage:stage andAlias:nil];
}

- (NSString *)getLongURLWithParams:(NSDictionary *)params andFeature:(NSString *)feature andStage:(NSString *)stage andAlias:(NSString *)alias {
    return [self generateLongURLWithParams:params andChannel:nil andTags:nil andFeature:feature andStage:stage andAlias:alias];
}

#pragma mark - Referral methods

- (NSString *)getReferralUrlWithParams:(NSDictionary *)params andTags:(NSArray *)tags andChannel:(NSString *)channel {
    return [self generateShortUrl:tags andAlias:nil andType:BranchLinkTypeUnlimitedUse andMatchDuration:0 andChannel:channel andFeature:BRANCH_FEATURE_TAG_REFERRAL andStage:nil andParams:params ignoreUAString:nil];
}

- (NSString *)getReferralUrlWithParams:(NSDictionary *)params andChannel:(NSString *)channel {
    return [self generateShortUrl:nil andAlias:nil andType:BranchLinkTypeUnlimitedUse andMatchDuration:0 andChannel:channel andFeature:BRANCH_FEATURE_TAG_REFERRAL andStage:nil andParams:params ignoreUAString:nil];
}

- (void)getReferralUrlWithParams:(NSDictionary *)params andTags:(NSArray *)tags andChannel:(NSString *)channel andCallback:(callbackWithUrl)callback {
    [self generateShortUrl:tags andAlias:nil andType:BranchLinkTypeUnlimitedUse andMatchDuration:0 andChannel:channel andFeature:BRANCH_FEATURE_TAG_REFERRAL andStage:nil andParams:params andCallback:callback];
}

- (void)getReferralUrlWithParams:(NSDictionary *)params andChannel:(NSString *)channel andCallback:(callbackWithUrl)callback {
    [self generateShortUrl:nil andAlias:nil andType:BranchLinkTypeUnlimitedUse andMatchDuration:0 andChannel:channel andFeature:BRANCH_FEATURE_TAG_REFERRAL andStage:nil andParams:params andCallback:callback];
}

- (void)getPromoCodeWithCallback:(callbackWithParams)callback {
    [self getPromoCodeWithPrefix:nil amount:0 expiration:nil bucket:nil usageType:BranchPromoCodeUsageTypeUnlimitedUses rewardLocation:BranchPromoCodeRewardReferringUser callback:callback];
}

- (void)getReferralCodeWithCallback:(callbackWithParams)callback {
    [self getPromoCodeWithPrefix:nil amount:0 expiration:nil bucket:nil usageType:BranchPromoCodeUsageTypeUnlimitedUses rewardLocation:BranchPromoCodeRewardReferringUser callback:callback];
}

- (void)getPromoCodeWithAmount:(NSInteger)amount callback:(callbackWithParams)callback {
    [self getPromoCodeWithPrefix:nil amount:amount expiration:nil bucket:nil usageType:BranchPromoCodeUsageTypeUnlimitedUses rewardLocation:BranchPromoCodeRewardReferringUser callback:callback];
}

- (void)getReferralCodeWithAmount:(NSInteger)amount andCallback:(callbackWithParams)callback {
    [self getPromoCodeWithPrefix:nil amount:amount expiration:nil bucket:nil usageType:BranchPromoCodeUsageTypeUnlimitedUses rewardLocation:BranchPromoCodeRewardReferringUser callback:callback];
}

- (void)getPromoCodeWithPrefix:(NSString *)prefix amount:(NSInteger)amount callback:(callbackWithParams)callback {
    [self getPromoCodeWithPrefix:prefix amount:amount expiration:nil bucket:nil usageType:BranchPromoCodeUsageTypeUnlimitedUses rewardLocation:BranchPromoCodeRewardReferringUser callback:callback];
}

- (void)getReferralCodeWithPrefix:(NSString *)prefix amount:(NSInteger)amount andCallback:(callbackWithParams)callback {
    [self getPromoCodeWithPrefix:prefix amount:amount expiration:nil bucket:nil usageType:BranchPromoCodeUsageTypeUnlimitedUses rewardLocation:BranchPromoCodeRewardReferringUser callback:callback];
}

- (void)getPromoCodeWithAmount:(NSInteger)amount expiration:(NSDate *)expiration callback:(callbackWithParams)callback {
    [self getPromoCodeWithPrefix:nil amount:amount expiration:expiration bucket:nil usageType:BranchPromoCodeUsageTypeUnlimitedUses rewardLocation:BranchPromoCodeRewardReferringUser callback:callback];
}

- (void)getReferralCodeWithAmount:(NSInteger)amount expiration:(NSDate *)expiration andCallback:(callbackWithParams)callback {
    [self getPromoCodeWithPrefix:nil amount:amount expiration:expiration bucket:nil usageType:BranchPromoCodeUsageTypeUnlimitedUses rewardLocation:BranchPromoCodeRewardReferringUser callback:callback];
}

- (void)getPromoCodeWithPrefix:(NSString *)prefix amount:(NSInteger)amount expiration:(NSDate *)expiration callback:(callbackWithParams)callback {
    [self getPromoCodeWithPrefix:prefix amount:amount expiration:expiration bucket:nil usageType:BranchPromoCodeUsageTypeUnlimitedUses rewardLocation:BranchPromoCodeRewardReferringUser callback:callback];
}

- (void)getReferralCodeWithPrefix:(NSString *)prefix amount:(NSInteger)amount expiration:(NSDate *)expiration andCallback:(callbackWithParams)callback {
    [self getPromoCodeWithPrefix:prefix amount:amount expiration:expiration bucket:nil usageType:BranchPromoCodeUsageTypeUnlimitedUses rewardLocation:BranchPromoCodeRewardReferringUser callback:callback];
}

- (void)getReferralCodeWithPrefix:(NSString *)prefix amount:(NSInteger)amount expiration:(NSDate *)expiration bucket:(NSString *)bucket calculationType:(BranchPromoCodeUsageType)calcType location:(BranchPromoCodeRewardLocation)location andCallback:(callbackWithParams)callback {
    [self getPromoCodeWithPrefix:prefix amount:amount expiration:expiration bucket:bucket usageType:calcType rewardLocation:location useOld:YES callback:callback];
}

- (void)getPromoCodeWithPrefix:(NSString *)prefix amount:(NSInteger)amount expiration:(NSDate *)expiration bucket:(NSString *)bucket usageType:(BranchPromoCodeUsageType)usageType rewardLocation:(BranchPromoCodeRewardLocation)rewardLocation callback:(callbackWithParams)callback {
    [self getPromoCodeWithPrefix:prefix amount:amount expiration:expiration bucket:bucket usageType:usageType rewardLocation:rewardLocation useOld:NO callback:callback];
}

- (void)getPromoCodeWithPrefix:(NSString *)prefix amount:(NSInteger)amount expiration:(NSDate *)expiration bucket:(NSString *)bucket usageType:(BranchPromoCodeUsageType)usageType rewardLocation:(BranchPromoCodeRewardLocation)rewardLocation useOld:(BOOL)useOld callback:(callbackWithParams)callback {
    if (!self.isInitialized) {
        [self initUserSessionAndCallCallback:NO];
    }
    
    if (!bucket) {
        bucket = @"default";
    }
    
    BranchGetPromoCodeRequest *req = [[BranchGetPromoCodeRequest alloc] initWithUsageType:usageType rewardLocation:rewardLocation amount:amount bucket:bucket prefix:prefix expiration:expiration useOld:useOld callback:callback];
    [self.requestQueue enqueue:req];
    [self processNextQueueItem];
}

- (void)validateReferralCode:(NSString *)code andCallback:(callbackWithParams)callback {
    [self validatePromoCode:code useOld:YES callback:callback];
}

- (void)validatePromoCode:(NSString *)code callback:(callbackWithParams)callback {
    [self validatePromoCode:code useOld:NO callback:callback];
}

- (void)validatePromoCode:(NSString *)code useOld:(BOOL)useOld callback:(callbackWithParams)callback {
    if (!code.length) {
        if (callback) {
            callback(nil, [NSError errorWithDomain:BNCErrorDomain code:BNCInvalidReferralCodeError userInfo:@{ NSLocalizedDescriptionKey: @"No code specified" }]);
        }
        return;
    }

    if (!self.isInitialized) {
        [self initUserSessionAndCallCallback:NO];
    }
    
    BranchValidatePromoCodeRequest *req = [[BranchValidatePromoCodeRequest alloc] initWithCode:code useOld:useOld callback:callback];
    [self.requestQueue enqueue:req];
    [self processNextQueueItem];
}

- (void)applyReferralCode:(NSString *)code andCallback:(callbackWithParams)callback {
    [self applyPromoCode:code useOld:YES callback:callback];
}

- (void)applyPromoCode:(NSString *)code callback:(callbackWithParams)callback {
    [self applyPromoCode:code useOld:NO callback:callback];
}

- (void)applyPromoCode:(NSString *)code useOld:(BOOL)useOld callback:(callbackWithParams)callback {
    if (!code.length) {
        if (callback) {
            callback(nil, [NSError errorWithDomain:BNCErrorDomain code:BNCInvalidReferralCodeError userInfo:@{ NSLocalizedDescriptionKey: @"No code specified" }]);
        }
        return;
    }
    
    if (!self.isInitialized) {
        [self initUserSessionAndCallCallback:NO];
    }
    
    
    BranchApplyPromoCodeRequest *req = [[BranchApplyPromoCodeRequest alloc] initWithCode:code useOld:useOld callback:callback];
    [self.requestQueue enqueue:req];
    [self processNextQueueItem];
}


#pragma mark - Logging
- (void)log:(NSString *)log {
    BranchLogRequest *request = [[BranchLogRequest alloc] initWithLog:log];
    [self.requestQueue enqueue:request];
    [self processNextQueueItem];
}


#pragma mark - Private methods

+ (Branch *)getInstanceInternal:(NSString *)key {
    static Branch *branch;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        // If there was stored key and it isn't the same as the currently used (or doesn't exist), we need to clean up
        // Note: Link Click Identifier is not cleared because of the potential for that to mess up a deep link
        NSString *lastKey = [BNCPreferenceHelper getLastRunBranchKey];
        if (lastKey && ![key isEqualToString:lastKey]) {
            NSLog(@"Branch Warning: The Branch Key has changed, clearing relevant items");
            
            [BNCPreferenceHelper setAppVersion:nil];
            [BNCPreferenceHelper setDeviceFingerprintID:nil];
            [BNCPreferenceHelper setSessionID:nil];
            [BNCPreferenceHelper setIdentityID:nil];
            [BNCPreferenceHelper setUserURL:nil];
            [BNCPreferenceHelper setInstallParams:nil];
            [BNCPreferenceHelper setSessionParams:nil];
            [[BNCServerRequestQueue getInstance] clearQueue];
        }
        
        [BNCPreferenceHelper setLastRunBranchKey:key];

        branch = [[Branch alloc] initWithInterface:[[BNCServerInterface alloc] init] queue:[BNCServerRequestQueue getInstance] cache:[[BNCLinkCache alloc] init] key:key];
    });

    return branch;
}


#pragma mark - URL Generation methods

- (void)generateShortUrl:(NSArray *)tags andAlias:(NSString *)alias andType:(BranchLinkType)type andMatchDuration:(NSUInteger)duration andChannel:(NSString *)channel andFeature:(NSString *)feature andStage:(NSString *)stage andParams:(NSDictionary *)params andCallback:(callbackWithUrl)callback {
    if (!self.isInitialized) {
        [self initUserSessionAndCallCallback:NO];
    }
    
    BNCLinkData *linkData = [self prepareLinkDataFor:tags andAlias:alias andType:type andMatchDuration:duration andChannel:channel andFeature:feature andStage:stage andParams:params ignoreUAString:nil];
    
    if ([self.linkCache objectForKey:linkData]) {
        if (callback) {
            callback([self.linkCache objectForKey:linkData], nil);
        }
        return;
    }

    BranchShortUrlRequest *req = [[BranchShortUrlRequest alloc] initWithTags:tags alias:alias type:type matchDuration:duration channel:channel feature:feature stage:stage params:params linkData:linkData linkCache:self.linkCache callback:callback];
    [self.requestQueue enqueue:req];
    [self processNextQueueItem];
}

- (NSString *)generateShortUrl:(NSArray *)tags andAlias:(NSString *)alias andType:(BranchLinkType)type andMatchDuration:(NSUInteger)duration andChannel:(NSString *)channel andFeature:(NSString *)feature andStage:(NSString *)stage andParams:(NSDictionary *)params ignoreUAString:(NSString *)ignoreUAString {
    NSString *shortURL = nil;
    
    BNCLinkData *linkData = [self prepareLinkDataFor:tags andAlias:alias andType:type andMatchDuration:duration andChannel:channel andFeature:feature andStage:stage andParams:params ignoreUAString:ignoreUAString];
    
    // If an ignore UA string is present, we always get a new url. Otherwise, if we've already seen this request, use the cached version
    if (!ignoreUAString && [self.linkCache objectForKey:linkData]) {
        shortURL = [self.linkCache objectForKey:linkData];
    }
    else {
        BranchShortUrlSyncRequest *req = [[BranchShortUrlSyncRequest alloc] initWithTags:tags alias:alias type:type matchDuration:duration channel:channel feature:feature stage:stage params:params linkData:linkData linkCache:self.linkCache];
        
        if (self.isInitialized) {
            [BNCPreferenceHelper log:FILE_NAME line:LINE_NUM message:@"Created custom url synchronously"];
            BNCServerResponse *serverResponse = [req makeRequest:self.bServerInterface key:self.branchKey];
            shortURL = [req processResponse:serverResponse];
            
            // cache the link
            if (shortURL) {
                [self.linkCache setObject:shortURL forKey:linkData];
            }
        }
        else {
            NSLog(@"Branch SDK Error: making request before init succeeded!");
        }
    }
    
    return shortURL;
}

- (NSString *)generateLongURLWithParams:(NSDictionary *)params andChannel:(NSString *)channel andTags:(NSArray *)tags andFeature:(NSString *)feature andStage:(NSString *)stage andAlias:(NSString *)alias {
    NSString *baseLongUrl = [NSString stringWithFormat:@"%@/a/%@", BNC_LINK_URL, self.branchKey];

    return [self longUrlWithBaseUrl:baseLongUrl params:params tags:tags feature:feature channel:nil stage:stage alias:alias duration:0 type:BranchLinkTypeUnlimitedUse];
}

- (NSString *)longUrlWithBaseUrl:(NSString *)baseUrl params:(NSDictionary *)params tags:(NSArray *)tags feature:(NSString *)feature channel:(NSString *)channel stage:(NSString *)stage alias:(NSString *)alias duration:(NSUInteger)duration type:(BranchLinkType)type {
    NSMutableString *longUrl = [[NSMutableString alloc] initWithFormat:@"%@?", baseUrl];
    
    for (NSString *tag in tags) {
        [longUrl appendFormat:@"tags=%@&", tag];
    }
    
    if ([alias length]) {
        [longUrl appendFormat:@"alias=%@&", alias];
    }
    
    if ([channel length]) {
        [longUrl appendFormat:@"channel=%@&", channel];
    }
    
    if ([feature length]) {
        [longUrl appendFormat:@"feature=%@&", feature];
    }
    
    if ([stage length]) {
        [longUrl appendFormat:@"stage=%@&", stage];
    }
    
    [longUrl appendFormat:@"type=%ld&", (long)type];
    [longUrl appendFormat:@"matchDuration=%ld&", (long)duration];
    
    NSData *jsonData = [BNCEncodingUtils encodeDictionaryToJsonData:params];
    NSString *base64EncodedParams = [BNCEncodingUtils base64EncodeData:jsonData];
    [longUrl appendFormat:@"source=ios&data=%@", base64EncodedParams];
    
    return longUrl;
}

- (BNCLinkData *)prepareLinkDataFor:(NSArray *)tags andAlias:(NSString *)alias andType:(BranchLinkType)type andMatchDuration:(NSUInteger)duration andChannel:(NSString *)channel andFeature:(NSString *)feature andStage:(NSString *)stage andParams:(NSDictionary *)params ignoreUAString:(NSString *)ignoreUAString {
    BNCLinkData *post = [[BNCLinkData alloc] init];

    [post setupType:type];
    [post setupTags:tags];
    [post setupChannel:channel];
    [post setupFeature:feature];
    [post setupStage:stage];
    [post setupAlias:alias];
    [post setupMatchDuration:duration];
    [post setupIgnoreUAString:ignoreUAString];
    [post setupParams:params];

    return post;
}


#pragma mark - Application State Change methods

- (void)applicationDidBecomeActive {
    if (!self.isInitialized) {
        [self initUserSessionAndCallCallback:YES];
    }
    
    [self addDebugGestureRecognizer];
}

- (void)applicationWillResignActive {
    [self clearTimer];
    self.sessionTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(callClose) userInfo:nil repeats:NO];
    [self.requestQueue persistImmediately];
    
    if (self.debugGestureRecognizer) {
        [[UIApplication sharedApplication].keyWindow removeGestureRecognizer:self.debugGestureRecognizer];
    }
}

- (void)clearTimer {
    [self.sessionTimer invalidate];
}

- (void)callClose {
    if (self.isInitialized) {
        self.isInitialized = NO;

        if (![self.requestQueue containsClose]) {
            BranchCloseRequest *req = [[BranchCloseRequest alloc] init];
            [self.requestQueue enqueue:req];
        }
        
        [self processNextQueueItem];
    }
}

- (void)getAppList {
    BranchGetAppListRequest *req = [[BranchGetAppListRequest alloc] initWithCallback:^(NSArray *apps, NSError *error) {
        if (error) {
            return;
        }

        NSDictionary *appList = [BNCSystemObserver getOpenableAppDictFromList:apps];
        [self processListOfApps:appList];
    }];
    
    [self.requestQueue enqueue:req];
    [self processNextQueueItem];
}

- (void)processListOfApps:(NSDictionary *)appList {
    BranchUpdateAppListRequest *req = [[BranchUpdateAppListRequest alloc] initWithAppList:appList];
    [self.requestQueue enqueue:req];
    [self processNextQueueItem];
}


#pragma mark - Queue management

- (void)insertRequestAtFront:(BNCServerRequest *)req {
    if (self.networkCount == 0) {
        [self.requestQueue insert:req at:0];
    }
    else {
        [self.requestQueue insert:req at:1];
    }
}

- (void)processNextQueueItem {
    dispatch_semaphore_wait(self.processing_sema, DISPATCH_TIME_FOREVER);
    
    if (self.networkCount == 0 && self.requestQueue.size > 0) {
        self.networkCount = 1;
        dispatch_semaphore_signal(self.processing_sema);
        
        BNCServerRequest *req = [self.requestQueue peek];
        
        if (req) {
            BNCServerCallback callback = ^(BNCServerResponse *response, NSError *error) {
                // If the request was successful, or was a bad user request, continue processing.
                if (!error || error.code == BNCBadRequestError || error.code == BNCDuplicateResourceError) {
                    [req processResponse:response error:error];

                    [self.requestQueue dequeue];
                    self.networkCount = 0;
                    [self processNextQueueItem];
                }
                // On network problems, or Branch down, call the other callbacks and stop processing.
                else {
                    // First, gather all the requests to fail
                    NSMutableArray *requestsToFail = [[NSMutableArray alloc] init];
                    for (int i = 0; i < self.requestQueue.size; i++) {
                        [requestsToFail addObject:[self.requestQueue peekAt:i]];
                    }

                    // Next, remove all the requests that should not be replayed. Note, we do this before calling callbacks, in case any
                    // of the callbacks try to kick off another request, which could potentially start another request (and call these callbacks again)
                    for (BNCServerRequest *request in requestsToFail) {
                        if (![request isKindOfClass:[BranchUserCompletedActionRequest class]] && ![request isKindOfClass:[BranchSetIdentityRequest class]]) {
                            [self.requestQueue remove:request];
                        }
                    }

                    // Then, set the network count to zero, indicating that requests can be started again
                    self.networkCount = 0;

                    // Finally, call all the requests callbacks with the error
                    for (BNCServerRequest *request in requestsToFail) {
                        [request processResponse:nil error:error];
                    }
                }
            };

            if (![req isKindOfClass:[BranchInstallRequest class]] && ![self hasUser]) {
                NSLog(@"Branch Error: User session has not been initialized!");
                [req processResponse:nil error:[NSError errorWithDomain:BNCErrorDomain code:BNCInitError userInfo:@{ NSLocalizedDescriptionKey: @"Branch User Session has not been initialized" }]];
                return;
            }
            
            if (![req isKindOfClass:[BranchCloseRequest class]]) {
                [self clearTimer];
            }
            
            [req makeRequest:self.bServerInterface key:self.branchKey callback:callback];
        }
    }
    else {
        dispatch_semaphore_signal(self.processing_sema);
    }
}


#pragma mark - Branch State checks

- (BOOL)hasIdentity {
    return [BNCPreferenceHelper getUserIdentity] != nil;
}

- (BOOL)hasUser {
    return [BNCPreferenceHelper getIdentityID] != nil;
}

- (BOOL)hasSession {
    return [BNCPreferenceHelper getSessionID] != nil;
}

- (BOOL)hasAppKey {
    return [BNCPreferenceHelper getAppKey] != nil;
}

#pragma mark - Session Initialization

- (void)initUserSessionAndCallCallback:(BOOL)callCallback {
    self.shouldCallSessionInitCallback = callCallback;
    
    // If the session is not yet initialized
    if (!self.isInitialized) {
        [self initializeSession];
    }
    // If the session was initialized, but callCallback was specified, do so.
    else if (callCallback) {
        if (self.sessionInitWithParamsCallback) {
            self.sessionInitWithParamsCallback([self getLatestReferringParams], nil);
        }
    }
}

- (void)initializeSession {
    if (!self.branchKey) {
        NSLog(@"Branch Warning: Please enter your branch_key in the plist!");
        return;
    }
    else if ([self.branchKey rangeOfString:@"key_test_"].location != NSNotFound) {
        NSLog(@"Branch Warning: You are using your test app's Branch Key. Remember to change it to live Branch Key for deployment.");
    }
    
    if (![self hasUser]) {
        [self registerInstallOrOpen:[BranchInstallRequest class]];
    }
    else {
        [self registerInstallOrOpen:[BranchOpenRequest class]];
    }
}

- (void)registerInstallOrOpen:(Class)clazz {
    callbackWithStatus initSessionCallback = ^(BOOL success, NSError *error) {
        if (error) {
            [self handleInitFailure:error];
        }
        else {
            [self handleInitSuccess];
        }
    };

    // If there isn't already an Open / Install request, add one to the queue
    if (![self.requestQueue containsInstallOrOpen]) {
        BranchOpenRequest *req = [[clazz alloc] initWithCallback:initSessionCallback];

        [self insertRequestAtFront:req];
    }
    // If there is already one in the queue, make sure it's in the front.
    // Make sure a callback is associated with this request. This callback can
    // be cleared if the app is terminated while an Open/Install is pending.
    else {
        BranchOpenRequest *req = [self.requestQueue moveInstallOrOpenToFront:self.networkCount];
        req.callback = initSessionCallback;
    }
    
    [self processNextQueueItem];
}

- (void)handleInitSuccess {
    self.isInitialized = YES;

    if (self.appListCheckEnabled && [BNCPreferenceHelper getNeedAppListCheck]) {
        [self getAppList];
    }
    
    if (self.shouldCallSessionInitCallback && self.sessionInitWithParamsCallback) {
        self.sessionInitWithParamsCallback([self getLatestReferringParams], nil);
    }
}

- (void)handleInitFailure:(NSError *)error {
    self.isInitialized = NO;

    if (self.shouldCallSessionInitCallback && self.sessionInitWithParamsCallback) {
        self.sessionInitWithParamsCallback(nil, error);
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Debugger functions

- (void)addDebugGestureRecognizer {
    [self addGesterRecognizer:@selector(connectToDebug:)];
}

- (void)addCancelDebugGestureRecognizer {
    [self addGesterRecognizer:@selector(endRemoteDebugging:)];
}

- (void)addGesterRecognizer:(SEL)action {
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window removeGestureRecognizer:self.debugGestureRecognizer]; // Remove existing gesture
    
    self.debugGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:action];
    self.debugGestureRecognizer.delegate = self;
    self.debugGestureRecognizer.minimumPressDuration = BNCDebugTriggerDuration;

    if ([BNCSystemObserver isSimulator]) {
        self.debugGestureRecognizer.numberOfTouchesRequired = BNCDebugTriggerFingersSimulator;
    }
    else {
        self.debugGestureRecognizer.numberOfTouchesRequired = BNCDebugTriggerFingers;
    }
    
    [window addGestureRecognizer:self.debugGestureRecognizer];
}

- (void)connectToDebug:(UILongPressGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan){
        NSLog(@"======= Start Debug Session =======");
        BranchConnectDebugRequest *request = [[BranchConnectDebugRequest alloc] initWithCallback:^(BOOL success, NSError *error) {
            [self startRemoteDebugging];
        }];
        
        [self.requestQueue enqueue:request];
        [self processNextQueueItem];
    }
}

- (void)startRemoteDebugging {
    NSLog(@"======= Connected to Branch Remote Debugger =======");
    
    [[UIApplication sharedApplication].keyWindow removeGestureRecognizer:self.debugGestureRecognizer];
    [self addCancelDebugGestureRecognizer];
    
    //TODO: change to send screenshots instead in future
    if (!self.debugHeartbeatTimer || !self.debugHeartbeatTimer.isValid) {
        self.debugHeartbeatTimer = [NSTimer scheduledTimerWithTimeInterval:20 target:self selector:@selector(keepDebugAlive) userInfo:nil repeats:YES];
    }
}

- (void)endRemoteDebugging:(UILongPressGestureRecognizer *)sender {
    NSLog(@"======= End Debug Session =======");
    
    [[UIApplication sharedApplication].keyWindow removeGestureRecognizer:sender];
    BranchDisconnectDebugRequest *request = [[BranchDisconnectDebugRequest alloc] init];
    [self.requestQueue enqueue:request];
    [self processNextQueueItem];

    [self.debugHeartbeatTimer invalidate];
    [self addDebugGestureRecognizer];
}

- (void)keepDebugAlive {
    NSLog(@"[Branch Debug] Sending Keep Alive");
    [self log:@""];
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

@end
