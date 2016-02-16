//
//  ViewController.h
//  DrawingBoard
//
//  Created by renren on 16/2/15.
//  Copyright © 2016年 chunhong.wang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DrawingCanvas.h"

@interface ViewController : UIViewController

- (IBAction)undo:(id)sender;
- (IBAction)clear:(id)sender;
- (IBAction)redo:(id)sender;

@property (strong, nonatomic) IBOutlet UISlider *slider;
- (IBAction)sliderValueChanged:(id)sender;
@property (strong, nonatomic) IBOutlet UILabel *sizeLabel;
@property (strong, nonatomic) IBOutlet DrawingCanvas *drawingView;
@property (strong, nonatomic) IBOutlet UIButton *undoButton;
@property (strong, nonatomic) IBOutlet UIButton *redoButton;
@property (strong, nonatomic) IBOutlet UIButton *colorButton;
- (IBAction)chooseColor:(id)sender;

@property (strong, nonatomic) IBOutlet UIButton *clearButton;
@property (strong, nonatomic) IBOutlet UIButton *saveButton;
- (IBAction)savePic:(id)sender;

@end

