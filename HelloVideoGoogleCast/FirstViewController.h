//
//  FirstViewController.h
//  mediacast
//
//  Created by david davis on 2/28/14.
//  Copyright (c) 2014 david davis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleCast/GoogleCast.h>
#import <GPUImage/GPUImage.h>
#import "Media.h"
#import "ChromecastDeviceController.h"
#import "AppDelegate.h"
#import <AVFoundation/AVFoundation.h>
#import "ELCImagePickerDemoViewController.h"
#import "ELCImagePickerController.h"
#import "ELCAlbumPickerController.h"
#import "ELCAssetTablePicker.h"
#import <AVFoundation/AVFoundation.h>


@interface FirstViewController : UIViewController<GCKDeviceManagerDelegate,
                                                  GCKMediaControlChannelDelegate,
                                                  UIActionSheetDelegate,
ELCImagePickerControllerDelegate>
{
    __strong ChromecastDeviceController *_chromecastController;
    NSTimeInterval _mediaStartTime;
    BOOL _currentlyDraggingSlider;
    BOOL _readyToShowInterface;
    BOOL _joinExistingSession;
    float _fLenInSeconds;
    
}
@property(weak, nonatomic) NSTimer* updateStreamTimer;
@property(weak, nonatomic) NSTimer* updateFilterTimer;
@property (weak, nonatomic) IBOutlet UIProgressView *filterProgress;

@property (weak, nonatomic) IBOutlet UILabel *currTime;
//@property(nonatomic) UIBarButtonItem* currTime;
@property (weak, nonatomic) IBOutlet UILabel *totalTime;

@property (weak, nonatomic) IBOutlet UISlider *slider;
@property ChromecastDeviceController* chromecastDeviceController;
@property(nonatomic, strong) GPUImageMovie *movieFile;
@property(nonatomic, strong) GPUImageOutput<GPUImageInput> *filter;
@property (weak, nonatomic) IBOutlet UIButton *playPauseButton;
@property(nonatomic, strong) GPUImageMovieWriter *movieWriter;
@property(nonatomic,retain) IBOutlet UISegmentedControl *filterSegment;
@property(nonatomic, strong) NSTimer*  nst_Timer;
@property(nonatomic, strong)  ELCImagePickerController *elcPicker;
@property(strong, nonatomic) Media* mediaToPlay;
@property (weak, nonatomic) IBOutlet UIImageView *movieThumb;
@property (weak, nonatomic) IBOutlet UILabel *videoProcessLabel;
@property NSString *strDateShot;

/** The media object and when to start playing on Chromecast device. Set this before presenting the view. */
- (void)setMediaToPlay:(Media*)newMedia withStartingTime:(NSTimeInterval)startTime;
;
@end
