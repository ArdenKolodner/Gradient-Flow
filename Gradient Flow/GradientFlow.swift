//
//  GradientFlow.swift
//  Gradient Flow
//
//  Created by Arden Kolodner on 6/18/23.
//

import ScreenSaver

class GradientFlow: ScreenSaverView {
    private var redPos: CGPoint = .zero
    private var greenPos: CGPoint = .zero
    private var bluePos: CGPoint = .zero
    
    private var redVel: CGVector = .zero
    private var greenVel: CGVector = .zero
    private var blueVel: CGVector = .zero
    
    private var squareSize = 50
    
    private var perturbEveryNFrames = 120
    private var frameCount = 0

    // MARK: - Initialization
    override init?(frame: NSRect, isPreview: Bool) {
        super.init(frame: frame, isPreview: isPreview)
        redPos = CGPoint(x: frame.width / 2, y: frame.height / 2)
        greenPos = CGPoint(x: frame.width / 2, y: frame.height / 2)
        bluePos = CGPoint(x: frame.width / 2, y: frame.height / 2)
        
        redVel = initialVelocity()
        greenVel = initialVelocity()
        blueVel = initialVelocity()
    }
    
    private func initialVelocity() -> CGVector {
        let desiredVelocityMagnitude: CGFloat = 15
        let xVelocity = CGFloat.random(in: 5.5...10.5)
        let xSign: CGFloat = Bool.random() ? 1 : -1
        let yVelocity = sqrt(pow(desiredVelocityMagnitude, 2) - pow(xVelocity, 2))
        let ySign: CGFloat = Bool.random() ? 1 : -1
        return CGVector(dx: xVelocity * xSign, dy: yVelocity * ySign)
    }

    @available(*, unavailable)
    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle
    override func draw(_ rect: NSRect) {
        // Draw a single frame in this function
        for x in 0...Int(frame.width)/squareSize {
            for y in 0...Int(frame.height)/squareSize {
                let pxRect = NSRect(x: x * squareSize, y: y * squareSize, width: squareSize, height: squareSize)
                let pxPath = NSBezierPath(rect: pxRect)
                
                colorAt(p: CGPoint(x: x * squareSize, y: y * squareSize)).setFill()
                pxPath.fill()
            }
        }
        
        frameCount += 1
        if frameCount >= perturbEveryNFrames {
            frameCount = 0
            
            redVel.dx += CGFloat.random(in: -1.0...1.0)
            redVel.dy += CGFloat.random(in: -1.0...1.0)
            greenVel.dx += CGFloat.random(in: -1.0...1.0)
            greenVel.dy += CGFloat.random(in: -1.0...1.0)
            blueVel.dx += CGFloat.random(in: -1.0...1.0)
            blueVel.dy += CGFloat.random(in: -1.0...1.0)
        }
        
//        let ballRect = NSRect(x: redPos.x,
//                              y: redPos.y,
//                                  width: 10,
//                                  height: 10)
//            let ball = NSBezierPath(roundedRect: ballRect,
//                                    xRadius: 5,
//                                    yRadius: 5)
//            NSColor.black.setFill()
//            ball.fill()
    }
    
    func colorAt(p: CGPoint) -> NSColor {
        let r = distancePct(d: distanceBetweenPoints(p1: p, p2: redPos))
        let g = distancePct(d: distanceBetweenPoints(p1: p, p2: greenPos))
        let b = distancePct(d: distanceBetweenPoints(p1: p, p2: bluePos))
        
        return NSColor(red: r, green: g, blue: b, alpha: 1)
    }
    
    func distanceBetweenPoints(p1: CGPoint, p2: CGPoint) -> CGFloat {
        return sqrt(pow(p1.x - p2.x, 2) + pow(p1.y - p2.y, 2))
    }
    
    // Given a distance, what percent is it of the max possible distance (length of diagonal of frame)
    func distancePct(d: CGFloat) -> CGFloat {
        return 1 - d / sqrt(pow(frame.height, 2) + pow(frame.width, 2))
    }

    override func animateOneFrame() {
        super.animateOneFrame()

        // Update the "state" of the screensaver in this function
        if redPos.x + redVel.dx > frame.width || redPos.x + redVel.dx < 0 {
            redVel.dx *= -1
        }
        if redPos.y + redVel.dy > frame.height || redPos.y + redVel.dy < 0 {
            redVel.dy *= -1
        }
        
        if bluePos.x + blueVel.dx > frame.width || bluePos.x + blueVel.dx < 0 {
            blueVel.dx *= -1
        }
        if bluePos.y + blueVel.dy > frame.height || bluePos.y + blueVel.dy < 0 {
            blueVel.dy *= -1
        }
        
        if greenPos.x + greenVel.dx > frame.width || greenPos.x + greenVel.dx < 0 {
            greenVel.dx *= -1
        }
        if greenPos.y + greenVel.dy > frame.height || greenPos.y + greenVel.dy < 0 {
            greenVel.dy *= -1
        }
        
        redPos.x += redVel.dx
        redPos.y += redVel.dy
        bluePos.x += blueVel.dx
        bluePos.y += blueVel.dy
        greenPos.x += greenVel.dx
        greenPos.y += greenVel.dy
        
        setNeedsDisplay(bounds);
    }

}
