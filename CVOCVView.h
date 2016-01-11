/*
 *  CVOCVView.h
 *
 *  Created by buza on 10/02/08.
 *
 *  Brought to you by buzamoto. http://buzamoto.com
 */

#import <Cocoa/Cocoa.h>


@interface CVOCVView : NSView 
{
    NSMutableArray *faceRectsArray;
}
- (void)clearFaceRects;
- (void)addFaceRect:(NSRect)faceRect;
@end
