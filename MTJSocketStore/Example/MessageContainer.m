//
//  MessageContainer.m
//  MTJSocketStore
//
//  Created by sintaiyuan on 10/19/15.
//  Copyright © 2015 mataejoon. All rights reserved.
//

#import "MessageContainer.h"

@implementation MessageContainer

- (void)drawRect:(CGRect)rect {
    CALayer *upperBorder = [CALayer layer];
    upperBorder.backgroundColor = [[UIColor grayColor] CGColor];
    upperBorder.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), 1.0f);
    [self.layer addSublayer:upperBorder];}


@end
