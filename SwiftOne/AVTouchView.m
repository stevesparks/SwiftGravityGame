//
//  AVTouchView.m
//  GravityGame
//
//  Created by Steve Sparks on 3/30/14.
//  Copyright (c) 2014 Me. All rights reserved.
//

#import "AVTouchView.h"

@interface AVTouchView()
@property (strong, nonatomic) CAShapeLayer *dot;

@end

@implementation AVTouchView

static const CGFloat circleRadius = 10;

- (id)initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];
	if(self) {
		[self commonInit];
	}
	return self;
}

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if(self) {
		[self commonInit];
	}
	return self;
}

- (void)commonInit {
	// init
	self.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.8];
	self.layer.borderColor = [UIColor blackColor].CGColor;
	self.layer.borderWidth = 1.0;
	self.clipsToBounds = YES;
	[self dot];
}

- (CAShapeLayer *)dot {
	if(!_dot) {
		CAShapeLayer *dot = [CAShapeLayer layer];
		_dot = dot;

		dot.path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, 2.0*circleRadius, 2.0*circleRadius) cornerRadius:circleRadius].CGPath;
		[self.layer addSublayer:dot];
		// ever so slight gravity
		CGPoint p = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds)*1.5);
		[self moveDotToPoint:p];

		self.dotColor = [UIColor blueColor];
	}
	return _dot;
}

- (void)setDotColor:(UIColor *)dotColor {
	_dotColor = dotColor;
	_dot.fillColor = (_dotColor?:UIColor.clearColor).CGColor;
	_dot.strokeColor = _dot.fillColor;
}

- (void) moveDotToTouch:(UITouch*)touch {
	if(!touch)return;
	CGPoint p = [touch locationInView:self];
	if(CGRectContainsPoint(self.bounds, p))
		[self moveDotToPoint:p];
}

- (void) moveDotToPoint:(CGPoint)p {
	_lastTouchedPoint =  p;
	p.x -= circleRadius;
	p.y -= circleRadius;
	self.dot.position = p;
	self.dot.speed = 1000;
	[self.dot setNeedsLayout];
	if([self.delegate respondsToSelector:@selector(touchViewDidChange:)]) {
		[self.delegate touchViewDidChange:self];
	}
}

- (CGPoint)offsetFromCenter {
	CGPoint center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
	CGPoint ret = CGPointMake(center.x - _lastTouchedPoint.x, center.y - _lastTouchedPoint.y);

	return ret;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	[super touchesBegan:touches withEvent:event];
	UITouch *touch = [touches anyObject];

	[self moveDotToTouch:touch];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	[super touchesMoved:touches withEvent:event];
	UITouch *touch = [touches anyObject];
	[self moveDotToTouch:touch];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	[super touchesEnded:touches withEvent:event];
	UITouch *touch = [touches anyObject];
	[self moveDotToTouch:touch];
}

- (void)setOffsetFromCenter:(CGPoint)offset {
	CGPoint point = CGPointMake(CGRectGetMidX(self.bounds)+offset.x, CGRectGetMidY(self.bounds)+offset.y);
	[self moveDotToPoint:point];
}

@end
