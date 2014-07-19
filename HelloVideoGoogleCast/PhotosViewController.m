//
//  PhotosViewController.m
//  MediaCast
//
//  Created by david davis on 3/2/14.

#import "PhotosViewController.h"
#import "DeviceViewController.h"
#import "FileUtil.h"
#import "NetworkUtil.h"
#import "VideoUtil.h"
#import "UIImage+Resizing.h"

@interface PhotosViewController (){
     ChromecastDeviceController *_chromecastController;
}

@end

@implementation PhotosViewController
-(void)selectPhotos {
    if (!_chromecastController.deviceManager.isConnectedToApp)
    {
        DeviceViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"devies"];
        [self presentViewController:vc animated:YES completion:nil];
    }

    _elcPicker = [[ELCImagePickerController alloc] initImagePicker];
    _elcPicker.maximumImagesCount = 70;
    _elcPicker.returnsOriginalImage = NO; //Only return the fullScreenImage, not the fullResolutionImage
	_elcPicker.imagePickerDelegate = self;
    _elcPicker.oneAtaTime = FALSE;
    
    
    [self presentViewController:_elcPicker animated:YES completion:nil];
    
    
}
- (IBAction)showPhotoOneAtATime:(id)sender {
    if (!_chromecastController.deviceManager.isConnectedToApp)
    {
        DeviceViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"devies"];
        [self presentViewController:vc animated:YES completion:nil];
    }

    _elcPicker = [[ELCImagePickerController alloc] initImagePicker];
    _elcPicker.maximumImagesCount = 1;
    _elcPicker.returnsOriginalImage = NO; //Only return the fullScreenImage, not the fullResolutionImage
	_elcPicker.imagePickerDelegate = self;
    _elcPicker.oneAtaTime = TRUE;
    
    [self presentViewController:_elcPicker animated:YES completion:nil];

    
}

- (IBAction)selectPhotos:(id)sender {
    [self selectPhotos];
    

}
- (void)elcImagePickerControllerDidCancel:(ELCImagePickerController *)picker
{
  [self dismissViewControllerAnimated:YES completion:nil];   
}


- (BOOL) assetCast:(NSMutableDictionary *)asset{
    if (!_chromecastController.deviceManager.isConnectedToApp)
    {
        DeviceViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"devies"];
        [self presentViewController:vc animated:YES completion:nil];
    }

    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        int photocout = 0;
        NSMutableArray* videoFileNameArray= [[NSMutableArray alloc] init];
        CGSize maxPhotosize;
      //  for (NSDictionary *dict in info) {
            
            
            UIImage *image = [asset objectForKey:UIImagePickerControllerOriginalImage];
            //  [images addObject:image];
            NSURL *mediaurl =    [asset objectForKey:UIImagePickerControllerReferenceURL];
            NSString *path = [[NSString alloc] initWithString:[ mediaurl absoluteString]];
            NSLog(@"mediaUL %@",path);
            
            //  AVURLAsset *asset2 = [AVURLAsset URLAssetWithURL:mediaurl options:nil];
            NSString *fileName =[NSString stringWithFormat:@"temp%d.jpg",photocout];
            [videoFileNameArray addObject:fileName];
        float fScale = 4;
            image = [image scaleByFactor:fScale];
            [FileUtil saveImage:image withName:fileName];
            maxPhotosize.height = MAX(maxPhotosize.height,image.size.height);
            maxPhotosize.width = MAX(maxPhotosize.width,image.size.width);
            
            [self castPhoto];
        
         });
            
            //
            
        //}

    return TRUE;
}







- (void)elcImagePickerController:(ELCImagePickerController *)picker didFinishPickingMediaWithInfo:(NSArray *)info
{
   [self dismissViewControllerAnimated:YES completion:nil];
	dispatch_async(dispatch_get_main_queue(), ^{
        _fLenInSeconds = 4.0/[info count];
        [_updateFilterTimer invalidate];
        _updateFilterTimer = nil;
        //  updateTimer = [NSTimer scheduledTimerWithTimeInterval:0.01428 target:self selector:@selector(GameUpdate) userInfo:nil repeats:YES];
        _updateFilterTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(showTime) userInfo:nil repeats:YES];
        self.filterProgress.hidden = false;
        [self.filterProgress setProgress:0.0 animated:TRUE];
    });
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        int photocout = 0;
        NSMutableArray* videoFileNameArray= [[NSMutableArray alloc] init];
        CGSize maxPhotosize;
        for (NSDictionary *dict in info) {
            
            
            UIImage *image = [dict objectForKey:UIImagePickerControllerOriginalImage];
            //  [images addObject:image];
            NSURL *mediaurl =    [dict objectForKey:UIImagePickerControllerReferenceURL];
            NSString *path = [[NSString alloc] initWithString:[ mediaurl absoluteString]];
            NSLog(@"mediaUL %@",path);
            
          //  AVURLAsset *asset2 = [AVURLAsset URLAssetWithURL:mediaurl options:nil];
            NSString *fileName =[NSString stringWithFormat:@"temp%d.jpg",photocout];
            [videoFileNameArray addObject:fileName];
            [FileUtil saveImage:image withName:fileName];
            maxPhotosize.height = MAX(maxPhotosize.height,image.size.height);
            maxPhotosize.width = MAX(maxPhotosize.width,image.size.width);
            
            image= nil;
            photocout++;
            
            //
            
        }
        if (photocout>1){
            
            NSFileManager *fileManager = [NSFileManager defaultManager];
            NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"slideshow.m4v"];
            NSError *error;
            BOOL success = [fileManager removeItemAtPath:filePath error:&error];
          //
            _elcPicker=nil;
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [VideoUtil writeImagesAsMovie:[NSArray arrayWithArray:videoFileNameArray]  toPath:@"slideshow.m4v" maxSize:maxPhotosize];
            [self castSlideShow];
                
           
               });
             return;
        }
        else
           [self castPhoto];
        //[self selectPhotos];
    });
}



- (void)mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker
{
    [self dismissModalViewControllerAnimated:YES];

}

        

-(void)showTime
{
    [self.filterProgress setProgress:self.filterProgress.progress +_fLenInSeconds animated:TRUE];
    _videoProcessLabel.hidden = FALSE;
}


-(void) castSlideShowWithMusic{
    // [self castAlert];
    NSLog(@"Cast SlideShow");
    dispatch_async(dispatch_get_main_queue(), ^{
    ChromecastDeviceController *chromecastController;
    // Do any additional setup after loading the view, typically from a nib.
    
   
       

    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    chromecastController = delegate.chromecastDeviceController;
    
    GCKMediaMetadata *metadata = [[GCKMediaMetadata alloc] init];
    
    NSError *error;
        
        
       // NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *slideShow = [NSTemporaryDirectory() stringByAppendingPathComponent:@"slideshow.m4v"];

  
        NSString * slideShowWithMusic = [NSTemporaryDirectory() stringByAppendingPathComponent:@"SlideShowWithMusic.m4v"];
   
        NSFileManager *fileMgr = [NSFileManager defaultManager];
        
        
        
        if ([fileMgr removeItemAtPath:slideShow error:&error] != YES)
            NSLog(@"Unable to delete file: %@", [error localizedDescription]);
        sleep(.5);

    
   
        if ([fileMgr moveItemAtPath:slideShowWithMusic toPath:slideShow error:&error] != YES)
            NSLog(@"Unable to move file: %@", [error localizedDescription]);
        
        
        if ([fileMgr removeItemAtPath:slideShowWithMusic error:&error] != YES)
            NSLog(@"Unable to delete file: %@", [error localizedDescription]);
    

    
                                                                                                              
    
    NSString * url = [NSString stringWithFormat:@"%@%@%@",@"http://",[NetworkUtil getIPAddress:TRUE],@":7083/slideshow.m4v"];
    
    
    NSLog(@"Started HTTP Server on url %@", url);
    
    GCKMediaInformation *mediaInformation =
    [[GCKMediaInformation alloc] initWithContentID:
     url
                                        streamType:GCKMediaStreamTypeNone
                                       contentType:@"video/mp4"
                                          metadata:metadata
                                    streamDuration:0
                                        customData:nil];
    [chromecastController.mediaControlChannel loadMedia:mediaInformation autoplay:TRUE playPosition:0];
    });
    
}


-(void) castSlideShow{
    // [self castAlert];
     dispatch_async(dispatch_get_main_queue(), ^{
    NSLog(@"Cast SlideShow");
    [_updateFilterTimer invalidate];
    _updateFilterTimer = nil;
    
    self.filterProgress.hidden = TRUE;
    self.videoProcessLabel.hidden = TRUE;
         
         [_updateFilterTimer invalidate];
         _updateFilterTimer = nil;
         
         if (self.updateStreamTimer) {
             [self.updateStreamTimer invalidate];
             self.updateStreamTimer = nil;
         }

    
    
    
    GCKMediaMetadata *metadata = [[GCKMediaMetadata alloc] init];
    
    NSString * url = [NSString stringWithFormat:@"%@%@%@",@"http://",[NetworkUtil getIPAddress:TRUE],@":7083/slideshow.m4v"];
    
    
    NSLog(@"Started HTTP Server on url %@", url);
   _chromecastController.type = @"Photo";
   // id object = type;
  /*  GCKMediaInformation *mediaInformation =
    [[GCKMediaInformation alloc] initWithContentID:
     url
                                        streamType:GCKMediaStreamTypeNone
                                       contentType:@"video/mp4"
                                          metadata:metadata
                                    streamDuration:0
                                        customData:nil];
    [_chromecastController.mediaControlChannel loadMedia:mediaInformation autoplay:TRUE playPosition:0];
   
*/

    
    [_chromecastController loadMedia:[NSURL URLWithString :url ]
                        thumbnailURL:nil
                               title: @"slide show"
                            subtitle: @"IPad/iPhone/iTouch"
                            mimeType:@"video/mp4"
                           startTime:0
                            autoPlay:YES
                          customData:nil];

   
           _readyToShowInterface = YES;
        
        
        
        
        _totalTime.text = @"0";
        _currTime.text = @"0";
        
        
        
        _updateStreamTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateInterfaceFromCast:) userInfo:nil repeats:YES];
        //  TRACE(@"Start Up updates");
    });
    
}

-(void) castPhoto{
       _chromecastController.type = @"SinglePhoto";
    [_updateFilterTimer invalidate];
    _updateFilterTimer = nil;
    
    self.filterProgress.hidden = TRUE;
    self.videoProcessLabel.hidden = TRUE;
    
    [_updateFilterTimer invalidate];
    _updateFilterTimer = nil;
    
    if (self.updateStreamTimer) {
        [self.updateStreamTimer invalidate];
        self.updateStreamTimer = nil;
    }
    

    // [self castAlert];
    NSLog(@"Cast Video");
    GCKMediaMetadata *metadata = [[GCKMediaMetadata alloc] init];
    
    NSString * url = [NSString stringWithFormat:@"%@%@%@",@"http://",[NetworkUtil getIPAddress:TRUE],@":7083/temp0.jpg"];
    
    
    NSLog(@"Started HTTP Server on url %@", url);
    
    GCKMediaInformation *mediaInformation =
    [[GCKMediaInformation alloc] initWithContentID:
     url
                                        streamType:GCKMediaStreamTypeNone
                                       contentType:@"jpg"
                                         metadata:metadata
                                       //   metadata:nil
                                    streamDuration:3
                                        customData:nil];
    
    NSLog(@"Medialurl = %@",url);
    
    //cast video
 //   [_chromecastController.mediaControlChannel loadMedia:mediaInformation autoplay:FALSE playPosition:0];
      [_chromecastController.mediaControlChannel loadMedia:mediaInformation ];
     //     [_chromecastController.mediaControlChannel loadMedia:mediaInformation ];
    
        
    
    
    
    
}

-(void) viewDidAppear:(BOOL)animated
{
  //  return;
    
    if (!_chromecastController.deviceManager.isConnected)
    {
        sleep(2);
        if (!_chromecastController.deviceManager.isConnected)
        {
            DeviceViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"devies"];
            [self presentViewController:vc animated:YES completion:nil];
        }
        
    }
    if (_chromecastController.deviceManager.isConnected)
    {
        //   [self video];
    }
    
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initControls];
	


}

- (void)initControls {
    
    //self.slider = [[UISlider alloc] init];
    [self.slider addTarget:self
                    action:@selector(onSliderValueChanged:)
          forControlEvents:UIControlEventValueChanged];
    [self.slider addTarget:self
                    action:@selector(onTouchDown:)
          forControlEvents:UIControlEventTouchDown];
    [self.slider addTarget:self
                    action:@selector(onTouchUpInside:)
          forControlEvents:UIControlEventTouchUpInside];
    [self.slider addTarget:self
                    action:@selector(onTouchUpOutside:)
          forControlEvents:UIControlEventTouchUpOutside];
    self.slider.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    UIBarButtonItem* sliderItem = [[UIBarButtonItem alloc] initWithCustomView:self.slider];
    sliderItem.tintColor = [UIColor yellowColor];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        sliderItem.width = 500;
    }
    
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    _chromecastController = delegate.chromecastDeviceController;
    self.navigationItem.rightBarButtonItem = _chromecastController.chromecastBarButton;
   
    //Add cast button
    if (_chromecastController.deviceScanner.devices.count > 0) {
        // _buttonbar = _chromecastController.chromecastBarButton;
    }
    _chromecastController.delegate = self;
    
    // Assign ourselves as delegate ONLY in viewWillAppear of a view controller.
    
    
    
}
- (void)didReceiveMediaStateChange {
    
}


- (void)didConnectToDevice:(GCKDevice *)device {
    [_chromecastController updateToolbarForViewController:self];
}

- (void)didDiscoverDeviceOnNetwork {
    
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void)setMediaToPlay:(Media*)newDetailItem {
    _playPauseButton.hidden = FALSE;
    [self setMediaToPlay:newDetailItem withStartingTime:0];
}

- (void)setMediaToPlay:(Media*)newMedia withStartingTime:(NSTimeInterval)startTime {
    _mediaStartTime = startTime;
    if (_mediaToPlay != newMedia) {
        _mediaToPlay = newMedia;
        
        // Update the view.
        //dmd     [self configureView];
    }
}

- (void)mediaNowPlaying {
    _readyToShowInterface = YES;
    [self updateInterfaceFromCast:nil];
    self.navigationController.toolbarHidden = NO;
}

- (void)updateInterfaceFromCast:(NSTimer*)timer {
    [_chromecastController updateStatsFromDevice];
    //_contentID	__NSCFString *	@"http://192.168.1.3:7083/slideshow.m4v"	0x21062600
     NSString *type  = _chromecastController.type;
     NSLog(type);
    if (type == nil || ![type isEqualToString:@"Photo"]){
        _slider.hidden = TRUE;
        
        _currTime.hidden = TRUE;
        _totalTime.hidden = TRUE;
         [_playPauseButton setTitle:@"Play"forState:UIControlStateNormal];
        
        return;
    }
    
    
    if (!_readyToShowInterface)
        return;
    _videoProcessLabel.hidden = TRUE;
    _slider.hidden = FALSE;
    
    _currTime.hidden = FALSE;
    _totalTime.hidden = FALSE;
    _playPauseButton.hidden = FALSE;
    
    if (_chromecastController.playerState != GCKMediaPlayerStateBuffering) {
        //dmd        [self.castActivityIndicator stopAnimating];
    } else {
        //dmd        [self.castActivityIndicator startAnimating];
    }
    
    if (_chromecastController.streamDuration > 0 && !_currentlyDraggingSlider) {
        self.currTime.text = @"cur";
        self.totalTime.text = @"total";
        self.currTime.text = [self getFormattedTime:_chromecastController.streamPosition];
        self.totalTime.text = [self getFormattedTime:_chromecastController.streamDuration];
        [self.slider
         setValue:(_chromecastController.streamPosition / _chromecastController.streamDuration)
         animated:YES];
       
    }
    if (_chromecastController.playerState == GCKMediaPlayerStatePaused ||
        _chromecastController.playerState == GCKMediaPlayerStateIdle) {
        //dmd        self.toolbarItems = self.playToolbar;
                  [_playPauseButton setTitle:@"PLay"forState:UIControlStateNormal];
    } else if (_chromecastController.playerState == GCKMediaPlayerStatePlaying ||
               _chromecastController.playerState == GCKMediaPlayerStateBuffering) {
        //dmd    self.toolbarItems = self.pauseToolbar;
          [_playPauseButton setTitle:@"Pause"forState:UIControlStateNormal];
    }
}

// Little formatting option here

- (NSString*)getFormattedTime:(NSTimeInterval)timeInSeconds {
    NSInteger seconds = (NSInteger) round(timeInSeconds);
    NSInteger hours = seconds / (60 * 60);
    seconds %= (60 * 60);
    
    NSInteger minutes = seconds / 60;
    seconds %= 60;
    
    if (hours > 0) {
        return [NSString stringWithFormat:@"%d:%02d:%02d", hours, minutes, seconds];
    } else {
        return [NSString stringWithFormat:@"%d:%02d", minutes, seconds];
    }
}


#pragma mark - On - screen UI elements
- (IBAction)pauseButtonClicked:(id)sender {
    if (!_chromecastController.deviceManager.isConnectedToApp)
    {
        DeviceViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"devies"];
        [self presentViewController:vc animated:YES completion:nil];
    }

     NSString *type  = _chromecastController.type;
    if (![type isEqualToString:@"Photo"]){
        [self castSlideShow];
        NSLog(type);
        
    }
    if(_chromecastController.playerState == GCKMediaPlayerStatePaused)
    {
        [_chromecastController pauseCastMedia:NO];
        [_playPauseButton setTitle:@"Pause"forState:UIControlStateNormal];
    }
    else
    {
        if(_chromecastController.streamPosition)
        {
            [_chromecastController pauseCastMedia:YES];
            [_playPauseButton setTitle:@"Play"forState:UIControlStateNormal];
        }
        else
        {
            [self castSlideShow];
            [_playPauseButton setTitle:@"Pause"forState:UIControlStateNormal];
        }
    }
}
- (IBAction)slideShowMusic:(id)sender {
    if (!_chromecastController.deviceManager.isConnectedToApp)
    {
        DeviceViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"devies"];
        [self presentViewController:vc animated:YES completion:nil];
    }

    MPMediaPickerController *picker =
    [[MPMediaPickerController alloc] initWithMediaTypes: MPMediaTypeMusic];
    
    picker.delegate						= self;
    picker.allowsPickingMultipleItems	= NO;
    picker.prompt						= NSLocalizedString (@"Add songs to play", "Prompt in media item picker");
    
    [[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleDefault animated: YES];
    
    
    [self presentViewController:picker animated:YES completion:nil];
    
	
}
- (void)mediaPicker:(MPMediaPickerController *)mediaPicker didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection
{
    
    NSError *error;
    NSString * slideShowWithMusic = [NSString stringWithFormat:@"%@%@%@",@"http://",[NetworkUtil getIPAddress:TRUE],@":7083/slideShowWithMisuc.mov"];
 [self dismissViewControllerAnimated:YES completion:nil];
    
    
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    
    
    
    if ([fileMgr removeItemAtPath:slideShowWithMusic error:&error] != YES)
        NSLog(@"Unable to delete file: %@", [error localizedDescription]);
    [self performSelectorInBackground: @selector(loadingMusic:) withObject:mediaItemCollection];
    
	//MPMediaItem *currentItem = (MPMediaItem *)[mediaItemCollection.items objectAtIndex: 0];
    
    
    
    
}

- (void)loadingMusic:(MPMediaItemCollection *)mediaItemCollection
{
    
   // for(int i=0; i< self.mediaItemCollection.count; i++)
    {
        MPMediaItem *currentItem = [mediaItemCollection.items objectAtIndex:0];
        NSURL *url = [currentItem valueForProperty: MPMediaItemPropertyAssetURL];
        [self mediaItemToData:url];
        AVURLAsset *asset2 = [AVURLAsset URLAssetWithURL:url options:nil];
        
        
        
        CMTime duration;
        duration = asset2.duration;
        float fLenInSeconds = CMTimeGetSeconds(duration);
        NSLog(@"media legth seconds = %f", CMTimeGetSeconds(duration));
           }
    
    
}


-(void)mediaItemToData:( NSURL *)url
{
    // Implement in your project the media item picker
    
    
    
    //    NSURL *url = [curItem valueForProperty: MPMediaItemPropertyAssetURL];
    
    AVURLAsset *songAsset = [AVURLAsset URLAssetWithURL: url options:nil];
    
    AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset: songAsset
                                                                      presetName: AVAssetExportPresetPassthrough];
    
    exporter.outputFileType = @"com.apple.quicktime-movie";
    
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    // NSString *documentsPath = [NSTemporaryDirectory(), NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"SlideShowWithMusic.m4v"];
    NSError *error;
    BOOL success = [fileManager removeItemAtPath:filePath error:&error];
    
    NSString *exportFile = [NSTemporaryDirectory() stringByAppendingPathComponent:
                            @"slideshow.mov"];
    
    NSString *exportVideo = [NSTemporaryDirectory() stringByAppendingPathComponent:
                            @"slideshow.m4v"];
     success = [fileManager removeItemAtPath:exportFile error:&error];
    
    NSURL *exportURL = [NSURL fileURLWithPath:exportFile] ;
    NSURL *exportVideoURL = [NSURL fileURLWithPath:exportVideo] ;
    exporter.outputURL = exportURL;
    
    // do the export
    // (completion handler block omitted)
    [exporter exportAsynchronouslyWithCompletionHandler:
     ^{
         [self addAudioToVidoe:exportURL videoURU:exportVideoURL];
         
       //slideshow
         // add music to slide show

  
     // sleep(1);
         
  
         
     }];
}

-(void) addAudioToVidoe:(NSURL*) audioUrl  videoURU:(NSURL*)videoUrl{
    
    AVURLAsset* audioAsset = [[AVURLAsset alloc]initWithURL:audioUrl options:nil];
    AVURLAsset* videoAsset = [[AVURLAsset alloc]initWithURL:videoUrl options:nil];
    
    AVMutableComposition* mixComposition = [AVMutableComposition composition];
    
    AVMutableCompositionTrack *compositionCommentaryTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio
                                                                                        preferredTrackID:kCMPersistentTrackID_Invalid];
    [compositionCommentaryTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoAsset.duration)
                                        ofTrack:[[audioAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0]
                                         atTime:kCMTimeZero error:nil];
    
    AVMutableCompositionTrack *compositionVideoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo
                                                                                   preferredTrackID:kCMPersistentTrackID_Invalid];
    [compositionVideoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoAsset.duration)
                                   ofTrack:[[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0]
                                    atTime:kCMTimeZero error:nil];
    
    AVAssetExportSession* _assetExport = [[AVAssetExportSession alloc] initWithAsset:mixComposition
                                                                          presetName:AVAssetExportPresetPassthrough];
    
    NSString* videoName = @"SlideShowWithMusic.m4v";
    
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
          NSFileManager *fileManager = [NSFileManager defaultManager];
         NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"slideshow.m4v"];
        NSString *filePathTemp = [NSTemporaryDirectory() stringByAppendingPathComponent:@"SlideShowWithMusic.m4v"];
         NSError *error;
         
         BOOL success = [fileManager removeItemAtPath:filePath error:&error];
         if ([fileManager moveItemAtPath:filePathTemp toPath:filePath error:&error] != YES)
             NSLog(@"Unable to move file: %@", [error localizedDescription]);
         
[self performSelectorOnMainThread:@selector(castSlideShow) withObject:nil waitUntilDone:NO];
         
         
     }];
    
    
}


- (IBAction)onTouchDown:(id)sender {
    _currentlyDraggingSlider = YES;
}

// This is continuous, so we can update the current/end time labels
- (IBAction)onSliderValueChanged:(id)sender {
    float pctThrough = [self.slider value];
    if (_chromecastController.streamDuration > 0) {
        self.currTime.text =
        [self getFormattedTime:(pctThrough * _chromecastController.streamDuration)];
    }
}
// This is called only on one of the two touch up events
- (void)touchIsFinished {
    [_chromecastController setPlaybackPercent:[self.slider value]];
    _currentlyDraggingSlider = NO;
}

- (IBAction)onTouchUpInside:(id)sender {
    NSLog(@"Touch up inside");
    [self touchIsFinished];
    
}

- (IBAction)onTouchUpOutside:(id)sender {
    NSLog(@"Touch up outside");
    [self touchIsFinished];
}






@end
