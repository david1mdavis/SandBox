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

@interface PhotosViewController (){
    __strong ChromecastDeviceController *_chromecastController;
}

@end

@implementation PhotosViewController
-(void)selectPhotos {
    _elcPicker = [[ELCImagePickerController alloc] initImagePicker];
    _elcPicker.maximumImagesCount = 60;
    _elcPicker.returnsOriginalImage = NO; //Only return the fullScreenImage, not the fullResolutionImage
	_elcPicker.imagePickerDelegate = self;
    
    
    [self presentViewController:_elcPicker animated:YES completion:nil];
    
    
}
- (IBAction)showPhotoOneAtATime:(id)sender {
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
	
    /*    for (UIView *v in [_scrollView subviews]) {
     [v removeFromSuperview];
     }
     
     CGRect workingFrame = _scrollView.frame;
     
     workingFrame.origin.x = 0;
     */
 //dmd   NSMutableArray *images = [NSMutableArray arrayWithCapacity:[info count]];
    
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

        
        
        

-(void)showTime
{
   // [self._filterProgress setProgress:self.filterProgress.progress +_fLenInSeconds animated:TRUE];
}

-(void) castSlideShow{
    // [self castAlert];
    NSLog(@"Cast SlideShow");
    GCKMediaMetadata *metadata = [[GCKMediaMetadata alloc] init];
    
    NSString * url = [NSString stringWithFormat:@"%@%@%@",@"http://",[NetworkUtil getIPAddress:TRUE],@":8080/slideshow.m4v"];
    
    
    NSLog(@"Started HTTP Server on url %@", url);
    
    GCKMediaInformation *mediaInformation =
    [[GCKMediaInformation alloc] initWithContentID:
     url
                                        streamType:GCKMediaStreamTypeNone
                                       contentType:@"video/mp4"
                                          metadata:metadata
                                    streamDuration:0
                                        customData:nil];
    [_chromecastController.mediaControlChannel loadMedia:mediaInformation autoplay:TRUE playPosition:0];
    
}

-(void) castPhoto{
    // [self castAlert];
    NSLog(@"Cast Video");
    GCKMediaMetadata *metadata = [[GCKMediaMetadata alloc] init];
    
    NSString * url = [NSString stringWithFormat:@"%@%@%@",@"http://",[NetworkUtil getIPAddress:TRUE],@":8080/temp0.jpg"];
    
    
    NSLog(@"Started HTTP Server on url %@", url);
    
    GCKMediaInformation *mediaInformation =
    [[GCKMediaInformation alloc] initWithContentID:
     url
                                        streamType:GCKMediaStreamTypeNone
                                       contentType:@"jpg"
                                          metadata:metadata
                                    streamDuration:0
                                        customData:nil];
    
    NSLog(@"Medialurl = %@",url);
    
    //cast video
    [_chromecastController.mediaControlChannel loadMedia:mediaInformation autoplay:TRUE playPosition:0];
    
        
    
    
    
    
}

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
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    _chromecastController = delegate.chromecastDeviceController;
    self.navigationItem.rightBarButtonItem = _chromecastController.chromecastBarButton;
    //Add cast button
    if (_chromecastController.deviceScanner.devices.count > 0) {
        // _buttonbar = _chromecastController.chromecastBarButton;
    }
    _chromecastController.delegate = self;


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
            [self castSlideShow];
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


@end
