//
//  MNKABSearchResult.h
//  InteractiveMNK
//
//  Created by Qiao John on 13-11-9.
//  Copyright (c) 2013年 Qiao John. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MNKState.h"

@interface MNKABSearchResult : NSObject

@property int flag; // research result, it could be kResultPlayerWin / kResultCPUWin / kResultDraw
@property BOOL fake_win; // useless right now (I tried to fix a problem: in this situation, _ O O O _ , the game is over and AI cannot take further moves.)
@property (strong, nonatomic) MNKState *state; // the best state AI has founded

// Initialization
- (MNKABSearchResult *)initWithSearchVal:(int)v NextStates:(MNKState *)next_state;

@end
