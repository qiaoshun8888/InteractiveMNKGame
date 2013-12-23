//
//  MNKState.h
//  InteractiveMNK
//
//  Created by Qiao John on 13-11-8.
//  Copyright (c) 2013年 Qiao John. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MNKNode.h"

@interface MNKState : NSObject

@property (strong, nonatomic) id search_instance;

@property (strong, nonatomic) NSArray *nodes;

@property int used; // # of used boardcell, for improving algorithm performance
@property int player_moves; // # of player moves
@property int cpu_moves; // # of cpu moves
@property int last_move_index;

@property BOOL fake_win; // True is these situations: _ O O O _ / _ X X X _

/* === use for eval ===*/
@property int x3, x2, x1;
@property int o3, o2, o1;

@property int v;
@property int a;
@property int b;

// Initialization
- (MNKState *)initWithNodes:(NSArray *)nodes;

// Get all the next move states of current state
- (NSArray *)nextMoveStates;

// Not implemented yet
- (void)printGameStateBoard;

// Set these parameters for evaluation function
- (void)setEval:(int)x3 :(int)x2 :(int)x1 :(int)o3 :(int)o2 :(int)o1;
- (int)getEval;

- (id)copy;

@end
