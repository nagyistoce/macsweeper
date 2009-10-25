//
//  MineView+Drawing.m
//  MacSweeper
//
//  Created by Morgan Conbere on 5/9/07.
//

#import "MineView+Drawing.h"


@implementation MineView (Drawing)


- (void)drawCellAtRow:(int)r column:(int)c inRect:(NSRect)rect {
	Cell *cell = [field cellAtRow:r column:c];
    
	if (state == gameLose) {
		if ((deathPoint.x == c) && (deathPoint.y == r)) {
			[[NSColor redColor] set];
			[NSBezierPath fillRect:rect];
			[self drawCellClearedBackgroundInRect:rect];
			[self drawMineInRect:rect];
		} else if ([cell isMine] && ![cell isFlagged]) {
			[[colors colorWithKey:@"background"] set];
			[NSBezierPath fillRect:rect];
			[self drawCellHiddenBackgroundInRect:rect];
			[self drawMineInRect:rect];
		} else if (![cell isMine] && [cell isFlagged]) {
            [[colors colorWithKey:@"background"] set];
            [NSBezierPath fillRect:rect];
            [self drawCellHiddenBackgroundInRect:rect];
            [self drawFlagInRect:rect];
            [self drawXInRect:rect];
        }
		return;
	}
	
	[[colors colorWithKey:@"background"] set];
	[NSBezierPath fillRect:rect];
    
	if (drag == leftClick || drag == rightClick) {
        int x = mousePoint.x;
        int y = mousePoint.y;
		if (x==c && y==r && [cell isHidden]) {
			[self drawCellClearedBackgroundInRect: rect];
			return;
		}
        
        if (drag == leftClick) {
            if ([[field cellAtRow:y column:x] isCleared]) {
                if ( (x==c-1 || x==c || x==c+1) && (y==r-1 || y==r || y==r+1) && [cell isHidden]) {
                    [self drawCellClearedBackgroundInRect: rect];
                    return;
                }
            }
        }
	}
    
	NSString *text = nil;
	NSColor *color = [NSColor blackColor];	
	
	if ([cell isCleared]) {
		[self drawCellClearedBackgroundInRect:rect];
		int n = [cell neighbors];
		text = [NSString stringWithFormat:@"%d", n];
		color = [colors colorWithKey:text];
	} else {
		[self drawCellHiddenBackgroundInRect:rect];
		if ([cell isFlagged]) {
			[self drawFlagInRect: rect];
		} else if ([cell isQuestioned]) {
			text = @"?";
		}
	}
    
	if (text) {
		/* Set up attributes dictionary */
        CGFloat minDimension = cellWidth < cellHeight ? cellWidth : cellHeight;
        CGFloat fontSize = (minDimension * (3.0f/4.0f)); // This appears to be the magic ratio that creates text the right size
		NSFont *font = [NSFont fontWithName:@"Helvetica-Bold" size:fontSize]; 
		NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:
			font, NSFontAttributeName,
			color, NSForegroundColorAttributeName, nil];
		
		/* Center the drawing horizontally */
		NSSize size = [text sizeWithAttributes:attrs];
		NSPoint location;
		location.x = (rect.size.width - size.width)/2 + rect.origin.x + 1;
		location.y = rect.origin.y;
		
		/* Draw the text */
		[text drawAtPoint:location withAttributes:attrs];
	}
    
	[cell updated];
}

- (void)drawCellClearedBackgroundInRect:(NSRect)rect {
    NSInteger n = (NSInteger)(cellHeight / 16.0f);
    
	NSBezierPath *topLeft = [NSBezierPath bezierPath];
	[topLeft moveToPoint:NSMakePoint(rect.origin.x, rect.origin.y)];
	[topLeft lineToPoint:NSMakePoint(rect.origin.x, rect.origin.y + rect.size.height)];
	[topLeft lineToPoint:NSMakePoint(rect.origin.x + rect.size.width, rect.origin.y + rect.size.height)];	
	[topLeft lineToPoint:NSMakePoint(rect.origin.x + rect.size.width - n, rect.origin.y + rect.size.height - n)];
	[topLeft lineToPoint:NSMakePoint(rect.origin.x + n, rect.origin.y + rect.size.height - n)];
	[topLeft lineToPoint:NSMakePoint(rect.origin.x + n, rect.origin.y + n)];
	[topLeft closePath];
    
	[[colors colorWithKey:@"shadow"] set];
	[topLeft fill];
}

- (void)drawCellHiddenBackgroundInRect:(NSRect)rect {
	NSInteger n = (NSInteger)(cellHeight / 8.0f);
	
	NSBezierPath *topLeft = [NSBezierPath bezierPath];
	/* Build the top Left corner */ 
	[topLeft moveToPoint:NSMakePoint(rect.origin.x, rect.origin.y)];
	[topLeft lineToPoint:NSMakePoint(rect.origin.x, rect.origin.y + rect.size.height)];
	[topLeft lineToPoint:NSMakePoint(rect.origin.x + rect.size.width, rect.origin.y + rect.size.height)];
	[topLeft lineToPoint:NSMakePoint(rect.origin.x + rect.size.width - n, rect.origin.y + rect.size.height - n)];
	[topLeft lineToPoint:NSMakePoint(rect.origin.x + n, rect.origin.y + rect.size.height - n)];
	[topLeft lineToPoint:NSMakePoint(rect.origin.x + n, rect.origin.y + n)];
	[topLeft closePath];
	
	NSBezierPath *bottomRight = [NSBezierPath bezierPath];
	/* Build the bottom right corner */
	[bottomRight moveToPoint:NSMakePoint(rect.origin.x, rect.origin.y)];
	[bottomRight lineToPoint:NSMakePoint(rect.origin.x + rect.size.width, rect.origin.y)];
	[bottomRight lineToPoint:NSMakePoint(rect.origin.x + rect.size.width, rect.origin.y + rect.size.height)];
	[bottomRight lineToPoint:NSMakePoint(rect.origin.x + rect.size.width - n, rect.origin.y + rect.size.height - n)];
	[bottomRight lineToPoint:NSMakePoint(rect.origin.x + rect.size.width - n, rect.origin.y + n)];
	[bottomRight lineToPoint:NSMakePoint(rect.origin.x + n, rect.origin.y + n)];
	[bottomRight closePath];
	
	/* draw the two paths*/
	[[colors colorWithKey:@"foreground"] set];
	[topLeft fill];
    
	[[colors colorWithKey:@"shadow"] set];
	[bottomRight fill];
}

- (void)drawFlagInRect:(NSRect)rect {
	float nH = rect.size.height/16;
	float nW = rect.size.width/16;
	float base = rect.origin.y + (nH * 3);
	float top = rect.origin.y + (nH * 13);
	float flagHeight = nH * 4;
	float flagWidth = nW * 5;
	
	NSBezierPath *flagPole = [NSBezierPath bezierPath];
	/* Build the flag pole */
	[flagPole moveToPoint: NSMakePoint(rect.origin.x+(nW*4),base)];
	[flagPole lineToPoint: NSMakePoint(rect.origin.x+(nW*12),base)];
	[flagPole lineToPoint: NSMakePoint(rect.origin.x+(nW*9),base+3)];
	[flagPole lineToPoint: NSMakePoint(rect.origin.x+(nW*9),top)];
	[flagPole lineToPoint: NSMakePoint(rect.origin.x+(rect.size.width/2),top)];
	[flagPole lineToPoint: NSMakePoint(rect.origin.x+(rect.size.width/2),base+3)];
	[flagPole closePath];
	
	NSBezierPath * flag = [NSBezierPath bezierPath];
	/* Build the flag */
	[flag moveToPoint: NSMakePoint(rect.origin.x+(rect.size.width/2), top-1)];
	[flag lineToPoint: NSMakePoint(rect.origin.x+(rect.size.width/2)-flagWidth, top-1-(flagHeight/2))];
	[flag lineToPoint: NSMakePoint(rect.origin.x+(rect.size.width/2), top-1-flagHeight)];
	[flag closePath];
	
	/* Draw the flag */
	[[NSColor blackColor] set];
	[flagPole fill];
	
	[[NSColor redColor] set];
	[flag fill];
}

- (void)drawMineInRect: (NSRect) rect {
	NSRect inset = NSInsetRect(rect, cellWidth/4, cellHeight/4);
	NSBezierPath *mine = [NSBezierPath bezierPathWithOvalInRect:inset];
	NSBezierPath *hLine = [NSBezierPath bezierPathWithRect:NSInsetRect(rect, cellWidth/8, (cellHeight/32)*15)];
	NSBezierPath *vLine = [NSBezierPath bezierPathWithRect:NSInsetRect(rect, (cellWidth/32)*15, cellHeight/8)];
    
	inset.size.height = cellHeight/8;
	inset.size.width = cellWidth/8;
	inset.origin.y += cellHeight/4;
	inset.origin.x += cellHeight/16;
	NSBezierPath *light = [NSBezierPath bezierPathWithOvalInRect:inset];
    
    [[NSColor blackColor] set];
    [mine fill];
    [hLine fill];
    [vLine fill];
    
    [[NSColor whiteColor] set];
    [light fill];
}

- (void)drawXInRect: (NSRect) rect {
    NSRect r = NSInsetRect(rect, cellWidth/8.0f, cellHeight/8.0f);
    
    NSBezierPath *down = [NSBezierPath bezierPath];
    [down moveToPoint:NSMakePoint(r.origin.x, r.origin.y + r.size.height * 15.0f / 16.0f)];
    [down lineToPoint:NSMakePoint(r.origin.x+r.size.width/16.0f, r.origin.y+r.size.height)];
    [down lineToPoint:NSMakePoint(r.origin.x+r.size.width, r.origin.y+r.size.height/16.0f)];
    [down lineToPoint:NSMakePoint(r.origin.x+r.size.width*15.0f/16.0f, r.origin.y)];
    [down closePath];
    
    NSBezierPath *up = [NSBezierPath bezierPath];
    [up moveToPoint:NSMakePoint(r.origin.x, r.origin.y+r.size.height/16.0f)];
    [up lineToPoint:NSMakePoint(r.origin.x+r.size.width*15.0f/16.0f, r.origin.y+r.size.height)];
    [up lineToPoint:NSMakePoint(r.origin.x+r.size.width, r.origin.y+r.size.height*15.0f/16.0f)];
    [up lineToPoint:NSMakePoint(r.origin.x+r.size.width/16.0f, r.origin.y)];
    [up closePath];
    
    [[NSColor redColor] set];
    [down fill];
    [up fill];
}

@end
