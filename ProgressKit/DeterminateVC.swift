//
//  ViewController.swift
//  ProgressKit
//
//  Created by Kauntey Suryawanshi on 30/06/15.
//  Copyright (c) 2015 Kauntey Suryawanshi. All rights reserved.
//

import Cocoa

class DeterminateViewController: NSViewController {

    dynamic var labelPercentage: String = "30%"

    override func viewDidLoad() {
        preferredContentSize = NSMakeSize(500, 300)
    }

    @IBAction func sliderDragged(sender: NSSlider) {
        self.updateProgress(CGFloat(sender.floatValue))
        labelPercentage = "\(Int(sender.floatValue))%"
    }

    func updateProgress(progress: CGFloat) {
        for view in self.view.subviews {
            if view is CircularProgressView {
                (view as! CircularProgressView).progress = progress
            }
            if view is ProgressBar {
                (view as! ProgressBar).progress = progress
            }
        }
    }
}

