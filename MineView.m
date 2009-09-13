//
//  MineView.m
//  MacSweeper
//
//  Created by Morgan Conbere on 3/12/07.
//

#import "MineView.h"
#import "MineView+Drawing.h"
#import "Cell.h"

@implementation MineView

- (id)initWithFrame:(NSRect)frame {
	if ((self = [super initWithFrame:frame])) {
		field = nil;
        
        cellWidth = MSCellWidth;
        cellHeight = MSCellHeight;
		statusBarHeight = MSStatusBarHeight;
        
        timerField = nil;
        minesLeftField = nil;
        delegate = nil;
        
		state = gameLose;
		drag = noClick;
		
		/* Set up colors */
		colors = [[NSColorList alloc] initWithName:@"minesweeper"];

        // More appropriate Mac-like colors
        float backGray = 204.0f / 255.0f;
        float shadowGray = 140.0f / 255.0f;
        // Default Microsoft colors
        //float backGray = 180 / 255.0;
        //float shadowGray = 110 / 255.0;
        
        [colors setColor:[NSColor whiteColor] forKey:@"foreground"];
		[colors setColor:[NSColor colorWithDeviceRed:backGray green:backGray blue:backGray alpha:1.0f] forKey:@"background"];
		[colors setColor:[NSColor colorWithDeviceRed:shadowGray green:shadowGray blue:shadowGray alpha:1.0f] forKey:@"shadow"];
		[colors setColor:[NSColor clearColor] forKey:@"0"];
		[colors setColor:[NSColor blueColor] forKey:@"1"];
		[colors setColor:[NSColor colorWithDeviceRed:0.0f green:0.443f blue:0.0f alpha:1.0f] forKey:@"2"];
		[colors setColor:[NSColor redColor] forKey:@"3"];
		[colors setColor:[NSColor colorWithDeviceRed:0.0f green:0.0f blue:0.443f alpha:1.0f] forKey:@"4"];
		[colors setColor:[NSColor colorWithDeviceRed:0.443f green:0.0f blue:0.0f alpha:1.0f] forKey:@"5"];
		[colors setColor:[NSColor colorWithDeviceRed:0.0f green:shadowGray blue:shadowGray alpha:1.0f] forKey:@"6"];
		[colors setColor:[NSColor blackColor] forKey:@"7"];
		[colors setColor:[NSColor colorWithDeviceRed:shadowGray green:shadowGray blue:shadowGray alpha:1.0f] forKey:@"8"];
        
        
		srandom(time(0));
		timer = nil;
	}
	return self;
}

- (void)setTimerField:(NSTextField *)tf andMinesLeftField:(NSTextField *)mlf
{
    timerField = tf;
    minesLeftField = mlf;
}

- (id)delegate
{
    return delegate;
}

- (void)setDelegate:(id)newDelegate
{
    delegate = newDelegate;
}

- (void)awakeFromNib {
	[[self window] setAcceptsMouseMovedEvents:YES];
}

// Responding
- (BOOL)acceptsFirstResponder
{
    return YES;
}

- (BOOL)becomeFirstResponder
{
    return  YES;
}

- (BOOL)resignFirstResponder
{
    return YES;
}

// Speed up drawing by guaranteeing to be opaque
- (BOOL)isOpaque {
	return YES;
}

// Deallocate reserved memory
- (void)dealloc {
	[timer invalidate]; 
	[field release];
	[colors release];
	[super dealloc];
}

- (void)reshape
{
    NSWindow *window = [self window];
    NSRect windowFrame = [window frame];
    
    NSRect frame = [self frame];
    
    size_t oldHeight = frame.size.height;
    frame.size.width = columns * cellWidth;
    frame.size.height = rows * cellHeight;
    
    windowFrame.size = frame.size;
    windowFrame.origin.y += oldHeight - frame.size.height;
    
    [window setFrame:[window frameRectForContentRect:windowFrame]
             display:YES
             animate:NO];
}

- (void)newGameWithMines:(int)m rows:(int)r columns:(int)c questions:(BOOL)b {
    rows = r;
    columns = c;
    mines = m;
	[self reshape];
    
	/* set up the new internal game */
	[field release];
	state = gameWait;
	field = [[MineField alloc] initWithMines:m rows:r columns:c questions:b];
	
	/* reset timer */
    if (timer)
    {
        [timer invalidate];
        timer = nil;
    }
    
	seconds = 0;
	[timerField setIntValue:seconds];
    [minesLeftField setIntValue:[field minesLeft]];
	
	[self setNeedsDisplay:YES];
}

- (void)endGame {
    if (timer)
    {
        [timer invalidate];
        timer = nil;
	}
    if ([delegate respondsToSelector:@selector(endGameWithTime:win:)])
        [delegate endGameWithTime:seconds win:(state == gameWin)];
}

- (void)revealCellAtPoint:(NSPoint)p {
	if (state == gameWait) {
		timer = [NSTimer scheduledTimerWithTimeInterval:1
												 target:self
											   selector:@selector(clock:)
											   userInfo:nil
												repeats:YES];
	}
	state = [field revealRow:(int)(p.y / cellHeight) column:(int)(p.x / cellWidth)];
	[self setNeedsDisplay:YES];
	if (state != gameGo) [self endGame];
}

- (void)toggleCellAtPoint: (NSPoint) p {
	[field toggleRow:(int)(p.y / cellHeight) column:(int)(p.x / cellWidth)];
    [minesLeftField setIntValue:[field minesLeft]];
	[self setNeedsDisplay:YES];
}

- (void)mouseDown:(NSEvent *)event {
	if ([event modifierFlags] & NSControlKeyMask) {
		[self rightMouseDown:event];
		return;
	}
	if (state == gameWait || state == gameGo) {
		if ([delegate respondsToSelector:@selector(mouseDownAction)])
            [delegate mouseDownAction];
        drag = leftClick;
		[self updateMousePoint:event];
	}
}

- (void)mouseDragged:(NSEvent *)event {
	if ([event modifierFlags] & NSControlKeyMask) {
		[self rightMouseDragged:event];
		return;
	}
	if (state == gameWait || state == gameGo) {
		[self updateMousePoint:event];
	}
}

- (void)mouseUp:(NSEvent *)event {
	if ([event modifierFlags] & NSControlKeyMask) {
		[self rightMouseUp:event];
		return;
	}
	drag = noClick;
	if (state == gameWin || state == gameLose) { // A click on a dead board resets
		if ([delegate respondsToSelector:@selector(newGame:)])
            [delegate newGame:nil];
        return;
	}
    if ([delegate respondsToSelector:@selector(mouseUpAction)])
        [delegate mouseUpAction];
	NSPoint mouse = [self convertPoint:[event locationInWindow] fromView:nil];
	[self revealCellAtPoint:mouse];
    [minesLeftField setIntValue:[field minesLeft]];
}

- (void)rightMouseDown:(NSEvent *)event {
	if (state != gameLose) {
        if ([delegate respondsToSelector:@selector(mouseDownAction)])
            [delegate mouseDownAction];
		drag = rightClick;
		[self updateRightMousePoint:event];		
	}
}

- (void)rightMouseDragged:(NSEvent *)event {
	if (state != gameLose) {
		[self updateRightMousePoint:event];
	}
}

- (void)rightMouseUp:(NSEvent *)event {
    if ([delegate respondsToSelector:@selector(mouseUpAction)])
        [delegate mouseUpAction];
	drag = noClick;
	NSPoint mouse = [self convertPoint:[event locationInWindow] fromView:nil];
	[self toggleCellAtPoint:mouse];
}

- (BOOL)updateMousePoint:(NSEvent *)event {
	int x;
    int y;
	NSPoint mouse = [self convertPoint:[event locationInWindow] fromView:nil];
	y = (int)floor(mouse.y / cellHeight);
	x = (int)floor(mouse.x / cellWidth);
    BOOL result = NO;
 
	if (x != mousePoint.x || y != mousePoint.y) {
        int oldX = mousePoint.x;
        int oldY = mousePoint.y;
        
        if (drag==leftClick) {
            [[field cellAtRow:y    column:x   ] changed];
            [[field cellAtRow:oldY column:oldX] changed];
        }
        /*
        else if (drag==rightClick) {
            int i, j;
            for (i = y-1; i <= y+1; i++) {
                for (j = x-1; j <= x+1; j++) {
                    [[field cellAtRow: i column: j] changed];
                }
            }
            for (i = oldY-1; i <= oldY+1; i++) {
                for (j = oldX-1; j <= oldX+1; j++) {
                    [[field cellAtRow: i column: j] changed];
                }
            }
        }*/
		[self setNeedsDisplay:YES];
		result = YES;
	}
    
    mousePoint.x = x;
    mousePoint.y = y;
    
	return result;
}

- (BOOL)updateRightMousePoint:(NSEvent *)event {
	int x;
    int y;
	NSPoint mouse = [self convertPoint:[event locationInWindow] fromView:nil];
	y = (int)floor(mouse.y / cellHeight);
	x = (int)floor(mouse.x / cellWidth);
	
	if (x != mousePoint.x || y != mousePoint.y) {
		[[field cellAtRow:y column:x] changed];
		[[field cellAtRow:mousePoint.y column:mousePoint.x] changed];
		mousePoint.x = x;
		mousePoint.y = y;
		[self setNeedsDisplay: YES];
		return YES;
	}
	return NO;
}

- (void)clock:(NSTimer *)sender {
	if ((seconds < 999) && (state == gameGo)) {
		seconds++;
		[timerField setIntValue:seconds];
	}
	else if (state != gameGo) {
		NSLog(@"Timer running while game stopped");
	}
}

- (void)drawRect:(NSRect)rect {
	int i;
    int j;
    
	/* Cell rectangle */
	NSRect cellRect = NSMakeRect(0, 0, cellWidth, cellHeight);
	
	for (i = 0; i < rows; i++) {
		for (j = 0; j < columns; j++) {
			if ([[field cellAtRow:i column:j] needsUpdate])
                [self drawCellAtRow:i column:j inRect:cellRect];
			cellRect.origin.x += cellWidth;
		}
		cellRect.origin.y += cellHeight;
		cellRect.origin.x = 0;
	}
}
@end