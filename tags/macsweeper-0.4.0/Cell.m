//
//  Cell.m
//  MacSweeper
//
//  Created by Morgan Conbere on 3/9/07.
//

#import "Cell.h"

@implementation Cell
- (Cell *)init
{
    if ((self = [super init])) {
        state = hidden;
        neighbors = 0;
        mined = NO;
        dirty = YES;
    }
    
    return self;
}

- (BOOL)isMine
{
    return mined;
}

- (void)setMine:(BOOL)b
{
    mined = b;
}

- (int)toggleStateWithQuestion:(BOOL)q
{
    [self changed];
    if (state == questioned) {
        state = hidden;
        return 0;
    }
    else if (state == flagged) {
        if (q) {
            state = questioned;
        }
        else {
            state = hidden;
        }
        return -1;
    }
    else if (state == hidden) {
        state = flagged;
        return 1;
    }
    return 0;
}

- (BOOL)isHidden
{
    return state == hidden;
}

- (BOOL)isFlagged
{
    return state == flagged;
}

- (BOOL)isQuestioned
{
    return state == questioned;
}

- (BOOL)isCleared
{
    return state == cleared;
}

- (void)clear
{
    state = cleared;
    [self changed];
}

- (void)flag
{
    state = flagged;
    [self changed];
    
}

- (void)setNeighbors: (int) n
{
    neighbors = n;
}

- (int)neighbors
{
    return neighbors;
}

- (BOOL)needsUpdate
{
    return (dirty == YES);
}

- (void)updated
{
    dirty = NO;
}

- (void)changed
{
    dirty = YES;
}

@end
