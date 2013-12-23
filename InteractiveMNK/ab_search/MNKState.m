//
//  MNKState.m
//  InteractiveMNK
//
//  Created by Qiao John on 13-11-8.
//  Copyright (c) 2013年 Qiao John. All rights reserved.
//

#import "MNKState.h"
#import "MNKABSearch.h"

@implementation MNKState

- (MNKState *)initWithNodes:(NSArray *)nodes {
    self.nodes = nodes;
    /*
     Calculate these value before hand to improve the performance
     
     self.used : how many board cell has been used
     
     self.player_moves : how many player's marks
     
     self.cpu_moves : how many computer's marks
     */
    for (MNKNode *node in nodes) {
        if (node.val != kEmptyNode) {
            self.used++;
            if (node.val == kPlayerNode) {
                self.player_moves++;
            }
            else if (node.val == kComputerNode) {
                self.cpu_moves++;
            }
        }
    }
    return self;
}

- (NSArray *)nextMoveStates {
    NSMutableArray *states = [NSMutableArray new];
    // NSLog(@"player_moves: %d, cpu_moves: %d", self.player_moves, self.cpu_moves);
    /*
     Player goes first:     self.player_moves > self.cpu_moves
     AI goes first:         self.player_moves >= self.cpu_moves
     */
    BOOL is_human_first = ((MNKABSearch *)self.search_instance).is_human_first;
    
    if (is_human_first ? (self.player_moves > self.cpu_moves) : (self.player_moves >= self.cpu_moves)) {
        for (MNKNode *node in self.nodes) {
            if (node.val == kEmptyNode) {
                MNKState *state = [self copy];
                ((MNKNode *)(state.nodes[node.pos])).val = kComputerNode;
                state.last_move_index = node.pos;
                state.cpu_moves++;
                state.used++;
                [states addObject:state];
            }
        }
    }
    else {
        for (MNKNode *node in self.nodes) {
            if (node.val == kEmptyNode) {
                MNKState *state = [self copy];
                ((MNKNode *)(state.nodes[node.pos])).val = kPlayerNode;
                // state.last_move_index = node.pos;
                state.player_moves++;
                state.used++;
                [states addObject:state];
            }
        }
    }
    return states;
}

- (void)printGameStateBoard {
    // metrix
}

- (void)setEval:(int)x3 :(int)x2 :(int)x1 :(int)o3 :(int)o2 :(int)o1 {
    self.x3 = x3;
    self.x2 = x2;
    self.x1 = x1;
    self.o3 = o3;
    self.o2 = o2;
    self.o1 = o1;
}

- (int)getEval {
    /*
        Evaluation function is easy to get:
        1. Draw a picture that player wins, like
     
        _ O O O _
        _ _ _ _ 1
        _ _ 1 _ _
        1 _ _ _ _
        
        Define this as: aO3 + bO2 + O1 - (aX3 + bX2 + X1) = 1
     
        2. Draw another picture that computer wins, like
     
        _ X _ _ O
        O _ X _ _
        O _ _ X _
        _ _ _ _ _
     
        Define this as: aO3 + bO2 + O1 - (aX3 + bX2 + X1) = -1
     
        Get the values of a and b.
     */
    
    // x4=1 -> -1 or o4=1  -> 1 otherwise 0
    int eval_a = 4, eval_b = 2, eval_c=1;
    
    int eval = (eval_a*self.o3 + eval_b*self.o2 + eval_c*self.o1) - (eval_a*self.x3 + eval_b*self.x2 + eval_c*self.x1);
    
    // NSLog(@"eval(x3=%d,x2=%d,x1=%d,,o3=%d,o2=%d,o1=%d): %d", self.x3, self.x2, self.x1, self.o3, self.o2, self.o1, eval);
    
    if (eval != -1 || eval != 1) {
        eval = 0;
    }
    
    // NSLog(@"eval(x3=%d,x2=%d,x1=%d,,o3=%d,o2=%d,o1=%d): %d", self.x3, self.x2, self.x1, self.o3, self.o2, self.o1, eval);
    
    return eval;
}

- (id)copy {
    NSMutableArray *array = [NSMutableArray new];
    for (MNKNode *node in self.nodes) {
        [array addObject:[node copy]];
    }
    
    MNKState *state = [[MNKState alloc] initWithNodes:array];
    
    state.search_instance = self.search_instance;
    
    state.nodes = array;
    state.used = self.used;
    state.player_moves = self.player_moves;
    state.cpu_moves = self.cpu_moves;
    
    state.v = self.v;
    state.a = self.a;
    state.b = self.b;
    
    return state;
}

@end
