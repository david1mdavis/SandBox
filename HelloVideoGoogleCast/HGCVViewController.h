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

#import <UIKit/UIKit.h>
#import <GoogleCast/GoogleCast.h>
#import <GPUImage/GPUImage.h>
#import "ELCImagePickerDemoAppDelegate.h"
#import "ELCImagePickerDemoViewController.h"
#import "ELCImagePickerController.h"
#import "ELCAlbumPickerController.h"
#import "ELCAssetTablePicker.h"
#define PLAYER_TYPE_PREF_KEY @"player_type_preference"
#define AUDIO_TYPE_PREF_KEY @"audio_technology_preference"

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "MusicTableViewController.h"



@interface HGCVViewController : UIViewController<GCKDeviceScannerListener,
                                                 GCKDeviceManagerDelegate,
                                                 GCKMediaControlChannelDelegate,
                                                 UIActionSheetDelegate,
                                                ELCImagePickerControllerDelegate,
                                                MPMediaPickerControllerDelegate,
                                                MusicTableViewControllerDelegate,
                                                AVAudioPlayerDelegate>

{
 
    __weak IBOutlet UIButton *castMidea;
     __weak IBOutlet UIButton *choosmedia;
    __weak IBOutlet UISegmentedControl *filterSegment;
    
    //music
  //  AddMusicAppDelegate			*applicationDelegate;
	IBOutlet UIBarButtonItem	*artworkItem;
	IBOutlet UINavigationBar	*navigationBar;
	IBOutlet UILabel			*nowPlayingLabel;
	BOOL						playedMusicOnce;
    
	AVAudioPlayer				*appSoundPlayer;
	NSURL						*soundFileURL;
	IBOutlet UIButton			*appSoundButton;
	IBOutlet UIButton			*addOrShowMusicButton;
	BOOL						interruptedOnPlayback;
	BOOL						playing ;
    
	UIBarButtonItem				*playBarButton;
	UIBarButtonItem				*pauseBarButton;
	MPMusicPlayerController		*musicPlayer;
	MPMediaItemCollection		*userMediaItemCollection;
	UIImage						*noArtworkImage;
	NSTimer						*backgroundColorTimer;

}



@property(strong, nonatomic)    AVMutableComposition *mutableComposition;
@property(strong, nonatomic)   AVMutableVideoComposition *mutableVideoComposition ;

//music
@property (nonatomic, retain)	UIBarButtonItem			*artworkItem;
@property (nonatomic, retain)	UINavigationBar			*navigationBar;
@property (nonatomic, retain)	UILabel					*nowPlayingLabel;
@property (readwrite)			BOOL					playedMusicOnce;

@property (nonatomic, retain)	UIBarButtonItem			*playBarButton;
@property (nonatomic, retain)	UIBarButtonItem			*pauseBarButton;
@property (nonatomic, retain)	MPMediaItemCollection	*userMediaItemCollection;
@property (nonatomic, retain)	MPMusicPlayerController	*musicPlayer;
@property (nonatomic, retain)	UIImage					*noArtworkImage;
@property (nonatomic, retain)	NSTimer					*backgroundColorTimer;

@property (nonatomic, retain)	AVAudioPlayer			*appSoundPlayer;
@property (nonatomic, retain)	NSURL					*soundFileURL;
@property (nonatomic, retain)	IBOutlet UIButton		*appSoundButton;
@property (nonatomic, retain)	IBOutlet UIButton		*addOrShowMusicButton;
@property (readwrite)			BOOL					interruptedOnPlayback;
@property (readwrite)			BOOL					playing;

- (IBAction)	playOrPauseMusic:		(id) sender;
- (IBAction)	AddMusicOrShowMusic:	(id) sender;
- (IBAction)	playAppSound:			(id) sender;

- (BOOL) useiPodPlayer;

@end