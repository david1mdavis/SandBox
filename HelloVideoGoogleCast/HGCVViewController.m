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
    [self video];
}


-(void)video {
    ELCImagePickerController *elcPicker = [[ELCImagePickerController alloc] initVideoPicker];
    elcPicker.maximumImagesCount = 1;
    elcPicker.returnsOriginalImage = NO; //Only return the fullScreenImage, not the fullResolutionImage
	elcPicker.imagePickerDelegate = self;
    
    [self presentViewController:elcPicker animated:YES completion:nil];

    
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
        
        //dmd
       _theFileName =@"test.mp4";
        NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:_theFileName];
        
        ALAssetsLibrary *assetLibrary=[[ALAssetsLibrary alloc] init];
        [assetLibrary assetForURL:mediaurl resultBlock:^(ALAsset *asset) {
            ALAssetRepresentation *rep = [asset defaultRepresentation];
            Byte *buffer = (Byte*)malloc(rep.size);
            NSUInteger buffered = [rep getBytes:buffer fromOffset:0.0 length:rep.size error:nil];
            NSData *data = [NSData dataWithBytesNoCopy:buffer length:buffered freeWhenDone:YES];
            [data writeToFile:filePath atomically:YES];
        } failureBlock:^(NSError *err) {
            NSLog(@"Error: %@",[err localizedDescription]);
        }];
        
        //dmd
      //  NSURL *videoUrl =   [NSURL fileURLWithPath:filePath];;
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
       // [self dismissModalViewControllerAnimated:YES];
        [self rotateVideo:videoAngleInDegree ];
        
        
        
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

- (void)video1 {
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePicker.mediaTypes = [[NSArray alloc] initWithObjects:(NSString *)kUTTypeMovie,      nil];
    imagePicker.videoQuality = UIImagePickerControllerQualityTypeHigh;
    
    [self presentModalViewController:imagePicker animated:YES];
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



-(void) rotateVideo:(float)rad{
    
    
    NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:_theFileName];
    NSURL *sampleURL = [NSURL fileURLWithPath:filePath];
    
    _movieFile = [[GPUImageMovie alloc] initWithURL:sampleURL];
    _movieFile.runBenchmark = YES;
    _movieFile.playAtActualSpeed = NO;
    GPUImageTransformFilter *filter ;
 
    
    
    filter = [[GPUImageTransformFilter alloc] init];

    
    
    
    [filter setAffineTransform:CGAffineTransformMakeRotation(rad)];
    
    [_movieFile addTarget:filter];
    _theFileName = @"temp.m4v";
    filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:_theFileName];
   
    unlink([filePath UTF8String]);
   
    NSURL *movieURL = [NSURL fileURLWithPath:filePath];
    
   
    _movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:movieURL size:CGSizeMake(1280 , 720)];
    [filter addTarget:_movieWriter];
    
    // Configure this for video from the movie file, where we want to preserve all video frames and audio samples
    _movieWriter.shouldPassthroughAudio = YES;
    _movieFile.audioEncodingTarget = _movieWriter;
    [_movieFile enableSynchronizedEncodingUsingMovieWriter:_movieWriter];
    
    [_movieWriter startRecording];
    [_movieFile startProcessing];
    
    [_movieWriter setCompletionBlock:^{
        [_filter removeTarget:_movieWriter];
        [_movieWriter finishRecording];
    }];
}



-(void) rotateVideo2:(float)rad{
    

     NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:_theFileName];
    NSURL *sampleURL = [NSURL fileURLWithPath:filePath];
  
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
    
    //[filterG addFilter:filter];
    [_movieFile addTarget:filterG];
    _theFileName = @"temp.m4v";
    filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:_theFileName];
    //filePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Movie.m4v"];
    unlink([filePath UTF8String]);
//    NSURL *movieURL = [[NSURL alloc] initWithString:filePath];
     NSURL *movieURL = [NSURL fileURLWithPath:filePath];
    
//    _movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:movieURL size:CGSizeMake(1280 , 720)];
    _movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:movieURL size:CGSizeMake(1280 , 720)];
    [filterG addTarget:_movieWriter];
    
    // Configure this for video from the movie file, where we want to preserve all video frames and audio samples
    _movieWriter.shouldPassthroughAudio = YES;
    _movieFile.audioEncodingTarget = _movieWriter;
    [_movieFile enableSynchronizedEncodingUsingMovieWriter:_movieWriter];
    
    [_movieWriter startRecording];
    [_movieFile startProcessing];
    
    [_movieWriter setCompletionBlock:^{
        [_filter removeTarget:_movieWriter];
        [_movieWriter finishRecording];
    }];
}


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    
    if (CFStringCompare ((__bridge CFStringRef) mediaType, kUTTypeMovie, 0) == kCFCompareEqualTo) {
        
        
    /*    NSURL *videoURL = [info objectForKey:UIImagePickerControllerMediaURL];
        
        NSData *videoData = [NSData dataWithContentsOfURL:videoURL];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *tempPath = [documentsDirectory stringByAppendingFormat:@"/vid1.mp4"];
        
        BOOL success = [videoData writeToFile:tempPath atomically:NO];
        
      */
        
        
        
        
        NSString *moviePath = [[info objectForKey:UIImagePickerControllerMediaURL] path];
        // NSLog(@"%@",moviePath);
        NSURL *videoUrl=(NSURL*)[info objectForKey:UIImagePickerControllerMediaURL];
        
        if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum (moviePath)) {
         //dmd   UISaveVideoAtPathToSavedPhotosAlbum (moviePath, nil, nil, nil);
          //  theFileName = [[string lastPathComponent] moviePath];
           // _theFileName = [[moviePath lastPathComponent] stringByDeletingPathExtension];
            NSURL *mediaURL; // Your video's URL
            AVURLAsset *asset = [AVURLAsset URLAssetWithURL:videoUrl options:nil];
            NSArray *tracks = [asset tracksWithMediaType:AVMediaTypeVideo];
            AVAssetTrack *track = [tracks objectAtIndex:0];
 //           int orientation = [[asset valueForProperty:ALAssetPropertyOrientation] intValue];
            CGSize mediaSize = track.naturalSize;
            NSLog(@"videosize %d  %d",(int)mediaSize.height, (int)mediaSize.width);
            _theFileName = [moviePath lastPathComponent];
            NSLog(_theFileName);
            
            CGAffineTransform txf       = [track preferredTransform];
            float  videoAngleInDegree  = (atan2(txf.b, txf.a));
         //   [self dismissModalViewControllerAnimated:YES];
            [self rotateVideo2:videoAngleInDegree ];
            [self dismissModalViewControllerAnimated:YES];

            
            
            
            

            
        }
    }
    
   

}

//Cast video
- (IBAction)castVideo22:(id)sender {
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

  //Define Media metadata
  GCKMediaMetadata *metadata = [[GCKMediaMetadata alloc] init];

  [metadata setString:@"Big Buck Bunny (2008)" forKey:kGCKMetadataKeyTitle];

  [metadata setString:@"Big Buck Bunny tells the story of a giant rabbit with a heart bigger than "
                       "himself. When one sunny day three rodents rudely harass him, something "
                       "snaps... and the rabbit ain't no bunny anymore! In the typical cartoon "
                       "tradition he prepares the nasty rodents a comical revenge."
               forKey:kGCKMetadataKeySubtitle];

  [metadata addImage:[[GCKImage alloc]
      initWithURL:[[NSURL alloc] initWithString:@"http://commondatastorage.googleapis.com/"
                                                 "gtv-videos-bucket/sample/images/BigBuckBunny.jpg"]
    //  initWithURL:[[NSURL alloc] initWithString:@"https://s3.amazonaws.com/vushaper/0e25ab6e098e3c9fee8b29b7d250215d_1.jpg" ]
            width:480
           height:360]];

  //define Media information
  GCKMediaInformation *mediaInformation =
      [[GCKMediaInformation alloc] initWithContentID:
      // @"https://s3.amazonaws.com/vushaper/0e25ab6e098e3c9fee8b29b7d250215d.mp4"
      // @"https://s3.amazonaws.com/vushaper/110dc4040afa22c968b20c0b72dafc2d.mp4"
       //@"https://s3.amazonaws.com/vushaper/00e69baa442cd0f80ed4968efad7ab17.m3u8"
             @"http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4"
                                          streamType:GCKMediaStreamTypeNone
                                         contentType:@"video/mp4"
                                            metadata:metadata
                                      streamDuration:0
                                          customData:nil];

  //cast video
  [_mediaControlChannel loadMedia:mediaInformation autoplay:TRUE playPosition:0];

}
- (IBAction)castVideo2:(id)sender {
    NSLog(@"Cast Video");
    GCKMediaMetadata *metadata = [[GCKMediaMetadata alloc] init];
/*    //Show alert if not connected
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
    
    //Define Media metadata
 
    
    [metadata setString:@"Big Buck Bunny (2008)" forKey:kGCKMetadataKeyTitle];
    
    [metadata setString:@"Big Buck Bunny tells the story of a giant rabbit with a heart bigger than "
     "himself. When one sunny day three rodents rudely harass him, something "
     "snaps... and the rabbit ain't no bunny anymore! In the typical cartoon "
     "tradition he prepares the nasty rodents a comical revenge."
                 forKey:kGCKMetadataKeySubtitle];
    
    [metadata addImage:[[GCKImage alloc]
                              initWithURL:[[NSURL alloc] initWithString:@"http://commondatastorage.googleapis.com/"
                                                                       "gtv-videos-bucket/sample/images/BigBuckBunny.jpg"]
                //        initWithURL:[[NSURL alloc] initWithString:@"https://s3.amazonaws.com/vushaper/0e25ab6e098e3c9fee8b29b7d250215d_1.jpg" ]
                        width:480
                        height:360]];
  */
    //define Media information
    NSString * url = [@"http://192.168.1.5:8080/" stringByAppendingPathComponent:_theFileName];;

     GCKMediaInformation *mediaInformation =
     [[GCKMediaInformation alloc] initWithContentID:
     // @"https://s3.amazonaws.com/vushaper/0e25ab6e098e3c9fee8b29b7d250215d.mp4"
     //@" http://192.168.1.5:8080/trim.yRttUC.MOV"
     url
      //dmd @"https://s3.amazonaws.com/vushaper/110dc4040afa22c968b20c0b72dafc2d.mp4"
     //@"https://s3.amazonaws.com/vushaper/00e69baa442cd0f80ed4968efad7ab17.m3u8"
     //     @"http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4"
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

@end
