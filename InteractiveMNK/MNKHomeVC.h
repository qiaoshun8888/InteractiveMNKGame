//
//  MNKHomeVC.h
//  InteractiveMNK
//
//  Created by Qiao John on 13-11-6.
//  Copyright (c) 2013年 Qiao John. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MNKHomeVC : UIViewController

@property (strong, nonatomic) IBOutlet UISegmentedControl *player_move_segmentedcontrol;

@property (strong, nonatomic) IBOutlet UILabel *level_label;
@property (strong, nonatomic) IBOutlet UISlider *level_slider;
@property (strong, nonatomic) IBOutlet UILabel *thinking_time_label;
@property (strong, nonatomic) IBOutlet UISlider *thinking_time_slider;

- (IBAction)levelChanged:(id)sender;
- (IBAction)thinkingTimeChanged:(id)sender;
- (IBAction)playerMoveChanged:(id)sender;

@end
