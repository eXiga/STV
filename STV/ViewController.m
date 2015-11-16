//
//  ViewController.m
//  STV
//
//  Created by Anton Kostenich on 10/27/15.
//  Copyright © 2015 Anton Kostenich. All rights reserved.
//

#import "ViewController.h"
#import "STVImageProcessor.h"
#import "SaturatedBorders.h"

@interface ViewController ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, weak) IBOutlet UIImageView *sourceImage;

@property (nonatomic, strong) UIImagePickerController *imagePickerController;
@property (nonatomic, strong) UIAlertController *alertController;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initAlertController];
    
    UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageViewTapped)];
    [tgr setNumberOfTouchesRequired:1];
    [_sourceImage setUserInteractionEnabled:YES];
    [_sourceImage addGestureRecognizer:tgr];
}

- (void)initAlertController {
    _alertController = [UIAlertController alertControllerWithTitle:@"SELECT IMAGE"
                                                           message:nil
                                                    preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *openCamera = [UIAlertAction actionWithTitle:@"Camera"
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction * _Nonnull action) {
                                                       
                                                   }];
    UIAlertAction *openGallery = [UIAlertAction actionWithTitle:@"Gallery"
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction *action) {
                                                             self.imagePickerController = [[UIImagePickerController alloc] init];
                                                             self.imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                                                             self.imagePickerController.modalPresentationStyle = UIModalPresentationPopover;
                                                             self.imagePickerController.popoverPresentationController.sourceView = self.sourceImage;
                                                             self.imagePickerController.delegate = self;
                                                             [self presentViewController:self.imagePickerController animated:YES completion:nil];
                                                         }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel"
                                                     style:UIAlertActionStyleDestructive
                                                   handler:^(UIAlertAction *action) {
                                                       [self dismissViewControllerAnimated:YES completion:nil];
                                                   }];
    [_alertController addAction:openCamera];
    [_alertController addAction:openGallery];
    [_alertController addAction:cancel];
}

#pragma mark - UIImagePickerControllerDelegate methods

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    [self dismissViewControllerAnimated:YES completion:^{
        self.sourceImage.image = [info objectForKey:UIImagePickerControllerOriginalImage];
    }];
}

#pragma mark - Tap gestures

- (void)imageViewTapped {
/*    self.alertController.popoverPresentationController.sourceView = self.sourceImage;
    [self presentViewController:self.alertController animated:YES completion:nil];*/
    
    STVImageProcessor *p = [[STVImageProcessor alloc] initWithImage:[UIImage imageNamed:@"lena.png"]];
    SaturatedBorders *b = [SaturatedBorders new];
    b.s1 = [NSNumber numberWithInt:0];
    b.s2 = [NSNumber numberWithInt:11];
    UIImage *i = [p saturateWithBorders:b];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.sourceImage.image = i;
    });
}

@end
