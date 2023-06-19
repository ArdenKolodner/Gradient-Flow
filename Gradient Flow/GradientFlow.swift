//
//  GradientFlow.swift
//  Gradient Flow
//
//  Created by Arden Kolodner on 6/18/23.
//

import ScreenSaver

class Projectile {
    var position: CGPoint
    var velocity: CGVector
    var color: NSColor
    
    init(position: CGPoint, velocity: CGVector, color: NSColor) {
        self.position = position
        self.velocity = velocity
        self.color = color
    }
}

class GradientFlow: ScreenSaverView {
    private var projs: [Projectile]
    private var numProjs = 0
    private var minProjs = 2
    private var maxProjs = 4
    
    private var squareSize = 50
    
    private var perturbEveryNFrames = 120
    private var frameCount = 0
    
    private func randomColor() -> NSColor {
//        switch Int.random(in: 0 ... 5) {
//        case 0:
//            return NSColor.red
//        case 1:
//            return NSColor.blue
//        case 2:
//            return NSColor.green
//        case 3:
//            return NSColor.yellow
//        case 4:
//            return NSColor.orange
//        case 5:
//            return NSColor.purple
//        default:
//            return NSColor.white
//        }
        return NSColor(red: CGFloat.random(in: 0.3...1), green: CGFloat.random(in: 0.3...1), blue: CGFloat.random(in: 0.3...1), alpha: 1)
    }

    // MARK: - Initialization
    override init?(frame: NSRect, isPreview: Bool) {
        numProjs = Int.random(in: minProjs ... maxProjs)
        projs = []
        
        super.init(frame: frame, isPreview: isPreview)
        
        for _ in 0 ... numProjs-1 {
            projs.append(Projectile(
                position: CGPoint(x: frame.width / 2, y: frame.height / 2),
                velocity: initialVelocity(),
                color: randomColor()
            ))
        }
        
        print(numProjs)
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
            
            for i in 0 ... numProjs-1 {
                projs[i].velocity.dx += CGFloat.random(in: -1.0...1.0)
                projs[i].velocity.dy += CGFloat.random(in: -1.0...1.0)
            }
            
            projs[Int.random(in: 0 ... numProjs-1)].color = randomColor()
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
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        for i in 0 ... numProjs-1 {
            let d = distancePct(d: distanceBetweenPoints(p1: p, p2: projs[i].position))
            r += d * projs[i].color.redComponent
            g += d * projs[i].color.greenComponent
            b += d * projs[i].color.blueComponent
        }
        r /= CGFloat(numProjs)
        g /= CGFloat(numProjs)
        b /= CGFloat(numProjs)
        
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
        for i in 0 ... numProjs-1 {
            if projs[i].position.x + projs[i].velocity.dx > frame.width || projs[i].position.x + projs[i].velocity.dx < 0 {
                projs[i].velocity.dx *= -1
            }
            if projs[i].position.y + projs[i].velocity.dy > frame.height || projs[i].position.y + projs[i].velocity.dy < 0 {
                projs[i].velocity.dy *= -1
            }
            
            projs[i].position.x += projs[i].velocity.dx
            projs[i].position.y += projs[i].velocity.dy
        }
        
        setNeedsDisplay(bounds);
    }

}
