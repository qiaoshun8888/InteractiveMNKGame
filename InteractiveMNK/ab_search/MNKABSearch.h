//
//  MNKABSearch.h
//  InteractiveMNK
//
//  Created by Qiao John on 13-11-7.
//  Copyright (c) 2013年 Qiao John. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MNKState.h"
#import "MNKABSearchResult.h"

@interface MNKABSearch : NSObject

@property int M; // # of rows
@property int N; // # of columns
@property int K; // # of marks to win

@property BOOL is_human_first; // YES is human goes first
@property BOOL cutoff; // YES is use cutoff and evaluation function
@property int depth; // cutoff depth

@property BOOL is_timeup; // YES if time's up, and return current best value immediately

// Initialization
- (MNKABSearch *)initWithM:(int)m N:(int)n K:(int)k IsHumanFirst:(BOOL)is_human_first CutOff:(BOOL)cutoff Depth:(int)depth;

// Give a current MNKState and compute the next best move
- (MNKABSearchResult *)search:(MNKState *)state;

// This is a private function. I made it public just for Test
- (int)check:(MNKState *)state;

@end
