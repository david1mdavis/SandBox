//
//  FileUtil.h
//  MediaCast
//
//  Created by david davis on 3/1/14.
//  Copyright (c) 2014 Google Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileUtil : NSObject
//+(void)copyVideoToTemp:(NSString*) mediaURL;
+(void)copyVideoToTemp:(NSURL*) mediaURL;
+ (void)saveImage:(UIImage *)image withName:(NSString *)name;

@end
