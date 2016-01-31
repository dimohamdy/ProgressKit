//
//  ProgressBar.swift
//  ProgressKit
//
//  Created by Kauntey Suryawanshi on 31/07/15.
//  Copyright (c) 2015 Kauntey Suryawanshi. All rights reserved.
//

import Foundation
import Cocoa

@IBDesignable
public class ProgressBar: NSView {

    private var borderLayer = CAShapeLayer()
    private var progressLayer = CAShapeLayer()

    override public init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.configureLayers()
    }

    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        self.configureLayers()
    }

    @IBInspectable public var background: NSColor = NSColor(red: 0.345, green: 0.408, blue: 0.463, alpha: 1.0) {
        didSet {
            self.layer?.backgroundColor = background.CGColor
        }
    }

    @IBInspectable public var foreground: NSColor = NSColor(red: 0.26, green: 0.677, blue: 0.4156, alpha: 1.0) {
        didSet {
            progressLayer.backgroundColor = foreground.CGColor
        }
    }

    @IBInspectable public var animated: Bool = true

    /// Value of progress now. Range 0..100
    @IBInspectable public var progress: CGFloat = 0 {
        didSet {
            updateProgress()
        }
    }

    @IBInspectable public var borderColor: NSColor = NSColor.blackColor() {
        didSet {
            borderLayer.borderColor = borderColor.CGColor
        }
    }

    private func configureLayers() {
        self.wantsLayer = true
        self.layer?.cornerRadius = self.frame.height / 2
        borderLayer.frame = self.bounds
        borderLayer.cornerRadius = borderLayer.frame.height / 2
        borderLayer.borderWidth = 1.0
        self.layer?.addSublayer(borderLayer)

        progressLayer.frame = NSInsetRect(borderLayer.bounds, 3, 3)
        progressLayer.frame.size.width = (borderLayer.bounds.width - 6)
        progressLayer.cornerRadius = progressLayer.frame.height / 2
        progressLayer.backgroundColor = foreground.CGColor
        borderLayer.addSublayer(progressLayer)

    }

    private func updateProgress() {
        CATransaction.begin()
        if animated {
            CATransaction.setAnimationDuration(0.5)
        } else {
            CATransaction.setDisableActions(true)
        }
        let timing = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        CATransaction.setAnimationTimingFunction(timing)
        progressLayer.frame.size.width = (borderLayer.bounds.width - 6) * (progress / 100)
        CATransaction.commit()
    }
}
