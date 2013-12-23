//
//  MNKHomeVC.m
//  InteractiveMNK
//
//  Created by Qiao John on 13-11-6.
//  Copyright (c) 2013年 Qiao John. All rights reserved.
//

#import "MNKHomeVC.h"
#import "MNKGameVC.h"

@interface MNKHomeVC ()

@end

@implementation MNKHomeVC {
    int level;
    int thinking_time;
    BOOL is_human_first;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    level = (int)self.level_slider.value;
    thinking_time = (int)self.thinking_time_slider.value;
    is_human_first = self.player_move_segmentedcontrol.selectedSegmentIndex == 0;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}


- (IBAction)levelChanged:(id)sender {
    UISlider *slider = (UISlider *)sender;
    level = (int)slider.value;
    if (level < 3) {
        self.level_label.text = @"Easy";
    }
    else if (level < 4) {
        self.level_label.text = @"Medium";
    }
    else {
        self.level_label.text = @"Hard";
    }
    
    self.thinking_time_slider.value = level * 5.0f;
    [self.thinking_time_slider sendActionsForControlEvents:UIControlEventValueChanged];
}

- (IBAction)thinkingTimeChanged:(id)sender {
    UISlider *slider = (UISlider *)sender;
    thinking_time = (int)slider.value;
    self.thinking_time_label.text = [NSString stringWithFormat:@"%ds", thinking_time];
}

- (IBAction)playerMoveChanged:(id)sender {
    UISegmentedControl *segment = (UISegmentedControl *)sender;
    is_human_first = segment.selectedSegmentIndex == 0;
}

#pragma mark -
#pragma mark - PrepareForSegue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    MNKGameVC *game_vc = (MNKGameVC *)segue.destinationViewController;
    game_vc.level = level;
    game_vc.thinking_time = thinking_time;
    game_vc.is_human_first = is_human_first;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
