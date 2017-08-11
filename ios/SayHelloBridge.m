//
//  SayHelloBridge.m
//  swiftTest
//
//  Created by Max Brodheim on 8/11/17.
//  Copyright © 2017 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>

// SayHelloBridge.m
#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(SayHello, NSObject)

RCT_EXTERN_METHOD(greetings: (NSString *)name )

@end
