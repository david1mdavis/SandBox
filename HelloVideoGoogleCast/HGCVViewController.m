// Copyright 2014 Google Inc. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#import "HGCVViewController.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import <AVFoundation/AVFoundation.h>


static NSString *const kReceiverAppID = @"9D100972";

@interface HGCVViewController () {

  UIImage *_btnImage;
  UIImage *_btnImageSelected;

}

@property GCKMediaControlChannel *mediaControlChannel;
@property GCKApplicationMetadata *applicationMetadata;
@property GCKDevice *selectedDevice;
@property(nonatomic, strong) GCKDeviceScanner *deviceScanner;
@property(nonatomic, strong) UIButton *chromecastButton;
@property(nonatomic, strong) GCKDeviceManager *deviceManager;
@property(nonatomic, readonly) GCKMediaInformation *mediaInformation;
@property(nonatomic, strong)  NSString* theFileName;
@property(nonatomic, strong) GPUImageMovie *movieFile;
@property(nonatomic, strong) GPUImageOutput<GPUImageInput> *filter;
@property(nonatomic, strong) GPUImageMovieWriter *movieWriter;
@property(nonatomic,retain) IBOutlet UISegmentedControl *filterSegment;

@end

@implementation HGCVViewController

- (void)viewDidLoad {
  [super viewDidLoad];

  //Create chromecast button
  _btnImage = [UIImage imageNamed:@"icon-cast-identified.png"];
  _btnImageSelected = [UIImage imageNamed:@"icon-cast-connected.png"];

  _chromecastButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
  [_chromecastButton addTarget:self
                        action:@selector(chooseDevice:)
              forControlEvents:UIControlEventTouchDown];
  _chromecastButton.frame = CGRectMake(0, 0, _btnImage.size.width, _btnImage.size.height);
  [_chromecastButton setImage:nil forState:UIControlStateNormal];
  _chromecastButton.hidden = YES;

  self.navigationItem.rightBarButtonItem =
      [[UIBarButtonItem alloc] initWithCustomView:_chromecastButton];

  //Initialize device scanner
  self.deviceScanner = [[GCKDeviceScanner alloc] init];

  [self.deviceScanner addListener:self];
  [self.deviceScanner startScan];

}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (void)chooseDevice:(id)sender {
  //Choose device
  if (self.selectedDevice == nil) {
    //Choose device
    UIActionSheet *sheet =
        [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Connect to Device", nil)
                                    delegate:self
                           cancelButtonTitle:nil
                      destructiveButtonTitle:nil
                           otherButtonTitles:nil];

    for (GCKDevice *device in self.deviceScanner.devices) {
      [sheet addButtonWithTitle:device.friendlyName];
    }

    [sheet addButtonWithTitle:NSLocalizedString(@"Cancel", nil)];
    sheet.cancelButtonIndex = sheet.numberOfButtons - 1;

    //show device selection
    [sheet showInView:_chromecastButton];
  } else {
    // Gather stats from device.
    [self updateStatsFromDevice];

    NSString *friendlyName = [NSString stringWithFormat:NSLocalizedString(@"Casting to %@", nil),
        self.selectedDevice.friendlyName];
    NSString *mediaTitle = [self.mediaInformation.metadata stringForKey:kGCKMetadataKeyTitle];

    UIActionSheet *sheet = [[UIActionSheet alloc] init];
    sheet.title = friendlyName;
    sheet.delegate = self;
    if (mediaTitle != nil) {
      [sheet addButtonWithTitle:mediaTitle];
    }

    //Offer disconnect option
    [sheet addButtonWithTitle:@"Disconnect"];
    [sheet addButtonWithTitle:@"Cancel"];
    sheet.destructiveButtonIndex = (mediaTitle != nil ? 1 : 0);
    sheet.cancelButtonIndex = (mediaTitle != nil ? 2 : 1);

    [sheet showInView:_chromecastButton];
  }
}

- (void)updateStatsFromDevice {

  if (self.mediaControlChannel && self.isConnected) {
    _mediaInformation = self.mediaControlChannel.mediaStatus.mediaInformation;
  }
}

- (BOOL)isConnected {
  return self.deviceManager.isConnected;
}

- (void)connectToDevice {
  if (self.selectedDevice == nil)
    return;

  NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
  self.deviceManager =
      [[GCKDeviceManager alloc] initWithDevice:self.selectedDevice
                             clientPackageName:[info objectForKey:@"CFBundleIdentifier"]];
  self.deviceManager.delegate = self;
  [self.deviceManager connect];

}

- (void)deviceDisconnected {
  self.mediaControlChannel = nil;
  self.deviceManager = nil;
  self.selectedDevice = nil;
}

- (void)updateButtonStates {
  if (self.deviceScanner.devices.count == 0) {
    //Hide the cast button
    _chromecastButton.hidden = YES;
  } else {
    //Show cast button
    [_chromecastButton setImage:_btnImage forState:UIControlStateNormal];
    _chromecastButton.hidden = NO;

    if (self.deviceManager && self.deviceManager.isConnected) {
      //Show cast button in enabled state
      [_chromecastButton setTintColor:[UIColor blueColor]];
    } else {
      //Show cast button in disabled state
      [_chromecastButton setTintColor:[UIColor grayColor]];

    }
  }

}
- (IBAction)castVideo:(id)sender {
  //  castMidea.hidden =YES;
    choosmedia.hidden =YES;

    [self video];
}

//First try at rotate on iPhone 5 GPU version is faster might need for iphone 4s

- (void) getVideoComposition:(AVAsset*)asset
{
    
    AVMutableComposition *mutableComposition = nil;
    AVMutableVideoComposition *mutableVideoComposition = nil;
    
    AVMutableVideoCompositionInstruction *instruction = nil;
    AVMutableVideoCompositionLayerInstruction *layerInstruction = nil;
    CGAffineTransform t1;
    CGAffineTransform t2;
    
    AVAssetTrack *assetVideoTrack = nil;
    AVAssetTrack *assetAudioTrack = nil;
    // Check if the asset contains video and audio tracks
    if ([[asset tracksWithMediaType:AVMediaTypeVideo] count] != 0) {
        assetVideoTrack = [asset tracksWithMediaType:AVMediaTypeVideo][0];
    }
    if ([[asset tracksWithMediaType:AVMediaTypeAudio] count] != 0) {
        assetAudioTrack = [asset tracksWithMediaType:AVMediaTypeAudio][0];
    }
    
    CMTime insertionPoint = kCMTimeZero;
    NSError *error = nil;
    
    
    // Step 1
    // Create a composition with the given asset and insert audio and video tracks into it from the asset
    // Check whether a composition has already been created, i.e, some other tool has already been applied
    // Create a new composition
    mutableComposition = [AVMutableComposition composition];
    
    // Insert the video and audio tracks from AVAsset
    if (assetVideoTrack != nil) {
        AVMutableCompositionTrack *compositionVideoTrack = [mutableComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
        [compositionVideoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, [asset duration]) ofTrack:assetVideoTrack atTime:insertionPoint error:&error];
    }
    if (assetAudioTrack != nil) {
        AVMutableCompositionTrack *compositionAudioTrack = [mutableComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
        [compositionAudioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, [asset duration]) ofTrack:assetAudioTrack atTime:insertionPoint error:&error];
    }
    
    
    // Step 2
    // Translate the composition to compensate the movement caused by rotation (since rotation would cause it to move out of frame)
    t1 = CGAffineTransformMakeTranslation(assetVideoTrack.naturalSize.height, 0.0);
    // Rotate transformation
    t2 = CGAffineTransformRotate(t1, M_PI/2);
    
    
    // Step 3
    // Set the appropriate render sizes and rotational transforms
    // Create a new video composition
    mutableVideoComposition = [AVMutableVideoComposition videoComposition];
    mutableVideoComposition.renderSize = CGSizeMake(assetVideoTrack.naturalSize.height,assetVideoTrack.naturalSize.width);
    mutableVideoComposition.frameDuration = CMTimeMake(1, 30);
    
    // The rotate transform is set on a layer instruction
    instruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    instruction.timeRange = CMTimeRangeMake(kCMTimeZero, [mutableComposition duration]);
    layerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:(mutableComposition.tracks)[0]];
    [layerInstruction setTransform:t2 atTime:kCMTimeZero];
    
    
    // Step 4
    // Add the transform instructions to the video composition
    instruction.layerInstructions = @[layerInstruction];
    mutableVideoComposition.instructions = @[instruction];
    _mutableComposition = mutableComposition ;
    _mutableVideoComposition = mutableVideoComposition ;
    
  
}

-(void) convertVideo:(NSURL*)outputURL
             handler:(void (^)(AVAssetExportSession*))handler
{
    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:[_mutableComposition copy] presetName:AVAssetExportPresetHighestQuality];
    exportSession.outputURL = outputURL;
    exportSession.outputFileType = AVFileTypeQuickTimeMovie;

    exportSession.videoComposition = _mutableVideoComposition;
    
    [exportSession exportAsynchronouslyWithCompletionHandler:^(void)
     {
         NSLog(@"Status is %d %@", exportSession.status, exportSession.error);
         
         handler(exportSession);
         
     }];
    
}

- (void)convertVideoToLowQuailtyWithInputURL:(NSURL*)inputURL
                                   outputURL:(NSURL*)outputURL
                                     handler:(void (^)(AVAssetExportSession*))handler
{
    [[NSFileManager defaultManager] removeItemAtURL:outputURL error:nil];
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:inputURL options:nil];
    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:asset presetName:AVAssetExportPresetHighestQuality];
    exportSession.outputURL = outputURL;
    exportSession.outputFileType = AVFileTypeMPEG4;
    exportSession.videoComposition = _mutableVideoComposition;
    [exportSession exportAsynchronouslyWithCompletionHandler:^(void)
     {
         handler(exportSession);
              }];
}

-(void)video {
    ELCImagePickerController *elcPicker = [[ELCImagePickerController alloc] initVideoPicker];
    elcPicker.maximumImagesCount = 1;
    elcPicker.returnsOriginalImage = NO; //Only return the fullScreenImage, not the fullResolutionImage
	elcPicker.imagePickerDelegate = self;
    
    [self presentViewController:elcPicker animated:YES completion:nil];

    
}

-(void)copyVideoToTemp:(NSURL*) mediaURL
{
ALAssetsLibrary *assetLibrary=[[ALAssetsLibrary alloc] init];
 [assetLibrary assetForURL:mediaURL resultBlock:^(ALAsset *asset) {
 ALAssetRepresentation *rep = [asset defaultRepresentation];
 Byte *buffer = (Byte*)malloc(rep.size);
 NSUInteger buffered = [rep getBytes:buffer fromOffset:0.0 length:rep.size error:nil];
 NSData *data = [NSData dataWithBytesNoCopy:buffer length:buffered freeWhenDone:YES];
 _theFileName = @"temp.m4v";
 NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent: _theFileName];
 [data writeToFile:filePath atomically:YES];
 } failureBlock:^(NSError *err) {
 NSLog(@"Error: %@",[err localizedDescription]);
 }];

}

- (void)elcImagePickerController:(ELCImagePickerController *)picker didFinishPickingMediaWithInfo:(NSArray *)info
{
   [self dismissViewControllerAnimated:YES completion:nil];
	
/*    for (UIView *v in [_scrollView subviews]) {
        [v removeFromSuperview];
    }
    
	CGRect workingFrame = _scrollView.frame;

	workingFrame.origin.x = 0;
 */
    NSMutableArray *images = [NSMutableArray arrayWithCapacity:[info count]];
	
	for (NSDictionary *dict in info) {
       
        
        UIImage *image = [dict objectForKey:UIImagePickerControllerOriginalImage];
        [images addObject:image];
        NSURL *mediaurl =    [dict objectForKey:UIImagePickerControllerReferenceURL];
        NSString *path = [[NSString alloc] initWithString:[ mediaurl absoluteString]];
        NSLog(@"mediaUL %@",path);

        _theFileName =@"test.mp4";
        NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:_theFileName];
        
        AVURLAsset *asset2 = [AVURLAsset URLAssetWithURL:mediaurl options:nil];
        CMTime duration;
        duration = asset2.duration;
        
        NSLog(@"media legth seconds = %f", CMTimeGetSeconds(duration));
        
        NSURL *outputURL = [NSURL fileURLWithPath:filePath];
             {
            printf("completed\n");
            AVURLAsset *asset = [AVURLAsset URLAssetWithURL:mediaurl options:nil];
          
            
            NSArray *tracks = [asset tracksWithMediaType:AVMediaTypeVideo];
            AVAssetTrack *track = [tracks objectAtIndex:0];
            //           int orientation = [[asset valueForProperty:ALAssetPropertyOrientation] intValue];
            CGSize mediaSize = track.naturalSize;
            NSLog(@"videosize %d  %d",(int)mediaSize.height, (int)mediaSize.width);
            // _theFileName = [filePath lastPathComponent];
            NSLog(_theFileName);
            
            CGAffineTransform txf       = [track preferredTransform];
            float  videoAngleInDegree  = (atan2(txf.b, txf.a));

            int filterIndex =[self.filterSegment selectedSegmentIndex];
            switch (filterIndex) {
                case 0:
                    [self rotateVideo:mediaurl radins:0.0 videoWidth:mediaSize.width videoHheightt:mediaSize.height ];
                    break;
                    
                case 1:
                    [self rotateVideo:mediaurl radins:videoAngleInDegree videoWidth:mediaSize.width videoHheightt:mediaSize.height ];
                    break;
                    
                case 2:
                    [self sketchVideo:mediaurl radins:videoAngleInDegree videoWidth:mediaSize.width videoHheightt:mediaSize.height ];
                    break;
                    
                case 3:
                    [self toonVideo:mediaurl radins:videoAngleInDegree videoWidth:mediaSize.width videoHheightt:mediaSize.height ];
                    break;
            }
            
        }

        
       
        
           //dmd
      //  NSURL *videoUrl =   [NSURL fileURLWithPath:filePath];;
        
        
        
      //   [self dismissViewControllerAnimated:YES completion:nil];
        
        
        
        /*		UIImageView *imageview = [[UIImageView alloc] initWithImage:image];
         [imageview setContentMode:UIViewContentModeScaleAspectFit];
         imageview.frame = workingFrame;
         
         [_scrollView addSubview:imageview];
         
         workingFrame.origin.x = workingFrame.origin.x + workingFrame.size.width;
         */
	}
    
//    self.chosenImages = images;
	
//	[_scrollView setPagingEnabled:YES];
//	[_scrollView setContentSize:CGSizeMake(workingFrame.origin.x, workingFrame.size.height)];
}


- (void)elcImagePickerControllerDidCancel:(ELCImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}




/*
-(void) exportcameraroll( )
{
    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:composition presetName:AVAssetExportPresetMediumQuality];
    self.exportSession.outputURL = [NSURL fileURLWithPath:path];
    self.exportSession.outputFileType = AVFileTypeQuickTimeMovie;
    [self.exportSession exportAsynchronouslyWithCompletionHandler:^{
        
        switch (self.exportSession.status)
        {
            case AVAssetExportSessionStatusCompleted:
                NSLog(@"Export OK");
                if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(path)) {
                    UISaveVideoAtPathToSavedPhotosAlbum(path, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
                }
                break;
            case AVAssetExportSessionStatusFailed:
                NSLog (@"AVAssetExportSessionStatusFailed: %@", self.exportSession.error);
                break;
            case AVAssetExportSessionStatusCancelled:
                NSLog(@"Export Cancelled");
                break;
        }
    }];
    
}
 */
- (UIImageOrientation)getImageOrientationWithVideoOrientation:(UIInterfaceOrientation)videoOrientation {
    UIImageOrientation imageOrientation;
    switch (videoOrientation) {
        case UIInterfaceOrientationLandscapeLeft:
            imageOrientation = UIImageOrientationUp;
            break;
        case UIInterfaceOrientationLandscapeRight:
            imageOrientation = UIImageOrientationDown;
            break;
        case UIInterfaceOrientationPortrait:
            imageOrientation = UIImageOrientationRight;
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            imageOrientation = UIImageOrientationLeft;
            break;
    }
    return imageOrientation;
}

typedef enum {
    LBVideoOrientationUp,               //Device starts recording in Portrait
	LBVideoOrientationDown,             //Device starts recording in Portrait upside down
	LBVideoOrientationLeft,             //Device Landscape Left  (home button on the left side)
	LBVideoOrientationRight,            //Device Landscape Right (home button on the Right side)
    LBVideoOrientationNotFound = 99     //An Error occurred or AVAsset doesn't contains video track
} LBVideoOrientation;


-(void) sketchVideo: (NSURL *)sampleURL
             radins: (float) rad
         videoWidth: (int)width
      videoHheightt: (int)Height{
    
     NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:_theFileName];
   
    _movieFile = [[GPUImageMovie alloc] initWithURL:sampleURL];
    _movieFile.runBenchmark = YES;
    _movieFile.playAtActualSpeed = NO;
    GPUImageTransformFilter *filter ;
    GPUImageSketchFilter *filter2 ;
    GPUImageFilterGroup* filterG = [[GPUImageFilterGroup alloc] init];
    
    
    filter = [[GPUImageTransformFilter alloc] init];
    filter2 = [[GPUImageSketchFilter alloc] init];
    
    [filter setAffineTransform:CGAffineTransformMakeRotation(rad)];
    [filterG  addFilter:filter];
    [filterG  addFilter:filter2];
    
    [filter addTarget:filter2];
    [(GPUImageFilterGroup *)filterG setInitialFilters:[NSArray arrayWithObject:filter]];
    [(GPUImageFilterGroup *)filterG setTerminalFilter:filter2];
    
    [_movieFile addTarget:filterG];
    _theFileName = @"temp.m4v";
    filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:_theFileName];
    
    unlink([filePath UTF8String]);
    //    NSURL *movieURL = [[NSURL alloc] initWithString:filePath];
    NSURL *movieURL = [NSURL fileURLWithPath:filePath];
    
    //    _movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:movieURL size:CGSizeMake(1280 , 720)];
    if (Height>width)
        _movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:movieURL size:CGSizeMake(Height , width)];
    else
        _movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:movieURL size:CGSizeMake(width , Height)];
    [filterG addTarget:_movieWriter];
    
    // Configure this for video from the movie file, where we want to preserve all video frames and audio samples
    _movieWriter.shouldPassthroughAudio = YES;
    _movieFile.audioEncodingTarget = _movieWriter;
    [_movieFile enableSynchronizedEncodingUsingMovieWriter:_movieWriter];
    
    [_movieWriter startRecording];
    [_movieFile startProcessing];
    
    [_movieWriter setCompletionBlock:^{
        
        choosmedia.hidden =NO;
        castMidea.hidden =NO;
        
        [_filter removeTarget:_movieWriter];
        [_movieWriter finishRecording];
        
    }];
}



-(void) toonVideo: (NSURL *)sampleURL
           radins: (float) rad
       videoWidth: (int)width
    videoHheightt: (int)Height{
    
    NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:_theFileName];
   
    
    _movieFile = [[GPUImageMovie alloc] initWithURL:sampleURL];
    _movieFile.runBenchmark = YES;
    _movieFile.playAtActualSpeed = NO;
    GPUImageTransformFilter *filter ;
    GPUImageSmoothToonFilter *filter2 ;
    GPUImageFilterGroup* filterG = [[GPUImageFilterGroup alloc] init];
    
    
    filter  = [[GPUImageTransformFilter alloc] init];
    filter2 = [[GPUImageSmoothToonFilter alloc] init];
    
    
    [filter setAffineTransform:CGAffineTransformMakeRotation(rad)];
    [filterG  addFilter:filter];
    [filterG  addFilter:filter2];
    
    [filter addTarget:filter2];
    [(GPUImageFilterGroup *)filterG setInitialFilters:[NSArray arrayWithObject:filter]];
    [(GPUImageFilterGroup *)filterG setTerminalFilter:filter2];
    
   
    [_movieFile addTarget:filterG];
    _theFileName = @"temp.m4v";
    filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:_theFileName];
   
    unlink([filePath UTF8String]);
   
    NSURL *movieURL = [NSURL fileURLWithPath:filePath];
    
    //    _movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:movieURL size:CGSizeMake(1280 , 720)];
    if (Height>width)
        _movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:movieURL size:CGSizeMake(Height , width)];
    else
        _movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:movieURL size:CGSizeMake(width , Height)];
    [filterG addTarget:_movieWriter];
    
    // Configure this for video from the movie file, where we want to preserve all video frames and audio samples
    _movieWriter.shouldPassthroughAudio = YES;
    _movieFile.audioEncodingTarget = _movieWriter;
    [_movieFile enableSynchronizedEncodingUsingMovieWriter:_movieWriter];
    
    [_movieWriter startRecording];
    [_movieFile startProcessing];
    
    [_movieWriter setCompletionBlock:^{
        choosmedia.hidden =NO;
        castMidea.hidden =NO;
        [_filter removeTarget:_movieWriter];
        [_movieWriter finishRecording];
        
    }];
}




-(void) rotateVideo:( NSURL *)sampleURL
              radins: (float) rad
          videoWidth:(int)width
        videoHheightt:(int)Height{

    castMidea.hidden =YES;
    
    NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:_theFileName];
    _movieFile = [[GPUImageMovie alloc] initWithURL:sampleURL];
    _movieFile.runBenchmark = YES;
    _movieFile.playAtActualSpeed = YES;
    GPUImageTransformFilter *filter ;
    
    if (!rad)
    {
        [self copyVideoToTemp:sampleURL];
        choosmedia.hidden =NO;
         castMidea.hidden =NO;
        
      return;
    }
    
    filter = [[GPUImageTransformFilter alloc] init];
    
    
    [filter setAffineTransform:CGAffineTransformMakeRotation(rad)];
    
    [_movieFile addTarget:filter];
    _theFileName = @"temp.m4v";
    filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:_theFileName];
    
    unlink([filePath UTF8String]);
    
    NSURL *movieURL = [NSURL fileURLWithPath:filePath];
    
    if (Height>width)
        _movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:movieURL size:CGSizeMake( Height,width)];
    else
        _movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:movieURL size:CGSizeMake( width,Height)];
        
    [filter addTarget:_movieWriter];
    
    _movieWriter.shouldPassthroughAudio = YES;
    _movieFile.audioEncodingTarget = _movieWriter;
    [_movieFile enableSynchronizedEncodingUsingMovieWriter:_movieWriter];
    [_movieWriter startRecording];
    [_movieFile startProcessing];
    
    [_movieWriter setCompletionBlock:^{
        
        choosmedia.hidden = NO;
        castMidea.hidden  = NO;
        [_filter removeTarget:_movieWriter];
        [_movieWriter finishRecording];
        
       
    }];
}



//Cast video
- (IBAction)castVideo2:(id)sender {
  NSLog(@"Cast Video");

  //Show alert if not connected
  if (!self.deviceManager || !self.deviceManager.isConnected) {
    UIAlertView *alert =
        [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Not Connected", nil)
                                   message:NSLocalizedString(@"Please connect to Cast device", nil)
                                  delegate:nil
                         cancelButtonTitle:NSLocalizedString(@"OK", nil)
                         otherButtonTitles:nil];
    [alert show];
    return;
  }
   NSString * url = [@"http://192.168.1.5:8080" stringByAppendingPathComponent:@"stream/index.m3u8"];;
    NSLog(@"%@",url);
  //Define Media metadata
  GCKMediaMetadata *metadata = [[GCKMediaMetadata alloc] init];

  //define Media information
  GCKMediaInformation *mediaInformation =
 [[GCKMediaInformation alloc] initWithContentID:
       
       /*   CORS permission on AWS s3   is needed for live streaming
        <?xml version="1.0" encoding="UTF-8"?>
        <CORSConfiguration xmlns="http://s3.amazonaws.com/doc/2006-03-01/">
        <CORSRule>
        <AllowedOrigin>*</AllowedOrigin>
        <AllowedMethod>GET</AllowedMethod>
        <MaxAgeSeconds>3000</MaxAgeSeconds>
        <AllowedHeader>Content-Type</AllowedHeader>
        </CORSRule>
        </CORSConfiguration>
*/
                                  //      @"https://s3.amazonaws.com/vushaper/00e69baa442cd0f80ed4968efad7ab17.m3u8"
                                        url
                                        streamType:GCKMediaStreamTypeLive
                                        contentType:@"application/x-mpegURL"
                                        metadata:metadata
                                        streamDuration:0
                                        customData:nil];


  [_mediaControlChannel loadMedia:mediaInformation autoplay:TRUE playPosition:0];

}

- (IBAction)castVideo22:(id)sender {
    NSLog(@"Cast Video");
    GCKMediaMetadata *metadata = [[GCKMediaMetadata alloc] init];
  
 
    NSString * url = [NSString stringWithFormat:@"%@%@%@",@"http:\\",[self getIPAddress:TRUE],@":8080/temp.m4v"];
    NSLog(@"Started HTTP Server on url %@", url);

     GCKMediaInformation *mediaInformation =
     [[GCKMediaInformation alloc] initWithContentID:
     url
     streamType:GCKMediaStreamTypeNone
     contentType:@"video/mp4"
     metadata:metadata
     streamDuration:0
     customData:nil];
    
     NSLog(@"Medialurl = %@",url);
     
     //cast video
     [_mediaControlChannel loadMedia:mediaInformation autoplay:TRUE playPosition:0];
    
}


#pragma mark - GCKDeviceScannerListener
- (void)deviceDidComeOnline:(GCKDevice *)device {
  NSLog(@"device found!! %@", device.friendlyName);
  [self updateButtonStates];
}

- (void)deviceDidGoOffline:(GCKDevice *)device {
  [self updateButtonStates];
}

#pragma mark UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
  if (self.selectedDevice == nil) {
    if (buttonIndex < self.deviceScanner.devices.count) {
      self.selectedDevice = self.deviceScanner.devices[buttonIndex];
      NSLog(@"Selecting device:%@", self.selectedDevice.friendlyName);
      [self connectToDevice];
    }
  } else {
    if (buttonIndex == 1) {  //Disconnect button
      NSLog(@"Disconnecting device:%@", self.selectedDevice.friendlyName);
      // New way of doing things: We're not going to stop the applicaton. We're just going
      // to leave it.
      [self.deviceManager leaveApplication];
      // If you want to force application to stop, uncomment below
      //[self.deviceManager stopApplicationWithSessionID:self.applicationMetadata.sessionID];
      [self.deviceManager disconnect];

      [self deviceDisconnected];
      [self updateButtonStates];
    } else if (buttonIndex == 0) {
      // Join the existing session.

    }
  }
}

#pragma mark - GCKDeviceManagerDelegate

- (void)deviceManagerDidConnect:(GCKDeviceManager *)deviceManager {
  NSLog(@"connected!!");

  [self updateButtonStates];
  [self.deviceManager launchApplication:kReceiverAppID];
}

- (void)deviceManager:(GCKDeviceManager *)deviceManager
    didConnectToCastApplication:(GCKApplicationMetadata *)applicationMetadata
                      sessionID:(NSString *)sessionID
            launchedApplication:(BOOL)launchedApplication {

  NSLog(@"application has launched");
  self.mediaControlChannel = [[GCKMediaControlChannel alloc] init];
  self.mediaControlChannel.delegate = self;
  [self.deviceManager addChannel:self.mediaControlChannel];
  [self.mediaControlChannel requestStatus];

}

- (void)deviceManager:(GCKDeviceManager *)deviceManager
    didFailToLaunchCastApplicationWithError:(NSError *)error {
  [self showError:error];

  [self deviceDisconnected];
  [self updateButtonStates];
}

- (void)deviceManager:(GCKDeviceManager *)deviceManager
    didFailToConnectWithError:(GCKError *)error {
  [self showError:error];

  [self deviceDisconnected];
  [self updateButtonStates];
}

- (void)deviceManager:(GCKDeviceManager *)deviceManager didDisconnectWithError:(GCKError *)error {
  NSLog(@"Received notification that device disconnected");

  if (error != nil) {
    [self showError:error];
  }

  [self deviceDisconnected];
  [self updateButtonStates];

}

- (void)deviceManager:(GCKDeviceManager *)deviceManager
    didReceiveStatusForApplication:(GCKApplicationMetadata *)applicationMetadata {
  self.applicationMetadata = applicationMetadata;
}

#pragma mark - misc
- (void)showError:(NSError *)error {
  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil)
                                                  message:NSLocalizedString(error.description, nil)
                                                 delegate:nil
                                        cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                        otherButtonTitles:nil];
  [alert show];
}

//dmd this needs to be moved

#include <ifaddrs.h>
#include <arpa/inet.h>
#include <net/if.h>

#define IOS_CELLULAR    @"pdp_ip0"
#define IOS_WIFI        @"en0"
#define IP_ADDR_IPv4    @"ipv4"
#define IP_ADDR_IPv6    @"ipv6"

- (NSString *)getIPAddress:(BOOL)preferIPv4
{
    NSArray *searchArray = preferIPv4 ?
    @[ IOS_WIFI @"/" IP_ADDR_IPv4, IOS_WIFI @"/" IP_ADDR_IPv6, IOS_CELLULAR @"/" IP_ADDR_IPv4, IOS_CELLULAR @"/" IP_ADDR_IPv6 ] :
    @[ IOS_WIFI @"/" IP_ADDR_IPv6, IOS_WIFI @"/" IP_ADDR_IPv4, IOS_CELLULAR @"/" IP_ADDR_IPv6, IOS_CELLULAR @"/" IP_ADDR_IPv4 ] ;
    
    NSDictionary *addresses = [self getIPAddresses];
    //NSLog(@"addresses: %@", addresses);
    
    __block NSString *address;
    [searchArray enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop)
     {
         address = addresses[key];
         if(address) *stop = YES;
     } ];
    return address ? address : @"0.0.0.0";
}

- (NSDictionary *)getIPAddresses
{
    NSMutableDictionary *addresses = [NSMutableDictionary dictionaryWithCapacity:8];
    
    // retrieve the current interfaces - returns 0 on success
    struct ifaddrs *interfaces;
    if(!getifaddrs(&interfaces)) {
        // Loop through linked list of interfaces
        struct ifaddrs *interface;
        for(interface=interfaces; interface; interface=interface->ifa_next) {
            if(!(interface->ifa_flags & IFF_UP) || (interface->ifa_flags & IFF_LOOPBACK)) {
                continue; // deeply nested code harder to read
            }
            const struct sockaddr_in *addr = (const struct sockaddr_in*)interface->ifa_addr;
            if(addr && (addr->sin_family==AF_INET || addr->sin_family==AF_INET6)) {
                NSString *name = [NSString stringWithUTF8String:interface->ifa_name];
                char addrBuf[INET6_ADDRSTRLEN];
                if(inet_ntop(addr->sin_family, &addr->sin_addr, addrBuf, sizeof(addrBuf))) {
                    NSString *key = [NSString stringWithFormat:@"%@/%@", name, addr->sin_family == AF_INET ? IP_ADDR_IPv4 : IP_ADDR_IPv6];
                    addresses[key] = [NSString stringWithUTF8String:addrBuf];
                }
            }
        }
        // Free memory
        freeifaddrs(interfaces);
    }
    return [addresses count] ? addresses : nil;
}



@end
