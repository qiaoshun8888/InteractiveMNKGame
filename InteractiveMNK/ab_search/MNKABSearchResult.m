//
//  MNKABSearchResult.m
//  InteractiveMNK
//
//  Created by Qiao John on 13-11-9.
//  Copyright (c) 2013年 Qiao John. All rights reserved.
//

#import "MNKABSearchResult.h"

@implementation MNKABSearchResult

- (MNKABSearchResult *)initWithSearchVal:(int)v NextStates:(MNKState *)next_state {
    self.flag = v;
    
    if (next_state) {
        self.state = next_state;
        self.fake_win = next_state.fake_win;
        NSLog(@"MNKABSearchResult.fake_win: %@", self.fake_win ? @"YES" : @"NO");
    }
    
    return self;
}

@end
