//
//  NetworkUtil.h
//  MediaCast
//
//  Created by david davis on 3/1/14.
//

#import <Foundation/Foundation.h>

@interface NetworkUtil : NSObject
+ (NSString *)getIPAddress:(BOOL)preferIPv4;
+ (NSDictionary *)getIPAddresses;

@end
