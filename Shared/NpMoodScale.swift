//
//  NpMoodScale.swift
//  DrLullaby
//
//  Created by Nilesh Phadtare on 01/08/19.
//  Copyright © 2019 Medsolis. All rights reserved.
//

import Foundation
import UIKit

protocol NpMoodScaleDelegate: class {
    func didValueChange(value: Float)
    func didEndSliding(value: Float)
}
@IBDesignable class NpMoodScale: UIView, CAAnimationDelegate {
    
    var fillSliderColor: UIColor = .white { didSet { setNeedsDisplay() } }
    var emptySliderColor: UIColor = UIColor.white.withAlphaComponent(0.6) { didSet { setNeedsDisplay() } }
    var thumbColor: UIColor = .white { didSet { setNeedsDisplay() } }
    var thumbInnerColor: UIColor? { didSet { setNeedsDisplay() } }

    var slideInterval: Float = 1
    var dotWidth = 5 { didSet { setNeedsDisplay() } }
    var barWidth: CGFloat = 10 { didSet { setNeedsDisplay() } }
    var image: UIImage? { didSet { setNeedsDisplay() } }
    weak var delegate: NpMoodScaleDelegate?
    var sliderMaximumValue: Float = 5 {
        didSet {
            slider.maximumValue = sliderMaximumValue - 1
            setNeedsDisplay()
        }
    }
    var slider: UISlider! {
        didSet {
            slider.minimumTrackTintColor = .clear
            slider.maximumTrackTintColor = .clear
            slider.thumbTintColor = .clear
        }
    }
    var sliderValue: CGFloat = 1 {
        didSet {
            slider.value = Float(sliderValue)
            var xpos = Int(((self.frame.size.width)/CGFloat(self.sliderMaximumValue-1))) * Int(slider.value)
            if xpos < 30 {
                xpos = 30
            }
            if xpos > Int(self.frame.size.width - 20) {
                xpos = Int(self.frame.size.width - 20)
            }
            if sliderValue == 1, sliderMaximumValue == 5 {
                xpos = xpos + 15
            }
            if sliderValue == 3, sliderMaximumValue == 5 {
                xpos = xpos - 5
            }
            if sliderMaximumValue == 10, sliderValue < 5 {
                xpos = xpos + 10
            }
            if sliderMaximumValue == 10, sliderValue > 5 {
                xpos = xpos - 8
            }
            if sliderValue == 0 && sliderMaximumValue == 10 {
                xpos = xpos - 6
            }
            
            controlPoint = CGPoint(x: xpos, y: Int(yPos-9))
            setNeedsDisplay()
        }
    }
    
    var yPos: CGFloat = 20 {
        didSet {
            yPos = CGFloat(self.frame.size.height/2)
        }
    }
    var controlPoint = CGPoint.zero
    var isAnimate = false
    func roundValue(value: Float) -> String {
        let newValue  = round(value / slideInterval) * slideInterval
        return newValue.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", newValue) : String(format: "%.1f", newValue)
    }
    
    func roundValueInt(value: Float) -> Int {
        let newValue  = round(value / slideInterval) * slideInterval
        return Int(newValue)
    }
    
    override init(frame: CGRect) {
        var newRect  = frame
        if frame.height < 80 {
            newRect.size.height = 80
        }
        super.init(frame: newRect)
        setupUI()
        self.backgroundColor = .clear
        controlPoint = CGPoint(x: 20, y: yPos)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
        self.backgroundColor = .clear
        controlPoint = CGPoint(x: 20, y: yPos)
        //fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect)  {
        super.draw(rect)
        
        if let allLayers = layer.sublayers {
            for sublayer in allLayers {
                if sublayer.isKind(of: UIBezierPath.self) ||  sublayer.isKind(of: CAShapeLayer.self){
                    sublayer.removeFromSuperlayer()
                }
            }
        }
        self.backgroundColor = .clear
        let start = CGPoint(x: 20, y: yPos)
        let end = CGPoint(x: self.frame.size.width-20, y: yPos)
        let path = UIBezierPath()
        path.move(to: start)
        
        let fillEndPoint = CGPoint(x: controlPoint.x, y: yPos)
        path.addLine(to: fillEndPoint)
        let fillEndPoint1 = CGPoint(x: controlPoint.x, y: yPos+barWidth)
        path.addLine(to: fillEndPoint1)
        let startPoint = CGPoint(x: 20, y: yPos+barWidth)
        path.addLine(to: startPoint)
        let controlPoint1 = CGPoint(x: (barWidth/1.2), y: yPos+(barWidth/2))
        path.addQuadCurve(to: start, controlPoint: controlPoint1)
        
        let path1 = UIBezierPath()
        path1.move(to: fillEndPoint)
        path1.addLine(to: end)
        let fillEndPoint2 = CGPoint(x: self.frame.size.width-20, y: yPos+barWidth)
        let controlPoint2 = CGPoint(x: self.frame.size.width-(barWidth/1.2), y: yPos+(barWidth/2))
        path1.addQuadCurve(to: fillEndPoint2, controlPoint: controlPoint2)
        path1.addLine(to: fillEndPoint1)
        path1.addLine(to: fillEndPoint)
        
        //design path in layer
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.lineWidth = 2.0
        shapeLayer.strokeColor = fillSliderColor.cgColor
        shapeLayer.fillColor = fillSliderColor.cgColor
        self.layer.addSublayer(shapeLayer)
        
        let shapeLayer1 = CAShapeLayer()
        shapeLayer1.path = path1.cgPath
        shapeLayer1.lineWidth = 2.0
        shapeLayer1.strokeColor = emptySliderColor.cgColor
        shapeLayer1.fillColor = emptySliderColor.cgColor
        self.layer.addSublayer(shapeLayer1)
        
        
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: controlPoint.x, y: yPos+(barWidth/2)), radius: CGFloat(20), startAngle: CGFloat(0), endAngle:CGFloat(Double.pi * 2), clockwise: true)
        let shapeLayerCircle = CAShapeLayer()
        shapeLayerCircle.path = circlePath.cgPath
        
        shapeLayerCircle.fillColor = thumbColor.cgColor
        shapeLayerCircle.strokeColor = thumbColor.cgColor
        shapeLayerCircle.lineWidth = 2.0//(UI_USER_INTERFACE_IDIOM() == .pad) ? 3.0 : 2.0
        shapeLayerCircle.shadowColor = UIColor.lightGray.cgColor
        shapeLayerCircle.shadowOpacity = 1.0
        shapeLayerCircle.shadowOffset = CGSize(width:-2, height: 2)
        shapeLayerCircle.shadowRadius = 2.0
        self.layer.addSublayer(shapeLayerCircle)
        
        let innerCirclePath = UIBezierPath(arcCenter: CGPoint(x: controlPoint.x, y: yPos+(barWidth/2)), radius: CGFloat(9), startAngle: CGFloat(0), endAngle:CGFloat(Double.pi * 2), clockwise: true)
        let innerShapeLayerCircle = CAShapeLayer()
        innerShapeLayerCircle.path = innerCirclePath.cgPath
        var color = thumbColor
        if thumbInnerColor != nil {
            color = thumbInnerColor ?? .white
        }
        innerShapeLayerCircle.fillColor = color.cgColor
        innerShapeLayerCircle.strokeColor = color.cgColor
        innerShapeLayerCircle.lineWidth = 1.0//(UI_USER_INTERFACE_IDIOM() == .pad) ? 3.0 : 2.0
        shapeLayerCircle.addSublayer(innerShapeLayerCircle)

        setupUI()
        var xPos = 25
        let value = Int(self.sliderMaximumValue)
        for i in (0..<value) {
            let shapeLayerdot = CAShapeLayer()
            if let img = image {
                shapeLayerdot.fillColor = UIColor.clear.cgColor
                shapeLayerdot.strokeColor = UIColor.clear.cgColor
                if sliderValue >= CGFloat(i) {
                    shapeLayerdot.contents = img.cgImage
                } else {
                    shapeLayerdot.contents = img.cgImage
                }
                shapeLayerdot.fillColor = UIColor.red.cgColor
                shapeLayerdot.bounds = CGRect(x: xPos + Int(rect.size.width), y: Int(yPos+50), width: dotWidth*2, height: dotWidth*2)
                shapeLayerdot.position = CGPoint(x: xPos, y: Int(yPos+50))

            } else {
                let circlePath1 = UIBezierPath(roundedRect: CGRect(x: xPos, y: Int(yPos+50), width: dotWidth, height: dotWidth), cornerRadius: CGFloat(dotWidth/2))
                shapeLayerdot.path = circlePath1.cgPath

                if sliderValue >= CGFloat(i) {
                    shapeLayerdot.fillColor = thumbColor.cgColor
                    shapeLayerdot.strokeColor = thumbColor.cgColor
                } else {
                    shapeLayerdot.fillColor = thumbColor.withAlphaComponent(0.6).cgColor
                    shapeLayerdot.strokeColor = thumbColor.withAlphaComponent(0.6).cgColor
                }
            }
            xPos =  xPos +  Int((self.frame.size.width-50)/CGFloat(self.sliderMaximumValue-1))
            self.layer.addSublayer(shapeLayerdot)
        }
        
        var sliderFrame = self.frame
        sliderFrame.origin.x = 0
        sliderFrame.origin.y = yPos-CGFloat((slider.currentThumbImage?.size.height)!)+barWidth
        sliderFrame.size.width = self.frame.size.width-10
        slider.frame = sliderFrame
    }
    
    func setupUI() {
        if slider == nil {
            var sliderFrame = self.frame
            sliderFrame.origin.x = 20
            sliderFrame.size.width = self.frame.size.width-15
            slider = UISlider(frame: sliderFrame)
            sliderFrame.origin.y = yPos-CGFloat((slider.currentThumbImage?.size.height)!)+5
            slider.frame = sliderFrame
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(sliderTapped(gestureRecognizer:)))
            self.slider.addGestureRecognizer(tapGestureRecognizer)
            slider.addTarget(self, action: #selector(sliderValueChange(sender:)), for: .valueChanged)
            slider.addTarget(self, action: #selector(sliderDidEndSliding(_:)), for: ([.touchUpInside,.touchUpOutside]))
            slider.minimumValue = 0
            self.addSubview(slider)
        }
    }
    
    @objc func sliderDidEndSliding(_ notification: NSNotification?){
        let value = Float(roundValue(value: slider.value))
        let xpos = Int(((self.frame.size.width-25)/CGFloat(self.sliderMaximumValue))) * Int(value ?? 0)
        controlPoint.x = CGFloat(xpos)
        sliderValue = CGFloat(value ?? 0)
        delegate?.didEndSliding(value: value ?? 0)
        setNeedsDisplay()
    }
    
    @objc func sliderTapped(gestureRecognizer: UIGestureRecognizer) {
        let pointTapped: CGPoint = gestureRecognizer.location(in: self)
        let positionOfSlider: CGPoint = slider.frame.origin
        let widthOfSlider: CGFloat = slider.frame.size.width
        var newValue = ((pointTapped.x - positionOfSlider.x) * CGFloat(slider.maximumValue) / widthOfSlider)
        if sliderMaximumValue == 10 {
            newValue = newValue - 0.2
        }

        let value = Float(roundValue(value: Float(newValue))) ?? 0
        sliderValue = CGFloat(value)
        
        delegate?.didEndSliding(value: value )
        //delegate?.didValueChange(value: value)
    }
    
    
    @IBAction func sliderValueChange(sender: Any) {
        let value = Float(roundValue(value: slider.value))
        let xpos = Int(((self.frame.size.width-25)/CGFloat(self.sliderMaximumValue))) * Int(value ?? 0)
        controlPoint.x = CGFloat(xpos)
        sliderValue = CGFloat(value ?? 0)
        delegate?.didValueChange(value: value ?? 0)
        setNeedsDisplay()
    }
}
