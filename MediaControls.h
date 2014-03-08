//
//  MediaControls.h
//  CastMedia
//
//  Created by david davis on 3/8/14.
//  Copyright (c) 2014 Google Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ChromecastDeviceController.h"

@interface MediaControls : NSObject{
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



@end
