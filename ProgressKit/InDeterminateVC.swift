//
//  WhatsAppCircular.swift
//  ProgressKit
//
//  Created by Kauntey Suryawanshi on 30/06/15.
//  Copyright (c) 2015 Kauntey Suryawanshi. All rights reserved.
//

import Foundation
import Cocoa

class InDeterminateViewController: NSViewController {

    override func viewDidAppear() {
        for view in self.view.subviews {
            (view as? RotatingArc)?.animate = true
            (view as? Spinner)?.animate = true
            (view as? ShootingStars)?.animate = true
            (view as? Crawler)?.animate = true
            (view as? Rainbow)?.animate = true
            (view as? CircularSnail)?.animate = true
        }
    }

    override func viewWillDisappear() {
        for view in self.view.subviews {
            (view as? RotatingArc)?.animate = false
            (view as? Spinner)?.animate = false
            (view as? ShootingStars)?.animate = false
            (view as? Crawler)?.animate = false
            (view as? Rainbow)?.animate = false
            (view as? CircularSnail)?.animate = false
        }
    }
}
