//
//  SecondViewController.m
//  mediacast
//
//  Created by david davis on 2/28/14.
//  Copyright (c) 2014 david davis. All rights reserved.
//

#import "SecondViewController.h"
#import "DeviceViewController.h"
#import "MusicNavViewController.h"
#import "FileUtil.h"
#import "NetworkUtil.h"

@interface SecondViewController (){
    __strong ChromecastDeviceController *_chromecastController;
    }

@property MPMediaItem *currentItem;
@property MPMediaItemCollection *  mediaItemCollection;
@property BOOL listenToMusic;
@end

@implementation SecondViewController

/*- (void) handle_NowPlayingItemChanged: (id) notification {
    
	MPMediaItem *currentItem = [musicPlayer nowPlayingItem];
	
	// Assume that there is no artwork for the media item.
	UIImage *artworkImage = nil;
	
	// Get the artwork from the current media item, if it has artwork.
	MPMediaItemArtwork *artwork = [currentItem valueForProperty: MPMediaItemPropertyArtwork];
	
	// Obtain a UIImage object from the MPMediaItemArtwork object
	if (artwork) {
		artworkImage = [artwork imageWithSize: CGSizeMake (30, 30)];
	}
	
	// Obtain a UIButton object and set its background to the UIImage object
	UIButton *artworkView = [[UIButton alloc] initWithFrame: CGRectMake (0, 0, 30, 30)];
	[artworkView setBackgroundImage: artworkImage forState: UIControlStateNormal];
    
	// Obtain a UIBarButtonItem object and initialize it with the UIButton object
	UIBarButtonItem *newArtworkItem = [[UIBarButtonItem alloc] initWithCustomView: artworkView];
	[self setArtworkItem: newArtworkItem];
	[newArtworkItem release];
	
	[artworkItem setEnabled: NO];
	
	// Display the new media item artwork
	[navigationBar.topItem setRightBarButtonItem: artworkItem animated: YES];
	
	// Display the artist and song name for the now-playing media item
	[nowPlayingLabel setText: [
                               NSString stringWithFormat: @"%@ %@ %@ %@",
                               NSLocalizedString (@"Now Playing:", @"Label for introducing the now-playing song title and artist"),
                               [currentItem valueForProperty: MPMediaItemPropertyTitle],
                               NSLocalizedString (@"by", @"Article between song name and artist name"),
                               [currentItem valueForProperty: MPMediaItemPropertyArtist]]];
    
	if (musicPlayer.playbackState == MPMusicPlaybackStateStopped) {
		// Provide a suitable prompt to the user now that their chosen music has
		//		finished playing.
		[nowPlayingLabel setText: [
                                   NSString stringWithFormat: @"%@",
                                   NSLocalizedString (@"Music-ended Instructions", @"Label for prompting user to play music again after it has stopped")]];
        
	}
}

*/
/**
 * Called when connection to the device was established.
 *
 * @param device The device to which the connection was established.
 */
- (void)didConnectToDevice:(GCKDevice *)device {
    [_chromecastController updateToolbarForViewController:self];
}

- (void)didDiscoverDeviceOnNetwork {
    
    
    
    
    
}

-(void) viewDidAppear:(BOOL)animated
{
    if (!_chromecastController.deviceManager.isConnected)
    {
        
            DeviceViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"devies"];
            [self presentViewController:vc animated:YES completion:nil];
        
    
    }
    if (_chromecastController.deviceManager.isConnected  && _listenToMusic)
        [self pickMusic];
    
}


- (IBAction)pickMusic:(id)sender {
    [self pickMusic];
}
- (IBAction)ediPlayList:(id)sender {
    
      MusicNavViewController   *detailViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"MusicList"];
   // MusicNavViewController *detailViewController = [[MusicNavViewController alloc] initWithStyle:UITableViewStyleGrouped];
    detailViewController.objects = _objects;
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:detailViewController];
    
    
    
    [self presentViewController:navController animated:YES completion:nil];
  /*    MusicNavViewController   *navController = [self.storyboard instantiateViewControllerWithIdentifier:@"MusicList"];
    vc.objects = _objects;
    [self presentViewController:vc animated:YES completion:nil];
    */

}

- (void) pickMusic
    
 {
        
		MPMediaPickerController *picker =
        [[MPMediaPickerController alloc] initWithMediaTypes: MPMediaTypeMusic];
		
		picker.delegate						= self;
		picker.allowsPickingMultipleItems	= YES;
		picker.prompt						= NSLocalizedString (@"Add songs to play", "Prompt in media item picker");
		
		[[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleDefault animated: YES];
		

        [self presentViewController:picker animated:YES completion:nil];
		
	
}
- (void)mediaPicker:(MPMediaPickerController *)mediaPicker didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection
{
 
    _objects = [(NSArray*)mediaItemCollection.items mutableCopy];
    //  [player setQueueWithItemCollection:mediaItemCollection];
    [self performSelectorInBackground: @selector(loadingMusic:) withObject:mediaItemCollection];

	//MPMediaItem *currentItem = (MPMediaItem *)[mediaItemCollection.items objectAtIndex: 0];
    

   //  [self dismissViewControllerAnimated:YES completion:nil];
   
}





- (void)loadingMusic:(MPMediaItemCollection *)mediaItemCollection
{
    
    for(int i=0; i< self.objects.count; i++)
    {
        _currentItem = [self.objects objectAtIndex:i];
        NSURL *url = [_currentItem valueForProperty: MPMediaItemPropertyAssetURL];
        [self mediaItemToData:url];
        AVURLAsset *asset2 = [AVURLAsset URLAssetWithURL:url options:nil];
        
        
        
        CMTime duration;
        duration = asset2.duration;
        float fLenInSeconds = CMTimeGetSeconds(duration);
        NSLog(@"media legth seconds = %f", CMTimeGetSeconds(duration));
        sleep(fLenInSeconds);            }
    
    
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
    
    NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"exported.mov"];
    NSError *error;
    BOOL success = [fileManager removeItemAtPath:filePath error:&error];
    
    NSString *exportFile = [NSTemporaryDirectory() stringByAppendingPathComponent:
                            @"exported.mov"];
    
    NSURL *exportURL = [NSURL fileURLWithPath:exportFile] ;
    exporter.outputURL = exportURL;
    
    // do the export
    // (completion handler block omitted)
    [exporter exportAsynchronouslyWithCompletionHandler:
     ^{
         NSData *data = [NSData dataWithContentsOfFile: [NSTemporaryDirectory()
                                                         stringByAppendingPathComponent: @"exported.mov"]];
         UIImage* artworkImage;
         NSURL* thumbURL = nil;
         
         MPMediaItemArtwork *artwork = [_currentItem valueForProperty: MPMediaItemPropertyArtwork];
         
         // Obtain a UIImage object from the MPMediaItemArtwork object
         if (artwork) {
             UIImage * artworkImage = [artwork imageWithSize: CGSizeMake (800, 800)];
             [FileUtil saveImage:artworkImage withName:
              @"artThumb.jpg"];
              NSString * url = [NSString stringWithFormat:@"%@%@%@",@"http://",[NetworkUtil getIPAddress:TRUE],@":8080/artThumb.jpg"];
             thumbURL =[NSURL URLWithString:url];
         }

         
         
         NSString * url = [NSString stringWithFormat:@"%@%@%@",@"http://",[NetworkUtil getIPAddress:TRUE],@":8080/exported.mov"];

       
         
         [_chromecastController loadMedia:[NSURL URLWithString :url ]
                             thumbnailURL:thumbURL
     title:[_currentItem valueForProperty: MPMediaItemPropertyArtist]
     subtitle:[_currentItem valueForProperty: MPMediaItemPropertyTitle]
     mimeType:@"video/mp4"
     startTime:0
     autoPlay:YES];

         
       //  [self casttexported_mov];
         
     }];
}


- (void)mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker
{
    [self dismissModalViewControllerAnimated:YES];
    _listenToMusic = FALSE;
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
     _listenToMusic =TRUE;
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Assign ourselves as delegate ONLY in viewWillAppear of a view controller.
    _chromecastController.delegate = self;
    

}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
