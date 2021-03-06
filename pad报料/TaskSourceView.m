//
//  TaskSourceView.m
//  BreakingNews
//
//  Created by qianmenhui on 14-7-2.
//  Copyright (c) 2014年 钱门慧. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "TaskSourceView.h"

@implementation TaskSourceView

@synthesize isNeedLayout;
@synthesize delegate;
@synthesize itemWidth;
@synthesize itemHeight;
@synthesize imgArray;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        //self.backgroundColor = [UIColor grayColor];
        isNeedLayout = YES;
        imgArray = [[NSMutableArray alloc] init];
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


- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (!isNeedLayout)
        return;
    
    //如果有图片显示和添加按钮，应该先删除
    for (int i=0; i<imgArray.count; i++) {
        if ([self viewWithTag:(500+i)]) {
            [[self viewWithTag:(500+i)] removeFromSuperview];
            
            UIView *imageView = [self viewWithTag:(500+i)];
            imageView = nil;
        }
    }
    if ([self viewWithTag:499]) {
        [[self viewWithTag:499] removeFromSuperview];
        
        UIView *addView = [self viewWithTag:499];
        addView = nil;
    }
    
    isNeedLayout = NO;
    //每个资源相隔为1
    if (imgArray != nil && imgArray.count > 0) {
        //一行可显示的资源数目
        NSInteger numPerRow = self.frame.size.width/(self.itemWidth + 5);
        //需要显示的数目
        NSInteger sourceNum = imgArray.count;
        //需要显示的行数
        NSInteger rowTotal = (sourceNum/numPerRow) + 1;
        
        CGRect Curframe = self.frame;
        if (Curframe.size.height != (self.itemHeight + 5)*rowTotal + 5) {
            self.frame = CGRectMake(Curframe.origin.x, Curframe.origin.y, Curframe.size.width, (self.itemHeight + 5)*rowTotal + 5);
        }
        
        //记录最后一个按钮的位置
        CGRect lastBtnFrame = CGRectMake(1, 1, self.itemWidth, self.itemHeight);
        for (int i=0; i<imgArray.count; i++) {
            if (i >= 3*numPerRow) //不支持显示超过3行
                break;
            
            UIImageView *imageView = [[UIImageView alloc] init];
            if (i < numPerRow)
                imageView.frame = CGRectMake(5 + i*(5+self.itemWidth), 5, self.itemWidth, self.itemHeight);
            else if (i >= numPerRow && i < 2*numPerRow)
                imageView.frame = CGRectMake(5 + (i - numPerRow)*(5+self.itemWidth), 10 + self.itemHeight, self.itemWidth, self.itemHeight);
            else if (i >= 2*numPerRow && i < 3*numPerRow)
                imageView.frame = CGRectMake(5 + (i - 2*numPerRow)*(5+self.itemWidth), 15 + 2*self.itemHeight, self.itemWidth, self.itemHeight);
            [imageView setImage:[imgArray objectAtIndex:i]];
            imageView.tag = 500+i;
            [imageView setUserInteractionEnabled:YES];

            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(btnImgClicked:)];
            [imageView addGestureRecognizer:tap];
            
            UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(imgLongPress:)];
            longPress.minimumPressDuration = 1.0f;
            [imageView addGestureRecognizer:longPress];
            
            //NSLog(@"imageView.gesture:%d",imageView.gestureRecognizers.count);
            
            [self addSubview:imageView];

            lastBtnFrame = imageView.frame;
        }
        
        UIButton *btnAdd = [UIButton buttonWithType:UIButtonTypeCustom];
        //如果资源数目刚好与一行能显示的数目相等，那么add按钮需要在第二行画
        if (imgArray.count == numPerRow)
            btnAdd.frame = CGRectMake(5, 10 + self.itemHeight, self.itemWidth, self.itemHeight);
        else if (imgArray.count == 2*numPerRow)   //在第三行画
            btnAdd.frame = CGRectMake(5, 15 + 2*self.itemHeight, self.itemWidth, self.itemHeight);
        else        //直接在最后一个按钮右边画
            btnAdd.frame = CGRectMake(lastBtnFrame.origin.x + (5+self.itemWidth), lastBtnFrame.origin.y, self.itemWidth, self.itemHeight);
        [btnAdd setTitle:@"+" forState:UIControlStateNormal];
        btnAdd.titleLabel.font = [UIFont systemFontOfSize:40];
        [btnAdd setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        btnAdd.tag = 499;
        btnAdd.layer.borderWidth = 1.0f;
        btnAdd.layer.borderColor = [UIColor lightGrayColor].CGColor;
        btnAdd.layer.cornerRadius = 5.0f;
        [btnAdd addTarget:self action:@selector(btnAdd:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btnAdd];
    }
    else
    {
        CGRect Curframe = self.frame;
        if (Curframe.size.height != self.itemHeight + 10) {
            self.frame = CGRectMake(Curframe.origin.x, Curframe.origin.y, Curframe.size.width, self.itemHeight + 10);
        }
        
        UIButton *btnAdd = [UIButton buttonWithType:UIButtonTypeCustom];
        btnAdd.frame = CGRectMake(5, 5, self.itemWidth, self.itemHeight);
        [btnAdd setTitle:@"+" forState:UIControlStateNormal];
        btnAdd.titleLabel.font = [UIFont systemFontOfSize:40];
        [btnAdd setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        btnAdd.tag = 499;
        btnAdd.layer.borderWidth = 1.0f;
        btnAdd.layer.borderColor = [UIColor lightGrayColor].CGColor;
        btnAdd.layer.cornerRadius = 5.0f;
        [btnAdd addTarget:self action:@selector(btnAdd:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btnAdd];
    }
    
    if (delegate && [delegate respondsToSelector:@selector(layoutReset:)]) {
        [delegate layoutReset:self.frame];
    }
}

- (void)btnAdd:(UIButton*)sender
{
    if (delegate && [delegate respondsToSelector:@selector(AddBtnClicked:)]) {
        [delegate AddBtnClicked:sender];
    }
}

//单击图片
- (void)btnImgClicked:(id)sender
{
    UITapGestureRecognizer *tap = (UITapGestureRecognizer*)sender;
    UIView *imageView = [tap view];
    NSInteger index = imageView.tag - 500;
    
//    UIButton *btn = (UIButton*)sender;
//    NSInteger index = btn.tag - 500;
    if (delegate && [delegate respondsToSelector:@selector(imgClicked:)]) {
        [delegate imgClicked:index];
    }
}

//长按图片
- (void)imgLongPress:(id)sender
{
    UILongPressGestureRecognizer *longPress = (UILongPressGestureRecognizer*)sender;
    
    if (longPress.state == UIGestureRecognizerStateBegan) {
        UIView *imgView = [longPress view];
        NSInteger index = imgView.tag - 500;
        if (delegate && [delegate respondsToSelector:@selector(imageLongPress:)]) {
            [delegate imageLongPress:index];
        }
    }
}

- (void)removeItemFromView:(NSInteger)index
{
    if (imgArray == nil || imgArray.count <= index)
        return;
    
    //先删除所有
    for (int i=0; i<imgArray.count; i++) {
        [[self viewWithTag:(500+i)] removeFromSuperview];
        UIView *imageView = [self viewWithTag:(500+i)];
        imageView = nil;
    }
    if ([self viewWithTag:499]) {
        [[self viewWithTag:499] removeFromSuperview];
        
        UIView *addView = [self viewWithTag:499];
        addView = nil;
    }
    
    //删除index的条目
    [imgArray removeObjectAtIndex:index];
    
    //刷新界面
    isNeedLayout = YES;
    [self layoutSubviews];
}

//去除所有按钮，包括add
- (void)removeAllItems
{
    if (imgArray == nil || imgArray.count <= 0)
        return;
    
    for (int i=0; i<imgArray.count; i++) {
        if ([self viewWithTag:(500+i)]) {
            [[self viewWithTag:(500+i)] removeFromSuperview];
            
            UIView *imageView = [self viewWithTag:(500+i)];
            imageView = nil;
        }
    }
    if ([self viewWithTag:499]) {
        [[self viewWithTag:499] removeFromSuperview];
        
        UIView *addView = [self viewWithTag:499];
        addView = nil;
    }
    
    [imgArray removeAllObjects];
    
    //刷新界面
    isNeedLayout = YES;
    [self layoutSubviews];
}

- (void)AppendItemsImgArray:(NSMutableArray *)newArray
{
    if (newArray == nil || newArray.count <= 0)
        return;
    
    [imgArray addObjectsFromArray:newArray];
    
    //刷新界面
    isNeedLayout = YES;
    [self layoutSubviews];
}


@end
