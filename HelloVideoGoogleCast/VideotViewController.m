//
//  FirstViewController.m
//  mediacast
//
//  Created by david davis on 2/28/14.
//  Copyright (c) 2014 david davis. All rights reserved.
//

#import "VideosViewController.h"
#import "DeviceViewController.h"
#import "FileUtil.h"
#import "NetworkUtil.h"
#import "MediaControls.h"
@interface VideosViewController ()



@end

@implementation VideosViewController


- (void)didConnectToDevice:(GCKDevice *)device {
    [_chromecastController updateToolbarForViewController:self];
}

- (void)didDiscoverDeviceOnNetwork {

    
}
- (IBAction)ChooseVideo:(id)sender {

    [self video];
}

-(void)video {
    
    if (!_chromecastController.deviceManager.isConnectedToApp)
    {
        DeviceViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"devies"];
        [self presentViewController:vc animated:YES completion:nil];
    }
    
    // _nst_Timer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(showTime) userInfo:nil repeats:YES];
    
    _elcPicker = [[ELCImagePickerController alloc] initVideoPicker];
    _elcPicker.maximumImagesCount = 1;
    _elcPicker.returnsOriginalImage = NO; //Only return the fullScreenImage, not the fullResolutionImage
	_elcPicker.imagePickerDelegate = self;
    
    [self presentViewController:_elcPicker animated:YES completion:nil];
    
    
}

- (void)elcImagePickerControllerDidCancel:(ELCImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(float)getFrameRateFromAVPlayer:(AVAssetTrack *) assessetTrack
{
    float fps = 0.0;
    
        {
            fps = assessetTrack.nominalFrameRate;
        }
    
    return fps;
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
                
                
                //11308151.000000
                //17033096.000000
                NSLog(@"estimatedDataRate= %f",track.estimatedDataRate);
                //
                if (!videoAngleInDegree  && track.estimatedDataRate<11008151  )
                {
                    NSFileManager *fileManager = [NSFileManager defaultManager];
                    NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"temp.m4v"];
                    NSError *error;
                    BOOL success = [fileManager removeItemAtPath:filePath error:&error];
                      NSURL *exportURL = [NSURL fileURLWithPath:filePath] ;
                    [self convertVideoToMediumQualityWithInputURL:mediaurl outputURL:exportURL ];
                    _fLenInSeconds *= 12/_fLenInSeconds;
                   // [self copyVRawideoToTemp:mediaurl];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        // _fLenInSeconds *= 1.5;
                        //  updateTimer = [NSTimer scheduledTimerWithTimeInterval:0.01428 target:self selector:@selector(GameUpdate) userInfo:nil repeats:YES];
                        _updateFilterTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(showTime:) userInfo:nil repeats:YES];
                        self.filterProgress.hidden = false;
                        [self.filterProgress setProgress:0.0 animated:TRUE];
                    });
                    
                    return;
                    
                }

                
                
               
                
                int filterIndex =[self.filterSegment selectedSegmentIndex];
                switch (1) {
                    case 0:
                        
                        [self rotateVideo:mediaurl radins:0.0 videoWidth:mediaSize.width videoHheightt:mediaSize.height ];
                        break;
                        
                    case 1:
                        //_movieThumb.transform = CGAffineTransformMakeRotation(videoAngleInDegree - M_2_PI/2);
                        [self rotateVideo:mediaurl radins:videoAngleInDegree videoWidth:mediaSize.width videoHheightt:mediaSize.height ];
                        break;
                        
                    case 2:
                       // _movieThumb.transform = CGAffineTransformMakeRotation(videoAngleInDegree - M_2_PI/2);
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

- (void)convertVideoToMediumQualityWithInputURL:(NSURL*)inputURL outputURL:(NSURL*)outputURL
{
  /*  if([[NSFileManager defaultManager] fileExistsAtURL:outputURL])
        [[NSFileManager defaultManager] removeItemAtURL:outputURL error:nil];*/
    
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:inputURL options:nil];
    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:asset presetName:AVAssetExportPresetMediumQuality];
    exportSession.outputURL = outputURL;
    exportSession.outputFileType = AVFileTypeQuickTimeMovie;
    [exportSession exportAsynchronouslyWithCompletionHandler:^(void) {
        if (exportSession.status == AVAssetExportSessionStatusCompleted) {
 //           successHandler();
            [self castVideo];
        } else {
           // NSError *error = [NSError errorWithDomain:domain code:code userInfo:userInfo];
            //failureHandler(error);
        }
    }];
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

-(void)copyVRawideoToTemp:(NSURL*) mediaURL
{
    
    

    
    ALAssetsLibrary *assetLibrary=[[ALAssetsLibrary alloc] init];
    [assetLibrary assetForURL:mediaURL resultBlock:^(ALAsset *asset) {
        NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent: @"temp.m4v"];
       if ([[NSFileManager defaultManager] fileExistsAtPath:filePath])
        {
            [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
        }
        
        
        
        NSOutputStream * fileStream = [NSOutputStream outputStreamToFileAtPath:filePath append:NO];
        [fileStream open];
        NSInteger       dataLength;
        const uint8_t * dataBytes;
        NSInteger       bytesWritten;
        NSInteger       bytesWrittenSoFar =0;
        ALAssetRepresentation *rep = [asset defaultRepresentation];
        
        
        
        NSInteger blocksize = 1024*1024;
        
        //  Byte *buffer = (Byte*)malloc(rep.size);
        Byte *buffer = (Byte*)malloc(blocksize);
        NSInteger blockcount = rep.size/ blocksize;
        NSInteger lastWrite = rep.size - blocksize* blockcount;
        NSUInteger buffered =0;
        NSData *data;
        
        
        for (int i =0 ;i<=blockcount;i++ )
        {
            NSLog(@"copy video  %f",(float)i/(float)blockcount);
            
            // NSUInteger buffered = [rep getBytes:buffer fromOffset:0.0 length:rep.size error:nil];
            if(i == blockcount)
            {
                buffered = [rep getBytes:buffer fromOffset:i*blocksize length:lastWrite error:nil];
                data = [NSData dataWithBytesNoCopy:buffer length:buffered freeWhenDone:YES];
            }
            else
            {
                buffered = [rep getBytes:buffer fromOffset:i*blocksize length:blocksize error:nil];
              //  data = [NSData dataWithBytesNoCopy:buffer length:buffered freeWhenDone:YES];
                
            }
            
            
            
            
          //  dataLength = [data length];
           // dataBytes  = [data bytes];
            
            bytesWrittenSoFar = 0;
            do {
                
              //  bytesWritten = [fileStream write:&dataBytes[bytesWrittenSoFar] maxLength:dataLength - bytesWrittenSoFar];
                bytesWritten = [fileStream write:buffer maxLength:buffered - bytesWrittenSoFar];
//                assert(bytesWritten != 0);
                if (bytesWritten <= 0) {
                    NSLog(@"COPY VIDEO ERRO");
                    break;
                    
                } else {
                    bytesWrittenSoFar += bytesWritten;
                }
            } while (bytesWrittenSoFar != buffered);
            
            
        }
        
        data = nil;
        buffered = nil;
        buffer=nil;
        rep = nil;
        
        [fileStream close];
        
        
     
        
        
        
       dispatch_async(dispatch_get_main_queue(), ^{
                        [self castVideo];
        });
        
        
        
        
        
        
        
        
    } failureBlock:^(NSError *err) {
        NSLog(@"Error: %@",[err localizedDescription]);
    }];
    
}




-(void) rotateVideo:( NSURL *)sampleURL
             radins: (float) rad
         videoWidth:(int)width
      videoHheightt:(int)Height{
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        // _fLenInSeconds *= 1.5;
        //  updateTimer = [NSTimer scheduledTimerWithTimeInterval:0.01428 target:self selector:@selector(GameUpdate) userInfo:nil repeats:YES];
        _updateFilterTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(showTime:) userInfo:nil repeats:YES];
        self.filterProgress.hidden = false;
        [self.filterProgress setProgress:0.0 animated:TRUE];
    });

    
    
    
    NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"test.mp4"];
    _movieFile = [[GPUImageMovie alloc] initWithURL:sampleURL];
    _movieFile.runBenchmark = NO;
    _movieFile.playAtActualSpeed = YES;
    GPUImageTransformFilter *filter ;
    
    
    
    
    filter = [[GPUImageTransformFilter alloc] init];
    
    if(rad)
    {
        [filter setAffineTransform:CGAffineTransformMakeRotation(rad)];
    
       [_movieFile addTarget:filter];
    }
        
   
    

    filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"temp.m4v"];
    
    unlink([filePath UTF8String]);
    
    NSURL *movieURL = [NSURL fileURLWithPath:filePath];
    
    if (Height>width)
        _movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:movieURL size:CGSizeMake( Height,width)];
    else
        _movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:movieURL size:CGSizeMake( width,Height)];
    
   if(rad)
        [filter addTarget:_movieWriter];
    else
        [_movieFile addTarget:_movieWriter];
        

   
    
   
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
    
    NSString * url = [NSString stringWithFormat:@"%@%@%@",@"http://",[NetworkUtil getIPAddress:TRUE],@":7083/temp.m4v"];
     NSString * thumbURL = [NSString stringWithFormat:@"%@%@%@",@"http://",[NetworkUtil getIPAddress:TRUE],@":7083/thumbNail.jpg"];
    
    
    NSLog(@"Started HTTP Server on url %@", url);
    
    
    
    NSString *type = @"Video";
    // id object = type;
    
    [_chromecastController loadMedia:[NSURL URLWithString :url ]
                        thumbnailURL:[NSURL URLWithString :thumbURL ]
                               title: _strDateShot
                            subtitle: @"IPad/iPhone/iTouch"
                            mimeType:@"video/mp4"
                           startTime:0
                            autoPlay:YES
                          customData:type];
   
    
    NSLog(@"Medialurl = %@",url);
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [_updateFilterTimer invalidate];
        _updateFilterTimer = nil;
        
        if (self.updateStreamTimer) {
            [self.updateStreamTimer invalidate];
            self.updateStreamTimer = nil;
        }
        

      
        _playPauseButton.hidden = FALSE;
        _videoProcessLabel.hidden = TRUE;
        _slider.hidden = FALSE;
        
        _currTime.hidden = FALSE;
        _totalTime.hidden = FALSE;
        

         _updateStreamTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateInterfaceFromCast:) userInfo:nil repeats:YES];
      //  TRACE(@"Start Up updates");
    });
    
    
   

        self.filterProgress.hidden = TRUE;
    _readyToShowInterface = TRUE;

}



-(void) viewDidAppear:(BOOL)animated
{
  
    
    if (!_chromecastController.deviceManager.isConnected)
    {
        sleep(1);
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
    NSString *type  = _chromecastController.mediaInformation.customData;
    NSLog(type);
    if (type == nil || ![type isEqualToString:@"Video"]){
        _slider.hidden = FALSE;
        
        _currTime.hidden = FALSE;
        _totalTime.hidden = FALSE;
         [_playPauseButton setTitle:@"PLay"forState:UIControlStateNormal];
        return;
    }

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
        self.currTime.hidden = FALSE;
        self.totalTime.hidden = FALSE;
        self.currTime.text = @"cur";
        self.totalTime.text = @"total";
        self.currTime.text = [self getFormattedTime:_chromecastController.streamPosition];
        self.totalTime.text = [self getFormattedTime:(_chromecastController.streamDuration - _chromecastController.streamPosition)];
        [self.slider setValue:(_chromecastController.streamPosition / _chromecastController.streamDuration)
         animated:YES];
    }
    if (_chromecastController.playerState == GCKMediaPlayerStatePaused ||
        _chromecastController.playerState == GCKMediaPlayerStateIdle) {
         [_playPauseButton setTitle:@"PLay"forState:UIControlStateNormal];
        
//dmd        self.toolbarItems = self.playToolbar;
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
    
    NSString *type  = _chromecastController.mediaInformation.customData;
    NSLog(type);
    if (type == nil && ![type isEqualToString:@"Video"]){
        [self castVideo];
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
  /*  UIBarButtonItem* playButton =
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
   */
    
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
