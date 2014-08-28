//
//  ViewController.h
//  LightMeterProject
//
//  Created by Kok Hong on 8/19/14.
//  Copyright (c) 2014 Kok Hong. All rights reserved.
//

#import <UIKit/UIKit.h>
@import AVFoundation;
@import MobileCoreServices;
@import ImageIO;

@interface ViewController : UIViewController  <AVCaptureVideoDataOutputSampleBufferDelegate>
@property (weak, nonatomic) IBOutlet UITextView *textView;

@property (weak, nonatomic) IBOutlet UILabel *luxValueLabel;
@property (weak, nonatomic) IBOutlet UIView *cameraView;
@property (weak, nonatomic) IBOutlet UILabel *calibrationLabel;
@property (weak, nonatomic) IBOutlet UISlider *slider;
@property (strong,nonatomic) AVCaptureSession *captureSession;
@end

