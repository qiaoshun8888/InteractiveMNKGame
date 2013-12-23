//
//  MNKABSearch.m
//  InteractiveMNK
//
//  Created by Qiao John on 13-11-7.
//  Copyright (c) 2013年 Qiao John. All rights reserved.
//

#import "MNKABSearch.h"
#import "MNKConstants.h"

//#define NSLog(...) do { } while (0)

@implementation MNKABSearch {
    NSArray *next_states;
}

- (MNKABSearch *)initWithM:(int)m N:(int)n K:(int)k IsHumanFirst:(BOOL)is_human_first CutOff:(BOOL)cutoff Depth:(int)depth {
    self.M = m;
    self.N = n;
    self.K = k;
    
    self.is_human_first = is_human_first;
    self.cutoff = cutoff;
    self.depth = depth;
    
    return self;
}

- (MNKABSearchResult *)search:(MNKState *)state {
    // Reset search
    next_states = nil;
    self.is_timeup = NO;
    state.search_instance = self;
    
    NSLog(@"first check game result");
    int check_val = [self check:state];
    
    // If player win, return search result
    if (check_val == kResultPlayerWin) {
        return [[MNKABSearchResult alloc] initWithSearchVal:check_val NextStates:nil];
    }
    
    NSLog(@"start absearch min: a: b:");
    int v = -1;
    v = [self min:state :kDefaultAlpha :kDefaultBeta :0];
    /*
    if (self.is_human_first) {
        v = [self min:state :kDefaultAlpha :kDefaultBeta :0];
    }
    else {
        v = [self max:state :kDefaultAlpha :kDefaultBeta :0];
    }
    */
    
    NSLog(@"search result v: %d, next_states count: %d", v, [next_states count]);
    
    // Filter the win / draw / lose moves
    NSMutableArray *cpu_win_set = [NSMutableArray new];
    NSMutableArray *cpu_draw_set = [NSMutableArray new];
    NSMutableArray *cpu_lose_set = [NSMutableArray new];
    
    for (MNKState *state in next_states) {
        NSLog(@"next move v: %d (last_move_index: %d)", state.v, state.last_move_index);
        if (state.v == kResultCPUWin) {
            [cpu_win_set addObject:state];
        }
        else if (state.v == kResultDraw || state.v == kResultUnknow) {
            [cpu_draw_set addObject:state];
        }
        else if (state.v == kResultPlayerWin) {
            [cpu_lose_set addObject:state];
        }
    }
    
    MNKState *next_state = nil;
    
    /*
     AI will first choose the next move from cpu_win_set,
     then from the cpu_draw_set.
     Ai only choose the next move from cpu_lose_set because there is no other choice for AI not to lose.
     */
    if ([cpu_win_set count] > 0) {
        NSLog(@"select from win_set");
        next_state = [cpu_win_set objectAtIndex:(arc4random()%[cpu_win_set count])];
        check_val = [self check:next_state];
    }
    else if ([cpu_draw_set count] > 0) {
        NSLog(@"select from draw_set");
        next_state = [cpu_draw_set objectAtIndex:(arc4random()%[cpu_draw_set count])];
        check_val = ([self check:next_state] == kResultDraw && next_state.used == self.M * self.N)
        ? kResultDraw : kResultUnknow;
    }
    else if ([cpu_lose_set count] > 0) {
        NSLog(@"select from lose_set");
        next_state = [cpu_lose_set objectAtIndex:(arc4random()%[cpu_lose_set count])];
        check_val = [self check:next_state];
    }
    
    NSLog(@"next_state: %@", next_state);
    
    return [[MNKABSearchResult alloc] initWithSearchVal:check_val NextStates:next_state];
}

- (int)max:(MNKState *)state :(int)a :(int)b :(int)d{
    if (self.cutoff && d > self.depth) {
        return [self cutoffTerminalState:state Depth:d];
    }
    else {
        int v = [self isTerminalState:state];
        
        // Is terminal state
        if (v != kResultUnknow) {
            // NSLog(@"max_v1: %d", v);
            return v;
        }
    }
    
    state.v = -INFINITY;
    
    // If is timeup, AI doesn't expand any nodes.
    if (!self.is_timeup) {
        for (MNKState *n_state in [self exploreState:state]) {
            state.v = MAX(state.v, [self min:n_state :a :b :d+1]);
            // NSLog(@"max_a:%d b:%d v:%d", a, b, state.v);
            if (state.v >= b) {
                return state.v;
            }
            state.a = MAX(a, state.v);
        }
    }
    else {
        state.v = kResultUnknow;
        // NSLog(@"max timeup!!");
    }
    
    // NSLog(@"max_v3: %d", v);
    return state.v;
}

- (int)min:(MNKState *)state :(int)a :(int)b :(int)d{
    if (self.cutoff && d > self.depth) {
        return [self cutoffTerminalState:state Depth:d];
    }
    else {
        int v = [self isTerminalState:state];
        // Is terminal state
        if (v != kResultUnknow) {
            // NSLog(@"max_v1: %d", v);
            return v;
        }
    }
    
    state.v = INFINITY;
    
    // If is timeup, AI doesn't expand any nodes.
    if (!self.is_timeup) {
        for (MNKState *n_state in [self exploreState:state]) {
            state.v = MIN(state.v, [self max:n_state :a :b :d+1]);
            // NSLog(@"min_a:%d b:%d v:%d", a, b, state.v);
            if (state.v <= a) {
                return state.v;
            }
            state.b = MIN(b, state.v);
        }
    }
    else {
        state.v = kResultUnknow;
        // NSLog(@"min timeup!!");
    }
    
    // NSLog(@"min_v3: %d", v);
    return state.v;
}

- (int)isTerminalState:(MNKState *)state {
    int check_val = [self check:state];
    // NSLog(@"isTerminalState - used:%d, check_val:%d, state.v:%d", state.used, check_val, state.v);
    return check_val;
}

- (int)cutoffTerminalState:(MNKState *)state Depth:(int)depth {
    [self check:state];
    // NSLog(@"cutoffTerminalState depth: %d/%d, state-x3=%d,x2=%d,x1=%d", depth, self.depth, state.x3, state.x2, state.x1);
    return [state getEval];
}

#pragma mark -
#pragma mark CPU explore the state
- (NSArray *)exploreState:(MNKState *)state {
    NSArray *explore_stats = [state nextMoveStates];
    // NSLog(@"explore state count: %d", [explore_stats count]);
    if (!next_states) {
        next_states = explore_stats;
    }
    return explore_stats;
}

/*
 Check if Player or AI has 4-consecutive marks in a row, in a column or in a diagonal. (YES -> WIN)
 
 UPDATES:
 Above can only guarantee that AI will take the correct move in this situation: _ _ O O O / O O O _ _
 But in this situation, _ O O _ _ , if AI doesn't do this, X O O _ _ or _ O O X _ _, it'll lose the game.
 So it's necessary to tell AI that if Player has three marks in a row <del>/column/diagonal</del> with empty marks in the head and tail, then player will win. I add 'start_consecutive_of_player_index == 1' / 'start_consecutive_of_cpu_index == 1' below to tell AI this situation. And 'head_tail_mark_of_player' & 'head_tail_mark_of_cpu' to tell AI in these situation, X O O O _ / _ O O O X , player not win.
 */
- (int)check:(MNKState *)state {
    // Prameters for eval func
    int x3=0, x2=0, x1=0, o3=0, o2=0, o1=0;
    
    // ============================
    // check row
    // NSLog(@"check row");
    for (int i = 0; i < [state.nodes count] / self.N; i++) {
        int row_consecutive_of_player [] = {0, 0}; // {cur, max}
        int row_consecutive_of_cpu [] = {0, 0}; // {cur, max}
        int start_consecutive_of_player_index = -1;
        int start_consecutive_of_cpu_index = -1;
        int head_tail_mark_of_player [] = {0, 0}; // {head, tail}
        int head_tail_mark_of_cpu [] = {0, 0}; // {head, tail}
        
        for (int j = 0; j < self.N; j++) {
            MNKNode *node = state.nodes[i*self.N+j];
            if (node.val == kEmptyNode) {
                row_consecutive_of_player[0] = 0;
                row_consecutive_of_cpu[0] = 0;
                continue;
            }
            else if (node.val == kPlayerNode) {
                row_consecutive_of_cpu[0] = 0;
                
                // Mark the head and tail of player's marks
                if (j==0) {
                    head_tail_mark_of_player[0] = 1;
                }
                else if (j==self.N-1) {
                    head_tail_mark_of_player[1] = 1;
                }
                
                // Mark the start index of player's consecutive marks
                if (start_consecutive_of_player_index == -1) {
                    start_consecutive_of_player_index = j;
                }
                row_consecutive_of_player[0]++;
                row_consecutive_of_player[1] = MAX(row_consecutive_of_player[0], row_consecutive_of_player[1]);
            }
            else if (node.val == kComputerNode) {
                row_consecutive_of_player[0] = 0;
                
                // Mark the head and tail of player's marks
                if (j==0) {
                    head_tail_mark_of_cpu[0] = 1;
                }
                else if (j==self.N-1) {
                    head_tail_mark_of_cpu[1] = 1;
                }
                
                // Mark the start index of computer's consecutive marks
                if (start_consecutive_of_cpu_index == -1) {
                    start_consecutive_of_cpu_index = j;
                }

                row_consecutive_of_cpu[0]++;
                row_consecutive_of_cpu[1] = MAX(row_consecutive_of_cpu[0], row_consecutive_of_cpu[1]);
            }
        }
        
        // NSLog(@"Row consecutive at row[%d]: Player[%d], CPU[%d], last_move_index: %d", i, row_consecutive_of_player[1], row_consecutive_of_cpu[1], state.last_move_index);
        
        // For eval
        switch (row_consecutive_of_cpu[1]) {
            case 3: x3++; break;
            case 2: x2++; break;
            case 1: x1++;
            default:break;
        }
        switch (row_consecutive_of_player[1]) {
            case 3: o3++; break;
            case 2: o2++; break;
            case 1: o1++;
            default: break;
        }
        
        [state setEval:x3 :x2 :x1 :o3 :o2 :o1];
        
        // If player gets 4 consecutive nodes, then WIN.
        if (row_consecutive_of_player[1] >= self.K ||
            (row_consecutive_of_player[1] >= self.K-1 &&
             start_consecutive_of_player_index == 1 &&
             (head_tail_mark_of_cpu[0] != 1 && head_tail_mark_of_cpu[1] != 1)
             )) {
            // NSLog(@"Player Win");
            state.v = kResultPlayerWin;
            // NSLog(@"row_consecutive_of_player[1] < self.K: %d < %d", row_consecutive_of_player[1], self.K);
            state.fake_win = row_consecutive_of_player[1] < self.K;
            return kResultPlayerWin;
        }
        else if (row_consecutive_of_cpu[1] >= self.K ||
                 (row_consecutive_of_cpu[1] >= self.K-1 &&
                  start_consecutive_of_cpu_index == 1 &&
                  (head_tail_mark_of_player[0] != 1 && head_tail_mark_of_player[1] != 1)
                  )) {
            // NSLog(@"Computer Win");
            state.v = kResultCPUWin;
            // NSLog(@"row_consecutive_of_cpu[1] < self.K: %d < %d", row_consecutive_of_cpu[1], self.K);
            state.fake_win = row_consecutive_of_cpu[1] < self.K;
            return kResultCPUWin;
        }
        
        // New row, reset row_consecutive
        row_consecutive_of_player[0] = 0; row_consecutive_of_player[1] = 0;
        row_consecutive_of_cpu[0] = 0; row_consecutive_of_cpu[1] = 0;
    }
    
    // ============================
    // check column
    // NSLog(@"check column");
    for (int i = 0; i < [state.nodes count] / self.M; i++) {
        int column_consecutive_of_player [] = {0, 0}; // {cur, max}
        int column_consecutive_of_cpu [] = {0, 0}; // {cur, max}
        for (int j = 0; j < self.M; j++) {
            MNKNode *node = state.nodes[j*self.N+i];
            if (node.val == kEmptyNode) {
                column_consecutive_of_player[0] = 0;
                column_consecutive_of_cpu[0] = 0;
                continue;
            }
            else if (node.val == kPlayerNode) {
                column_consecutive_of_cpu[0] = 0;
                
                column_consecutive_of_player[0]++;
                column_consecutive_of_player[1] = MAX(column_consecutive_of_player[0], column_consecutive_of_player[1]);
            }
            else if (node.val == kComputerNode) {
                column_consecutive_of_player[0] = 0;
                
                column_consecutive_of_cpu[0]++;
                column_consecutive_of_cpu[1] = MAX(column_consecutive_of_cpu[0], column_consecutive_of_cpu[1]);
            }
        }
        
        // NSLog(@"Row consecutive at row[%d]: Player[%d], CPU[%d], last_move_index: %d", i, row_consecutive_of_player[1], row_consecutive_of_cpu[1], state.last_move_index);
        
        // For eval
        switch (column_consecutive_of_cpu[1]) {
            case 3: x3++; break;
            case 2: x2++; break;
            case 1: x1++;
            default: break;
        }
        switch (column_consecutive_of_player[1]) {
            case 3: o3++; break;
            case 2: o2++; break;
            case 1: o1++;
            default: break;
        }
        
        [state setEval:x3 :x2 :x1 :o3 :o2 :o1];
        
        // If player gets 4 consecutive nodes, then WIN.
        if (column_consecutive_of_player[1] >= self.K) {
            // NSLog(@"Player Win");
            state.v = kResultPlayerWin;
            return kResultPlayerWin;
        }
        else if (column_consecutive_of_cpu[1] >= self.K) {
            // NSLog(@"Computer Win");
            state.v = kResultCPUWin;
            return kResultCPUWin;
        }
        
        // New row, reset row_consecutive
        column_consecutive_of_player[0] = 0; column_consecutive_of_player[1] = 0;
        column_consecutive_of_cpu[0] = 0; column_consecutive_of_cpu[1] = 0;
    }
    
    // ============================
    // check / diagonal
    // NSLog(@"check / diagonal");
    for (int i = 0; i < self.M + self.N - 1; i++) {
        int diagonal_consecutive_of_player [] = {0, 0}; // {cur, max}
        int diagonal_consecutive_of_cpu [] = {0, 0}; // {cur, max}
        for (int j = 0; j <= i; j++) {
            if (j < self.M && i - j < self.N) {
                // NSLog(@"(x,y) = (%d,%d)", i-j, j);
                MNKNode *node = state.nodes[i-j+j*self.N];
                if (node.val == kEmptyNode) {
                    diagonal_consecutive_of_player[0] = 0;
                    diagonal_consecutive_of_cpu[0] = 0;
                    continue;
                }
                else if (node.val == kPlayerNode) {
                    diagonal_consecutive_of_cpu[0] = 0;
                    
                    diagonal_consecutive_of_player[0]++;
                    diagonal_consecutive_of_player[1] = MAX(diagonal_consecutive_of_player[0], diagonal_consecutive_of_player[1]);
                }
                else if (node.val == kComputerNode) {
                    diagonal_consecutive_of_player[0] = 0;
                    
                    diagonal_consecutive_of_cpu[0]++;
                    diagonal_consecutive_of_cpu[1] = MAX(diagonal_consecutive_of_cpu[0], diagonal_consecutive_of_cpu[1]);
                }
            }
        }
        
        // For eval
        switch (diagonal_consecutive_of_cpu[1]) {
            case 3: x3++; break;
            case 2: x2++; break;
            case 1: x1++;
            default: break;
        }
        switch (diagonal_consecutive_of_player[1]) {
            case 3: o3++; break;
            case 2: o2++; break;
            case 1: o1++;
            default: break;
        }
        
        [state setEval:x3 :x2 :x1 :o3 :o2 :o1];
        
        // If player gets 4 consecutive nodes, then WIN.
        if (diagonal_consecutive_of_player[1] >= self.K) {
            // NSLog(@"Player Win");
            state.v = kResultPlayerWin;
            return kResultPlayerWin;
        }
        else if (diagonal_consecutive_of_cpu[1] >= self.K) {
            // NSLog(@"Computer Win");
            state.v = kResultCPUWin;
            return kResultCPUWin;
        }
        
        // New row, reset row_consecutive
        diagonal_consecutive_of_player[0] = 0; diagonal_consecutive_of_player[1] = 0;
        diagonal_consecutive_of_cpu[0] = 0; diagonal_consecutive_of_cpu[1] = 0;
    }
    
    // ============================
    // check \ diagonal
    // NSLog(@"check \\ diagonal");
    for (int i = 0; i < self.M + self.N - 1; i++) {
        int diagonal_consecutive_of_player [] = {0, 0}; // {cur, max}
        int diagonal_consecutive_of_cpu [] = {0, 0}; // {cur, max}
        for (int j = 0; j <= i; j++) {
            if (j < self.M && i - j < self.N) {
                MNKNode *node = state.nodes[self.N-1-(i-j)+j*self.N];
                if (node.val == kEmptyNode) {
                    diagonal_consecutive_of_player[0] = 0;
                    diagonal_consecutive_of_cpu[0] = 0;
                    continue;
                }
                else if (node.val == kPlayerNode) {
                    diagonal_consecutive_of_cpu[0] = 0;
                    
                    diagonal_consecutive_of_player[0]++;
                    diagonal_consecutive_of_player[1] = MAX(diagonal_consecutive_of_player[0], diagonal_consecutive_of_player[1]);
                }
                else if (node.val == kComputerNode) {
                    diagonal_consecutive_of_player[0] = 0;
                    
                    diagonal_consecutive_of_cpu[0]++;
                    diagonal_consecutive_of_cpu[1] = MAX(diagonal_consecutive_of_cpu[0], diagonal_consecutive_of_cpu[1]);
                }
            }
        }
        
        // For eval
        switch (diagonal_consecutive_of_cpu[1]) {
            case 3: x3++; break;
            case 2: x2++; break;
            case 1: x1++;
            default: break;
        }
        switch (diagonal_consecutive_of_player[1]) {
            case 3: o3++; break;
            case 2: o2++; break;
            case 1: o1++;
            default: break;
        }
        
        [state setEval:x3 :x2 :x1 :o3 :o2 :o1];
        
        // If player gets 4 consecutive nodes, then WIN.
        if (diagonal_consecutive_of_player[1] >= self.K) {
            // NSLog(@"Player Win");
            state.v = kResultPlayerWin;
            return kResultPlayerWin;
        }
        else if (diagonal_consecutive_of_cpu[1] >= self.K) {
            // NSLog(@"Computer Win");
            state.v = kResultCPUWin;
            return kResultCPUWin;
        }
        
        // New row, reset row_consecutive
        diagonal_consecutive_of_player[0] = 0; diagonal_consecutive_of_player[1] = 0;
        diagonal_consecutive_of_cpu[0] = 0; diagonal_consecutive_of_cpu[1] = 0;
    }

    // NSLog(@"consecutive_player: %d, consecutive_cpu: %d", state.consecutive_of_player, state.consecutive_of_cpu);
    // NSLog(@"\n");

    // If all the boardcell used, then it's a tie. Otherwise this is not a terminal state
    if (state.used != self.N * self.M) {
        state.v = kResultUnknow;
        return kResultUnknow;
    }
    else {
        // NSLog(@"Player & Computer Tie");
        state.v = kResultDraw;
        return kResultDraw;
    }
}

@end
