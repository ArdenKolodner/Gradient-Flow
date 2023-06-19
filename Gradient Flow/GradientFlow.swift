//
//  GradientFlow.swift
//  Gradient Flow
//
//  Created by Arden Kolodner on 6/18/23.
//

import ScreenSaver

class GradientFlow: ScreenSaverView {
    private var redPos: [CGPoint]
    private var greenPos: [CGPoint]
    private var bluePos: [CGPoint]
    
    private var redVel: [CGVector]
    private var greenVel: [CGVector]
    private var blueVel: [CGVector]
    
    //private var numProjsPerColor = 2
    private var numRed: Int
    private var numGreen: Int
    private var numBlue: Int
    
    private var squareSize = 50
    
    private var perturbEveryNFrames = 120
    private var frameCount = 0
    
    // MARK: - Initialization
    override init?(frame: NSRect, isPreview: Bool) {
        redPos = []
        greenPos = []
        bluePos = []
        redVel = []
        greenVel = []
        blueVel = []
        
        numRed = Int.random(in: 0 ... 2)
        numGreen = Int.random(in: 0 ... 2)
        numBlue = Int.random(in: 0 ... 2)
        
        print("r: " + String(numRed))
        print("g: " + String(numGreen))
        print("b: " + String(numBlue))
        
        super.init(frame: frame, isPreview: isPreview)
        
        if numRed > 0 {
            for _ in 1 ... numRed {
                redPos.append(CGPoint(x: frame.width / 2, y: frame.height / 2))
                redVel.append(initialVelocity())
            }
        }
        
        if numGreen > 0 {
            for _ in 1 ... numGreen {
                greenPos.append(CGPoint(x: frame.width / 2, y: frame.height / 2))
                greenVel.append(initialVelocity())
            }
        }
        
        if numBlue > 0 {
            for _ in 1 ... numBlue {
                bluePos.append(CGPoint(x: frame.width / 2, y: frame.height / 2))
                blueVel.append(initialVelocity())
            }
        }
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
            
            if numRed > 0 {
                for i in 0 ... numRed-1 {
                    redVel[i].dx += CGFloat.random(in: -1.0...1.0)
                    redVel[i].dy += CGFloat.random(in: -1.0...1.0)
                }
            }
            if numGreen > 0 {
                for i in 0 ... numGreen-1 {
                    greenVel[i].dx += CGFloat.random(in: -1.0...1.0)
                    greenVel[i].dy += CGFloat.random(in: -1.0...1.0)
                }
            }
            if numBlue > 0 {
                for i in 0 ... numBlue-1 {
                    blueVel[i].dx += CGFloat.random(in: -1.0...1.0)
                    blueVel[i].dy += CGFloat.random(in: -1.0...1.0)
                }
            }
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
        
        if numRed > 0 {
            for i in 0 ... numRed-1 {
                r += distancePct(d: distanceBetweenPoints(p1: p, p2: redPos[i]))
            }
            r /= CGFloat(numRed)
        }
        if numGreen > 0 {
            for i in 0 ... numGreen-1 {
                g += distancePct(d: distanceBetweenPoints(p1: p, p2: greenPos[i]))
            }
            g /= CGFloat(numGreen)
        }
        if numBlue > 0 {
            for i in 0 ... numBlue-1 {
                b += distancePct(d: distanceBetweenPoints(p1: p, p2: bluePos[i]))
            }
            b /= CGFloat(numBlue)
        }
        
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
        
        if numRed != 0 {
            for i in 0 ... numRed-1 {
                if redPos[i].x + redVel[i].dx > frame.width || redPos[i].x + redVel[i].dx < 0 {
                    redVel[i].dx *= -1
                }
                if redPos[i].y + redVel[i].dy > frame.height || redPos[i].y + redVel[i].dy < 0 {
                    redVel[i].dy *= -1
                }
            }
        }
        
        if numBlue != 0 {
            for i in 0 ... numBlue-1 {
                if bluePos[i].x + blueVel[i].dx > frame.width || bluePos[i].x + blueVel[i].dx < 0 {
                    blueVel[i].dx *= -1
                }
                if bluePos[i].y + blueVel[i].dy > frame.height || bluePos[i].y + blueVel[i].dy < 0 {
                    blueVel[i].dy *= -1
                }
            }
        }
        
        if numGreen != 0 {
            for i in 0 ... numGreen-1 {
                if greenPos[i].x + greenVel[i].dx > frame.width || greenPos[i].x + greenVel[i].dx < 0 {
                    greenVel[i].dx *= -1
                }
                if greenPos[i].y + greenVel[i].dy > frame.height || greenPos[i].y + greenVel[i].dy < 0 {
                    greenVel[i].dy *= -1
                }
            }
        }
            
        if numRed != 0 {
            for i in 0 ... numRed-1 {
                redPos[i].x += redVel[i].dx
                redPos[i].y += redVel[i].dy
            }
        }
        if numBlue != 0 {
            for i in 0 ... numBlue-1 {
                bluePos[i].x += blueVel[i].dx
                bluePos[i].y += blueVel[i].dy
            }
        }
        if numGreen != 0 {
            for i in 0 ... numGreen-1 {
                greenPos[i].x += greenVel[i].dx
                greenPos[i].y += greenVel[i].dy
            }
        }
        
        setNeedsDisplay(bounds);
    }

}
