//
//  ELCImagePickerController.m
//  ELCImagePickerDemo
//
//  Created by ELC on 9/9/10.
//  Copyright 2010 ELC Technologies. All rights reserved.
//

#import "ELCImagePickerController.h"
#import "ELCAsset.h"
#import "ELCAssetCell.h"
#import "ELCAssetTablePicker.h"
#import "ELCAlbumPickerController.h"
#import <CoreLocation/CoreLocation.h>
#import "MemoryUtil.h"

@implementation ELCImagePickerController

//Using auto synthesizers

- (id)initVideoPicker
{
    ELCAlbumPickerController *albumPicker = [[ELCAlbumPickerController alloc] initWithStyle:UITableViewStylePlain];
    albumPicker.filterTypeVideo = TRUE;
    self = [super initWithRootViewController:albumPicker];
    if (self) {
        self.maximumImagesCount = 4;
        [albumPicker setParent:self];
    }
    return self;
}

- (id)initImagePicker
{
    ELCAlbumPickerController *albumPicker = [[ELCAlbumPickerController alloc] initWithStyle:UITableViewStylePlain];
    
    albumPicker.filterTypeVideo = FALSE;
    self = [super initWithRootViewController:albumPicker];
    if (self) {
        self.maximumImagesCount = 4;
        [albumPicker setParent:self];
    }
    return self;
}

- (id)initWithRootViewController:(UIViewController *)rootViewController
{
    self = [super initWithRootViewController:rootViewController];
    if (self) {
        self.maximumImagesCount = 4;
    }
    return self;
}

- (void)cancelImagePicker
{
	if ([_imagePickerDelegate respondsToSelector:@selector(elcImagePickerControllerDidCancel:)]) {
		[_imagePickerDelegate performSelector:@selector(elcImagePickerControllerDidCancel:) withObject:self];
	}
}




- (BOOL) assetCast:(ELCAsset *)asset
{
    if(!_oneAtaTime )
        return FALSE;
    
    
    
    
 //
    NSMutableArray *returnArray = [[NSMutableArray alloc] init];
	
	//for(ALAsset *asset in assets) {
		id obj = [asset.asset valueForProperty:ALAssetPropertyType];
		if (!obj) {
			return FALSE;
		}
		NSMutableDictionary *workingDictionary = [[NSMutableDictionary alloc] init];
		
		CLLocation* wgs84Location = [asset.asset valueForProperty:ALAssetPropertyLocation];
		if (wgs84Location) {
			[workingDictionary setObject:wgs84Location forKey:ALAssetPropertyLocation];
		}
        
        [workingDictionary setObject:obj forKey:UIImagePickerControllerMediaType];
        
        //This method returns nil for assets from a shared photo stream that are not yet available locally. If the asset becomes available in the future, an ALAssetsLibraryChangedNotification notification is posted.
        ALAssetRepresentation *assetRep = [asset.asset defaultRepresentation];
        
        if(assetRep != nil) {
            CGImageRef imgRef = nil;
            //defaultRepresentation returns image as it appears in photo picker, rotated and sized,
            //so use UIImageOrientationUp when creating our image below.
            UIImageOrientation orientation = UIImageOrientationUp;
            
            if (_returnsOriginalImage) {
                imgRef = [assetRep fullResolutionImage];
                orientation = [assetRep orientation];
            } else {
                imgRef = [assetRep fullScreenImage];
            }
            UIImage *img = [UIImage imageWithCGImage:imgRef
                                               scale:1.0f
                                         orientation:orientation];
            [workingDictionary setObject:img forKey:UIImagePickerControllerOriginalImage];
            [workingDictionary setObject:[[asset.asset valueForProperty:ALAssetPropertyURLs] valueForKey:[[[asset.asset valueForProperty:ALAssetPropertyURLs] allKeys] objectAtIndex:0]] forKey:UIImagePickerControllerReferenceURL];
            
           // [returnArray addObject:workingDictionary];
      //  }
		
	}
    
    
    
    
    
    
    
    
    
    if ([_imagePickerDelegate respondsToSelector:@selector(assetCast:)])
    {
		[_imagePickerDelegate performSelector:@selector(assetCast:) withObject:workingDictionary];
        return TRUE;
	}
    
    return FALSE;
}



- (BOOL)shouldSelectAsset:(ELCAsset *)asset previousCount:(NSUInteger)previousCount
{
    BOOL shouldSelect = previousCount < self.maximumImagesCount;
    if (!shouldSelect) {
        NSString *title = [NSString stringWithFormat:NSLocalizedString(@"Only %d photos please!", nil), self.maximumImagesCount];
        NSString *message = [NSString stringWithFormat:NSLocalizedString(@"You can only send %d photos at a time.", nil), self.maximumImagesCount];
        [[[UIAlertView alloc] initWithTitle:title
                                    message:message
                                   delegate:nil
                          cancelButtonTitle:nil
                          otherButtonTitles:NSLocalizedString(@"Okay", nil), nil] show];
    }
    return shouldSelect;
}


- (void)selectedAssetsMarch9:(NSArray *)assets
{
		if (_imagePickerDelegate != nil && [_imagePickerDelegate respondsToSelector:@selector(elcImagePickerController:didFinishPickingMediaWithInfo:)]) {
		[_imagePickerDelegate performSelector:@selector(elcImagePickerController:didFinishPickingMediaWithInfo:) withObject:self withObject:assets];
	} else {
        [self popToRootViewControllerAnimated:NO];
    }
}








- (void)selectedAssets:(NSArray *)assets
{
	NSMutableArray *returnArray = [[NSMutableArray alloc] init];
	
	for(ALAsset *asset in assets) {
        [MemoryUtil print_free_memory];
		id obj = [asset valueForProperty:ALAssetPropertyType];
		if (!obj) {
			continue;
		}
		NSMutableDictionary *workingDictionary = [[NSMutableDictionary alloc] init];
		
		CLLocation* wgs84Location = [asset valueForProperty:ALAssetPropertyLocation];
		if (wgs84Location) {
			[workingDictionary setObject:wgs84Location forKey:ALAssetPropertyLocation];
		}
        NSDate * dateShot = [asset valueForProperty:ALAssetPropertyLocation];
        if (dateShot){
            [workingDictionary setObject:dateShot forKey:ALAssetPropertyDate];
        }
        
        
        [workingDictionary setObject:obj forKey:UIImagePickerControllerMediaType];
        
        //This method returns nil for assets from a shared photo stream that are not yet available locally. If the asset becomes available in the future, an ALAssetsLibraryChangedNotification notification is posted.
        ALAssetRepresentation *assetRep = [asset defaultRepresentation];
        
        if(assetRep != nil) {
            CGImageRef imgRef = nil;
            //defaultRepresentation returns image as it appears in photo picker, rotated and sized,
            //so use UIImageOrientationUp when creating our image below.
            UIImageOrientation orientation = UIImageOrientationUp;
            
            if (_returnsOriginalImage) {
                imgRef = [assetRep fullResolutionImage];
                orientation = [assetRep orientation];
            } else {
                imgRef = [assetRep fullScreenImage];
            }
            UIImage *img = [UIImage imageWithCGImage:imgRef
                                               scale:1.0f
                                         orientation:orientation];
            [workingDictionary setObject:img forKey:UIImagePickerControllerOriginalImage];
            [workingDictionary setObject:[[asset valueForProperty:ALAssetPropertyURLs] valueForKey:[[[asset valueForProperty:ALAssetPropertyURLs] allKeys] objectAtIndex:0]] forKey:UIImagePickerControllerReferenceURL];
            
            [returnArray addObject:workingDictionary];
        }
		
	}
	if (_imagePickerDelegate != nil && [_imagePickerDelegate respondsToSelector:@selector(elcImagePickerController:didFinishPickingMediaWithInfo:)]) {
		[_imagePickerDelegate performSelector:@selector(elcImagePickerController:didFinishPickingMediaWithInfo:) withObject:self withObject:returnArray];
	} else {
        [self popToRootViewControllerAnimated:NO];
    }
}


- (void)selectedAssetsdmd:(NSArray *)assets
{
	NSMutableArray *returnArray = [[NSMutableArray alloc] init];
	
	for(ALAsset *asset in assets) {
		id obj = [asset valueForProperty:ALAssetPropertyType];
		if (!obj) {
			continue;
		}
		NSMutableDictionary *workingDictionary = [[NSMutableDictionary alloc] init];
		
		CLLocation* wgs84Location = [asset valueForProperty:ALAssetPropertyLocation];
		if (wgs84Location) {
			[workingDictionary setObject:wgs84Location forKey:ALAssetPropertyLocation];
		}
        
        [workingDictionary setObject:obj forKey:UIImagePickerControllerMediaType];

        //This method returns nil for assets from a shared photo stream that are not yet available locally. If the asset becomes available in the future, an ALAssetsLibraryChangedNotification notification is posted.
        ALAssetRepresentation *assetRep = [asset defaultRepresentation];

        if(assetRep != nil) {
            CGImageRef imgRef = nil;
            //defaultRepresentation returns image as it appears in photo picker, rotated and sized,
            //so use UIImageOrientationUp when creating our image below.
            UIImageOrientation orientation = UIImageOrientationUp;
            
            if (_returnsOriginalImage) {
                imgRef = [assetRep fullResolutionImage];
                orientation = [assetRep orientation];
            } else {
                imgRef = [assetRep fullScreenImage];
            }
            UIImage *img = [UIImage imageWithCGImage:imgRef
                                               scale:1.0f
                                         orientation:orientation];
            [workingDictionary setObject:img forKey:UIImagePickerControllerOriginalImage];
            [workingDictionary setObject:[[asset valueForProperty:ALAssetPropertyURLs] valueForKey:[[[asset valueForProperty:ALAssetPropertyURLs] allKeys] objectAtIndex:0]] forKey:UIImagePickerControllerReferenceURL];
            
            [returnArray addObject:workingDictionary];
        }
		
	}    
	if (_imagePickerDelegate != nil && [_imagePickerDelegate respondsToSelector:@selector(elcImagePickerController:didFinishPickingMediaWithInfo:)]) {
		[_imagePickerDelegate performSelector:@selector(elcImagePickerController:didFinishPickingMediaWithInfo:) withObject:self withObject:returnArray];
	} else {
        [self popToRootViewControllerAnimated:NO];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return YES;
    } else {
        return toInterfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
    }
}

@end
