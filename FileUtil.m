//
//  FileUtil.m
//  MediaCast
//
//  Created by david davis on 3/1/14.
//  Copyright (c) 2014 Google Inc. All rights reserved.
//

#import "FileUtil.h"
#import <AssetsLibrary/AssetsLibrary.h>

@implementation FileUtil

+(void)copyVideoToTemp1:(NSString*) mediaURL
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent: @"temp.m4v"];
    
    if ([fileManager fileExistsAtPath:filePath] == YES) {
        [fileManager removeItemAtPath:filePath error:&error];
        
    }
        
    
    [fileManager copyItemAtPath:mediaURL toPath:filePath error:&error];
}

+(void)copyVideoToTemp:(NSURL*) mediaURL
{
    
    
    
    
    ALAssetsLibrary *assetLibrary=[[ALAssetsLibrary alloc] init];
    [assetLibrary assetForURL:mediaURL resultBlock:^(ALAsset *asset) {
        NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent: @"temp.m4v"];
        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath])
        {
            [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
        }
        

        
        NSOutputStream * fileStream = [NSOutputStream outputStreamToFileAtPath:filePath append:NO];
         [fileStream open];
        NSInteger       dataLength;
        const uint8_t * dataBytes;
        NSInteger       bytesWritten;
        NSInteger       bytesWrittenSoFar =0;
        ALAssetRepresentation *rep = [asset defaultRepresentation];
        
        
        
        NSInteger blocksize = rep.size/8;    //41024*1024;
        
      //  Byte *buffer = (Byte*)malloc(rep.size);
          Byte *buffer = (Byte*)malloc(blocksize);
          NSInteger blockcount = rep.size/ blocksize;
          NSInteger lastWrite = rep.size - blocksize* blockcount;
        NSUInteger buffered =0;
        NSData *data;
        
        
        for (int i =0 ;i<=blockcount;i++ )
        {
            NSLog(@"copy video  %f",(float)i/(float)blockcount);
        
       // NSUInteger buffered = [rep getBytes:buffer fromOffset:0.0 length:rep.size error:nil];
        if(i == blockcount)
        {
                buffered = [rep getBytes:buffer fromOffset:i*blocksize length:lastWrite error:nil];
                data = [NSData dataWithBytesNoCopy:buffer length:buffered freeWhenDone:YES];
        }
        else
            {
                buffered = [rep getBytes:buffer fromOffset:i*blocksize length:blocksize error:nil];
                data = [NSData dataWithBytesNoCopy:buffer length:buffered freeWhenDone:YES];
                
            }

        
        
        
        dataLength = [data length];
        dataBytes  = [data bytes];
        
        bytesWrittenSoFar = 0;
        do {
            
            bytesWritten = [fileStream write:&dataBytes[bytesWrittenSoFar] maxLength:dataLength - bytesWrittenSoFar];
            assert(bytesWritten != 0);
            if (bytesWritten == -1) {
                NSLog(@"COPY VIDEO ERRO");
                break;
                     
            } else {
                bytesWrittenSoFar += bytesWritten;
            }
        } while (bytesWrittenSoFar != dataLength);

        
        }
        
        
        [fileStream close];


            
        
       
            
        
        
        
       
        
        
        
        
    } failureBlock:^(NSError *err) {
        NSLog(@"Error: %@",[err localizedDescription]);
    }];
    
}



+(void)copyVideoToTemp2:(NSURL*) mediaURL
{
    NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent: @"temp.m4v"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath])
    {
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
    }
    
    ALAssetsLibrary *assetLibrary=[[ALAssetsLibrary alloc] init];
    [assetLibrary assetForURL:mediaURL resultBlock:^(ALAsset *asset) {
        ALAssetRepresentation *rep = [asset defaultRepresentation];
      
        {
            Byte *buffer = (Byte*)malloc(rep.size);
            NSUInteger buffered = [rep getBytes:buffer fromOffset:0.0 length:rep.size error:nil];
            
            NSData *data = [NSData dataWithBytesNoCopy:buffer length:buffered freeWhenDone:YES];
            
            
            [data writeToFile:filePath atomically:YES];
        }
        
    } failureBlock:^(NSError *err) {
        NSLog(@"Error: %@",[err localizedDescription]);
    }];
    
}
+ (void)saveImage:(UIImage *)image withName:(NSString *)name {
    NSData *data = UIImageJPEGRepresentation(image, 0);
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *fullPath = [NSTemporaryDirectory() stringByAppendingPathComponent:name];
    [fileManager createFileAtPath:fullPath contents:data attributes:nil];
    fileManager = nil;
}


@end
