/*
 *  CVOCVController.h
 *
 *  Created by buza on 10/02/08.
 *
 *  Brought to you by buzamoto. http://buzamoto.com
 */

#include "cv.h"

#import <Cocoa/Cocoa.h>
#import <QTKit/QTkit.h>
#import <Quartz/Quartz.h>

#import "CVOCVView.h"

@interface CVOCVController : NSObject 
{
    IBOutlet CVOCVView *openGLView;
    
    IBOutlet NSImageView *videoFrameView;
    
    int inputDevicesSelectedIndex; 
    IBOutlet NSPopUpButton *inputDevicesPopUpButton;
    
    IBOutlet NSSlider *frameIntervalSlider;
    IBOutlet NSSlider *triggerStartCountSlider;
    IBOutlet NSSlider *triggerStopCountSlider;
    
    IBOutlet NSTextView *startAppleScriptTextView;
    IBOutlet NSTextView *stopAppleScriptTextView;
    
    BOOL hasContact;
    int triggerCount;
   
    QTCaptureSession                    *mCaptureSession;
    QTCaptureMovieFileOutput            *mCaptureMovieFileOutput;
    QTCaptureDeviceInput                *mCaptureVideoDeviceInput;
    QTCaptureDecompressedVideoOutput    *mOutput;
    
    CvHaarClassifierCascade *cascade;

    IplImage *frameImage;
}

- (BOOL)hasFaces:(CVImageBufferRef)videoFrame;

- (IBAction)inputDeviceChanged:(NSPopUpButton *)popUpButton;
- (IBAction)frameIntervalSliderChanged:(NSSlider *)slider;
- (IBAction)triggerStartCountSliderChanged:(NSSlider *)slider;
- (IBAction)triggerStopCountSliderChanged:(NSSlider *)slider;

- (void)eyeContactDidStart;
- (void)eyeContactDidStop;

@end
