//
//  AppDelegate.m
//  mediacast
//
//  Created by david davis on 2/28/14.
//  Copyright (c) 2014 david davis. All rights reserved.
//

#import "AppDelegate.h"
#import "HTTPServer.h"
#import "DDLog.h"
#import "DDTTYLogger.h"
#import <ifaddrs.h>
#import <arpa/inet.h>
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#import "NetworkUtil.h"


@implementation AppDelegate



- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    // Hook up the logger.
 //   [GCKLogger sharedInstance].delegate = self;
    self.chromecastDeviceController = [[ChromecastDeviceController alloc] init];
    
    // Scan for devices.
    [self.chromecastDeviceController performScan:YES];
    
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    httpServer = [[HTTPServer alloc] init];
    [httpServer setType:@"_http._tcp."];
    [httpServer setPort:8080];
    //NSString *webPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Web"];
    NSString *webPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"tmp"];
	DDLogInfo(@"Setting document root: %@", webPath);
	
	[httpServer setDocumentRoot:webPath];
    [self startServer];

    return YES;
}
- (void)startServer
{
    // Start the server (and check for problems)
	
	NSError *error;
	if([httpServer start:&error])
	{
		DDLogInfo(@"Started HTTP Server on port %hu", [httpServer listeningPort]);
	}
	else
	{
		DDLogError(@"Error starting HTTP Server: %@", error);
	}
}

- (void)stopServer
{
    // Start the server (and check for problems)
	
    
	[httpServer stop];
	
    DDLogInfo(@"Stop Server");
	
}



							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}
- (void)logFromFunction:(const char *)function message:(NSString *)message {
    // Send SDK’s log messages directly to the console, as an example.
    NSLog(@"%s  %@", function, message);
}

@end
