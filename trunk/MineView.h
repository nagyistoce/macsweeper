//
//  MineView.h
//  MacSweeper
//
//  Created by Morgan Conbere on 3/12/07.
//

#import <Cocoa/Cocoa.h>
#import "MineField.h"

@interface NSObject (MineFieldDelegateMethods)
- (void)newGame:(id)sender;
- (void)endGameWithTime:(int)seconds win:(bool)win;
- (void)mouseUpAction;
- (void)mouseDownAction;
@end

enum {
    MSCellHeight = 16,
    MSCellWidth = 16,
    MSStatusBarHeight = 20
};

typedef enum {noClick, leftClick, rightClick} MouseState;

typedef struct {
    int x;
    int y;
} IntPoint;

@interface MineView : NSView {
    int rows;
    int columns;
    BOOL questions;
    
    int mines;
    GameState state;
    MouseState drag;
    
    IntPoint mousePoint;
    
    MineField *field;
    
    NSColorList *colors;
    
    NSTimer *timer;
    int seconds;
    NSTextField *timerField;
    NSTextField *minesLeftField;
    id delegate;
    
    float cellHeight;
    float cellWidth;
    float statusBarHeight;
}

- (void)newGameWithMines:(int)m
                    rows:(int)r 
                 columns:(int)c
               questions:(BOOL)b;

- (void)setTimerField:(NSTextField *)timer andMinesLeftField:(NSTextField *)minesLeft;
- (id)delegate;
- (void)setDelegate:(id)newDelegate;

- (void)endGame;

- (void)revealCellAtPoint:(NSPoint)p;
- (void)toggleCellAtPoint:(NSPoint)p;

- (void)mouseDown:(NSEvent *)event;
- (void)mouseDragged:(NSEvent *)event;
- (void)mouseUp:(NSEvent *)event;
- (void)rightMouseDown:(NSEvent *)event;
- (void)rightMouseDragged:(NSEvent *)event;
- (void)rightMouseUp:(NSEvent *)event;

- (BOOL)updateMousePoint: (NSEvent *) event;
- (BOOL)updateRightMousePoint: (NSEvent *) event;

- (void)clock: (NSTimer *) sender;

- (void)drawRect: (NSRect) rect;
    // The rest of the drawing functions are in the category (Drawing)
@end
