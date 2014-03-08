//
//  FileUtil.m
//  MediaCast
//
//  Created by david davis on 3/1/14.
//  Copyright (c) 2014 Google Inc. All rights reserved.
//

#import "FileUtil.h"
#import <AssetsLibrary/AssetsLibrary.h>

@implementation FileUtil

+(void)copyVideoToTemp:(NSURL*) mediaURL
{
    ALAssetsLibrary *assetLibrary=[[ALAssetsLibrary alloc] init];
    [assetLibrary assetForURL:mediaURL resultBlock:^(ALAsset *asset) {
        ALAssetRepresentation *rep = [asset defaultRepresentation];
        Byte *buffer = (Byte*)malloc(rep.size);
        NSUInteger buffered = [rep getBytes:buffer fromOffset:0.0 length:rep.size error:nil];
        NSData *data = [NSData dataWithBytesNoCopy:buffer length:buffered freeWhenDone:YES];
        NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent: @"temp.m4v"];
        [data writeToFile:filePath atomically:YES];
    } failureBlock:^(NSError *err) {
        NSLog(@"Error: %@",[err localizedDescription]);
    }];
    
}
+ (void)saveImage:(UIImage *)image withName:(NSString *)name {
    NSData *data = UIImageJPEGRepresentation(image, 1);
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *fullPath = [NSTemporaryDirectory() stringByAppendingPathComponent:name];
    [fileManager createFileAtPath:fullPath contents:data attributes:nil];
}


@end
