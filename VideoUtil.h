//
//  VideoUtil.h
//  MediaCast
//
//  Created by david davis on 3/3/14.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import "PhotosViewController.h"


@interface VideoUtil : NSObject
+ (void) writeImagesAsMovie:(NSArray *)array toPath:(NSString*)path  maxSize:(CGSize) maxPhotosize;
+ (void) writeImagesAsMovie:(NSArray *)array toPath:(NSString*)path;
+ (CVPixelBufferRef) pixelBufferFromCGImage: (CGImageRef) image;
+(void) addAudioToVidoe:(NSURL*) audioUrl  videoURU:(NSURL*)videoUrl;

@end
