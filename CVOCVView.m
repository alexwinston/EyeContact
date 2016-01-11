/*
 *  CVOCVView.m
 *
 *  Created by buza on 10/02/08.
 *
 *  Brought to you by buzamoto. http://buzamoto.com
 */

#include <OpenGL/OpenGL.h>

#import "CVOCVView.h"
#import "CVOCVController.h"

@implementation CVOCVView

- (id)initWithFrame:(NSRect)frame
{
	self = [super initWithFrame:frame];
    if (self) {
        faceRectsArray = [[NSMutableArray array] retain];
    }
    
    return self;
}

- (void)dealloc 
{
    [faceRectsArray release];
    [super dealloc];
}

- (void)clearFaceRects {
    [faceRectsArray removeAllObjects];
}

- (void)addFaceRect:(NSRect)faceRect {
    [faceRectsArray addObject:[NSValue valueWithRect:faceRect]];
}

- (void)drawRect:(NSRect)rect
{
    [NSGraphicsContext saveGraphicsState];
    
    NSAffineTransform *transform = [NSAffineTransform transform];
    [transform translateXBy: 0.5 yBy: 0.5];
    
    NSBezierPath *path = [NSBezierPath bezierPathWithRect:rect];
    [path setWindingRule:NSEvenOddWindingRule];
    
    for (NSValue *faceValue in faceRectsArray) {
        NSRect faceRect = [faceValue rectValue];
        
        [[NSColor colorWithCalibratedRed:0.0 green:0.0 blue:0.0 alpha:0.35] set];
        NSBezierPath *borderPath = [NSBezierPath bezierPathWithRoundedRect:faceRect xRadius:1.0 yRadius:1.0];
        [borderPath transformUsingAffineTransform: transform];
        [borderPath stroke];

        [path appendBezierPath:[NSBezierPath bezierPathWithRect:faceRect]];
        //[path appendBezierPath:[NSBezierPath bezierPathWithRect:NSMakeRect(faceRect.origin.x+10, faceRect.origin.y+20, faceRect.size.width-20, faceRect.size.height+30)]];
    }
    
    [[NSColor colorWithCalibratedRed:255.0 green:255.0 blue:255.0 alpha:0.15] set];
    [path fill];
    
    [NSGraphicsContext restoreGraphicsState];
}

- (void)drawRect2:(NSRect)rect
{
    NSAffineTransform *transform = [NSAffineTransform transform];
    [transform translateXBy: 0.5 yBy: 0.5];

    for (NSValue *faceValue in faceRectsArray) {
        NSRect faceRect = [faceValue rectValue];
//        NSLog(@"%f, %f, %f, %f", faceRect.origin.x, faceRect.origin.y, faceRect.size.width, faceRect.size.height);
        
        [[NSColor colorWithCalibratedRed:225.0/255.0 green:22.0/255.0 blue:20.0/255.0 alpha:0.75] setStroke]; // Sets current drawing color.
        NSBezierPath *crosshairBackgroundPath = [NSBezierPath bezierPathWithRoundedRect:faceRect xRadius:1 yRadius:1];
        [crosshairBackgroundPath setLineWidth:3.0];
        [crosshairBackgroundPath moveToPoint:NSMakePoint(faceRect.origin.x + faceRect.size.width / 2, faceRect.origin.y)];
        [crosshairBackgroundPath lineToPoint:NSMakePoint(faceRect.origin.x + faceRect.size.width / 2, faceRect.origin.y + 5)];
        
        [crosshairBackgroundPath moveToPoint:NSMakePoint(faceRect.origin.x + faceRect.size.width / 2, faceRect.origin.y + faceRect.size.height)];
        [crosshairBackgroundPath lineToPoint:NSMakePoint(faceRect.origin.x + faceRect.size.width / 2, faceRect.origin.y + faceRect.size.height - 5)];
        
        [crosshairBackgroundPath moveToPoint:NSMakePoint(faceRect.origin.x + faceRect.size.width, faceRect.origin.y + faceRect.size.height / 2)];
        [crosshairBackgroundPath lineToPoint:NSMakePoint(faceRect.origin.x + faceRect.size.width - 5, faceRect.origin.y + faceRect.size.height / 2)];
        
        [crosshairBackgroundPath moveToPoint:NSMakePoint(faceRect.origin.x, faceRect.origin.y + faceRect.size.height / 2)];
        [crosshairBackgroundPath lineToPoint:NSMakePoint(faceRect.origin.x + 5, faceRect.origin.y + faceRect.size.height / 2)];
        [crosshairBackgroundPath transformUsingAffineTransform: transform];
        [crosshairBackgroundPath stroke];
        
        [[NSColor whiteColor] setStroke]; // Sets current drawing color.
        NSBezierPath *crosshairPath = [NSBezierPath bezierPathWithRoundedRect:faceRect xRadius:1 yRadius:1];
        [crosshairPath setLineWidth:1.0];
        [crosshairPath moveToPoint:NSMakePoint(faceRect.origin.x + faceRect.size.width / 2, faceRect.origin.y)];
        [crosshairPath lineToPoint:NSMakePoint(faceRect.origin.x + faceRect.size.width / 2, faceRect.origin.y + 4)];
        
        [crosshairPath moveToPoint:NSMakePoint(faceRect.origin.x + faceRect.size.width / 2, faceRect.origin.y + faceRect.size.height)];
        [crosshairPath lineToPoint:NSMakePoint(faceRect.origin.x + faceRect.size.width / 2, faceRect.origin.y + faceRect.size.height - 4)];
        
        [crosshairPath moveToPoint:NSMakePoint(faceRect.origin.x + faceRect.size.width, faceRect.origin.y + faceRect.size.height / 2)];
        [crosshairPath lineToPoint:NSMakePoint(faceRect.origin.x + faceRect.size.width - 4, faceRect.origin.y + faceRect.size.height / 2)];
        
        [crosshairPath moveToPoint:NSMakePoint(faceRect.origin.x, faceRect.origin.y + faceRect.size.height / 2)];
        [crosshairPath lineToPoint:NSMakePoint(faceRect.origin.x + 4, faceRect.origin.y + faceRect.size.height / 2)];
        [crosshairPath transformUsingAffineTransform: transform];
        [crosshairPath stroke];
    }
}

@end
