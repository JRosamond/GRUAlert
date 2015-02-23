//
//  ViewController.swift
//  GRUCustomAlert
//
//  Created by jrosamond on 2/2/15.
//  Copyright (c) 2015 Georgia Regents University. All rights reserved.
//

import UIKit
import GRUAlert

class ViewController: UIViewController, GRUAlertViewDelegate
{
	@IBOutlet weak var gruAlert: GRUAlertView!
	
	override func viewDidLoad()
	{
		super.viewDidLoad()
		
		gruAlert.delegate = self
		
		gruAlert.setAlertMessageFont(UIFont(name: "HelveticaNeue", size: 20.0)!)
		gruAlert.setButtonLabelFont(UIFont(name: "Helvetica", size: 18.0)!)
	}

	@IBAction func showAlert(sender: UIButton)
	{
		switch sender.tag
		{
		case 0:
			gruAlert.show(animationKey: GRUAlertView.AnimationKeys.scaleFromCenter)
			
		case 1:
			gruAlert.show(animationKey: GRUAlertView.AnimationKeys.scaleFromBottom)
			
		case 2:
			gruAlert.show(animationKey: GRUAlertView.AnimationKeys.rotateAndTranslateFromLeft)
			
		default:
			gruAlert.show(animationKey: GRUAlertView.AnimationKeys.scaleFromCenter)
		}
	}
	
	// MARK: GRUAlertViewDelegate Methods
	
	func handleDefaultAlertAction()
	{
		performSegueWithIdentifier("segueToVC", sender: self)
	}

	
	
	@IBAction func unwindToRoot(unwindSegue: UIStoryboardSegue)
	{
		println("Unwind")
		
	}
}

