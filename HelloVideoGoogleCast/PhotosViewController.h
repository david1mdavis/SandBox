//
//  PhotosViewController.h
//  MediaCast
//
//  Created by david davis on 3/2/14.
//  Copyright (c) 2014 Google Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleCast/GoogleCast.h>
#import <GPUImage/GPUImage.h>

#import "ChromecastDeviceController.h"
#import "AppDelegate.h"
#import <AVFoundation/AVFoundation.h>
#import "ELCImagePickerDemoViewController.h"
#import "ELCImagePickerController.h"
#import "ELCAlbumPickerController.h"
#import "ELCAssetTablePicker.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "Media.h"
#import "MediaControls.h"

@interface PhotosViewController : UIViewController<GCKDeviceManagerDelegate,
                                                   GCKMediaControlChannelDelegate,
                                                    UIActionSheetDelegate,
                                                    ELCImagePickerControllerDelegate,
                                                    MPMediaPickerControllerDelegate>
{NSTimeInterval _mediaStartTime;
    BOOL _currentlyDraggingSlider;
    BOOL _readyToShowInterface;
    BOOL _joinExistingSession;
    float _fLenInSeconds;
    
}
@property (weak, nonatomic) IBOutlet UIButton *slideShowMusicbutton;

@property(strong, nonatomic) Media* mediaToPlay;
@property(weak, nonatomic) NSTimer* updateStreamTimer;
@property(weak, nonatomic) NSTimer* updateFilterTimer;
@property (weak, nonatomic) IBOutlet UIProgressView *filterProgress;

@property (weak, nonatomic) IBOutlet UILabel *currTime;
//@property(nonatomic) UIBarButtonItem* currTime;
@property (weak, nonatomic) IBOutlet UILabel *totalTime;

@property (weak, nonatomic) IBOutlet UISlider *slider;
@property (weak, nonatomic) IBOutlet UIImageView *movieThumb;
@property (weak, nonatomic) IBOutlet UILabel *videoProcessLabel;
@property (weak, nonatomic) IBOutlet UIButton *playPauseButton;


@property(nonatomic, strong)  ELCImagePickerController *elcPicker;
+(void) castSlideShowWithMusic;
@end
