//
//  MNKNode.m
//  InteractiveMNK
//
//  Created by Qiao John on 13-11-7.
//  Copyright (c) 2013年 Qiao John. All rights reserved.
//

#import "MNKNode.h"

@implementation MNKNode

- (MNKNode *)initWithPos:(int)pos {
    self.pos = pos;
    self.val = kEmptyNode;
    
    return self;
}

- (id)copy {
    MNKNode *node = [[MNKNode alloc] initWithPos:self.pos];
    
    node.val = self.val;
    node.x = self.x;
    node.y = self.y;
    
    return node;
}

@end
