//
//  VideoUtil.h
//  MediaCast
//
//  Created by david davis on 3/3/14.
//  Copyright (c) 2014 Google Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>


@interface VideoUtil : NSObject
+ (void) writeImagesAsMovie:(NSArray *)array toPath:(NSString*)path  maxSize:(CGSize) maxPhotosize;
+ (void) writeImagesAsMovie:(NSArray *)array toPath:(NSString*)path;
+ (CVPixelBufferRef) pixelBufferFromCGImage: (CGImageRef) image;

@end
