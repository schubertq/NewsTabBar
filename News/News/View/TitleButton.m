//
//  TitleButton.m
//  News
//
//  Created by schubertq on 15/10/21.
//  Copyright © 2015年 schubertq. All rights reserved.
//

#import "TitleButton.h"

@implementation TitleButton

- (void)setProgress:(CGFloat)progress
{
    _progress = progress;
    
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    CGRect drawRect = CGRectMake(0, 0, rect.size.width * self.progress, rect.size.height);
    [[UIColor redColor] set];
    
    UIRectFillUsingBlendMode(drawRect, kCGBlendModeSourceIn);
//    UIRectFill(drawRect);
}


@end
