//
//  TouchView.swift
//  SwiftOne
//
//  Created by Steve Sparks on 6/10/14.
//  Copyright (c) 2014 BBQ Steve. All rights reserved.
//
import UIKit
import Foundation
import QuartzCore

class TouchView : UIView {
	var lastTouchedPoint = CGPointMake(0,0)
	var delegate : ViewController?

	let dot = CAShapeLayer()
	let circleRadius : CGFloat = 10.0

	override func didMoveToSuperview()  {
		super.didMoveToSuperview();
		self.backgroundColor = UIColor(white: 1.0,  alpha:0.8)

		self.layer.borderColor = UIColor.blackColor().CGColor
		self.layer.borderWidth = 1.0
		self.clipsToBounds = true

		let dia = CGFloat(circleRadius + circleRadius)
		let rect : CGRect = CGRectMake(0, 0, dia, dia);

		dot.path = UIBezierPath(roundedRect:rect, cornerRadius:circleRadius).CGPath

		let blue = UIColor.blueColor().CGColor

		dot.fillColor = blue;
		dot.strokeColor = blue;

		self.layer.addSublayer(dot);
	}

	func moveDotToTouch(touch: UITouch) {
		let p = touch.locationInView(self);
		if CGRectContainsPoint(self.bounds, p) {
			self.moveDotToPoint(p)
		}
	}

	func moveDotToPoint(p: CGPoint) {
		lastTouchedPoint = p;

		// center it
		let newX = p.x - circleRadius;
		let newY = p.y - circleRadius;

		dot.position = CGPointMake(newX, newY)
		dot.speed = 1000
		dot.setNeedsLayout()
		if delegate {
			delegate?.touchViewDidChange(self);
		}
	}

	func offsetFromCenter() -> CGPoint {
		let center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
		let ret = CGPointMake(center.x - lastTouchedPoint.x, center.y - lastTouchedPoint.y);

		return ret;
	}

	func setOffsetFromCenter(offset: CGPoint) {
		let point = CGPointMake(CGRectGetMidX(self.bounds)+offset.x, CGRectGetMidY(self.bounds)+offset.y);
		moveDotToPoint(point)
	}


	// #### UIView touch methods

	override func touchesBegan(touches: NSSet!, withEvent event: UIEvent!)  {
		super.touchesBegan(touches, withEvent: event)
		if touches {
			let touch : UITouch = touches.anyObject() as UITouch
			self.moveDotToTouch(touch)
		}
	}

	override func touchesMoved(touches: NSSet!, withEvent event: UIEvent!) {
		super.touchesMoved(touches, withEvent: event)
		if touches {
			let touch : UITouch = touches.anyObject() as UITouch
			self.moveDotToTouch(touch)
		}
	}

	override func touchesEnded(touches: NSSet!, withEvent event: UIEvent!)  {
		super.touchesEnded(touches, withEvent: event)
		if touches {
			let touch : UITouch = touches.anyObject() as UITouch
			self.moveDotToTouch(touch)
		}
	}

}
