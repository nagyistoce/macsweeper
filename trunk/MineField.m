//
//  MineField.m
//  MacSweeper
//
//  Created by Morgan Conbere on 3/12/07.
//

#import "Cell.h"
#import "MineField.h"

#import <stdlib.h>
#import <stdio.h>
#import <time.h>

@implementation MineField
- (MineField *)initWithMines:(int)m rows:(int)r columns:(int)c
{
    return [self initWithMines:m rows:r columns:c questions:YES];
}

- (MineField *)initWithMines:(int)m rows:(int)r columns:(int)c questions:(BOOL)b
{
    if ((self = [super init])) {  
        srandom(time(0));
        
        rows = r;
        cols = c;
        minesTotal = m;
        minesLeft = -1; // Indicates that the games has not started
        flaggedCells = 0;
        revealed = 0;
        questions = b;
        mines = (Cell**)malloc(rows * cols * sizeof(Cell *));
        
        for (int i = 0; i < rows*cols; i++) {
            mines[i] = [[Cell alloc] init];
        }
    }
    
    return self;
}

- (int)countNeighborsOfRow:(int)r column:(int)c
{
    int count = 0;
    
    for (int i = -1; i <= 1; i++) {
        for (int j = -1; j <= 1; j++) {
            if ([[self cellAtRow:r+i column:c+j] isMine]) {
                count++;
            }
        }
    }
    
    return count;
}

- (int)countFlaggedOfRow:(int)r column:(int)c
{
    int count = 0;

    // This should only be called from an already cleared cell, 
    // so it can't be flagged itself
    for (int i = -1; i <= 1; i++) {
        for (int j = -1; j <= 1; j++) {
            if ([[self cellAtRow:r+i column:c+j] isFlagged]) {
                count++;
            }
        }
    }
    
    return count;
}

- (void)distributeMines:(int)m withClickAtRow:(int)r column:(int)c
{
    // Place the mines somewhere other than where there was a click
    for (int count = 0; count < m;) {
        int i = random() % rows;
        int j = random() % cols;
        if (!(i==r && j==c) && !([[self cellAtRow:i column:j] isMine]) ) {
            [[self cellAtRow:i column:j] setMine:YES];
            count++;
        }
    }
    
    // Set the neighbor count of the surrounding cells
    for (int i = 0; i < rows; i++) {
        for (int j = 0; j < cols; j++) {
            int count = [self countNeighborsOfRow:i column:j];
            [[self cellAtRow:i column:j] setNeighbors:count];
        }
    }
    
    minesLeft = m;
}

- (int)rows
{
    return rows;
}

- (int)cols
{
    return cols;
}

- (int)minesLeft
{
    return minesTotal - flaggedCells;
}

- (Cell *)cellAtRow:(int)r column:(int)c
{
    if ( (r < 0) || (r >= rows) || (c < 0) || (c >= cols) ) {
        return nil;
    }
    return mines[r*cols + c];
}

- (GameState)revealRow:(int)r column:(int)c
{
    Cell *cell;
    int flaggedCount = 0;
    int neighborsCount;
    
    // set up the game if we haven't yet
    if (minesLeft == -1) {
        [self distributeMines:minesTotal withClickAtRow:r column:c];
    }
    
    // get the cell that was pointed to
    cell = [self cellAtRow:r column:c];
    
    // if the cell is null, return
    if ( (cell == nil) || [cell isFlagged] ) {
        return gameGo;
    }
    
    /* Check if this move loses */
    if ([cell isMine]) {
        [self displayMines];
        return gameLose;
    }
    
    neighborsCount = [cell neighbors];
    
    if ([cell isCleared]) {
        flaggedCount = [self countFlaggedOfRow:r column:c];
        if (flaggedCount == 0) return gameGo;
        
        if (neighborsCount == flaggedCount) {
            for (int i = -1; i <= 1; i++) {
                for (int j = -1; j <= 1; j++) {
                    if ( ![[self cellAtRow:r+i column:c+j] isCleared] ) {
                        if ([self revealRow:r+i column:c+j] == gameLose) {
                            [self displayMines];
                            return gameLose;
                        }
                    }
                }
            }
        } else {
            for (int i = -1; i <= 1; i++) {
                for (int j = -1; j <= 1; j++) {
                    [[self cellAtRow:r+i column:c+j] changed];
                }
            }
        }
    }
    else {
        [cell clear];
        revealed++;
        
        if (neighborsCount == flaggedCount) {
            for (int i = -1; i <= 1; i++) {
                for (int j = -1; j <= 1; j++) {
                    [self revealRow:r+i column:c+j];
                }
            }
        }
    }
    
    /* Check if this move wins */
    if (revealed + minesTotal == rows * cols) {
        for (int i = 0; i < rows; i++) {
            for (int j = 0; j < cols; j++) {
                cell = [self cellAtRow:i column:j];
                if ([cell isMine] && ![cell isFlagged]) {
                    [cell flag];
                    ++flaggedCells;
                }
            }
        }
        minesLeft = 0;
        return gameWin;
    }
    
    return gameGo;
}

- (int)toggleRow:(int)r column:(int)c
{
    flaggedCells += [[self cellAtRow:r column:c] toggleStateWithQuestion:questions];
    return flaggedCells;
}

- (void)displayMines {
	for (int i = 0; i < rows; i++) {
		for (int j = 0; j < cols; j++) {
			Cell *cell = [self cellAtRow:i column:j];
            if ( [cell isMine] || [cell isFlagged] ) {
                [cell changed];
            }
        }
    }
}

- (void)dealloc
{
	for (int i = 0; i < rows*cols; i++) {
			[mines[i] release];
    }
    
    free(mines);
    [super dealloc];
}

@end
