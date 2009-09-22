//
//  MineView.h
//  MacSweeper
//
//  Created by Morgan Conbere on 3/12/07.
//
#pragma once

#import <Cocoa/Cocoa.h>
#import "MineField.h"

@protocol MineFieldDelegate <NSObject>

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


// Model an int-point struct after NSPoint
typedef struct {
    int x;
    int y;
} IntPoint;

NS_INLINE IntPoint MakeIntPoint(int x, int y)
{
    IntPoint p;
    p.x = x;
    p.y = y;
    return p;
}

@interface MineView : NSView {
@private
    int rows;
    int columns;    
    int mines;
    GameState state;
    MouseState drag;
    
    IntPoint mousePoint;
    IntPoint deathPoint;
    
    MineField *field;
    
    NSColorList *colors;
    
    NSTimer *timer;
    int seconds;
    NSTextField *timerField;
    NSTextField *minesLeftField;
    id <MineFieldDelegate> delegate;
    
    float cellHeight;
    float cellWidth;
    float statusBarHeight;
}

- (void)newGameWithMines:(int)m
                    rows:(int)r 
                 columns:(int)c
               questions:(BOOL)b;

- (void)setTimerField:(NSTextField *)timer andMinesLeftField:(NSTextField *)minesLeft;
- (id <MineFieldDelegate>)delegate;
- (void)setDelegate:(id <MineFieldDelegate>)newDelegate;

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
