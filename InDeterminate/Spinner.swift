//
//  Spinner.swift
//  ProgressKit
//
//  Created by Kauntey Suryawanshi on 28/07/15.
//  Copyright (c) 2015 Kauntey Suryawanshi. All rights reserved.
//

import Foundation
import Cocoa

@IBDesignable
public class Spinner: NSView {

    private var basicShape = CAShapeLayer()
    private var containerLayer = CAShapeLayer()
    private var starList = [CAShapeLayer]()

    private var animation: CAKeyframeAnimation = {
        var animation = CAKeyframeAnimation(keyPath: "transform.rotation")
        animation.repeatCount = Float.infinity
        animation.calculationMode = kCAAnimationDiscrete
        return animation
        }()

    @IBInspectable public var background: NSColor = NSColor(red: 0.345, green: 0.408, blue: 0.463, alpha: 1.0) {
        didSet {
            self.layer?.backgroundColor = background.CGColor
        }
    }

    @IBInspectable public var foreground: NSColor = NSColor(red: 0.26, green: 0.677, blue: 0.4156, alpha: 1.0) {
        didSet {
            notifyViewRedesigned()
        }
    }

    @IBInspectable public var cornerRadius: CGFloat = 5.0 {
        didSet {
            self.layer?.cornerRadius = cornerRadius
        }
    }

    @IBInspectable public var starSize:CGSize = CGSize(width: 6, height: 15) {
        didSet {
            notifyViewRedesigned()
        }
    }

    @IBInspectable public var roundedCorners: Bool = true {
        didSet {
            notifyViewRedesigned()
        }
    }


    @IBInspectable public var distance: CGFloat = CGFloat(20) {
        didSet {
            notifyViewRedesigned()
        }
    }

    @IBInspectable public var starCount: Int = 10 {
        didSet {
            notifyViewRedesigned()
        }
    }

    @IBInspectable public var duration: Double = 1 {
        didSet {
            animation.duration = duration
        }
    }

    @IBInspectable public var clockwise: Bool = false {
        didSet {
            notifyViewRedesigned()
        }
    }

    /// View is hidden when *animate* property is false
    @IBInspectable public var displayAfterAnimationEnds: Bool = false

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

    private func notifyViewRedesigned() {
        starList.removeAll(keepCapacity: true)
        containerLayer.sublayers = nil
        animation.values = [Double]()

        for var i = 0.0; i < 360; i = i + Double(360 / starCount) {
            var iRadian = CGFloat(i * M_PI / 180.0)
            if clockwise { iRadian = -iRadian }

            animation.values?.append(iRadian)
            let starShape = CAShapeLayer()
            starShape.cornerRadius = roundedCorners ? starSize.width / 2 : 0

            let centerLocation = CGPoint(x: frame.width / 2 - starSize.width / 2, y: frame.width / 2 - starSize.height / 2)

            starShape.frame = CGRect(origin: centerLocation, size: starSize)

            starShape.backgroundColor = foreground.CGColor
            starShape.anchorPoint = CGPoint(x: 0.5, y: 0)

            var  rotation: CATransform3D = CATransform3DMakeTranslation(0, 0, 0.0);

            rotation = CATransform3DRotate(rotation, -iRadian, 0.0, 0.0, 1.0);
            rotation = CATransform3DTranslate(rotation, 0, distance, 0.0);
            starShape.transform = rotation

            starShape.opacity = Float(360 - i) / 360
            containerLayer.addSublayer(starShape)
            starList.append(starShape)
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
        self.layer?.backgroundColor = background.CGColor
        self.layer?.cornerRadius = cornerRadius

        containerLayer.frame = self.bounds
        containerLayer.cornerRadius = cornerRadius
        self.layer?.addSublayer(containerLayer)

        animation.duration = duration
    }

    private func startAnimation() {
        containerLayer.addAnimation(animation, forKey: "rotation")
    }

    private func stopAnimation() {
        containerLayer.removeAllAnimations()
    }
}
