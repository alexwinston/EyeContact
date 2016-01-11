//
//  ECTextView.m
//  CVOCV
//
//  Created by Alex Winston on 6/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ECTextView.h"


@implementation ECTextView

- (id)initWithFrame:(NSRect)frameRect textContainer:(NSTextContainer *)container
{
    self = [super initWithFrame:frameRect textContainer:container];
    if (self) {
        // Initialization code goes here
    }
    
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

// http://www.cocoarocket.com/articles/copypaste.html
- (BOOL)performKeyEquivalent:(NSEvent *)event {
    if (([event modifierFlags] & NSDeviceIndependentModifierFlagsMask) == NSCommandKeyMask) {
        if ([[event charactersIgnoringModifiers] isEqualToString:@"x"]) {
            return [NSApp sendAction:@selector(cut:) to:[[self window] firstResponder] from:self];
        } else if ([[event charactersIgnoringModifiers] isEqualToString:@"c"]) {
            return [NSApp sendAction:@selector(copy:) to:[[self window] firstResponder] from:self];
        } else if ([[event charactersIgnoringModifiers] isEqualToString:@"v"]) {
            return [NSApp sendAction:@selector(paste:) to:[[self window] firstResponder] from:self];
        } else if ([[event charactersIgnoringModifiers] isEqualToString:@"a"]) {
            return [NSApp sendAction:@selector(selectAll:) to:[[self window] firstResponder] from:self];
        } else if ([[event charactersIgnoringModifiers] isEqualToString:@"z"]) {
            return [NSApp sendAction:@selector(undo:) to:nil from:self];
        }
    } else if (([event modifierFlags] & NSDeviceIndependentModifierFlagsMask) == (NSCommandKeyMask | NSShiftKeyMask)) {
        if ([[event charactersIgnoringModifiers] isEqualToString:@"Z"]) {
            return ([NSApp sendAction:@selector(redo:) to:nil from:self]);
        }
    }
    
    return [super performKeyEquivalent:event];
}

@end
