//
//  MNKGameBoardCell.h
//  InteractiveMNK
//
//  Created by Qiao John on 13-11-6.
//  Copyright (c) 2013年 Qiao John. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MNKNode.h"

@interface MNKGameBoardCell : UICollectionViewCell

@property (strong, nonatomic) MNKNode *node;

@property (strong, nonatomic) IBOutlet UIButton *board_button;

- (void)initView;

@end
