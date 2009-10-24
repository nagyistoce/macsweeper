//
//  SmileyImageView.m
//  MacSweeper
//
//  Created by Morgan Conbere on 10/24/09.
//  Copyright 2009. All rights reserved.
//

#import "SmileyImageView.h"


@implementation SmileyImageView

@synthesize delegate;

- (void)mouseDown:(NSEvent *)event
{
    if([delegate respondsToSelector:@selector(SmileyImageViewMouseDown)])
        [delegate SmileyImageViewMouseDown];
}

- (void)mouseUp:(NSEvent *)event
{
    if([delegate respondsToSelector:@selector(SmileyImageViewMouseUp)])
        [delegate SmileyImageViewMouseUp];
}

@end
