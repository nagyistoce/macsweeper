//
//  MineField.m
//  MacSweeper
//
//  Created by Morgan Conbere on 3/12/07.
//  Copyright 2007. All rights reserved.
//

#import "Cell.h"
#import "MineField.h"

#import <stdlib.h>
#import <stdio.h>
#import <time.h>

@implementation MineField
-(MineField*) initWithMines: (int) m
                       rows: (int) r
                    columns: (int) c
{
    return [self initWithMines: m rows: r columns: c questions: YES];
}

-(MineField*) initWithMines: (int) m
                       rows: (int) r
                    columns: (int) c
                  questions: (BOOL) b
{
    if ((self = [super init])) {
        int i;    
        srandom(time(0));
        
        rows = r;
        cols = c;
        minesTotal = m;
        minesLeft = -1; /* Indicates that the games has not started */
        flaggedCells = 0;
        revealed = 0;
        questions = b;
        mines = (Cell**)malloc(rows*cols*sizeof(Cell*));
        
        for (i = 0; i < rows*cols; i++) {
            mines[i] = [Cell new];
        }
    }
    
    return self;
}

-(int) countNeighborsOfRow: (int) r column: (int) c
{
    int i,j;
    int count = 0;
    
    for (i = -1; i <= 1; i++) {
        for (j = -1; j <= 1; j++) {
            if ([[self cellAtRow: r+i column: c+j] isMine]) {
                count++;
            }
        }
    }
    
    return count;
}

-(int) countFlaggedOfRow: (int) r column: (int) c
{
    int i,j;
    int count = 0;
    
    
    /* This should only be called from an already cleared cell, 
        * so it can't be flagged itself */
    for (i = -1; i <= 1; i++) {
        for (j = -1; j <= 1; j++) {
            if ([[self cellAtRow: r+i column: c+j] isFlagged]) {
                count++;
            }
        }
    }
    
    return count;
}

-(void) distributeMines: (int) m withClickAtRow: (int) r column: (int) c
{
    int i,j, count;
    
    /* place the mines somewhere other than where there was a click */
    for (count = 0; count < m;) {
        i = random() % rows;
        j = random() % cols;
        if ( !(i==r && j==c) && !([[self cellAtRow: i column: j] isMine]) ) {
            [[self cellAtRow: i column: j] setMine: YES];
            count++;
        }
    }
    
    /* Set the neighbor count of the surrounding cells */
    for (i = 0; i < rows; i++) {
        for (j = 0; j < cols; j++) {
            count = [self countNeighborsOfRow: i column: j];
            [[self cellAtRow: i column: j] setNeighbors: count];
        }
    }
    
    minesLeft = m;
}

-(int) rows
{
    return rows;
}

-(int) cols
{
    return cols;
}

-(int) minesLeft
{
    return minesTotal - flaggedCells;
}

-(Cell*) cellAtRow: (int) r column: (int) c
{
    if ( (r < 0) || (r >= rows) || (c < 0) || (c >= cols) ) {
        return nil;
    }
    return mines[r*cols + c];
}

-(GameState) revealRow: (int) r column: (int) c
{
    Cell * cell;
    int flaggedCount = 0;
    int neighborsCount;
    
    /* set up the game if we haven't yet */
    if (minesLeft == -1) {
        [self distributeMines: minesTotal withClickAtRow: r column: c];
    }
    
    /* get the cell that was pointed to */
    cell = [self cellAtRow: r column: c];
    
    /* if the cell is null, return */
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
        flaggedCount = [self countFlaggedOfRow: r column: c];
        if (flaggedCount == 0) return gameGo;
        
        if (neighborsCount == flaggedCount) {
            int i, j;
            
            for (i = -1; i <= 1; i++) {
                for (j = -1; j <= 1; j++) {
                    if ( ![[self cellAtRow: r+i column: c+j] isCleared] ) {
                        if ([self revealRow: r+i column: c+j] == gameLose) {
                            [self displayMines];
                            return gameLose;
                        }
                    }
                }
            }
        }
    }
    else {
        [cell clear];
        revealed++;
        
        if (neighborsCount == flaggedCount) {
            int i, j;
            
            for (i = -1; i <= 1; i++) {
                for (j = -1; j <= 1; j++) {
                    [self revealRow: r+i column: c+j];
                }
            }
        }
    }
    
    /* Check if this move wins */
    if (revealed + minesTotal == rows * cols) {
        int i, j;
        
        for (i = 0; i < rows; i++) {
            for (j = 0; j < cols; j++) {
                cell = [self cellAtRow: i column: j];
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

-(int) toggleRow: (int) r column: (int) c
{
    flaggedCells += [[self cellAtRow: r column: c] toggleStateWithQuestion: questions];
    return flaggedCells;
}

-(void) displayMines {
	Cell * cell;
	int i, j;
	
	for (i = 0; i < rows; i++) {
		for (j = 0; j < cols; j++) {
			cell = [self cellAtRow: i column: j];
            if ( [cell isMine] || [cell isFlagged] ) {
                [cell changed];
            }
        }
    }
}

-(void) dealloc
{
    free(mines);
    [super dealloc];
}

@end
