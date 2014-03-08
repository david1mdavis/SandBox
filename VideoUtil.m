//
//  VideoUtil.m
//  MediaCast
//
//  Created by david davis on 3/3/14.
#import "VideoUtil.h"
#import "FileUtil.h"
#import "UIImage+Resizing.h"

@implementation VideoUtil


+ (void) writeImagesAsMovie:(NSArray *)array toPath:(NSString*)path  maxSize:(CGSize) maxPhotosize{
    
 
    
    
    NSString *filename = [NSTemporaryDirectory() stringByAppendingPathComponent:[array objectAtIndex:0]];
   
//    maxPhotosize = CGSizeMake(MIN(2000,maxPhotosize.width), MIN(2000,maxPhotosize.height));
    
        UIImage *first1 = [UIImage imageWithContentsOfFile:filename];
    maxPhotosize.width = 640*2;
    maxPhotosize.height =480*2;
    
    UIImage * backImage = [UIImage CreateFillImage: maxPhotosize withColor:[UIColor blackColor]];
    UIImage * backImageTemp = [backImage copy];
    

    //UIImage *first =[first1 scaleToSize:maxPhotosize usingMode:NYXResizeModeAspectFit];
    backImageTemp=  [backImageTemp drawImage:backImageTemp withsize:maxPhotosize];
 
    
  //  CGSize frameSize = image.size;
    
    NSError *error = nil;
    AVAssetWriter *videoWriter = [[AVAssetWriter alloc] initWithURL:
                                  [NSURL fileURLWithPath:[NSTemporaryDirectory()stringByAppendingPathComponent:path]] fileType:AVFileTypeQuickTimeMovie
                                                              error:&error];
    
    if(error) {
        NSLog(@"error creating AssetWriter: %@",[error description]);
    }
    NSDictionary *videoSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                   AVVideoCodecH264, AVVideoCodecKey,
                                   [NSNumber numberWithInt:backImage.size.width], AVVideoWidthKey,
                                   [NSNumber numberWithInt:backImage.size.height], AVVideoHeightKey,
                                   nil];
    
    AVAssetWriterInput* writerInput = [AVAssetWriterInput
                                        assetWriterInputWithMediaType:AVMediaTypeVideo
                                        outputSettings:videoSettings] ;
    
    NSMutableDictionary *attributes = [[NSMutableDictionary alloc] init];
    [attributes setObject:[NSNumber numberWithUnsignedInt:kCVPixelFormatType_32ARGB] forKey:(NSString*)kCVPixelBufferPixelFormatTypeKey];
    [attributes setObject:[NSNumber numberWithUnsignedInt:backImage.size.width] forKey:(NSString*)kCVPixelBufferWidthKey];
    [attributes setObject:[NSNumber numberWithUnsignedInt:backImage.size.height] forKey:(NSString*)kCVPixelBufferHeightKey];
    
    AVAssetWriterInputPixelBufferAdaptor *adaptor = [AVAssetWriterInputPixelBufferAdaptor
                                                     assetWriterInputPixelBufferAdaptorWithAssetWriterInput:writerInput
                                                     sourcePixelBufferAttributes:attributes];
    
    
    [videoWriter addInput:writerInput];
    
    // fixes all errors
    writerInput.expectsMediaDataInRealTime = YES;
    
    //Start a session:
    BOOL start = [videoWriter startWriting];
    NSLog(@"Session started? %d", start);
    [videoWriter startSessionAtSourceTime:kCMTimeZero];
    
    
    CVPixelBufferRef buffer = NULL;
//dmd    buffer = [VideoUtil pixelBufferFromCGImage:[first CGImage]];
     buffer = [self newPixelBufferFromCGImage2:[backImageTemp CGImage]andFrameSize:backImage.size];
   // backImageTemp = nil;
    
    BOOL result = [adaptor appendPixelBuffer:buffer withPresentationTime:kCMTimeZero];
    
    if (result == NO) //failes on 3GS, but works on iphone 4
        NSLog(@"failed to append buffer");
    
    if(buffer)
        CVBufferRelease(buffer);
    
    [NSThread sleepForTimeInterval:0.05];
    
   // int reverseSort = NO;
  //dmd  NSArray *newArray = [array sortedArrayUsingFunction:sort context:&reverseSort];
      NSArray *newArray = array ;
    
   //dmd delta = 1.0/[newArray count];
    
   //dmd int fps = (int)fpsSlider.value;
     int fps = (int)1;
    
    int i = 0;
    for (NSString *filename in newArray)
    {
        if (adaptor.assetWriterInput.readyForMoreMediaData)
        {
            i = i+3;
            
            NSLog(@"inside for loop %d %@ ",i, filename);
            CMTime frameTime = CMTimeMake(1, fps);
            CMTime lastTime=CMTimeMake(i, fps);
            CMTime presentTime=CMTimeAdd(lastTime, frameTime);
            
            
            
          NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:filename];
            
            UIImage *imgFrame = [UIImage imageWithContentsOfFile:filePath] ;
           // UIImage *imgFrame =[imgFrame1 scaleToSize:maxPhotosize usingMode:NYXResizeModeAspectFit];
            
            
             backImageTemp = [backImage copy];
            
           // imgFrame =[imgFrame scaleToSize:maxPhotosize usingMode:NYXResizeModeAspectFit];
            
            backImageTemp=  [backImageTemp drawImage:imgFrame withsize:maxPhotosize];
            imgFrame = nil;
        

            
            
    
            
            buffer = [self newPixelBufferFromCGImage2:[backImageTemp CGImage]andFrameSize:backImageTemp.size];
           
         
            
            BOOL result = [adaptor appendPixelBuffer:buffer withPresentationTime:presentTime];
            
            
            if (result == NO) //failes on 3GS, but works on iphone 4
            {
                NSLog(@"failed to append buffer");
                NSLog(@"The error is %@", [videoWriter error]);
            }
            if(buffer)
                CVBufferRelease(buffer);
          
            [NSThread sleepForTimeInterval:0.05];
            if ([[NSFileManager defaultManager] fileExistsAtPath:filePath])
            {
                [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
            }
            backImageTemp = nil;
         
        }
        else
        {
            NSLog(@"error");
            i--;
        }
        [NSThread sleepForTimeInterval:0.02];
    }
    
    //Finish the session:
    [writerInput markAsFinished];
    [videoWriter finishWriting];
    CVPixelBufferPoolRelease(adaptor.pixelBufferPool);
    videoWriter = nil;
    writerInput=nil;
}

/*- (void) writeImagesAsMovie:(NSString*)path
{
    NSError *error  = nil;
    UIImage *first = [arrImages objectAtIndex:0];
    CGSize frameSize = first.size;
    AVAssetWriter *videoWriter = [[AVAssetWriter alloc] initWithURL:
                                  [NSURL fileURLWithPath:path] fileType:AVFileTypeQuickTimeMovie
                                                              error:&error];
    NSParameterAssert(videoWriter);
    
    NSDictionary *videoSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                   AVVideoCodecH264, AVVideoCodecKey,
                                   [NSNumber numberWithInt:640], AVVideoWidthKey,
                                   [NSNumber numberWithInt:480], AVVideoHeightKey,
                                   nil];
    AVAssetWriterInput* writerInput = [AVAssetWriterInput
                                        assetWriterInputWithMediaType:AVMediaTypeVideo
                                        outputSettings:videoSettings] ;
    
    AVAssetWriterInputPixelBufferAdaptor *adaptor = [AVAssetWriterInputPixelBufferAdaptor
                                                     assetWriterInputPixelBufferAdaptorWithAssetWriterInput:writerInput
                                                     sourcePixelBufferAttributes:nil];
    
    NSParameterAssert(writerInput);
    NSParameterAssert([videoWriter canAddInput:writerInput]);
    [videoWriter addInput:writerInput];
    
    [videoWriter startWriting];
    [videoWriter startSessionAtSourceTime:kCMTimeZero];
    
    int frameCount = 0;
    CVPixelBufferRef buffer = NULL;
    for(UIImage *img in arrImages)
    {
        buffer = [self newPixelBufferFromCGImage:[img CGImage] andFrameSize:frameSize];
        
        if (adaptor.assetWriterInput.readyForMoreMediaData)
        {
            CMTime frameTime = CMTimeMake(frameCount,(int32_t) kRecordingFPS);
            [adaptor appendPixelBuffer:buffer withPresentationTime:frameTime];
            
            if(buffer)
                CVBufferRelease(buffer);
        }
        frameCount++;
    }
    
    [writerInput markAsFinished];
    [videoWriter finishWriting];
}

 */
+ (CVPixelBufferRef) newPixelBufferFromCGImage2: (CGImageRef) image andFrameSize:(CGSize)frameSize
{
 //   frameSize.height=848;
   // frameSize.width=1136;
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGImageCompatibilityKey,
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGBitmapContextCompatibilityKey,
                             nil];
    CVPixelBufferRef pxbuffer = NULL;
    CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault, frameSize.width,
                                          frameSize.height, kCVPixelFormatType_32ARGB, (CFDictionaryRef) CFBridgingRetain(options),
                                          &pxbuffer);
    NSParameterAssert(status == kCVReturnSuccess && pxbuffer != NULL);
    
    CVPixelBufferLockBaseAddress(pxbuffer, 0);
    void *pxdata = CVPixelBufferGetBaseAddress(pxbuffer);
    NSParameterAssert(pxdata != NULL);
    
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(pxdata, frameSize.width,
                                            
                                                    frameSize.height, 8, 4*frameSize.width, rgbColorSpace,
                                                 kCGImageAlphaNoneSkipFirst);
    NSParameterAssert(context);
    CGContextConcatCTM(context, CGAffineTransformMakeRotation(0));
    CGContextDrawImage(context, CGRectMake(0, 0, CGImageGetWidth(image),
                                           CGImageGetHeight(image)), image);
    CGColorSpaceRelease(rgbColorSpace);
    CGContextRelease(context);
    
    CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
    
    return pxbuffer;
}

+ (CVPixelBufferRef) pixelBufferFromCGImage: (CGImageRef) image
{
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGImageCompatibilityKey,
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGBitmapContextCompatibilityKey,
                             nil];
    CVPixelBufferRef pxbuffer = NULL;
    
    CVPixelBufferCreate(kCFAllocatorDefault, CGImageGetWidth(image),
                        CGImageGetHeight(image), kCVPixelFormatType_32ARGB, (CFDictionaryRef) CFBridgingRetain(options),
                        &pxbuffer);
    
    CVPixelBufferLockBaseAddress(pxbuffer, 0);
    void *pxdata = CVPixelBufferGetBaseAddress(pxbuffer);
    
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(pxdata, CGImageGetWidth(image),
                                              //dmd   CGImageGetHeight(image), 8, 4*CGImageGetWidth(image), rgbColorSpace,
                                                    CGImageGetHeight(image), 8,0, rgbColorSpace,
                                                 kCGImageAlphaNoneSkipFirst);
    
    CGContextConcatCTM(context, CGAffineTransformMakeRotation(0));
    
   // CGAffineTransform flipVertical = CGAffineTransformMake(
     //                                                      1, 0, 0, -1, 0, CGImageGetHeight(image)
       //                                                    );
   //dmd CGContextConcatCTM(context, flipVertical);
    
  //  CGAffineTransform flipHorizontal = CGAffineTransformMake(
    //                                                         -1.0, 0.0, 0.0, 1.0, CGImageGetWidth(image), 0.0
      //                                                       );
    
    //dmdCGContextConcatCTM(context, flipHorizontal);
    
    CGContextDrawImage(context, CGRectMake(0, 0, CGImageGetWidth(image),
                                           CGImageGetHeight(image)), image);
    CGColorSpaceRelease(rgbColorSpace);
    CGContextRelease(context);
    
    CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
    
    return pxbuffer;
}

+(void) savePixbuf:(CVPixelBufferRef )imageDataSampleBuffer{
    CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(imageDataSampleBuffer);
    CFDictionaryRef attachments = CMCopyDictionaryOfAttachments(kCFAllocatorDefault, imageDataSampleBuffer, kCMAttachmentMode_ShouldPropagate);
    CIImage *ciImage = [[CIImage alloc] initWithCVPixelBuffer:pixelBuffer options:(__bridge NSDictionary *)attachments];
    if (attachments)
        CFRelease(attachments);
    size_t width = CVPixelBufferGetWidth(pixelBuffer);
    size_t height = CVPixelBufferGetHeight(pixelBuffer);
    if (width && height) { // test to make sure we have valid dimensions
        UIImage *image = [[UIImage alloc] initWithCIImage:ciImage];

    
    UIGraphicsEndImageContext();
}
}


+(void) addAudioToVidoe:(NSURL*) audioUrl  videoURU:(NSURL*)videoUrl{
  
    AVURLAsset* audioAsset = [[AVURLAsset alloc]initWithURL:audioUrl options:nil];
    AVURLAsset* videoAsset = [[AVURLAsset alloc]initWithURL:videoUrl options:nil];
    
    AVMutableComposition* mixComposition = [AVMutableComposition composition];
    
    AVMutableCompositionTrack *compositionCommentaryTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio
                                                                                        preferredTrackID:kCMPersistentTrackID_Invalid];
    [compositionCommentaryTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, audioAsset.duration)
                                        ofTrack:[[audioAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0]
                                         atTime:kCMTimeZero error:nil];
    
    AVMutableCompositionTrack *compositionVideoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo
                                                                                   preferredTrackID:kCMPersistentTrackID_Invalid];
    [compositionVideoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoAsset.duration)
                                   ofTrack:[[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0]
                                    atTime:kCMTimeZero error:nil];
    
    AVAssetExportSession* _assetExport = [[AVAssetExportSession alloc] initWithAsset:mixComposition
                                                                          presetName:AVAssetExportPresetPassthrough];
    
    NSString* videoName = @"export.mov";
    
    NSString *exportPath = [NSTemporaryDirectory() stringByAppendingPathComponent:videoName];
    NSURL    *exportUrl = [NSURL fileURLWithPath:exportPath];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:exportPath])
    {
        [[NSFileManager defaultManager] removeItemAtPath:exportPath error:nil];
    }
    
    _assetExport.outputFileType = @"com.apple.quicktime-movie";
    NSLog(@"file type %@",_assetExport.outputFileType);
    _assetExport.outputURL = exportUrl;
    _assetExport.shouldOptimizeForNetworkUse = YES;
    
    [_assetExport exportAsynchronouslyWithCompletionHandler:
     ^(void ) {      
         // your completion code here
     }];
     
     
     }
+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)size {
   // if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
     //   UIGraphicsBeginImageContextWithOptions(size, NO, [[UIScreen mainScreen] scale]);
   // } else {
        UIGraphicsBeginImageContext(size);
   // }
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

+ (UIImage *)imageWithImage:(UIImage *)image scaledToMaxWidth:(CGFloat)width maxHeight:(CGFloat)height {
    CGFloat oldWidth = image.size.width;
    CGFloat oldHeight = image.size.height;
    
    CGFloat scaleFactor = (oldWidth > oldHeight) ? width / oldWidth : height / oldHeight;
    
    CGFloat newHeight = oldHeight * scaleFactor;
    CGFloat newWidth = oldWidth * scaleFactor;
  //  CGSize newSize = CGSizeMake(newWidth, newHeight);
   
    return([UIImage imageWithCGImage:[image CGImage]
                        scale:(image.scale * scaleFactor)
                  orientation:(image.imageOrientation)]);
    
    //return [self imageWithImage:image scaledToSize:newSize];
}

+ (UIImage *)imageWithImage:(UIImage *)image MaxWidth:(CGFloat)width scaledTomaxHeight:(CGFloat)height {
    CGFloat oldWidth = image.size.width;
    CGFloat oldHeight = image.size.height;
    
 CGFloat scaleFactor = (oldWidth > oldHeight) ? width / oldWidth : height / oldHeight;
 //   CGFloat scaleFactor = (oldWidth < oldHeight) ? oldWidth / width : oldHeight / height;


    
    return([UIImage imageWithCGImage:[image CGImage]
                               scale:(image.scale * scaleFactor)
                         orientation:(image.imageOrientation)]);
    

}

     
@end
