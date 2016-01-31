//
//  CircularView.swift
//  Animo
//
//  Created by Kauntey Suryawanshi on 29/06/15.
//  Copyright (c) 2015 Kauntey Suryawanshi. All rights reserved.
//

import Foundation
import Cocoa

@IBDesignable
public class CircularProgressView: NSView {

    private var backgroundCircle = CAShapeLayer()
    private var progressLayer = CAShapeLayer()
    private var percentLabelLayer = CATextLayer()

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
            backgroundCircle.strokeColor = foreground.colorWithAlphaComponent(0.5).CGColor
            progressLayer.strokeColor = foreground.CGColor
            percentLabelLayer.foregroundColor = foreground.CGColor
        }
    }

    @IBInspectable public var cornerRadius: CGFloat = 5.0 {
        didSet {
            self.layer?.cornerRadius = cornerRadius
        }
    }

    @IBInspectable public var animated: Bool = true

    /// Value of progress now. Range 0..100
    @IBInspectable public var progress: CGFloat = 0 {
        didSet {
            updateProgress()
        }
    }

    @IBInspectable public var strokeWidth: CGFloat = -1 {
        didSet {
            backgroundCircle.lineWidth = self.strokeWidth / 2
            progressLayer.lineWidth = strokeWidth
        }
    }

    @IBInspectable public var showPercent: Bool = true {
        didSet {
            percentLabelLayer.hidden = !showPercent
        }
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
        progressLayer.strokeEnd = max(0, min(progress / 100, 1))
        percentLabelLayer.string = "\(Int(progress))%"
        CATransaction.commit()
    }

     private func configureLayers() {
        self.wantsLayer = true
        let rect = self.bounds
        let radius = (rect.width / 2) * 0.75
        let strokeScalingFactor = CGFloat(0.05)

        self.layer?.backgroundColor = background.CGColor
        self.layer?.cornerRadius = cornerRadius

        // Add background Circle
        do {
            backgroundCircle.frame = rect
            backgroundCircle.lineWidth = strokeWidth == -1 ? (rect.width * strokeScalingFactor / 2) : strokeWidth / 2

            backgroundCircle.strokeColor = foreground.colorWithAlphaComponent(0.5).CGColor
            backgroundCircle.fillColor = NSColor.clearColor().CGColor
            let backgroundPath = NSBezierPath()
            backgroundPath.appendBezierPathWithArcWithCenter(rect.mid, radius: radius, startAngle: 0, endAngle: 360)
            backgroundCircle.path = backgroundPath.CGPath
            self.layer?.addSublayer(backgroundCircle)
        }

        // Progress Layer
        do {
            progressLayer.strokeEnd = 0 //REMOVe this
            progressLayer.fillColor = NSColor.clearColor().CGColor
            progressLayer.lineCap = kCALineCapRound
            progressLayer.lineWidth = strokeWidth == -1 ? (rect.width * strokeScalingFactor) : strokeWidth

            progressLayer.frame = rect
            progressLayer.strokeColor = foreground.CGColor
            let arcPath = NSBezierPath()
            let startAngle = CGFloat(90)
            arcPath.appendBezierPathWithArcWithCenter(rect.mid, radius: radius, startAngle: startAngle, endAngle: (startAngle - 360), clockwise: true)
            progressLayer.path = arcPath.CGPath
            self.layer?.addSublayer(progressLayer)
        }

        // Percentage Layer
        do {
            percentLabelLayer.hidden = !showPercent
            percentLabelLayer.string = "0%"
            percentLabelLayer.foregroundColor = foreground.CGColor
            percentLabelLayer.frame = rect
            percentLabelLayer.font = "Helvetica Neue Light"
            percentLabelLayer.alignmentMode = kCAAlignmentCenter
            percentLabelLayer.position.y = rect.midY * 0.25
            percentLabelLayer.fontSize = rect.width * 0.2
            self.layer?.addSublayer(percentLabelLayer)
        }
    }
}
