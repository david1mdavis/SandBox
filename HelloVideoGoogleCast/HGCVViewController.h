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

@interface HGCVViewController : UIViewController<GCKDeviceScannerListener,
                                                 GCKDeviceManagerDelegate,
                                                 GCKMediaControlChannelDelegate,
                                                 UIActionSheetDelegate,
                                                ELCImagePickerControllerDelegate>
{
 
    __weak IBOutlet UIButton *castMidea;

    __weak IBOutlet UIButton *choosmedia;
    __weak IBOutlet UISegmentedControl *filterSegment;

}



@property(strong, nonatomic)    AVMutableComposition *mutableComposition;
@property(strong, nonatomic)   AVMutableVideoComposition *mutableVideoComposition ;
@end