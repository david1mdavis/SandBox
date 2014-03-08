//
//  NetworkUtil.h
//  MediaCast
//
//  Created by david davis on 3/1/14.
//  Copyright (c) 2014 Google Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NetworkUtil : NSObject
+ (NSString *)getIPAddress:(BOOL)preferIPv4;
+ (NSDictionary *)getIPAddresses;

@end
