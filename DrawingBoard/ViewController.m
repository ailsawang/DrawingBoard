//
//  ViewController.m
//  DrawingBoard
//
//  Created by renren on 16/2/15.
//  Copyright © 2016年 chunhong.wang. All rights reserved.
//

#import "ViewController.h"
#import "CHColorPickerView.h"
#import "CHImageSaveController.h"

@interface ViewController ()<CHColorPickerDelegate>

@property (nonatomic, assign) BOOL isColoPickerOn;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.redoButton.enabled = NO;
    self.drawingView.layer.cornerRadius = 2.0;
    self.drawingView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.drawingView.layer.borderWidth = 1.0;
    
    self.undoButton.layer.cornerRadius = 4.0;
    self.undoButton.layer.borderColor = [UIColor grayColor].CGColor;
    self.undoButton.layer.borderWidth = 1.0;
    
    self.redoButton.layer.cornerRadius = 4.0;
    self.redoButton.layer.borderColor = [UIColor grayColor].CGColor;
    self.redoButton.layer.borderWidth = 1.0;
    
    self.clearButton.layer.cornerRadius = 4.0;
    self.clearButton.layer.borderColor = [UIColor grayColor].CGColor;
    self.clearButton.layer.borderWidth = 1.0;
    
    self.saveButton.layer.cornerRadius = 4.0;
    self.saveButton.layer.borderColor = [UIColor grayColor].CGColor;
    self.saveButton.layer.borderWidth = 1.0;
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.drawingView clear];
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"pickedColor"]) {
        self.colorButton.backgroundColor = [CHColorPickerView sharedInstance].pickedColor;
    }
}

- (IBAction)undo:(id)sender {
    [self.drawingView undo];
    [self resetButton];
}

- (IBAction)clear:(id)sender {
    [self.drawingView clear];
    [self resetButton];
}

- (IBAction)redo:(id)sender {
    [self.drawingView redo];
    [self resetButton];
}

- (void)resetButton {
    if (self.drawingView.abandonStrokes.count == 0) {
        self.redoButton.enabled = NO;
    } else {
        self.redoButton.enabled = YES;
    }
}

- (IBAction)sliderValueChanged:(UISlider *)slider {
    self.sizeLabel.text = [NSString stringWithFormat:@"%.1f",slider.value];
    [self.drawingView changeToSize:slider.value];
}


- (IBAction)chooseColor:(id)sender {
//    self.drawingView.userInteractionEnabled = NO;
    [[CHColorPickerView sharedInstance] setColorPickerDelegate:self];
    [[CHColorPickerView sharedInstance] setupColorPickerViewWithFrame:CGRectMake(60, 120, 240, 240) InView:self.view];
    [[CHColorPickerView sharedInstance] addObserver:self forKeyPath:@"pickedColor" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
}

#pragma mark - CHColorPickerDelegate

- (void)colorPickerDidShowOnView:(UIView *)view {
    self.isColoPickerOn = YES;
    self.drawingView.userInteractionEnabled = NO;
}

- (void)colorPickerDidDismissFromView:(UIView *)view {
    self.isColoPickerOn = NO;
    [self.drawingView changeToColor:[CHColorPickerView sharedInstance].pickedColor];
    self.drawingView.userInteractionEnabled = YES;
}

- (void)colorPickerWillShowOnView:(UIView *)view {
    
}

- (void)colorPickerWillDismissFromView:(UIView *)view {
    
}

- (IBAction)savePic:(id)sender {
    if (self.drawingView.arrayStrokes.count == 0) {
        return;
    }
    UIImage *img = [self.drawingView saveToImage];
    if (img) {
        CHImageSaveController *saveController = [[CHImageSaveController alloc] init];
        saveController.img = img;
        [self.navigationController pushViewController:saveController animated:YES];
    }
}

@end
