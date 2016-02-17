//
//  CHImageSaveController.m
//  DrawingBoard
//
//  Created by renren on 16/2/16.
//  Copyright © 2016年 chunhong.wang. All rights reserved.
//

#import "CHImageSaveController.h"

@interface CHImageSaveController ()

@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation CHImageSaveController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    self.navigationItem.title = @"image";
    UIBarButtonItem *rightBtn = [[UIBarButtonItem alloc] initWithTitle:@"save" style:UIBarButtonItemStyleDone target:self action:@selector(saveButtonClicked)];
    self.navigationItem.rightBarButtonItem = rightBtn;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.imageView setFrame:CGRectMake(10, 100, self.view.bounds.size.width - 20, self.view.bounds.size.height - 100)];
    self.imageView.image = self.img;
    [self.imageView sizeToFit];
}

- (UIImageView *)imageView {
    if (nil == _imageView) {
        _imageView = [[UIImageView alloc] init];
        [self.view addSubview:_imageView];
        _imageView.backgroundColor = [UIColor lightGrayColor];
    }
    return _imageView;
}


- (void)saveButtonClicked {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"save success" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"ok" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        self.navigationItem.rightBarButtonItem.enabled = NO;
        [self.navigationController dismissViewControllerAnimated:YES completion:^{
        }];
    }];
    [alert addAction:action];
    [self.navigationController presentViewController:alert animated:YES completion:^{
        
    }];
}

@end
