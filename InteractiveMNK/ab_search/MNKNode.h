//
//  MNKNode.h
//  InteractiveMNK
//
//  Created by Qiao John on 13-11-7.
//  Copyright (c) 2013年 Qiao John. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kEmptyNode      -1
#define kPlayerNode     0
#define kComputerNode   1

@interface MNKNode : NSObject

@property int pos;
@property int val; // default = -1, player = 0, computer = 1

@property int x;
@property int y;

- (MNKNode *)initWithPos:(int)pos;

- (id)copy;

@end
