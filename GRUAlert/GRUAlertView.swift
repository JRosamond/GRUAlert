//
//  GRUAlertView.swift
//  GRUCustomAlert
//
/*************************************************************************
Created by jrosamond on 2/2/15.
Copyright (c) 2015 Georgia Regents University. All rights reserved.

Permission to use, copy, modify, and/or distribute this software for any
purpose with or without fee is hereby granted, provided that the above
copyright notice and this permission notice appear in all copies.

THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
**************************************************************************/

//	NOTES: This custom alert view has many customizable properties.  Many of the properties
//	can be set via Interface Builder.  This class contains 3 built-in methods
//	for animating the view and its contents on/off the screen. These animations can be
//	accessed from the calling view controller via the AnimationKeys enum included in this class.  
//	Feel free to add your own.
//

import UIKit

// Adopt this protocol to control what happens when either
// the left or right buttons on the AlertView are pressed.
@objc public protocol GRUAlertViewDelegate
{
	optional func handleDefaultAlertAction() // The action taken by pressing the right button
	optional func handleCancelAlertAction() // The action taken by presseing the left button
}

@IBDesignable
public class GRUAlertView: UIView
{
	// Use your view controller's instance of GRUAlertView to set this variable
	// and implement the methods of the GRUAlertViewDelegate protocol
	public var delegate:GRUAlertViewDelegate?
	
	var currentAnimation:AnimationKeys!
	var topBtnBorder:CALayer = CALayer()
	var rightBtnBorder:CALayer = CALayer()
	
	var dispatchGroup = dispatch_group_create()
	
	@IBOutlet weak var mainView:UIView!
	@IBOutlet weak var backgroundView:UIView!
	@IBOutlet weak var contentView:UIView!
	@IBOutlet weak var alertTitle:UILabel!
	@IBOutlet weak var alertMessage:UILabel!
	@IBOutlet var buttons:[UIButton] = []
	
	@IBOutlet weak var leftBtnWidthConstraint: NSLayoutConstraint!
	
	// Access the three built-in alert view animations by referencing the
	// keys below in your view controller
	public enum AnimationKeys: Int
	{
		case scaleFromCenter = 0
		case scaleFromBottom
		case rotateAndTranslateFromLeft
	}
	
	// MARK: Inspectable Properties
	
	@IBInspectable public var alertRadius:CGFloat = 0
	{
		didSet
		{
			contentView.layer.cornerRadius = alertRadius
		}
	}
	
	@IBInspectable public var strokeWidth:CGFloat = 1.0
	{
		didSet
		{
			contentView.layer.borderWidth = strokeWidth
		}
	}
	
	@IBInspectable public var strokeColor:UIColor = UIColor.blackColor()
	{
		didSet
		{
			contentView.layer.borderColor = strokeColor.CGColor
		}
	}
	
	@IBInspectable public var alertBgColor:UIColor = UIColor.lightGrayColor()
	{
		didSet
		{
			contentView.backgroundColor = alertBgColor
		}
	}
	
	@IBInspectable public var bgViewColor:UIColor = UIColor.lightGrayColor()
	{
		didSet
		{
			backgroundView.backgroundColor = bgViewColor
		}
	}
	
	@IBInspectable public var bgAlpha:CGFloat = 0.75
	{
		didSet
		{
			backgroundView.alpha = bgAlpha
		}
	}
	
	@IBInspectable public var titleText:String = ""
	{
		didSet
		{
			alertTitle.text = titleText
		}
	}
	
	@IBInspectable public var titleColor:UIColor = UIColor.blackColor()
	{
		didSet
		{
			alertTitle.textColor = titleColor
		}
	}
	
	@IBInspectable public var messageText:String = ""
	{
		didSet
		{
			alertMessage.text = messageText
		}
	}
	
	@IBInspectable public var messageColor:UIColor = UIColor.blackColor()
	{
		didSet
		{
			alertMessage.textColor = messageColor
		}
	}
	
	// The alert has two buttons by default.  If you only need one button,
	// set this property to NO in Interface Builder.
	@IBInspectable public var secondButton:Bool = true
	{
		didSet
		{
			// create buttons
			layoutButtons(secondButton)
			configBtnBorder(1.5, color: btnStroke)
		}
	}
	
	@IBInspectable public var btnStroke:UIColor = UIColor.blackColor()
	{
		didSet
		{
			configBtnBorder(1.5, color: btnStroke)
		}
	}
	
	@IBInspectable public var lBtnColor:UIColor = UIColor.whiteColor()
	{
		didSet
		{
			if (!buttons.isEmpty)
			{
				buttons[0].backgroundColor = lBtnColor
			}
		}
	}
	
	@IBInspectable public var rBtnColor:UIColor = UIColor.whiteColor()
	{
		didSet
		{
			if (buttons.count > 1)
			{
				buttons[1].backgroundColor = rBtnColor
			}
		}
	}
	
	@IBInspectable public var lBtnLabel:String = "Cancel"
	{
		didSet
		{
			if (!buttons.isEmpty)
			{
				buttons[0].setTitle(lBtnLabel, forState: UIControlState.Normal)
			}
		}
	}
	
	@IBInspectable public var rBtnLabel:String = "OK"
	{
		didSet
		{
			if (buttons.count > 1)
			{
				buttons[1].setTitle(rBtnLabel, forState: UIControlState.Normal)
			}
		}
	}
	
	@IBInspectable public var lBtnTxtColor:UIColor = UIColor.blackColor()
	{
		didSet
		{
			if (!buttons.isEmpty)
			{
				buttons[0].setTitleColor(lBtnTxtColor, forState: .Normal)
			}
		}
	}
	
	@IBInspectable public var rBtnTxtColor:UIColor = UIColor.blackColor()
	{
		didSet
		{
			if (buttons.count > 1)
			{
				buttons[1].setTitleColor(rBtnTxtColor, forState: .Normal)
			}
		}
	}

	
	// MARK: Initialization
	
	public init()
	{
		super.init(frame: CGRectZero)
		setTranslatesAutoresizingMaskIntoConstraints(false)
	}
	
	override public init(frame: CGRect)
	{
		super.init(frame: frame)
		initializeSubviews()
	}
	
	required public init(coder aDecoder: NSCoder)
	{
		super.init(coder: aDecoder)
		initializeSubviews()
	}
	
	func initializeSubviews()
	{
		self.backgroundColor = UIColor.clearColor()
		self.alpha = 0.0
		
		// Load contents of the xib
		var resourceBundle:NSBundle? = NSBundle(forClass: self.dynamicType)
		var xibFile:UINib = UINib(nibName: "GRUAlertView", bundle: resourceBundle!)
		xibFile.instantiateWithOwner(self, options: nil)
		contentView.layer.masksToBounds = true
		
		// Add the view loaded from the xib file into self
		self.addSubview(mainView)
		
		// Set up constraints on mainView
		mainView.setTranslatesAutoresizingMaskIntoConstraints(false)
		
		let leadingConstraint:NSLayoutConstraint = NSLayoutConstraint(item: mainView, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Leading, multiplier: 1.0, constant: 0)
		let topConstraint:NSLayoutConstraint = NSLayoutConstraint(item: mainView, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Top, multiplier: 1.0, constant: 0)
		let widthConstraint:NSLayoutConstraint = NSLayoutConstraint(item: mainView, attribute: .Width, relatedBy: .Equal, toItem: self, attribute: .Width, multiplier: 1.0, constant: 0)
		let heightConstraint:NSLayoutConstraint = NSLayoutConstraint(item: mainView, attribute: .Height, relatedBy: .Equal, toItem: self, attribute: .Height, multiplier: 1.0, constant: 0)
		self.addConstraints([leadingConstraint, topConstraint, widthConstraint, heightConstraint])
	}
	
	
	// MARK: Button Configuration
	
	func layoutButtons(hasSecondBtn:Bool)
	{
		// one Button
		if hasSecondBtn == false
		{
			// Hide the second(right) button
			buttons[1].hidden = true
			
			// delete the width constraint of the leftBtn so that we can reset the multiplier
			contentView.removeConstraint(leftBtnWidthConstraint)
			
			// Create a new width constraint for the leftBtn that sets it equal to the width of the contentView
			self.contentView.addConstraint(NSLayoutConstraint(item: buttons[0], attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: self.contentView, attribute: NSLayoutAttribute.Width, multiplier: 1.0, constant: 0.0))
		}
	}
	
	func configBtnBorder(width:CGFloat, color:UIColor)
	{
		if(!contentView.layer.sublayers.isEmpty)
		{
			topBtnBorder.removeFromSuperlayer()
			rightBtnBorder.removeFromSuperlayer()
		}
	
		topBtnBorder.backgroundColor = color.CGColor
		topBtnBorder.frame = CGRectMake(buttons[0].frame.origin.x, buttons[0].frame.origin.y, CGRectGetWidth(contentView.frame), width)
		contentView.layer.addSublayer(topBtnBorder)
		
		if secondButton
		{
			rightBtnBorder.backgroundColor = color.CGColor
			rightBtnBorder.frame = CGRectMake((buttons[0].frame.origin.x + buttons[0].frame.size.width) - 1.0, buttons[0].frame.origin.y, width, CGRectGetHeight(buttons[0].frame))
			contentView.layer.addSublayer(rightBtnBorder)
		}
	}
	
	// MARK: Customization
	
	public func setAlertTitleFont(customFont:UIFont)
	{
		alertTitle.font = customFont
	}
	
	public func setAlertMessageFont(customFont:UIFont)
	{
		alertMessage.font = customFont
	}
	
	public func setButtonLabelFont(customFont:UIFont)
	{
		for button in buttons
		{
			button.titleLabel?.font = customFont
		}
	}
	
	
	// MARK: Navigation
	
	public func show(animationKey:AnimationKeys = AnimationKeys.scaleFromCenter)
	{
		currentAnimation = animationKey
		
		switch animationKey
		{
		case .scaleFromCenter:
			scaleFromCenter()
			
		case .scaleFromBottom:
			scaleFromBottom()
		
		case .rotateAndTranslateFromLeft:
			rotateAndTranslateFromLeft()
			
		default:
			scaleFromCenter()
		}
	}
	
	// Called by the right button
	@IBAction func defaultAction()
	{
		dismiss()
		
		// Finish callback to delegate method after
		// all the animations have completed
		if (delegate != nil)
		{
			let mainQ = dispatch_get_main_queue()
			dispatch_group_notify(dispatchGroup, mainQ, {
				self.delegate!.handleDefaultAlertAction!()
			})
		}
	}
	
	// Called by the left button
	@IBAction func cancelAction()
	{
		dismiss()
		delegate?.handleCancelAlertAction?()
	}
	
	// Animates the alert view off of the screen
	func dismiss()
	{
		if let currentAnim = currentAnimation
		{
			switch currentAnim
			{
			case .scaleFromCenter:
				dismissScaleFromCenter()
			
			case .scaleFromBottom:
				dismissScaleFromBottom()
			
			case .rotateAndTranslateFromLeft:
				dismissRotateAndTranslateFromLeft()
				
			default:
				dismissScaleFromCenter()
			}
		}
	}
	
	
	// MARK: Animations
	
	func scaleFromCenter()
	{
		// scale up the view
		self.contentView.transform = CGAffineTransformMakeScale(0.1, 0.1)
		
		// Fade in the view
		UIView.animateWithDuration(0.4, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
			self.alpha = 1.0
		}, completion: nil)
		
		UIView.animateWithDuration(0.6, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.5, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
			self.contentView.transform = CGAffineTransformMakeScale(1.0, 1.0)
		}, completion: nil)
	}
	
	// NOTE ON DISPATCH GROUPS: Since we want the alert view to finish it's dismiss animation before say, loading another view controller, we are using
	// a dispatch group to monitor the animations' completion blocks.  The dispatch group lets us know when the completion blocks have all been called 
	// and we can then proceed with the handleDefaultAlertAction delegate method.  The dispatch_group_enter and dispatch_group_leave functions 
	// allow the group to act as a sort of counter, keeping track of the number of blocks running in the group. Each dispatch_group_enter call should have a
	// matching dispatch_group_leave call.  When the group is empty, we call dispatch_group_notify in our defaultAction() method.
	
	func dismissScaleFromCenter()
	{
		// Add an item to the dispatchGroup for each animation
		// then in each animation's completion block, we remove
		// it from the dispatchGroup
		dispatch_group_enter(dispatchGroup)
		dispatch_group_enter(dispatchGroup)
		dispatch_group_enter(dispatchGroup)
		
		UIView.animateWithDuration(0.13, delay: 0, usingSpringWithDamping: 0.3, initialSpringVelocity: 10, options: UIViewAnimationOptions.CurveEaseOut, animations: {
			self.contentView.transform = CGAffineTransformMakeScale(1.1, 1.1)
			}, completion: {(Bool) in
				dispatch_group_leave(self.dispatchGroup)
				UIView.animateWithDuration(0.07, delay: 0.0, options: UIViewAnimationOptions.CurveLinear, animations: {
					self.alpha = 0.0
					}, completion: {(Bool) in dispatch_group_leave(self.dispatchGroup)})
				
				UIView.animateWithDuration(0.1, delay: 0, options: UIViewAnimationOptions.CurveLinear, animations: {
					self.contentView.transform = CGAffineTransformMakeScale(0.1, 0.1)
					}, completion: {(Bool) in dispatch_group_leave(self.dispatchGroup)})
		})
		
	}
	
	func scaleFromBottom()
	{
		var viewTransform:CGAffineTransform  = CGAffineTransformConcat(CGAffineTransformMakeScale(0.2, 0.2), CGAffineTransformMakeTranslation(0, 800))
		self.contentView.transform = viewTransform
		
		UIView.animateWithDuration(0.5, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
				self.alpha = 1.0
			}, completion: nil)
		
		UIView.animateWithDuration(0.6, delay: 0.1, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: UIViewAnimationOptions.CurveEaseIn, animations: {
			var viewTransform:CGAffineTransform  = CGAffineTransformConcat(CGAffineTransformMakeScale(1.0, 1.0), CGAffineTransformMakeTranslation(0, 10))
			self.contentView.transform = viewTransform
			}, completion: nil)
	}
	
	func dismissScaleFromBottom()
	{
		dispatch_group_enter(dispatchGroup)
		dispatch_group_enter(dispatchGroup)
		
		UIView.animateWithDuration(0.125, delay: 0, options: UIViewAnimationOptions.CurveEaseIn, animations:
			{
				self.alpha = 0.0
				self.contentView.transform = CGAffineTransformScale(self.contentView.transform, 0.25, 0.25)
			}, completion: {(Bool) in dispatch_group_leave(self.dispatchGroup)})
		
		UIView.animateWithDuration(0.15, delay: 0, options: UIViewAnimationOptions.CurveEaseIn, animations:
			{
			self.contentView.transform = CGAffineTransformTranslate(self.contentView.transform, 0, UIScreen.mainScreen().nativeBounds.size.height)
			}, completion: {(Bool) in dispatch_group_leave(self.dispatchGroup)})
	}
	
	func rotateAndTranslateFromLeft()
	{
		var viewTransform:CGAffineTransform = CGAffineTransformConcat(CGAffineTransformMakeRotation(CGFloat(M_PI)), CGAffineTransformMakeTranslation(-UIScreen.mainScreen().nativeBounds.size.width, self.contentView.bounds.origin.y))
		self.contentView.transform = viewTransform
		
		UIView.animateWithDuration(0.5, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
			self.alpha = 1.0
			}, completion: nil)
		
		UIView.animateWithDuration(0.6, delay: 0.1, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
			var viewTransform:CGAffineTransform = CGAffineTransformConcat(CGAffineTransformMakeRotation(CGFloat(M_PI) * 0.0/180.0), CGAffineTransformMakeTranslation(0, 0))
			self.contentView.transform = viewTransform
			}, completion: nil)
	}
	
	func dismissRotateAndTranslateFromLeft()
	{
		dispatch_group_enter(dispatchGroup)
		dispatch_group_enter(dispatchGroup)
		dispatch_group_enter(dispatchGroup)
		dispatch_group_enter(dispatchGroup)
		
		UIView.animateWithDuration(0.17, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 5, options: UIViewAnimationOptions.CurveEaseIn, animations: {
			// Scale down the view and rotate it 5 degrees counter clockwise
			var viewtransform:CGAffineTransform = CGAffineTransformConcat(CGAffineTransformMakeScale(0.8, 0.8), CGAffineTransformMakeRotation(CGFloat(M_PI) * -5.0/180.0))
			self.contentView.transform = viewtransform
			
			}, completion: {(Bool) in
				
				dispatch_group_leave(self.dispatchGroup)
				// Setting the rotation back to 0, makes the animation smoother
				self.contentView.transform = CGAffineTransformMakeRotation(CGFloat(M_PI) * 0.0/180.0)
				
				// The following animations are separated out in case there is a need in future to
				// change them individually
				UIView.animateWithDuration(0.3, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
					self.alpha = 0.0
					}, completion: {(Bool) in dispatch_group_leave(self.dispatchGroup)})
				
				UIView.animateWithDuration(0.3, delay: 0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
					self.contentView.transform = CGAffineTransformMakeRotation(CGFloat(M_PI))
					}, completion: {(Bool) in dispatch_group_leave(self.dispatchGroup)})
				
				// Sends the view off screen to the right
				UIView.animateWithDuration(0.3, delay: 0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
					self.contentView.transform = CGAffineTransformMakeTranslation(1600, 2100)
					}, completion: {(Bool) in dispatch_group_leave(self.dispatchGroup)})
			})
	}
	
}
