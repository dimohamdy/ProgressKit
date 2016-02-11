//
//  ShootingStars.swift
//  ProgressKit
//
//  Created by Kauntey Suryawanshi on 09/07/15.
//  Copyright (c) 2015 Kauntey Suryawanshi. All rights reserved.
//

import Foundation
import Cocoa

@IBDesignable
public class ShootingStars: NSView {
    private let animationDuration = 1.0

    private var starLayer1 = CAShapeLayer()
    private var starLayer2 = CAShapeLayer()
    private var animation = CABasicAnimation(keyPath: "position.x")
    private var tempAnimation = CABasicAnimation(keyPath: "position.x")

    @IBInspectable public var background: NSColor = NSColor(red: 0.345, green: 0.408, blue: 0.463, alpha: 1.0) {
        didSet {
            self.layer?.backgroundColor = background.CGColor
        }
    }

    @IBInspectable public var starColor: NSColor = NSColor(red: 0.26, green: 0.677, blue: 0.4156, alpha: 1.0) {
        didSet {
            starLayer1.backgroundColor = starColor.CGColor
            starLayer2.backgroundColor = starColor.CGColor
        }
    }

    /// View is hidden when *animate* property is false
    @IBInspectable public var displayAfterAnimationEnds: Bool = false

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
        
        self.layer!.backgroundColor = background.CGColor
        self.layer!.cornerRadius = 0

        let rect = self.bounds
        let dimension = rect.height
        let starWidth = dimension * 1.5

        /// Add Stars
        do {
            starLayer1.position = CGPoint(x: dimension / 2, y: dimension / 2)
            starLayer1.bounds.size = CGSize(width: starWidth, height: dimension)
            starLayer1.backgroundColor = starColor.CGColor
            self.layer?.addSublayer(starLayer1)
            
            starLayer2.position = CGPoint(x: rect.midX, y: dimension / 2)
            starLayer2.bounds.size = CGSize(width: starWidth, height: dimension)
            starLayer2.backgroundColor = starColor.CGColor
            self.layer?.addSublayer(starLayer2)
        }
        
        /// Add default animation
        do {
            animation.fromValue = -dimension
            animation.toValue = rect.width * 0.9
            animation.duration = animationDuration
            animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
            animation.removedOnCompletion = false
            animation.repeatCount = Float.infinity
        }
        
        /** Temp animation will be removed after first animation
            After finishing it will invoke animationDidStop and starLayer2 is also given default animation.
        The purpose of temp animation is to generate an temporary offset
        */
        tempAnimation.fromValue = rect.midX
        tempAnimation.toValue = rect.width
        tempAnimation.delegate = self
        tempAnimation.duration = animationDuration / 2
        tempAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
    }
    
    override public func animationDidStop(anim: CAAnimation, finished flag: Bool) {
        starLayer2.addAnimation(animation, forKey: "default")
    }
    
    private func startAnimation() {
        starLayer1.addAnimation(animation, forKey: "default")
        starLayer2.addAnimation(tempAnimation, forKey: "tempAnimation")
    }
    
    private func stopAnimation() {
        starLayer1.removeAllAnimations()
        starLayer2.removeAllAnimations()
    }
}
