//
//  MNKGameVC.m
//  InteractiveMNK
//
//  Created by Qiao John on 13-11-6.
//  Copyright (c) 2013年 Qiao John. All rights reserved.
//

#import "MNKGameVC.h"
#import "MNKGameBoardCell.h"
#import "MNKConstants.h"
#import "MNKABSearch.h"

#define kGameboardCapacity          20
#define kPlayerMoveText             @"Player    O"
#define kComputerMoveText           @"Computer    X"
#define kWinnerPlayerText           @"You are winner!!"
#define kWinnerComputerText         @"You Lose... ㅠ ㅠ"
#define kWinnerDrawText             @"Draw!"

@interface MNKGameVC ()

@end

@implementation MNKGameVC {
    NSMutableArray *boardcell_list;
    MNKABSearch *absearch;
    
    BOOL game_over;
    BOOL is_computer_thinking;
    
    NSTimer *timer;
    NSDate *start_time;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    // Init MNKABSearch
    absearch = [[MNKABSearch alloc] initWithM:4 N:5 K:4 IsHumanFirst:self.is_human_first CutOff:YES Depth:self.level];
    
    // Game board configuration (1-cpu, 0-player)
    int gbc [] = {
        -1, -1, -1, -1, -1,
        -1, -1, -1, -1, -1,
        -1, -1, -1, -1, -1,
        -1, -1, -1, -1, -1
    };
    
    // Init game
    boardcell_list = [[NSMutableArray alloc] initWithCapacity:kGameboardCapacity];
    for (int i=0; i<kGameboardCapacity; i++) {
        MNKNode *node = [[MNKNode alloc] initWithPos:i];
        node.x = i % absearch.N;
        node.y = i / absearch.N;
        node.val = gbc[i];
        boardcell_list[i] = node;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (!self.is_human_first) {
        [self CPUMove];
    }
}

#pragma mark -
#pragma mark UICollectionView Delegate Methods
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [boardcell_list count];
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *BoardCellIdentifier = @"BoardCell";
    
    UINib *nib = [UINib nibWithNibName:@"MNKGameBoardCell" bundle:nil];
    [collectionView registerNib:nib forCellWithReuseIdentifier:BoardCellIdentifier];
    
    MNKGameBoardCell *cell = (MNKGameBoardCell *)[collectionView dequeueReusableCellWithReuseIdentifier: BoardCellIdentifier forIndexPath:indexPath];
    
    cell.node = [boardcell_list objectAtIndex:[indexPath row]];
    [cell initView];
    
    return cell;
}

#pragma mark -
#pragma mark - Collection view delegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    // If game is over or AI is thinking, player cannot mark on the game board.
    if (game_over || is_computer_thinking) {
        return;
    }

    // Construct game states, using ABSearch return the next move of the computer
    int index = [indexPath row];
    MNKNode *node = [boardcell_list objectAtIndex:index];
    
    // Only reponse to the empty node
    // NSLog(@"Current cell is empty? %@", node.val == kEmptyNode ? @"YES" : @"NO");
    if (node.val == kEmptyNode) {
        node.val = kPlayerNode;
        [collectionView reloadData];
        
        [self CPUMove];
    }
    else {
        // do nothing.
    }
}

#pragma mark -
#pragma mark Computer Move
- (void)CPUMove {
    // Running Timer
    timer = [NSTimer scheduledTimerWithTimeInterval:0.001f target:self selector:@selector(runTimer) userInfo:nil repeats:YES];
    start_time = [NSDate date];
    
    is_computer_thinking = YES;
    self.current_move_label.text = @"Computer X";
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // Generate MNKStates
        MNKState *state = [[MNKState alloc] initWithNodes:boardcell_list];
        // [absearch check:state];
        MNKABSearchResult *result = [absearch search:state];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (result.flag == kResultPlayerWin) {
                [self playerWin];
            }
            else {
                boardcell_list = [NSMutableArray arrayWithArray:result.state.nodes];
                if (result.flag == kResultCPUWin && !result.fake_win) {
                    [self computerWin];
                }
                else if (result.flag == kResultDraw) {
                    [self draw];
                }
            }
            if (result.state) {
                [self.game_board_collectionview reloadData];
            }
            
            // Stop timer
            [timer invalidate];
            timer = nil;
            
            is_computer_thinking = NO;
            self.current_move_label.text = @"Player O";
        });
    });
}

#pragma mark -
#pragma mark Win
- (void)playerWin {
    NSLog(@"Player Win!!");
    self.winner_label.text = kWinnerPlayerText;
    game_over = YES;
}
- (void)computerWin {
    NSLog(@"Computer Win!!");
    self.winner_label.text = kWinnerComputerText;
    game_over = YES;
}
- (void)draw {
    NSLog(@"Draw!!");
    self.winner_label.text = kWinnerDrawText;
    game_over = YES;
}

#pragma mark -
#pragma mark AI Timer
- (void)runTimer {
    self.ai_timer_label.text = [NSString stringWithFormat:@"%f", [start_time timeIntervalSinceNow] * -1];
    int past_seconds = (int)([start_time timeIntervalSinceNow] * -1);
    if (past_seconds >= self.thinking_time) {
        absearch.is_timeup = YES;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
