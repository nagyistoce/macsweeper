//
//  SmileyImageView.h
//  MacSweeper
//
//  Created by Morgan Conbere on 10/24/09.
//  Copyright 2009. All rights reserved.
//
#pragma once

#import <Cocoa/Cocoa.h>

@protocol SmileyImageViewDelegate <NSObject>

- (void)SmileyImageViewMouseDown;
- (void)SmileyImageViewMouseUp;

@end


@interface SmileyImageView : NSImageView {
    id<SmileyImageViewDelegate> delegate;
}

@property (assign) id<SmileyImageViewDelegate> delegate;

- (void)mouseDown:(NSEvent *)event;
- (void)mouseUp:(NSEvent *)event;

@end
