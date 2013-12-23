//
//  MNKGameBoardCell.m
//  InteractiveMNK
//
//  Created by Qiao John on 13-11-6.
//  Copyright (c) 2013年 Qiao John. All rights reserved.
//

#import "MNKGameBoardCell.h"

@implementation MNKGameBoardCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)initView {
    // init
    if (self.node.val == kPlayerNode) {
        [self.board_button setTitle:@"O" forState:UIControlStateNormal];
    }
    else if (self.node.val == kComputerNode) {
        [self.board_button setTitle:@"X" forState:UIControlStateNormal];
    }
    else {
        [self.board_button setTitle:@"" forState:UIControlStateNormal];
    }
}

@end
