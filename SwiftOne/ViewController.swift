//
//  ViewController.swift
//  SwiftOne
//
//  Created by Steve Sparks on 6/7/14.
//  Copyright (c) 2014 BBQ Steve. All rights reserved.
//

import UIKit
import CoreMotion

class ViewController: UIViewController, AVTouchViewDelegate {

	// all the stuff in the storyboard
	@IBOutlet var slider : UISlider
	@IBOutlet var label : UILabel
	@IBOutlet var touchView : AVTouchView
	@IBOutlet var sourceSwitch : UISwitch
	@IBOutlet var sourceLabel : UILabel
	@IBOutlet var redrawButton : UIButton

	// could put some logic here to have bigger boxes on iPad
	let rockSize : CGFloat = 10.0;
	let boxSize : CGFloat = 20.0;

	var rocks : Array<UIView> = []
	var boxes : UIView[] = []

	// UIDynamics stuff
	var animator:UIDynamicAnimator? = nil;
	let collider = UICollisionBehavior()
	let boxBehavior = UIDynamicItemBehavior()
	let gravity = UIGravityBehavior()

	// For getting device motion updates in gravity mode
	let motionQueue = NSOperationQueue()
	let motionManager = CMMotionManager()

	override func viewDidLoad() {
		super.viewDidLoad()
		initDynamics()
		populateScreen()
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}

	override func viewDidAppear(animated: Bool)  {
		super.viewDidAppear(animated)
		elasticitySliderChanged(slider)
		// check our values
		readSwitch()
	}

	// CoreMotion gravity stuff

	func readSwitch() {
		var selected = sourceSwitch.on
		if selected {
			sourceLabel.text = "Gravity"
			motionManager.startDeviceMotionUpdatesToQueue(motionQueue, withHandler: gravityUpdated)
		} else {
			motionManager.stopDeviceMotionUpdates()
			sourceLabel.text = "Joystick"
		}
	}

	func gravityUpdated(motion: CMDeviceMotion!, error: NSError!) {
		var x = CGFloat(motion.gravity.x) * 50.0
		var y = CGFloat(motion.gravity.y) * -50.0
		var p = CGPointMake(x,y)

		// Have to correct for orientation.
		var orientation = UIApplication.sharedApplication().statusBarOrientation;

		if(orientation == UIInterfaceOrientation.LandscapeLeft) {
			var t = p.x
			p.x = 0 - p.y
			p.y = t
		} else if (orientation == UIInterfaceOrientation.LandscapeRight) {
			var t = p.x
			p.x = p.y
			p.y = 0 - t
		} else if (orientation == UIInterfaceOrientation.PortraitUpsideDown) {
			p.x *= -1
			p.y *= -1
		}

		dispatch_async(dispatch_get_main_queue(), {() -> () in
			self.touchView.setOffsetFromCenter(p)
			})
	}



	// Initialize UIDynamics stuff

	func initDynamics() {
		animator = UIDynamicAnimator(referenceView:super.view);
		animator?.addBehavior(collider)

		// A collider, so things bounce into each other.
		collider.translatesReferenceBoundsIntoBoundary = true

		// Boxes have some small behaviors to them.
		boxBehavior.allowsRotation = true
		boxBehavior.friction = 0.1;
		animator?.addBehavior(boxBehavior)

		gravity.gravityDirection = CGVectorMake(0, 0.8)
		animator?.addBehavior(gravity);
	}

	func populateScreen() {
		removeAll()
		addRocks()
		addBoxes()

		// do a "gravity or joystick" check
		readSwitch()
	}

	func removeAll() {
		for rock in rocks {
			removeRock(rock)
		}

		for box in boxes {
			removeBox(box)
		}
	}

	func addRocks() {
		let maxX = super.view.bounds.size.width - (rockSize + 4);
		let maxY = super.view.bounds.size.height - (rockSize + 4);

		for i in 0..10 {
			var guess = CGRectMake(9, 9, 9, 9)

			do {
				let guessX = CGFloat(arc4random()) % maxX;
				let guessY = CGFloat(arc4random()) % maxY;
				guess = CGRectMake(guessX+2, guessY+2, rockSize, rockSize);
			} while(!doesNotCollide(guess))

			addRock(guess, tag:i)
		}
	}
	
	func addBoxes() {
		let maxX = super.view.bounds.size.width - boxSize;
		let maxY = super.view.bounds.size.height - boxSize;

		for i in 0..10 {
			var guess = CGRectMake(9, 9, 9, 9)

			do {
				let guessX = CGFloat(arc4random()) % maxX;
				let guessY = CGFloat(arc4random()) % maxY;
				guess = CGRectMake(guessX, guessY, boxSize, boxSize);
			} while(!doesNotCollide(guess))

			addBox(guess)
		}
	}

	// Checks several places for colliding views.
	func doesNotCollide(testRect: CGRect) -> Bool {

		if CGRectIntersectsRect(testRect, touchView.frame) {
			return false
		}

		if CGRectIntersectsRect(testRect, sourceSwitch.frame) {
			return false
		}

		if CGRectIntersectsRect(testRect, redrawButton.frame) {
			return false
		}

		if CGRectIntersectsRect(testRect, slider.frame) {
			return false
		}

		for rock in rocks {
			var viewRect = rock.frame;
			if(CGRectIntersectsRect(testRect, viewRect)) {
				return false
			}
		}

		for box in boxes {
			var viewRect = box.frame;
			if(CGRectIntersectsRect(testRect, viewRect)) {
				return false
			}
		}

		return true
	}

	// Rocks
	// Since rocks don't move, we define them as four boundaries, not as an
	// object subject to its own collision effects.
	func removeRock(rock: UIView) {
		var idx : Int = NSNotFound;

		for (index, rck) in enumerate(rocks) {
			if rck == rock {
				idx = index
			}
		}

		if idx != NSNotFound {
			rock.removeFromSuperview()
			rocks.removeAtIndex(idx)

			collider.removeBoundaryWithIdentifier("boundary \(rock.tag) top")
			collider.removeBoundaryWithIdentifier("boundary \(rock.tag) bot")
			collider.removeBoundaryWithIdentifier("boundary \(rock.tag) lft")
			collider.removeBoundaryWithIdentifier("boundary \(rock.tag) rgt")
		}
	}


	func addRock(frame: CGRect, tag: Int) {
		let newRock = UIView(frame:frame)
		newRock.backgroundColor = UIColor.blackColor()
		newRock.tag = tag;

		let shadowSize = CGFloat(rockSize / 12.0);
		newRock.layer.shadowColor = newRock.backgroundColor.CGColor
		newRock.layer.shadowOffset = CGSizeMake(shadowSize, shadowSize);
		newRock.layer.shadowOpacity = 0.9;
		newRock.layer.shadowRadius = shadowSize;

		let left : CGFloat = frame.origin.x;
		let right : CGFloat = left + rockSize;
		let top = frame.origin.y;
		let bottom = top + rockSize;

		let leftTop = CGPointMake(left, top);
		let leftBot = CGPointMake(left, bottom);
		let rightTop = CGPointMake(right, top);
		let rightBot = CGPointMake(right, bottom);

		collider.addBoundaryWithIdentifier("boundary \(tag) top", fromPoint: leftTop, toPoint: rightTop);
		collider.addBoundaryWithIdentifier("boundary \(tag) bot", fromPoint: leftBot, toPoint: rightBot);
		collider.addBoundaryWithIdentifier("boundary \(tag) lft", fromPoint: leftTop, toPoint: leftBot);
		collider.addBoundaryWithIdentifier("boundary \(tag) rgt", fromPoint: rightTop, toPoint: rightBot);

		view.insertSubview(newRock, atIndex: 0)
		rocks += newRock;

	}


	// Boxes
	// Straight up UIDynamics items. Gravity, box behavior, and the collider.

	func removeBox(box: UIView) {
		var idx : Int = NSNotFound;

		for (index, bx) in enumerate(boxes) {
			if bx == box {
				idx = index
			}
		}

		if idx != NSNotFound {
			box.removeFromSuperview()
			boxBehavior.removeItem(box)
			collider.removeItem(box)
			gravity.removeItem(box)
			boxes.removeAtIndex(idx)
		}
	}

	func randomColor() -> UIColor {
		let red = CGFloat(CGFloat(arc4random()%100000)/100000);
		let green = CGFloat(CGFloat(arc4random()%100000)/100000);
		let blue = CGFloat(CGFloat(arc4random()%100000)/100000);

		return UIColor(red: red, green: green, blue: blue, alpha: 0.85);
	}
	
	func addBox(frame: CGRect) {
		let newBox = UIView(frame: frame)
		newBox.layer.cornerRadius = CGFloat(boxSize/4)
		newBox.backgroundColor = randomColor()

		view.insertSubview(newBox, atIndex: 0)
		boxBehavior.addItem(newBox)
		gravity.addItem(newBox)
		collider.addItem(newBox)
		boxes += newBox
	}

	//----- Various callbacks

	@IBAction func sourceSwitchChanged(sender : UISwitch) {
		readSwitch()
	}

	@IBAction func redrawButtonTapped(sender : AnyObject) {
		populateScreen()
	}

	@IBAction func elasticitySliderChanged(sender : UISlider) {
		boxBehavior.elasticity = CGFloat(sender.value)
		label.text = "elasticity = \(sender.value)"
	}

	func touchViewDidChange(touchView: AVTouchView!) {
		var p = touchView.offsetFromCenter;
		var v = CGVectorMake(0 - (p.x / 50),0 - (p.y / 50));
		gravity.gravityDirection = v;
	}
}


