//
//  MineField.h
//  MacSweeper
//
//  Created by Morgan Conbere on 3/12/07.
//
#pragma once

#import <Foundation/NSObject.h>
#import "Cell.h"

typedef enum {gameWait, gameGo, gameWin, gameLose} GameState;

@interface MineField : NSObject {
@private
    int rows;
    int cols;
    
    BOOL questions;
    
    Cell **mines;
    
    int revealed;
    int flaggedCells;
    int minesLeft;
    int minesTotal;
}

- (MineField *)initWithMines:(int)m rows:(int)r columns:(int)c;

- (MineField *)initWithMines:(int)m rows:(int)r columns:(int)c questions:(BOOL)b;

- (int)countNeighborsOfRow:(int)r column:(int)c;

- (int)countFlaggedOfRow:(int)r column:(int)c;

- (void)distributeMines:(int)m withClickAtRow:(int)r column:(int)c;

- (int)rows;

- (int)cols;

- (int)minesLeft;

- (Cell *)cellAtRow:(int)r column:(int)c;

- (GameState)revealRow:(int)r column:(int)c;

- (int)toggleRow:(int)r column:(int)c;

- (void)displayMines;

@end
