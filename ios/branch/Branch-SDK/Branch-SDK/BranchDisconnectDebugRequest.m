//
//  BranchDisconnectDebugRequest.m
//  Branch-TestBed
//
//  Created by Graham Mueller on 6/3/15.
//  Copyright (c) 2015 Branch Metrics. All rights reserved.
//

#import "BranchDisconnectDebugRequest.h"
#import "BNCPreferenceHelper.h"

@implementation BranchDisconnectDebugRequest

- (void)makeRequest:(BNCServerInterface *)serverInterface key:(NSString *)key callback:(BNCServerCallback)callback {
    NSDictionary *params = @{
        @"device_fingerprint_id": [BNCPreferenceHelper getDeviceFingerprintID]
    };

    [serverInterface postRequest:params url:[BNCPreferenceHelper getAPIURL:@"debug/disconnect"] key:key log:NO callback:callback];
}

- (void)processResponse:(BNCServerResponse *)response error:(NSError *)error {
    [BNCPreferenceHelper setConnectedToRemoteDebug:NO];
}

@end
