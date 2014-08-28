//
//  ViewController.m
//  LightMeterProject
//
//  Created by Kok Hong on 8/19/14.
//  Copyright (c) 2014 Kok Hong. All rights reserved.
//

#import "ViewController.h"
@interface ViewController ()
{
@private
    AVCaptureDevicePosition _currentCameraPosition;
}
@end

@implementation ViewController
            
- (void)viewDidLoad {
    [super viewDidLoad];
    self.calibrationLabel.text = [NSString stringWithFormat:@"%.1f",self.slider.value];
    [self initCamera];
    
}

- (void)initCamera
{
    self.captureSession = [[AVCaptureSession alloc] init];
    self.captureSession .sessionPreset = AVCaptureSessionPresetMedium;
    
    AVCaptureVideoPreviewLayer *captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.captureSession ];
    
    captureVideoPreviewLayer.frame = self.cameraView.layer.bounds;
    [self.cameraView.layer addSublayer:captureVideoPreviewLayer];
    
    AVCaptureDevice *device =  [self cameraWithPosition:AVCaptureDevicePositionFront];
    NSError *error = nil;
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    _currentCameraPosition = device.position;
    
    if (!input) {
        // Handle the error appropriately.
        NSLog(@"ERROR: trying to open camera: %@", error);
    }
    
    [self.captureSession  addInput:input];
    AVCaptureVideoDataOutput *output = [[AVCaptureVideoDataOutput alloc] init];
    [self.captureSession  addOutput:output];
    output.videoSettings =
    @{ (NSString *)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_32BGRA) };
    dispatch_queue_t queue = dispatch_queue_create("VideoQueue", DISPATCH_QUEUE_SERIAL);
    [output setSampleBufferDelegate:self queue:queue];

    [self.captureSession  startRunning];
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    NSDictionary *exifDictionary = (__bridge NSDictionary*)CMGetAttachment(sampleBuffer, kCGImagePropertyExifDictionary, NULL);
    

    NSLog(@"%@",exifDictionary);
    double C = 1.0f;
    double N = [exifDictionary[@"FNumber"] doubleValue];
    double t = [exifDictionary[@"ExposureTime"] doubleValue];
    double S = [exifDictionary[@"ISOSpeedRatings"][0] doubleValue];
    double lux = (C * N *N ) / ( t * S);
    lux -= 0.09;
    lux = lux <= 0 ? 0 : lux;
    lux *= [self.calibrationLabel.text doubleValue];

    NSLog(@"%lf",lux);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.luxValueLabel.text = [@(lux) stringValue];
    });
    
}

- (IBAction)frontCameraButton:(id)sender
{
    if(self.captureSession)
    {
        //Indicate that some changes will be made to the session
        [_captureSession beginConfiguration];
        
        //Remove existing input
        AVCaptureInput* currentCameraInput = [_captureSession.inputs objectAtIndex:0];
        [_captureSession removeInput:currentCameraInput];
        
        //Get new input
        AVCaptureDevice *newCamera = nil;
        if(((AVCaptureDeviceInput*)currentCameraInput).device.position == AVCaptureDevicePositionBack)
        {
            newCamera = [self cameraWithPosition:AVCaptureDevicePositionFront];
        }
        else
        {
            newCamera = [self cameraWithPosition:AVCaptureDevicePositionBack];
        }
        
        //Add input to session
        AVCaptureDeviceInput *newVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:newCamera error:nil];
        [_captureSession addInput:newVideoInput];
        
        //Commit all the configuration changes at once
        [_captureSession commitConfiguration];
    }
}

- (AVCaptureDevice *) cameraWithPosition:(AVCaptureDevicePosition) position
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices)
    {
        if ([device position] == position) return device;
    }
    return nil;
}

- (IBAction)sliderChanged:(UISlider *)sender {
    self.calibrationLabel.text = [NSString stringWithFormat:@"%.1f",sender.value];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
