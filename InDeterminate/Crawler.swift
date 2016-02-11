//
//  Crawler.swift
//  ProgressKit
//
//  Created by Kauntey Suryawanshi on 11/07/15.
//  Copyright (c) 2015 Kauntey Suryawanshi. All rights reserved.
//

import Foundation
import Cocoa

@IBDesignable
public class Crawler: NSView {
    private let duration = 1.2

    @IBInspectable public var background: NSColor = NSColor(red: 0.345, green: 0.408, blue: 0.463, alpha: 1.0) {
        didSet {
            self.layer?.backgroundColor = background.CGColor
        }
    }

    @IBInspectable public var foreground: NSColor = NSColor(red: 0.26, green: 0.677, blue: 0.4156, alpha: 1.0) {
        didSet {
            for star in starList {
                star.backgroundColor = foreground.CGColor
            }
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

    private var starList = [CAShapeLayer]()

    private var smallCircleSize: Double {
        return Double(self.bounds.width) * 0.2
    }

    private var animationGroups = [CAAnimation]()

    override public init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.configureLayers()
    }

    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        self.configureLayers()
    }

    private func configureLayers() {
        self.wantsLayer = true
        self.layer?.backgroundColor = background.CGColor
        self.layer?.cornerRadius = cornerRadius

        let rect = self.bounds
        let insetRect = NSInsetRect(rect, rect.width * 0.15, rect.width * 0.15)

        for var i = 0.0; i < 5; i++ {
            let starShape = CAShapeLayer()
            starList.append(starShape)
            starShape.backgroundColor = foreground.CGColor

            let circleWidth = smallCircleSize - i * 2
            starShape.bounds = CGRect(x: 0, y: 0, width: circleWidth, height: circleWidth)
            starShape.cornerRadius = CGFloat(circleWidth / 2)
            starShape.position = CGPoint(x: rect.midX, y: rect.midY + insetRect.height / 2)
            self.layer?.addSublayer(starShape)

            let arcPath = NSBezierPath()
            arcPath.appendBezierPathWithArcWithCenter(insetRect.mid, radius: insetRect.width / 2, startAngle: 90, endAngle: -360 + 90, clockwise: true)

            let rotationAnimation = CAKeyframeAnimation(keyPath: "position")
            rotationAnimation.path = arcPath.CGPath
            rotationAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
            rotationAnimation.beginTime = (duration * 0.075) * i
            rotationAnimation.calculationMode = kCAAnimationCubicPaced

            let animationGroup = CAAnimationGroup()
            animationGroup.animations = [rotationAnimation]
            animationGroup.duration = duration
            animationGroup.repeatCount = Float.infinity
            animationGroups.append(animationGroup)

        }
    }

    private func startAnimation() {
        for (index, star) in starList.enumerate() {
            star.addAnimation(animationGroups[index], forKey: "")
        }
    }

    private func stopAnimation() {
        for star in starList {
            star.removeAllAnimations()
        }
    }
}

