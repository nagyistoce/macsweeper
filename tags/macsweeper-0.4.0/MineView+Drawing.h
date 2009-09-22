//
//  MineView+Drawing.h
//  MacSweeper
//
//  Created by Morgan Conbere on 5/9/07.
//
#pragma once

#import <Cocoa/Cocoa.h>
#import "MineView.h"

//
// Notes on drawing:
// Drawing could probably be made significantly faster if I created one bezier
// curve for each type of object and then for each drawing request merely
// flipped the transformation matrix around and used the prefabricated object.
// This shouldn't be too hard, I just need to do it.
//

@interface MineView (Drawing)

// Specific drawing functions
// These functions bear little or no relation to anything else in the 
// MineView class, so they were moved into their own file for
// cleanliness

- (void)drawCellAtRow:(int)r column:(int)c inRect:(NSRect)rect;
- (void)drawCellClearedBackgroundInRect:(NSRect)rect;
- (void)drawCellHiddenBackgroundInRect:(NSRect)rect;
- (void)drawFlagInRect:(NSRect)rect;
- (void)drawMineInRect:(NSRect)rect;
- (void)drawXInRect:(NSRect)rect;

@end
