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

@IBDesignable
public class Rainbow: CircularSnail {

    @IBInspectable public var onLightOffDark: Bool = false

    override func configureLayers() {
        super.configureLayers()
        self.background = NSColor.clearColor()
    }

    override public func animationDidStop(anim: CAAnimation, finished flag: Bool) {
        super.animationDidStop(anim, finished: flag)
        if onLightOffDark {
            progressLayer.strokeColor = lightColorList[Int(arc4random()) % lightColorList.count].CGColor
        } else {
            progressLayer.strokeColor = darkColorList[Int(arc4random()) % darkColorList.count].CGColor
        }
    }
}

var randomColor: NSColor {
    let red   = CGFloat(Double(arc4random()) % 256.0 / 256.0)
    let green = CGFloat(Double(arc4random()) % 256.0 / 256.0)
    let blue  = CGFloat(Double(arc4random()) % 256.0 / 256.0)
    return NSColor(calibratedRed: red, green: green, blue: blue, alpha: 1.0)
}

private let lightColorList:[NSColor] = [
    NSColor(red: 0.9461, green: 0.6699, blue: 0.6243, alpha: 1.0),
    NSColor(red: 0.8625, green: 0.7766, blue: 0.8767, alpha: 1.0),
    NSColor(red: 0.6676, green: 0.6871, blue: 0.8313, alpha: 1.0),
    NSColor(red: 0.7263, green: 0.6189, blue: 0.8379, alpha: 1.0),
    NSColor(red: 0.8912, green: 0.9505, blue: 0.9971, alpha: 1.0),
    NSColor(red: 0.7697, green: 0.9356, blue: 0.9692, alpha: 1.0),
    NSColor(red: 0.3859, green: 0.7533, blue: 0.9477, alpha: 1.0),
    NSColor(red: 0.6435, green: 0.8554, blue: 0.8145, alpha: 1.0),
    NSColor(red: 0.8002, green: 0.936,  blue: 0.7639, alpha: 1.0),
    NSColor(red: 0.5362, green: 0.8703, blue: 0.8345, alpha: 1.0),
    NSColor(red: 0.9785, green: 0.8055, blue: 0.4049, alpha: 1.0),
    NSColor(red: 1.0,    green: 0.8667, blue: 0.6453, alpha: 1.0),
    NSColor(red: 0.9681, green: 0.677,  blue: 0.2837, alpha: 1.0),
    NSColor(red: 0.9898, green: 0.7132, blue: 0.1746, alpha: 1.0),
    NSColor(red: 0.8238, green: 0.84,   blue: 0.8276, alpha: 1.0),
    NSColor(red: 0.8532, green: 0.8763, blue: 0.883,  alpha: 1.0),
]

let darkColorList: [NSColor] = [
    NSColor(red: 0.9472, green: 0.2496, blue: 0.0488, alpha: 1.0),
    NSColor(red: 0.8098, green: 0.1695, blue: 0.0467, alpha: 1.0),
    NSColor(red: 0.853,  green: 0.2302, blue: 0.3607, alpha: 1.0),
    NSColor(red: 0.8152, green: 0.3868, blue: 0.5021, alpha: 1.0),
    NSColor(red: 0.96,   green: 0.277,  blue: 0.3515, alpha: 1.0),
    NSColor(red: 0.3686, green: 0.3069, blue: 0.6077, alpha: 1.0),
    NSColor(red: 0.5529, green: 0.3198, blue: 0.5409, alpha: 1.0),
    NSColor(red: 0.2132, green: 0.4714, blue: 0.7104, alpha: 1.0),
    NSColor(red: 0.1706, green: 0.2432, blue: 0.3106, alpha: 1.0),
    NSColor(red: 0.195,  green: 0.2982, blue: 0.3709, alpha: 1.0),
    NSColor(red: 0.0,    green: 0.3091, blue: 0.5859, alpha: 1.0),
    NSColor(red: 0.2261, green: 0.6065, blue: 0.3403, alpha: 1.0),
    NSColor(red: 0.1101, green: 0.5694, blue: 0.4522, alpha: 1.0),
    NSColor(red: 0.1716, green: 0.4786, blue: 0.2877, alpha: 1.0),
    NSColor(red: 0.8289, green: 0.33,   blue: 0.0,    alpha: 1.0),
    NSColor(red: 0.4183, green: 0.4842, blue: 0.5372, alpha: 1.0),
    NSColor(red: 0.0,    green: 0.0,    blue: 0.0,    alpha: 1.0),
]

