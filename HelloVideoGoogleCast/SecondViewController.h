//
//  SecondViewController.h
//  mediacast
//
//  Created by david davis on 2/28/14.
//  Copyright (c) 2014 david davis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>

#import "ChromecastDeviceController.h"
#import "AppDelegate.h"
#import <AudioToolbox/AudioToolbox.h>
#import "ELCImagePickerDemoViewController.h"
#import "ELCImagePickerController.h"
#import "ELCAlbumPickerController.h"
#import "ELCAssetTablePicker.h"

#import <MediaPlayer/MediaPlayer.h>

//#import "MusicTableViewController.h"
#define PLAYER_TYPE_PREF_KEY @"player_type_preference"
#define AUDIO_TYPE_PREF_KEY @"audio_technology_preference"

@interface SecondViewController : UIViewController<
GCKDeviceManagerDelegate,
GCKMediaControlChannelDelegate,
UIActionSheetDelegate,
ELCImagePickerControllerDelegate,
MPMediaPickerControllerDelegate,

AVAudioPlayerDelegate
>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *buttonitem;

@property NSMutableArray* objects;
@end
