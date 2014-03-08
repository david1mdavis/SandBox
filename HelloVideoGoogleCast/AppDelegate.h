//
//  AppDelegate.h
//  mediacast
//
//  Created by david davis on 2/28/14.
//  Copyright (c) 2014 david davis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleCast/GoogleCast.h>

#import "ChromecastDeviceController.h"
@class HTTPServer;
@interface AppDelegate : UIResponder <UIApplicationDelegate, GCKLoggerDelegate>
{
    HTTPServer *httpServer;
}

@property (strong, nonatomic) UIWindow *window;
@property ChromecastDeviceController* chromecastDeviceController;

@end
