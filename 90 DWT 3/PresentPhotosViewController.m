//
//  PresentPhotosViewController.m
//  90 DWT 1
//
//  Created by Jared Grant on 7/14/12.
//  Copyright (c) 2012 g-rantsoftware.com. All rights reserved.
//

#import "PresentPhotosViewController.h"

@interface PresentPhotosViewController ()

@end

@implementation PresentPhotosViewController

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
	// Do any additional setup after loading the view.
    
    [self configureViewForIOSVersion];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)emailPhotos
{
    // Create MailComposerViewController object.
    MFMailComposeViewController *mailComposer;
    mailComposer = [[MFMailComposeViewController alloc] init];
    mailComposer.mailComposeDelegate = self;
    mailComposer.navigationBar.tintColor = [UIColor whiteColor];
    
    // Check to see if the device has at least 1 email account configured.
    if ([MFMailComposeViewController canSendMail]) {
        
        // Send email
        PhotoNavController *photoNC = [[PhotoNavController alloc] init];
        
        // Get path to documents directory to get default email address and images./
        NSString *docDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
        
        NSString *imageFile = nil;
        
        // Array to store the default email address.
        NSArray *emailAddresses;
        
        NSString *defaultEmailFile = nil;
        defaultEmailFile = [docDir stringByAppendingPathComponent:@"Default Email.out"];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:defaultEmailFile]) {
            NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:defaultEmailFile];
            
            NSString *defaultEmail = [[NSString alloc] initWithData:[fileHandle availableData] encoding:NSUTF8StringEncoding];
            [fileHandle closeFile];
            
            // There is a default email address.
            emailAddresses = @[defaultEmail];
        }
        else {
            // There is NOT a default email address.  Put an empty email address in the arrary.
            emailAddresses = @[@""];
        }
        
        [mailComposer setToRecipients:emailAddresses];
        
        // ALL PHOTOS
        if ([self.navigationItem.title isEqualToString:@"All"]) {
            [mailComposer setSubject:@"90 DWT 3 All Photos"];
            
            // MONTH 1
            imageFile = [docDir stringByAppendingPathComponent:@"Start Month 1 Front.JPG"];
            if ([[NSFileManager defaultManager] fileExistsAtPath:imageFile]) {
                [mailComposer addAttachmentData:[photoNC emailImage:@"Start Month 1 Front"] mimeType:@"image/jpg" fileName:@"Start Month 1 Front.jpg"];
            }
            
            imageFile = [docDir stringByAppendingPathComponent:@"Start Month 1 Side.JPG"];
            if ([[NSFileManager defaultManager] fileExistsAtPath:imageFile]) {
                [mailComposer addAttachmentData:[photoNC emailImage:@"Start Month 1 Side"] mimeType:@"image/jpg" fileName:@"Start Month 1 Side.jpg"];
            }
            
            imageFile = [docDir stringByAppendingPathComponent:@"Start Month 1 Back.JPG"];
            if ([[NSFileManager defaultManager] fileExistsAtPath:imageFile]) {
                [mailComposer addAttachmentData:[photoNC emailImage:@"Start Month 1 Back"] mimeType:@"image/jpg" fileName:@"Start Month 1 Back.jpg"];
            }
            
            // MONTH 2
            imageFile = [docDir stringByAppendingPathComponent:@"Start Month 2 Front.JPG"];
            if ([[NSFileManager defaultManager] fileExistsAtPath:imageFile]) {
                [mailComposer addAttachmentData:[photoNC emailImage:@"Start Month 2 Front"] mimeType:@"image/jpg" fileName:@"Start Month 2 Front.jpg"];
            }
            
            imageFile = [docDir stringByAppendingPathComponent:@"Start Month 2 Side.JPG"];
            if ([[NSFileManager defaultManager] fileExistsAtPath:imageFile]) {
                [mailComposer addAttachmentData:[photoNC emailImage:@"Start Month 2 Side"] mimeType:@"image/jpg" fileName:@"Start Month 2 Side.jpg"];
            }
            
            imageFile = [docDir stringByAppendingPathComponent:@"Start Month 2 Back.JPG"];
            if ([[NSFileManager defaultManager] fileExistsAtPath:imageFile]) {
                [mailComposer addAttachmentData:[photoNC emailImage:@"Start Month 2 Back"] mimeType:@"image/jpg" fileName:@"Start Month 2 Back.jpg"];
            }
            
            // MONTH 3
            imageFile = [docDir stringByAppendingPathComponent:@"Start Month 3 Front.JPG"];
            if ([[NSFileManager defaultManager] fileExistsAtPath:imageFile]) {
                [mailComposer addAttachmentData:[photoNC emailImage:@"Start Month 3 Front"] mimeType:@"image/jpg" fileName:@"Start Month 3 Front.jpg"];
            }
            
            imageFile = [docDir stringByAppendingPathComponent:@"Start Month 3 Side.JPG"];
            if ([[NSFileManager defaultManager] fileExistsAtPath:imageFile]) {
                [mailComposer addAttachmentData:[photoNC emailImage:@"Start Month 3 Side"] mimeType:@"image/jpg" fileName:@"Start Month 3 Side.jpg"];
            }
            
            imageFile = [docDir stringByAppendingPathComponent:@"Start Month 3 Back.JPG"];
            if ([[NSFileManager defaultManager] fileExistsAtPath:imageFile]) {
                [mailComposer addAttachmentData:[photoNC emailImage:@"Start Month 3 Back"] mimeType:@"image/jpg" fileName:@"Start Month 3 Back.jpg"];
            }
            
            // FINAL
            imageFile = [docDir stringByAppendingPathComponent:@"Final Front.JPG"];
            if ([[NSFileManager defaultManager] fileExistsAtPath:imageFile]) {
                [mailComposer addAttachmentData:[photoNC emailImage:@"Final Front"] mimeType:@"image/jpg" fileName:@"Final Front.jpg"];
            }
            
            imageFile = [docDir stringByAppendingPathComponent:@"Final Side.JPG"];
            if ([[NSFileManager defaultManager] fileExistsAtPath:imageFile]) {
                [mailComposer addAttachmentData:[photoNC emailImage:@"Final Side"] mimeType:@"image/jpg" fileName:@"Final Side.jpg"];
            }
            
            imageFile = [docDir stringByAppendingPathComponent:@"Final Back.JPG"];
            if ([[NSFileManager defaultManager] fileExistsAtPath:imageFile]) {
                [mailComposer addAttachmentData:[photoNC emailImage:@"Final Back"] mimeType:@"image/jpg" fileName:@"Final Back.jpg"];
            }
        }
        
        // FRONT PHOTOS
        else if ([self.navigationItem.title isEqualToString:@"Front"]) {
            [mailComposer setSubject:@"90 DWT 3 Front Photos"];
            
            // MONTH 1
            imageFile = [docDir stringByAppendingPathComponent:@"Start Month 1 Front.JPG"];
            if ([[NSFileManager defaultManager] fileExistsAtPath:imageFile]) {
                [mailComposer addAttachmentData:[photoNC emailImage:@"Start Month 1 Front"] mimeType:@"image/jpg" fileName:@"Start Month 1 Front.jpg"];
            }
            
            // MONTH 2
            imageFile = [docDir stringByAppendingPathComponent:@"Start Month 2 Front.JPG"];
            if ([[NSFileManager defaultManager] fileExistsAtPath:imageFile]) {
                [mailComposer addAttachmentData:[photoNC emailImage:@"Start Month 2 Front"] mimeType:@"image/jpg" fileName:@"Start Month 2 Front.jpg"];
            }
            
            // MONTH 3
            imageFile = [docDir stringByAppendingPathComponent:@"Start Month 3 Front.JPG"];
            if ([[NSFileManager defaultManager] fileExistsAtPath:imageFile]) {
                [mailComposer addAttachmentData:[photoNC emailImage:@"Start Month 3 Front"] mimeType:@"image/jpg" fileName:@"Start Month 3 Front.jpg"];
            }
            
            // FINAL
            imageFile = [docDir stringByAppendingPathComponent:@"Final Front.JPG"];
            if ([[NSFileManager defaultManager] fileExistsAtPath:imageFile]) {
                [mailComposer addAttachmentData:[photoNC emailImage:@"Final Front"] mimeType:@"image/jpg" fileName:@"Final Front.jpg"];
            }
        }
        
        // SIDE PHOTOS
        else if ([self.navigationItem.title isEqualToString:@"Side"]) {
            [mailComposer setSubject:@"90 DWT 3 Side Photos"];
            
            // MONTH 1
            imageFile = [docDir stringByAppendingPathComponent:@"Start Month 1 Side.JPG"];
            if ([[NSFileManager defaultManager] fileExistsAtPath:imageFile]) {
                [mailComposer addAttachmentData:[photoNC emailImage:@"Start Month 1 Side"] mimeType:@"image/jpg" fileName:@"Start Month 1 Side.jpg"];
            }
            
            // MONTH 2
            imageFile = [docDir stringByAppendingPathComponent:@"Start Month 2 Side.JPG"];
            if ([[NSFileManager defaultManager] fileExistsAtPath:imageFile]) {
                [mailComposer addAttachmentData:[photoNC emailImage:@"Start Month 2 Side"] mimeType:@"image/jpg" fileName:@"Start Month 2 Side.jpg"];
            }
            
            // MONTH 3
            imageFile = [docDir stringByAppendingPathComponent:@"Start Month 3 Side.JPG"];
            if ([[NSFileManager defaultManager] fileExistsAtPath:imageFile]) {
                [mailComposer addAttachmentData:[photoNC emailImage:@"Start Month 3 Side"] mimeType:@"image/jpg" fileName:@"Start Month 3 Side.jpg"];
            }
            
            // FINAL
            imageFile = [docDir stringByAppendingPathComponent:@"Final Side.JPG"];
            if ([[NSFileManager defaultManager] fileExistsAtPath:imageFile]) {
                [mailComposer addAttachmentData:[photoNC emailImage:@"Final Side"] mimeType:@"image/jpg" fileName:@"Final Side.jpg"];
            }
        }
        
        // BACK PHOTOS
        else if ([self.navigationItem.title isEqualToString:@"Back"]) {
            [mailComposer setSubject:@"90 DWT 3 Back Photos"];
            
            // MONTH 1
            imageFile = [docDir stringByAppendingPathComponent:@"Start Month 1 Back.JPG"];
            if ([[NSFileManager defaultManager] fileExistsAtPath:imageFile]) {
                [mailComposer addAttachmentData:[photoNC emailImage:@"Start Month 1 Back"] mimeType:@"image/jpg" fileName:@"Start Month 1 Back.jpg"];
            }
            
            // MONTH 2
            imageFile = [docDir stringByAppendingPathComponent:@"Start Month 2 Back.JPG"];
            if ([[NSFileManager defaultManager] fileExistsAtPath:imageFile]) {
                [mailComposer addAttachmentData:[photoNC emailImage:@"Start Month 2 Back"] mimeType:@"image/jpg" fileName:@"Start Month 2 Back.jpg"];
            }
            
            // MONTH 3
            imageFile = [docDir stringByAppendingPathComponent:@"Start Month 3 Back.JPG"];
            if ([[NSFileManager defaultManager] fileExistsAtPath:imageFile]) {
                [mailComposer addAttachmentData:[photoNC emailImage:@"Start Month 3 Back"] mimeType:@"image/jpg" fileName:@"Start Month 3 Back.jpg"];
            }
            
            // FINAL
            imageFile = [docDir stringByAppendingPathComponent:@"Final Back.JPG"];
            if ([[NSFileManager defaultManager] fileExistsAtPath:imageFile]) {
                [mailComposer addAttachmentData:[photoNC emailImage:@"Final Back"] mimeType:@"image/jpg" fileName:@"Final Back.jpg"];
            }
        }
        
        [self presentViewController:mailComposer animated:YES completion:^{
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        }];
    }
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)configureViewForIOSVersion {
    
    // Colors
    UIColor *lightGrey = [UIColor colorWithRed:234/255.0f green:234/255.0f blue:234/255.0f alpha:1.0f];
    //UIColor *midGrey = [UIColor colorWithRed:219/255.0f green:218/255.0f blue:218/255.0f alpha:1.0f];
    //UIColor *darkGrey = [UIColor colorWithRed:102/255.0f green:102/255.0f blue:102/255.0f alpha:1.0f];
    //UIColor* blueColor = [UIColor colorWithRed:0/255.0f green:122/255.0f blue:255/255.0f alpha:1.0f];
    
    // Apply Text Colors
    
    // Apply Background Colors
    
    //self.view.backgroundColor = [UIColor blackColor];
    self.collectionView.backgroundColor = lightGrey;
    
    // Apply Keyboard Color
}

- (IBAction)shareActionSheet:(UIBarButtonItem *)sender {
    
    UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:@"Share" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Email", @"Facebook", @"Twitter", nil];
    
    [action showFromTabBar:self.tabBarController.tabBar];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 0) {
        [self emailPhotos];
    }
    
    if (buttonIndex == 1) {
        [self facebook];
    }
    
    if (buttonIndex == 2) {
        [self twitter];
    }
}

#pragma mark - UICollectionView Datasource

// 1
- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    
    return [self.arrayOfImages count];
}
// 2
- (NSInteger)numberOfSectionsInCollectionView:
(UICollectionView *)collectionView {
    
    return 1;
}
// 3
- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UIColor *blueColor = [UIColor colorWithRed:76/255.0f green:152/255.0f blue:213/255.0f alpha:1.0f];
    
    photoCollectionViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    
    cell.backgroundColor = [UIColor whiteColor];
    cell.myImage.image = [self.arrayOfImages objectAtIndex:indexPath.item];
    
    cell.myLabel.text = self.arrayOfImageTitles[indexPath.item];
    cell.myLabel.backgroundColor = [UIColor blackColor];
    cell.myLabel.textColor = blueColor;
    cell.myLabel.textAlignment = NSTextAlignmentCenter;
    
    return cell;
}
@end
