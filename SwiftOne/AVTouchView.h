//
//  AVTouchView.h
//  GravityGame
//
//  Created by Steve Sparks on 3/30/14.
//  Copyright (c) 2014 Me. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AVTouchView;

@protocol AVTouchViewDelegate <NSObject>

- (IBAction)touchViewDidChange:(AVTouchView*)touchView;

@end


@interface AVTouchView : UIView

@property (strong, nonatomic) IBOutlet id<AVTouchViewDelegate> delegate;
@property (readonly, nonatomic) CGPoint lastTouchedPoint;
@property (readonly, nonatomic) CGPoint offsetFromCenter;

@property (strong, nonatomic) UIColor *dotColor;

/* */
- (void)setOffsetFromCenter:(CGPoint)offset;

@end
