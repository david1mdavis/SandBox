//
//  FirstViewController.m
//  mediacast
//
//  Created by david davis on 2/28/14.
//  Copyright (c) 2014 david davis. All rights reserved.
//

#import "FirstViewController.h"
#import "DeviceViewController.h"
#import "FileUtil.h"
#import "NetworkUtil.h"
#import "MediaControls.h"
@interface FirstViewController ()



@end

@implementation FirstViewController


- (void)didConnectToDevice:(GCKDevice *)device {
    [_chromecastController updateToolbarForViewController:self];
}

- (void)didDiscoverDeviceOnNetwork {

    
}
- (IBAction)ChooseVideo:(id)sender {
    [self video];
}

-(void)video {
    
    // _nst_Timer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(showTime) userInfo:nil repeats:YES];
    
    _elcPicker = [[ELCImagePickerController alloc] initVideoPicker];
    _elcPicker.maximumImagesCount = 1;
    _elcPicker.returnsOriginalImage = NO; //Only return the fullScreenImage, not the fullResolutionImage
	_elcPicker.imagePickerDelegate = self;
    
    [self presentViewController:_elcPicker animated:YES completion:nil];
    
    
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
        
        NSDate * dateShot =  [dict objectForKey:ALAssetPropertyDate];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"dd-MM-yyyy"];
        _strDateShot = [dateFormatter stringFromDate:dateShot];
        NSLog(@"Date shot = %@", _strDateShot);
        
        //  AVURLAsset *asset2 = [AVURLAsset URLAssetWithURL:mediaurl options:nil];
        NSString *thumbNail =@"thumbNail.jpg";

        [FileUtil saveImage:image withName:thumbNail];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            _movieThumb.hidden = FALSE;
            _movieThumb.image =  image;       });
        
        
        
        [images addObject:image];
        NSURL *mediaurl =    [dict objectForKey:UIImagePickerControllerReferenceURL];
        NSString *path = [[NSString alloc] initWithString:[ mediaurl absoluteString]];
        NSLog(@"mediaUL %@",path);
        

        NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"test.mp4"];
        
        AVURLAsset *asset2 = [AVURLAsset URLAssetWithURL:mediaurl options:nil];
        CMTime duration;
        duration = asset2.duration;
        _fLenInSeconds =1/ CMTimeGetSeconds(duration);
        NSLog(@"media legth seconds = %f", CMTimeGetSeconds(duration));
        
        NSURL *outputURL = [NSURL fileURLWithPath:filePath];
        {
            printf("completed\n");
            AVURLAsset *asset = [AVURLAsset URLAssetWithURL:mediaurl options:nil];
            
            
            NSArray *tracks = [asset tracksWithMediaType:AVMediaTypeVideo];
            
            {
                AVAssetTrack *track = [tracks objectAtIndex:0];
                //           int orientation = [[asset valueForProperty:ALAssetPropertyOrientation] intValue];
                CGSize mediaSize = track.naturalSize;
                NSLog(@"videosize %d  %d",(int)mediaSize.height, (int)mediaSize.width);
                
                
                
                CGAffineTransform txf       = [track preferredTransform];
                float  videoAngleInDegree  = (atan2(txf.b, txf.a));
                
                
                
                int filterIndex =[self.filterSegment selectedSegmentIndex];
                switch (1) {
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
-(void)showTime:(NSTimer *)timer
{
    [self.filterProgress setProgress:self.filterProgress.progress +_fLenInSeconds animated:TRUE];
    _videoProcessLabel.hidden = FALSE;
}

-(void) sketchVideo: (NSURL *)sampleURL
             radins: (float) rad
         videoWidth: (int)width
      videoHheightt: (int)Height{
    
    dispatch_async(dispatch_get_main_queue(), ^{
       // _fLenInSeconds *= .5;
        //  updateTimer = [NSTimer scheduledTimerWithTimeInterval:0.01428 target:self selector:@selector(GameUpdate) userInfo:nil repeats:YES];
        _updateFilterTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(showTime:) userInfo:nil repeats:YES];
        self.filterProgress.hidden = false;
        [self.filterProgress setProgress:0.0 animated:TRUE];
    });
    
    NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"test.mp4"];
    
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

    filePath = [NSTemporaryDirectory() stringByAppendingPathComponent: @"temp.m4v"];
    
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
        
      
        
        [_filter removeTarget:_movieWriter];
        [_movieWriter finishRecording];
        [self castVideo];
        
    }];
}



-(void) toonVideo: (NSURL *)sampleURL
           radins: (float) rad
       videoWidth: (int)width
    videoHheightt: (int)Height{
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
     //   _fLenInSeconds *= 1.5;
        //  updateTimer = [NSTimer scheduledTimerWithTimeInterval:0.01428 target:self selector:@selector(GameUpdate) userInfo:nil repeats:YES];
        _updateFilterTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(showTime:) userInfo:nil repeats:YES];
        self.filterProgress.hidden = false;
        [self.filterProgress setProgress:0.0 animated:TRUE];
    });
    
    NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"test.mp4"];
    
    
    _movieFile = [[GPUImageMovie alloc] initWithURL:sampleURL];
    _movieFile.runBenchmark = YES;
    _movieFile.playAtActualSpeed = NO;
    GPUImageTransformFilter *filter ;
    GPUImageToonFilter *filter2 ;
    GPUImageFilterGroup* filterG = [[GPUImageFilterGroup alloc] init];
    
    
    filter  = [[GPUImageTransformFilter alloc] init];
    filter2 = [[GPUImageToonFilter alloc] init];
    
    
    [filter setAffineTransform:CGAffineTransformMakeRotation(rad)];
    [filterG  addFilter:filter];
    [filterG  addFilter:filter2];
    
    [filter addTarget:filter2];
    [(GPUImageFilterGroup *)filterG setInitialFilters:[NSArray arrayWithObject:filter]];
    [(GPUImageFilterGroup *)filterG setTerminalFilter:filter2];
    
    
    [_movieFile addTarget:filterG];

    filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"test.mp4"];
    
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
       
        [_filter removeTarget:_movieWriter];
        [_movieWriter finishRecording];
        [self castVideo];
        
    }];
}




-(void) rotateVideo:( NSURL *)sampleURL
             radins: (float) rad
         videoWidth:(int)width
      videoHheightt:(int)Height{
    
  
    
    NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"test.mp4"];
    _movieFile = [[GPUImageMovie alloc] initWithURL:sampleURL];
    _movieFile.runBenchmark = YES;
    _movieFile.playAtActualSpeed = YES;
    GPUImageTransformFilter *filter ;
    
    if (!rad)
    {
        [FileUtil copyVideoToTemp:sampleURL];
        [self castVideo];
        
        return;
    }
    
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
       // _fLenInSeconds *= 1.5;
        //  updateTimer = [NSTimer scheduledTimerWithTimeInterval:0.01428 target:self selector:@selector(GameUpdate) userInfo:nil repeats:YES];
        _updateFilterTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(showTime:) userInfo:nil repeats:YES];
        self.filterProgress.hidden = false;
        [self.filterProgress setProgress:0.0 animated:TRUE];
    });
    
    filter = [[GPUImageTransformFilter alloc] init];
    
    
    [filter setAffineTransform:CGAffineTransformMakeRotation(rad)];
    
    [_movieFile addTarget:filter];

    filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"temp.m4v"];
    
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
        

        [_filter removeTarget:_movieWriter];
        [_movieWriter finishRecording];
        [self castVideo];
        
        
    }];
}


-(void) castVideo{
    // [self castAlert];
    NSLog(@"Cast Video");
    GCKMediaMetadata *metadata = [[GCKMediaMetadata alloc] init];
    
    NSString * url = [NSString stringWithFormat:@"%@%@%@",@"http://",[NetworkUtil getIPAddress:TRUE],@":8080/temp.m4v"];
     NSString * thumbURL = [NSString stringWithFormat:@"%@%@%@",@"http://",[NetworkUtil getIPAddress:TRUE],@":8080/thumbNail.jpg"];
    
    
    NSLog(@"Started HTTP Server on url %@", url);
    
    //thumbNail.jpg
    
    
    [_chromecastController loadMedia:[NSURL URLWithString :url ]
                        thumbnailURL:[NSURL URLWithString :thumbURL ]
                               title: _strDateShot
                            subtitle: @"IPad/iPhone/iTouch"
                            mimeType:@"video/mp4"
                           startTime:0
                            autoPlay:YES];

    
    
    
    
    
    
    
    
    
    
    /*
    
    GCKMediaInformation *mediaInformation =
    [[GCKMediaInformation alloc] initWithContentID:
     url
                                        streamType:GCKMediaStreamTypeNone
                                       contentType:@"video/mp4"
                                          metadata:metadata
                                    streamDuration:0
                                        customData:nil];
   
   
    
    //cast video
    [_chromecastController.mediaControlChannel loadMedia:mediaInformation autoplay:TRUE playPosition:0];
   
      */
    
    NSLog(@"Medialurl = %@",url);
    [_updateFilterTimer invalidate];
    _updateFilterTimer = nil;
    
    if (self.updateStreamTimer) {
        [self.updateStreamTimer invalidate];
        self.updateStreamTimer = nil;
    }

    
    dispatch_async(dispatch_get_main_queue(), ^{
      
        _playPauseButton.hidden = FALSE;
        _videoProcessLabel.hidden = TRUE;
        _slider.hidden = FALSE;
         NSTimer* stimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateInterfaceFromCast:) userInfo:nil repeats:YES];
      //  TRACE(@"Start Up updates");
    });
    
    
   

        self.filterProgress.hidden = TRUE;
    _readyToShowInterface = TRUE;

}

-(void)castVideo1
{
    NSString * url = @"http://192.168.1.5:8080/temp.mv4v";
    NSLog(url);

    
    [_chromecastController loadMedia:[NSURL URLWithString :url ]
                        thumbnailURL:nil
                               title:nil
                            subtitle:nil
                            mimeType:@"video/mp4"
                           startTime:0
                            autoPlay:YES];}

-(void) viewDidAppear:(BOOL)animated
{
    return;
    
    if (!_chromecastController.deviceManager.isConnected)
    {
        sleep(.1);
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
	// Do any additional setup after loading the view, typically from a nib.
    
     [self initControls];
     self.filterProgress.hidden = true;
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




- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//==============================================================================================================
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
    
    if (!_readyToShowInterface)
        return;
    
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
    } else if (_chromecastController.playerState == GCKMediaPlayerStatePlaying ||
               _chromecastController.playerState == GCKMediaPlayerStateBuffering) {
    //dmd    self.toolbarItems = self.pauseToolbar;
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
            [self castVideo];
             [_playPauseButton setTitle:@"Pause"forState:UIControlStateNormal];
        }
    }
}

- (IBAction)playButtonClicked:(id)sender {
    [_chromecastController pauseCastMedia:NO];
}

// Unsed, but if you wanted a stop, as opposed to a pause button, this is probably
// what you would call
- (IBAction)stopButtonClicked:(id)sender {
    [_chromecastController stopCastMedia];
    [self.navigationController popToRootViewControllerAnimated:YES];
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

#pragma mark - ChromecastControllerDelegate

/**
 * Called when connection to the device was closed.
 */
- (void)didDisconnect {
    [self.navigationController popViewControllerAnimated:YES];
}

/**
 * Called when the playback state of media on the device changes.
 */
- (void)didReceiveMediaStateChange {
  //  _readyToShowInterface = YES;
    self.navigationController.toolbarHidden = NO;
    
    if (_chromecastController.playerState == GCKMediaPlayerStateIdle) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

/**
 * Called to display the modal device view controller from the cast icon.
 */
- (void)shouldDisplayModalDeviceController {
    [self performSegueWithIdentifier:@"listDevices" sender:self];
}

#pragma mark - implementation.

- (void)initControls {
    UIBarButtonItem* playButton =
    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay
                                                  target:self
                                                  action:@selector(playButtonClicked:)];
    playButton.tintColor = [UIColor whiteColor];
    UIBarButtonItem* pauseButton =
    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPause
                                                  target:self
                                                  action:@selector(pauseButtonClicked:)];
    pauseButton.tintColor = [UIColor whiteColor];
        UIBarButtonItem* flexibleSpace =
    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                  target:nil
                                                  action:nil];
    UIBarButtonItem* flexibleSpace2 =
    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                  target:nil
                                                  action:nil];
    UIBarButtonItem* flexibleSpace3 =
    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                  target:nil
                                                  action:nil];
    
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


@end
