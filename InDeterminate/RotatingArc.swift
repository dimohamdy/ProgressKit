//
//  RotatingArc.swift
//  ProgressKit
//
//  Created by Kauntey Suryawanshi on 26/10/15.
//  Copyright © 2015 Kauntey Suryawanshi. All rights reserved.
//

import Foundation
import Cocoa

private let duration = 0.25

@IBDesignable
public class RotatingArc: NSView {

    @IBInspectable public var background: NSColor = NSColor(red: 0.345, green: 0.408, blue: 0.463, alpha: 1.0) {
        didSet {
            self.layer?.backgroundColor = background.CGColor
        }
    }

    @IBInspectable public var foreground: NSColor = NSColor(red: 0.26, green: 0.677, blue: 0.4156, alpha: 1.0) {
        didSet {
            arcLayer.strokeColor = foreground.CGColor
            backgroundCircle.strokeColor = foreground.colorWithAlphaComponent(0.4).CGColor
        }
    }

    @IBInspectable public var cornerRadius: CGFloat = 5.0 {
        didSet {
            self.layer?.cornerRadius = cornerRadius
        }
    }

    @IBInspectable public var strokeWidth: CGFloat = 5 {
        didSet {
            backgroundCircle.lineWidth = self.strokeWidth
            arcLayer.lineWidth = strokeWidth
        }
    }

    @IBInspectable public var arcLength: Int = 35 {
        didSet {
            let arcPath = NSBezierPath()
            let endAngle: CGFloat = CGFloat(-360) * CGFloat(arcLength) / 100
            arcPath.appendBezierPathWithArcWithCenter(self.bounds.mid, radius: radius, startAngle: 0, endAngle: endAngle, clockwise: true)

            arcLayer.path = arcPath.CGPath
        }
    }

    @IBInspectable public var clockWise: Bool = true {
        didSet {
            rotationAnimation.toValue = clockWise ? -1 : 1
        }
    }

    @IBInspectable public var displayAfterAnimationEnds: Bool = false

    var arcLayer = CAShapeLayer()
    var backgroundCircle = CAShapeLayer()

    var radius: CGFloat {
        return (self.frame.width / 2) * CGFloat(0.75)
    }

    public var animate: Bool = false {
        didSet {
            if animate {
                self.hidden = false
                startAnimation()
            } else {
                if !displayAfterAnimationEnds {
                    self.hidden = true
                }
                stopAnimation()
            }
        }
    }

    var rotationAnimation: CABasicAnimation = {
        var tempRotation = CABasicAnimation(keyPath: "transform.rotation")
        tempRotation.repeatCount = Float.infinity
        tempRotation.fromValue = 0
        tempRotation.toValue = 1
        tempRotation.cumulative = true
        tempRotation.duration = duration
        return tempRotation
        }()

    override public init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.configureLayers()
    }

    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        self.configureLayers()
    }

    func configureLayers() {
        self.wantsLayer = true

        let rect = self.bounds
        self.layer!.backgroundColor = background.CGColor
        self.layer!.cornerRadius = cornerRadius


        // Add background Circle
        do {
            backgroundCircle.frame = rect
            backgroundCircle.lineWidth = strokeWidth

            backgroundCircle.strokeColor = foreground.colorWithAlphaComponent(0.4).CGColor
            backgroundCircle.fillColor = NSColor.clearColor().CGColor
            let backgroundPath = NSBezierPath()
            backgroundPath.appendBezierPathWithArcWithCenter(rect.mid, radius: radius, startAngle: 0, endAngle: 360)
            backgroundCircle.path = backgroundPath.CGPath
            self.layer?.addSublayer(backgroundCircle)
        }

        // Arc Layer
        do {
            let arcPath = NSBezierPath()
            let endAngle: CGFloat = CGFloat(-360) * CGFloat(arcLength) / 100
            arcPath.appendBezierPathWithArcWithCenter(self.bounds.mid, radius: radius, startAngle: 0, endAngle: endAngle, clockwise: true)

            arcLayer.path = arcPath.CGPath

            arcLayer.fillColor = NSColor.clearColor().CGColor
            arcLayer.lineWidth = strokeWidth

            arcLayer.frame = rect
            arcLayer.strokeColor = foreground.CGColor
            self.layer?.addSublayer(arcLayer)
        }
    }

    func startAnimation() {
        arcLayer.addAnimation(rotationAnimation, forKey: "")
    }

    func stopAnimation() {
        arcLayer.removeAllAnimations()
    }
}
