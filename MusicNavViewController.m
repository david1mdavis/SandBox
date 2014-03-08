//
//  MusicNavViewController.m
//  MediaCast
//
//  Created by david davis on 3/2/14.
//  Copyright (c) 2014 Google Inc. All rights reserved.
//

#import "MusicNavViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>


#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>


@interface MusicNavViewController ()
@property MPMediaItem *currentItem;

@end

@implementation MusicNavViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIBarButtonItem *barBackButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleDone target:self action:@selector(done:)];
  

    self.navigationItem.leftBarButtonItem = barBackButton;
    self.navigationItem.rightBarButtonItem = self.editButtonItem;;
    

    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
	// Do any additional setup after loading the view.
}
- (IBAction)done:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
//      [self.parentViewController.navigationController popViewControllerAnimated: YES];

}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)insertNewObject:(id)sender
{
    if (!_objects) {
        _objects = [[NSMutableArray alloc] init];
    }
    [_objects insertObject:[NSDate date] atIndex:0];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}


// This is an example of using the canReorder property of BVReorderTableView to toggle re-ordering.
//- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
//    [super setEditing:editing animated:animated];
//    ((BVReorderTableView *)self.tableView).canReorder = editing;
//}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _objects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath


{
   // static NSString *CellIdentifier = @"Cell";
   // UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    cell.textLabel.text = [self.objects[indexPath.row] valueForProperty: MPMediaItemPropertyArtist];
    
   // return cell;
    
    //UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    // You will have to manually configure what the 'empty' row looks like in this
    // method. Your dummy object can be something entirely different. It doesn't
    // have to be a string.
   if ([[_objects objectAtIndex:indexPath.row] isKindOfClass:[NSString class]] &&
        [[_objects objectAtIndex:indexPath.row] isEqualToString:@"DUMMY"]) {
        cell.textLabel.text = @"";
        cell.contentView.backgroundColor = [UIColor clearColor];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    else {
         MPMediaItem *object= _objects[indexPath.row];
        cell.textLabel.text = [object valueForProperty: MPMediaItemPropertyArtist];
               
        
        MPMediaItemArtwork *artwork = [object valueForProperty: MPMediaItemPropertyArtwork];
        
        // Obtain a UIImage object from the MPMediaItemArtwork object
        if (artwork) {
           UIImage * artworkImage = [artwork imageWithSize: CGSizeMake (50, 50)];
            UIImageView *imv = [[UIImageView alloc]initWithFrame:CGRectMake(3,2, 50, 50)];
            imv.image=artworkImage;
            [cell.contentView addSubview:imv];

        }

//        imv.image=[UIImage imageNamed:@"user.jpg"];
            }
  
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [_objects removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
      //dmd  NSDate *object = _objects[indexPath.row];
 //dmd       [[segue destinationViewController] setDetailItem:object];
    }
}


// This method is called when starting the re-ording process. You insert a blank row object into your
// data source and return the object you want to save for later. This method is only called once.
- (id)saveObjectAndInsertBlankRowAtIndexPath:(NSIndexPath *)indexPath {
    id object = [_objects objectAtIndex:indexPath.row];
 //dmd   [_objects replaceObjectAtIndex:indexPath.row withObject:@"DUMMY"];
    return object;
}

// This method is called when the selected row is dragged to a new position. You simply update your
// data source to reflect that the rows have switched places. This can be called multiple times
// during the reordering process.
- (void)moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
    id object = [_objects objectAtIndex:fromIndexPath.row];
    [_objects removeObjectAtIndex:fromIndexPath.row];
    [_objects insertObject:object atIndex:toIndexPath.row];
}


// This method is called when the selected row is released to its new position. The object is the same
// object you returned in saveObjectAndInsertBlankRowAtIndexPath:. Simply update the data source so the
// object is in its new position. You should do any saving/cleanup here.
- (void)finishReorderingWithObject:(id)object atIndexPath:(NSIndexPath *)indexPath; {
    [_objects replaceObjectAtIndex:indexPath.row withObject:object];
    // do any additional cleanup here
}


@end
