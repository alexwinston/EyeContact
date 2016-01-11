/*
 *  CVOCVController.m
 *
 *  Created by buza on 10/02/08.
 *
 *  Brought to you by buzamoto. http://buzamoto.com
 */

#include "cv.h"

#import "CVOCVController.h"
#import "iTunes.h"

@implementation CVOCVController

static const int kFrameIntervals[6] = { 1, 2, 5, 10, 15, 30 };

- (void)awakeFromNib
{
    NSString *haarcascadePath = [[NSBundle mainBundle] pathForResource:@"haarcascade_frontalface_alt"
                                                                ofType:@"xml"];
    NSLog(@"%@", haarcascadePath);
    
    cascade = (CvHaarClassifierCascade*)cvLoad([haarcascadePath cStringUsingEncoding:NSUTF8StringEncoding], 0, 0, 0);
    
    // Create the capture session
	mCaptureSession = [[QTCaptureSession alloc] init];
    
    mOutput = [[QTCaptureDecompressedVideoOutput alloc] init];
    [mOutput setMinimumVideoFrameInterval:1];
    
    [mOutput setPixelBufferAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                       [NSNumber numberWithDouble:160.0], (id)kCVPixelBufferWidthKey,
                                       [NSNumber numberWithDouble:120.0], (id)kCVPixelBufferHeightKey,
                                       [NSNumber numberWithUnsignedInt:kCVPixelFormatType_24RGB], (id)kCVPixelBufferPixelFormatTypeKey,
                                       nil]];
    [mOutput setDelegate:self];
    
    frameImage = (IplImage*)malloc(sizeof(IplImage));
    
	BOOL success = NO;
	NSError *error;
	
    //Find a device  
    QTCaptureDevice *videoDevice = [QTCaptureDevice defaultInputDeviceWithMediaType:QTMediaTypeVideo];
    NSLog(@"Selecting device %@", videoDevice);
    success = [videoDevice open:&error];
    
    NSLog(@"Devices found: %@", [QTCaptureDevice inputDevicesWithMediaType:QTMediaTypeVideo]);
    for (QTCaptureDevice *inputDevice in [QTCaptureDevice inputDevicesWithMediaType:QTMediaTypeVideo])
        [inputDevicesPopUpButton addItemWithTitle:[NSString stringWithFormat:@"%@", inputDevice]];
    [inputDevicesPopUpButton selectItemWithTitle:[videoDevice description]];
    inputDevicesSelectedIndex = [inputDevicesPopUpButton indexOfSelectedItem];
    
    if (error != nil) {
        NSLog(@"Had some trouble selecting that device. I'm leaving now.");
        return;
    }
    
    //Add the video device to the session as a device input
    if (videoDevice) {
        
		mCaptureVideoDeviceInput = [[QTCaptureDeviceInput alloc] initWithDevice:videoDevice];
		success = [mCaptureSession addInput:mCaptureVideoDeviceInput error:&error];
        
		if (!success) {
            NSLog(@"Couldn't set up the input device. I'm leaving now.");
            return;
		}
        
        success = [mCaptureSession addOutput:mOutput error:&error];
        
		if (!success) {
            NSLog(@"Couldn't set up the output device. I'm leaving now.");
            return;
		}
        
        //[mCaptureView setCaptureSession:mCaptureSession];
        
        //Looks like we're good to go.
        [mCaptureSession startRunning];
	}
}

- (void)windowWillClose:(NSNotification *)notification
{
	[mCaptureSession stopRunning];
    
    if ([[mCaptureVideoDeviceInput device] isOpen])
        [[mCaptureVideoDeviceInput device] close];
}

- (void)dealloc
{
	[mCaptureSession release];
	[mCaptureVideoDeviceInput release];
    
    free(frameImage);

	[super dealloc];
}

- (IBAction)inputDeviceChanged:(NSPopUpButton *)popUpButton {
    NSLog(@"inputDeviceChanged:%d", [popUpButton indexOfSelectedItem]);
    [mCaptureSession removeInput:mCaptureVideoDeviceInput];
    [[[QTCaptureDevice inputDevicesWithMediaType:QTMediaTypeVideo] objectAtIndex:inputDevicesSelectedIndex] close];
    
    inputDevicesSelectedIndex = [inputDevicesPopUpButton indexOfSelectedItem];
    
    QTCaptureDevice *videoDevice = [[QTCaptureDevice inputDevicesWithMediaType:QTMediaTypeVideo] objectAtIndex:inputDevicesSelectedIndex];;
    NSLog(@"Selecting device %@", videoDevice);
    
    NSError *error;
    [videoDevice open:&error];
    
    if (error != nil) {
        NSLog(@"Had some trouble selecting that device.");
        return;
    }
    
    //Add the video device to the session as a device input
    if (videoDevice) {
		mCaptureVideoDeviceInput = [[QTCaptureDeviceInput alloc] initWithDevice:videoDevice];
        
		BOOL success = [mCaptureSession addInput:mCaptureVideoDeviceInput error:&error];
		if (!success) {
            NSLog(@"Couldn't set up the input device. I'm leaving now.");
            return;
		}
        
        success = [mCaptureSession addOutput:mOutput error:&error];
		if (!success) {
            NSLog(@"Couldn't set up the output device. I'm leaving now.");
            return;
		}
        
        [mCaptureSession startRunning];
	}
}

- (IBAction)frameIntervalSliderChanged:(NSSlider *)slider {
    NSLog(@"%d", kFrameIntervals[[slider intValue]]);

    [mOutput setMinimumVideoFrameInterval:kFrameIntervals[[slider intValue]]];
}

- (IBAction)triggerStartCountSliderChanged:(NSSlider *)slider {
}

- (IBAction)triggerStopCountSliderChanged:(NSSlider *)slider {
}

static CGImageRef CreateCGImageFromPixelBuffer(CVImageBufferRef inImage, OSType inPixelFormat)
{
    CGColorSpaceRef colorSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
    
    void *baseAddress = CVPixelBufferGetBaseAddress(inImage);
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(inImage);
    
    size_t width = CVPixelBufferGetWidth(inImage);
    size_t height = CVPixelBufferGetHeight(inImage);
    CGImageAlphaInfo alphaInfo = kCGImageAlphaNone;
    CGDataProviderRef provider = provider = CGDataProviderCreateWithData(NULL, baseAddress, bytesPerRow * height, NULL);
    
    CGImageRef image = CGImageCreate(width, height, 8, 24, bytesPerRow, colorSpace, alphaInfo, provider, NULL, false, kCGRenderingIntentDefault);
    
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
 
    return image;
}

/*
 * Here's one reference that I found moderately useful for this CoreVideo stuff:
 * http://developer.apple.com/documentation/graphicsimaging/Reference/CoreVideoRef/Reference/reference.html
 */
- (void)captureOutput:(QTCaptureOutput *)captureOutput didOutputVideoFrame:(CVImageBufferRef)videoFrame withSampleBuffer:(QTSampleBuffer *)sampleBuffer fromConnection:(QTCaptureConnection *)connection
{
    CVPixelBufferLockBaseAddress((CVPixelBufferRef)videoFrame, 0);
    
    //Process the frame, and get the result.
    if ([self hasFaces:videoFrame]) {
        triggerCount = !hasContact ? triggerCount + 1 : 0;
        if (triggerCount >= [triggerStartCountSlider intValue]) {
            hasContact = YES;
            triggerCount = 0;
            [self eyeContactDidStart];
        }
    } else {
        triggerCount = hasContact ? triggerCount + 1 : 0;
        if (triggerCount >= [triggerStopCountSlider intValue]) {
            hasContact = NO;
            triggerCount = 0;
            [self eyeContactDidStop];
        }
    }
    
    CVPixelBufferUnlockBaseAddress((CVPixelBufferRef)videoFrame, 0);
}

- (BOOL)hasFaces:(CVImageBufferRef)videoFrame {
    //Fill in the OpenCV image struct from the data from CoreVideo.
    frameImage->nSize       = sizeof(IplImage);
    frameImage->ID          = 0;
    frameImage->nChannels   = 3;
    frameImage->depth       = IPL_DEPTH_8U;
    frameImage->dataOrder   = 0;
    frameImage->origin      = 0; //Top left origin.
    frameImage->width       = CVPixelBufferGetWidth((CVPixelBufferRef)videoFrame);
    frameImage->height      = CVPixelBufferGetHeight((CVPixelBufferRef)videoFrame);
    frameImage->roi         = 0; //Region of interest. (struct IplROI).
    frameImage->maskROI     = 0;
    frameImage->imageId     = 0;
    frameImage->tileInfo    = 0;
    frameImage->imageSize   = CVPixelBufferGetDataSize((CVPixelBufferRef)videoFrame);
    frameImage->imageData   = (char*)CVPixelBufferGetBaseAddress((CVPixelBufferRef)videoFrame);
    frameImage->widthStep   = CVPixelBufferGetBytesPerRow((CVPixelBufferRef)videoFrame);
    frameImage->imageDataOrigin = (char*)CVPixelBufferGetBaseAddress((CVPixelBufferRef)videoFrame);
    
    [openGLView clearFaceRects];
    
    BOOL hasFaces = NO;
    
    CvMemStorage* storage = cvCreateMemStorage(0);
    
    float scale = 1;//videoFrameView.frame.size.width / 160.0f;
    
    // Create a new image based on the input image
    IplImage* temp = cvCreateImage( cvSize(frameImage->width/scale,frameImage->height/scale), 8, 3 );
    
    // Create two points to represent the face locations
    CvPoint pt1, pt2;
    int i;
    
    // Clear the memory storage which was used before
    cvClearMemStorage( storage );
    
    // Find whether the cascade is loaded, to find the faces. If yes, then:
    if (cascade) {
        // There can be more than one face in an image. So create a growable sequence of faces.
        // Detect the objects and store them in the sequence
        CvSeq* faces = cvHaarDetectObjects(frameImage, cascade, storage,
                                           1.1, 2, CV_HAAR_DO_CANNY_PRUNING,
                                           cvSize(40, 40) );
        
        CGImageRef imageRef = CreateCGImageFromPixelBuffer(videoFrame, kCVPixelFormatType_24RGB);
        
        NSBitmapImageRep *imageRep = [[[NSBitmapImageRep alloc] initWithCGImage:imageRef] autorelease];
        NSImage *image = [[[NSImage alloc] initWithSize:[imageRep size]] autorelease];
        [image addRepresentation:imageRep];
        
        [videoFrameView setImage:image];
        
        CGImageRelease(imageRef);
        
        // Loop the number of faces found.
        NSLog(@"faces->total: %d", faces->total);
        hasFaces = faces->total > 0;
        for( i = 0; i < (faces ? faces->total : 0); i++ ) {
            // Create a new rectangle for drawing the face
            CvRect* r = (CvRect*)cvGetSeqElem( faces, i );
            
            // Find the dimensions of the face,and scale it if necessary
            pt1.x = r->x*scale;
            pt2.x = (r->x+r->width)*scale;
            pt1.y = r->y*scale;
            pt2.y = (r->y+r->height)*scale;
            
            [openGLView addFaceRect:NSMakeRect(r->x, 120 - r->height - r->y, r->width, r->height)];
            
            // Draw the rectangle in the input image
//            cvRectangle(cpy, pt1, pt2, CV_RGB(255,0,0), 3, 8, 0);
        }
    }
    
    //    [self texturizeImage:cpy];
    
    // Release the temp images and storage.
    cvReleaseImage(&temp);
    cvReleaseMemStorage(&storage);
    
    [openGLView setNeedsDisplay:YES];
    
    return hasFaces;
}

- (void)eyeContactDidStart {
    NSLog(@"eyeContactDidStart");
    iTunesApplication *iTunes = [SBApplication applicationWithBundleIdentifier:@"com.apple.iTunes"];
    if ([iTunes isRunning] && [iTunes playerState] == iTunesEPlSPaused) {
        [iTunes playpause];
    }
    [iTunes release];
    
    NSAppleScript *script;
    script = [[NSAppleScript alloc] initWithSource:[startAppleScriptTextView string]];
    [script executeAndReturnError:nil];
    [script release];
}

- (void)eyeContactDidStop {
    NSLog(@"eyeContactDidStop");
    iTunesApplication *iTunes = [SBApplication applicationWithBundleIdentifier:@"com.apple.iTunes"];
    if ([iTunes isRunning] && [iTunes playerState] == iTunesEPlSPlaying) {
        [iTunes pause];
    }
    [iTunes release];
    
    NSAppleScript *script;
    script = [[NSAppleScript alloc] initWithSource:[stopAppleScriptTextView string]];
    [script executeAndReturnError:nil];
    [script release];
}

@end
