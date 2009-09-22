//
//  Cell.h
//  MacSweeper
//
//  Created by Morgan Conbere on 3/9/07.
//

#import <Foundation/NSObject.h>

typedef enum {hidden, flagged, questioned, cleared} CellState;

@interface Cell : NSObject {
    CellState state;
    int neighbors;
    BOOL mined;
    BOOL dirty;
}

- (Cell *)init;

- (BOOL)isMine;
- (void)setMine:(BOOL)b;

- (int)toggleStateWithQuestion:(BOOL)q;

- (BOOL)isHidden;
- (BOOL)isFlagged;
- (BOOL)isQuestioned;
- (BOOL)isCleared;

- (void)clear;
- (void)flag;

- (void)setNeighbors:(int)n;
- (int)neighbors;

- (BOOL)needsUpdate;
- (void)updated;
- (void)changed;
@end
