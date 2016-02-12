//
//  WhatsAppCircular.swift
//  ProgressKit
//
//  Created by Kauntey Suryawanshi on 30/06/15.
//  Copyright (c) 2015 Kauntey Suryawanshi. All rights reserved.
//

import Foundation
import Cocoa

private let duration = 1.5
private let strokeRange = (start: 0.0, end: 0.8)

@IBDesignable
public class CircularSnail: NSView {

    @IBInspectable public var background: NSColor = NSColor(red: 0.345, green: 0.408, blue: 0.463, alpha: 1.0) {
        didSet {
            self.layer?.backgroundColor = background.CGColor
        }
    }

    @IBInspectable public var foreground: NSColor = NSColor(red: 0.26, green: 0.677, blue: 0.4156, alpha: 1.0) {
        didSet {
            progressLayer.strokeColor = foreground.CGColor
        }
    }

    @IBInspectable public var cornerRadius: CGFloat = 5.0 {
        didSet {
            self.layer?.cornerRadius = cornerRadius
        }
    }

    /// View is hidden when *animate* property is false
    @IBInspectable public var displayAfterAnimationEnds: Bool = false

    /**
     Control point for all Indeterminate animation
     True invokes `startAnimation()` on subclass of IndeterminateAnimation
     False invokes `stopAnimation()` on subclass of IndeterminateAnimation
     */
    public var animate: Bool = false {
        didSet {
            guard animate != oldValue else {
                return
            }
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

    @IBInspectable public var lineWidth: CGFloat = -1 {
        didSet {
            progressLayer.lineWidth = lineWidth
        }
    }

    var backgroundRotationLayer = CAShapeLayer()

    var progressLayer: CAShapeLayer = {
        var tempLayer = CAShapeLayer()
        tempLayer.strokeEnd = CGFloat(strokeRange.end)
        tempLayer.lineCap = kCALineCapRound
        tempLayer.fillColor = NSColor.clearColor().CGColor
        return tempLayer
    }()

    //MARK: Animation Declaration
    private var animationGroup: CAAnimationGroup = {
        var tempGroup = CAAnimationGroup()
        tempGroup.repeatCount = 1
        tempGroup.duration = duration
        return tempGroup
    }()

    private var rotationAnimation: CABasicAnimation = {
        var tempRotation = CABasicAnimation(keyPath: "transform.rotation")
        tempRotation.repeatCount = Float.infinity
        tempRotation.fromValue = 0
        tempRotation.toValue = 1
        tempRotation.cumulative = true
        tempRotation.duration = duration / 2
        return tempRotation
        }()

    /// Makes animation for Stroke Start and Stroke End
    private func makeStrokeAnimationGroup() {
        var strokeStartAnimation: CABasicAnimation!
        var strokeEndAnimation: CABasicAnimation!

        func makeAnimationforKeyPath(keyPath: String) -> CABasicAnimation {
            let tempAnimation = CABasicAnimation(keyPath: keyPath)
            tempAnimation.repeatCount = 1
            tempAnimation.speed = 2.0
            tempAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)

            tempAnimation.fromValue = strokeRange.start
            tempAnimation.toValue =  strokeRange.end
            tempAnimation.duration = duration

            return tempAnimation
        }
        strokeEndAnimation = makeAnimationforKeyPath("strokeEnd")
        strokeStartAnimation = makeAnimationforKeyPath("strokeStart")
        strokeStartAnimation.beginTime = duration / 2
        animationGroup.animations = [strokeEndAnimation, strokeStartAnimation, ]
        animationGroup.delegate = self
    }

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

        makeStrokeAnimationGroup()
        let rect = self.bounds

        self.layer!.backgroundColor = background.CGColor
        self.layer!.cornerRadius = cornerRadius
        progressLayer.strokeColor = foreground.CGColor
        
        backgroundRotationLayer.frame = rect
        self.layer?.addSublayer(backgroundRotationLayer)

        // Progress Layer
        let radius = (rect.width / 2) * 0.75
        progressLayer.frame =  rect
        progressLayer.lineWidth = lineWidth == -1 ? radius / 10: lineWidth
        let arcPath = NSBezierPath()
        arcPath.appendBezierPathWithArcWithCenter(rect.mid, radius: radius, startAngle: 0, endAngle: 360, clockwise: false)
        progressLayer.path = arcPath.CGPath
        backgroundRotationLayer.addSublayer(progressLayer)
    }

    var currentRotation = 0.0
    let π2 = M_PI * 2
    override public func animationDidStop(anim: CAAnimation, finished flag: Bool) {
        if !animate { return }
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        currentRotation += strokeRange.end * π2
        currentRotation %= π2
        progressLayer.setAffineTransform(CGAffineTransformMakeRotation(CGFloat( currentRotation)))
        CATransaction.commit()
        progressLayer.addAnimation(animationGroup, forKey: "strokeEnd")
    }

    func startAnimation() {
        progressLayer.addAnimation(animationGroup, forKey: "strokeEnd")
        backgroundRotationLayer.addAnimation(rotationAnimation, forKey: rotationAnimation.keyPath)
    }

    func stopAnimation() {
        backgroundRotationLayer.removeAllAnimations()
        progressLayer.removeAllAnimations()
    }
}
