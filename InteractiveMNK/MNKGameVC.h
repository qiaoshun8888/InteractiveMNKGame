//
//  MNKGameVC.h
//  InteractiveMNK
//
//  Created by Qiao John on 13-11-6.
//  Copyright (c) 2013年 Qiao John. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MNKGameVC : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate>

@property BOOL is_human_first;
@property int level;
@property int thinking_time;

@property (strong, nonatomic) IBOutlet UILabel *current_move_label;
@property (strong, nonatomic) IBOutlet UILabel *winner_label;
@property (strong, nonatomic) IBOutlet UILabel *ai_thinking_label;
@property (strong, nonatomic) IBOutlet UILabel *ai_timer_label;

@property (strong, nonatomic) IBOutlet UICollectionView *game_board_collectionview;

@end
