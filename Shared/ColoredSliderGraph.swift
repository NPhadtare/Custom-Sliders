//
//  ColoredSliderGraph.swift
//  GraphDemo
//
//  Created by Medsolis on 4/28/17.
//  Copyright © 2017 Medsolis. All rights reserved.
//

import UIKit

class ColoredSliderGraph: UIView {
    
    private var fillHeightProportion: CGFloat { return sliderHeightProportion + 0.1 }
    private var fillWidthProportion: CGFloat { return sliderWidthProportion }
    
    var sliderHeightProportion: CGFloat = 0.2 { didSet { setNeedsDisplay() } }
    var sliderWidthProportion: CGFloat = 0.98 { didSet { setNeedsDisplay() } }
    
    var strokeColor = UIColor.darkGray { didSet { setNeedsDisplay() } }
    
    var sliderFillColor = UIColor.darkGray { didSet { setNeedsDisplay() } }
    var fillColor = UIColor.lightGray { didSet { setNeedsDisplay() } }
    var fillValue: CGFloat = 0.69 { didSet { setNeedsDisplay() } } // between 0 - 1
    
    var lowValue : CGFloat = 0
    var highValue : CGFloat = 0
    var highamberValue : CGFloat = 0
    var lowAmberValue : CGFloat = 0
    var highredValue : CGFloat = 0
    var lowredValue : CGFloat = 0
    var normalValue : CGFloat = 0
    var latestReading : CGFloat = 0
    
    func setValues (lowValue :CGFloat, highValue :CGFloat, highamberValue :CGFloat, lowAmberValue :CGFloat, highredValue :CGFloat, lowredValue :CGFloat, normalValue :CGFloat, latestReading :CGFloat) {
        self.lowValue = lowValue
        self.highValue = highValue
        self.highamberValue = highamberValue
        self.lowAmberValue = lowAmberValue
        self.highredValue = highredValue
        self.lowredValue = lowredValue
        self.normalValue = normalValue
        self.latestReading = latestReading
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor.clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        backgroundColor = UIColor.clear
    }
    func cleanValue(newValue: CGFloat, to places: Int = 0) -> String {
        let value  = String(format: "%.\(places)f", newValue)
        let reminder = Float(value)?.truncatingRemainder(dividingBy: 1)
        return reminder == 0 ? String(format: "%.0f", newValue) : String(format: "%.\(places)f", newValue)
    }
    
    func drawLineAndText(raeading value: CGFloat, start pointx: CGFloat, color: UIColor, isDown: Bool, rect: CGRect, sliderWidth: CGFloat, insetRect: CGRect, sliderHeight: CGFloat, andFillWidth fillWidth: CGFloat) -> Bool {
    
        var newRect = rect
        var isDown = isDown
        if value > 0 {
            
            let dashString = "—"
            
            let textFont = UIFont.systemFont(ofSize: 12)
            let textFontAttributes = [NSAttributedString.Key.font: textFont, NSAttributedString.Key.foregroundColor: UIColor.darkGray]
            
            let linetext = UIFont.systemFont(ofSize: 14)
            let linetextFontAttributes = [NSAttributedString.Key.font: linetext, NSAttributedString.Key.foregroundColor: color]
            
            if value > 0 {
                if pointx > ((insetRect.maxX - fillWidth) / 2) && !(pointx >= (sliderWidth-8)) {
                    
                    let PixelPerUnit = sliderWidth / (self.highValue - self.lowValue)
                    let greenStart = PixelPerUnit * (self.normalValue - self.lowValue)

                    let dashYPos = (greenStart <= ((insetRect.maxX - fillWidth) / 2)) ? pointx-2 : pointx-(linetext.pointSize - linetext.pointSize/3)
                    let textYPos = dashYPos+(textFont.pointSize/3)

                    newRect.origin = CGPoint(x: isDown ? insetRect.maxY : sliderHeight+textFont.pointSize, y: dashYPos)
                    
                    dashString.draw(in :newRect , withAttributes:linetextFontAttributes)
                    let string = cleanValue(newValue: value)
                    var characterCount = string.count
                    characterCount = (characterCount<3) ? 3-characterCount : 0
                    newRect.origin.x = isDown ? (insetRect.maxY + linetext.pointSize + textFont.pointSize/3) : ((insetRect.minX) + (CGFloat(characterCount) * linetext.pointSize - 5)/2)
                    newRect.origin.y = textYPos
                    string.draw(in :newRect, withAttributes:textFontAttributes)
                    isDown = !isDown
                }
            }
            
        }
        return isDown
        
    }
    
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        var isDown = false
        var insetRect = rect.insetBy(dx: 1, dy: 1)
        insetRect.origin.x += 2
        insetRect.size.height /= 4
        insetRect.size.width -= 5
        insetRect.origin.y = (self.frame.size.height/2 - insetRect.size.height/2)
        let borderPath = UIBezierPath(roundedRect: insetRect, cornerRadius: insetRect.maxY / 2)
        strokeColor.setStroke()
        borderPath.stroke()
        
        let sliderWidth = insetRect.maxX * sliderWidthProportion
        let sliderHeight = insetRect.maxY * sliderHeightProportion
        let yPosition = (insetRect.minY + insetRect.maxY - sliderHeight) / 2
        let sliderRect = CGRect(x: (insetRect.maxX - sliderWidth) / 2+5 , y: yPosition, width: sliderWidth-8, height: sliderHeight)
        
        let PixelPerUnit = sliderWidth / (self.highValue - self.lowValue)
        
        let yellowStart = PixelPerUnit * (self.lowAmberValue - self.lowValue)
        let yellowWidth = PixelPerUnit * (self.highredValue - self.lowAmberValue)
        
        let greenStart = PixelPerUnit * (self.normalValue - self.lowValue)
        let greenWidth = PixelPerUnit * (self.highamberValue - self.normalValue)
        
        let thumbStart = PixelPerUnit * (self.latestReading - self.lowValue)
        
        
        let sliderPath = UIBezierPath(roundedRect: sliderRect, cornerRadius: sliderRect.maxY / 2)
        UIColor.red.setFill()
        sliderPath.fill()
        
        let fillWidth = insetRect.maxX * fillWidthProportion
        let fillHeight = (insetRect.maxY * fillHeightProportion)/2
        
        let xPosition = (insetRect.maxX - fillWidth) / 2
        let fillRect = CGRect(x: xPosition , y: (insetRect.minY + insetRect.maxY - fillHeight) / 2, width: fillValue, height: sliderHeight)
        
        let startXPosition = (xPosition+10)
        let xPositionAdd5 = (xPosition+5)
        let newSliderWidth = (sliderWidth-8)
        let cornerRadius = fillRect.maxY / 2
        // Yellow Path
        var yellowBorderPath = UIBezierPath(rect: CGRect(x: yellowStart, y:  yPosition, width: yellowWidth, height: sliderHeight))
        
        if yellowStart <= startXPosition, yellowStart+yellowWidth >= newSliderWidth {
            yellowBorderPath = UIBezierPath(roundedRect: CGRect(x: xPositionAdd5, y: yPosition, width: (sliderWidth-(yellowStart+5)), height: sliderHeight), cornerRadius: cornerRadius)
        } else if yellowStart <= startXPosition, !(yellowStart+yellowWidth >= newSliderWidth) {
            yellowBorderPath = UIBezierPath(roundedRect: CGRect(x: xPositionAdd5, y: yPosition, width: yellowWidth, height: sliderHeight), byRoundingCorners:[.topLeft, .bottomLeft], cornerRadii: CGSize(width: cornerRadius, height: cornerRadius))
        } else if yellowStart+yellowWidth >= newSliderWidth, !(yellowStart <= (xPosition)) {
            yellowBorderPath = UIBezierPath(roundedRect: CGRect(x: yellowStart, y: yPosition, width: (sliderWidth-yellowStart), height: sliderHeight), byRoundingCorners:[.topRight, .bottomRight], cornerRadii: CGSize(width: cornerRadius, height: cornerRadius))
        }
        
        UIColor.yellow.setFill()
        yellowBorderPath.fill()
        
        
        //Green Path
        var greenBorderPath = UIBezierPath(rect: CGRect(x: greenStart, y: yPosition, width: greenWidth, height: sliderHeight))
        if greenStart <= startXPosition, greenStart+greenWidth >= newSliderWidth {
            greenBorderPath = UIBezierPath(roundedRect: CGRect(x: xPositionAdd5, y: yPosition, width: (sliderWidth-(greenStart+5)), height: sliderHeight), cornerRadius: cornerRadius)
        }else if greenStart <= startXPosition, !(greenStart+greenWidth >= newSliderWidth) {
            greenBorderPath = UIBezierPath(roundedRect: CGRect(x: xPositionAdd5, y: yPosition, width: greenWidth, height: sliderHeight), byRoundingCorners:[.topLeft, .bottomLeft], cornerRadii: CGSize(width: cornerRadius, height: cornerRadius))
        }else if greenStart+greenWidth >= newSliderWidth, !(greenStart <= startXPosition) {
            greenBorderPath = UIBezierPath(roundedRect: CGRect(x: greenStart, y: yPosition, width: (sliderWidth-greenStart), height: sliderHeight), byRoundingCorners:[.topRight, .bottomRight], cornerRadii: CGSize(width: cornerRadius, height: cornerRadius))
        }
        
        UIColor.green.setFill()
        greenBorderPath.fill()
        
        
        //Black thumb for latest reading
        var blackBoarderPath = UIBezierPath(roundedRect: CGRect(x: thumbStart, y: insetRect.origin.y, width: insetRect.size.height, height: insetRect.size.height), cornerRadius: insetRect.size.height / 2)
        if thumbStart <= startXPosition{
            blackBoarderPath = UIBezierPath(roundedRect: CGRect(x: startXPosition, y: insetRect.origin.y, width: insetRect.size.height, height: insetRect.size.height), cornerRadius: insetRect.size.height / 2)
        } else if thumbStart >= (sliderWidth-10) {
            blackBoarderPath = UIBezierPath(roundedRect: CGRect(x: (sliderWidth-22), y: insetRect.origin.y, width: insetRect.size.height, height: insetRect.size.height), cornerRadius: insetRect.size.height / 2)
        }
        UIColor.black.setFill()
        blackBoarderPath.fill()
        
        
        let textLatestFont = UIFont.boldSystemFont(ofSize: 16)
        let textLatestFontAttributes = [NSAttributedString.Key.font: textLatestFont, NSAttributedString.Key.foregroundColor: UIColor.black]

        //Condition for all values and line
        
        if let context = UIGraphicsGetCurrentContext() {
            context.saveGState()
            context.rotate(by: -(CGFloat.pi/2))
            context.translateBy(x: -rect.size.height, y: 0)
            let newRect = rect.applying(transform);
            
            //For Lowamber value
            isDown = drawLineAndText(raeading: self.lowAmberValue, start: yellowStart, color: UIColor.red, isDown: isDown, rect: newRect, sliderWidth:sliderWidth, insetRect: insetRect, sliderHeight:sliderHeight,andFillWidth: fillWidth)
            
            //For Normal value
            isDown = drawLineAndText(raeading: self.normalValue, start: greenStart, color: UIColor.yellow, isDown: isDown, rect: newRect, sliderWidth:sliderWidth, insetRect: insetRect, sliderHeight:sliderHeight,andFillWidth: fillWidth)
            
            //For Highamber value
            isDown = drawLineAndText(raeading: self.highamberValue, start: (greenStart + greenWidth), color: UIColor.green, isDown: isDown, rect: newRect, sliderWidth:sliderWidth, insetRect: insetRect, sliderHeight:sliderHeight,andFillWidth: fillWidth)
            
            //For highred value
            isDown = drawLineAndText(raeading: self.highredValue, start: (yellowStart + yellowWidth), color: UIColor.yellow, isDown: isDown, rect: newRect, sliderWidth:sliderWidth, insetRect: insetRect, sliderHeight:sliderHeight,andFillWidth: fillWidth)
            
            context.restoreGState()
        }
        
        if self.latestReading >= 0 {
            let string = cleanValue(newValue: latestReading)
            let textWidth = string.boundingRect(with: CGSize(width: 300, height: textLatestFont.pointSize), options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: textLatestFont], context: nil).width //(CGFloat(string.count) * textFont.pointSize)
            
            var frame = CGRect(x:(xPosition), y: (insetRect.origin.y-(textLatestFont.pointSize+3)), width:textWidth+10, height:20)
            if thumbStart <= startXPosition{
                frame = CGRect(x:startXPosition, y: (insetRect.origin.y-(textLatestFont.pointSize+3)), width:textWidth+10, height:20)
            } else if thumbStart >= newSliderWidth {
                frame = CGRect(x:(sliderWidth-25), y: (insetRect.origin.y-(textLatestFont.pointSize+3)), width:textWidth+10, height:20)
            } else {
                frame = CGRect(x:thumbStart-5, y: (insetRect.origin.y - (textLatestFont.pointSize+3)), width:textWidth+10, height:20)
            }
            let textBGBoarderPath = UIBezierPath(roundedRect: frame, cornerRadius: insetRect.size.height / 2)
            UIColor.white.setFill()
            textBGBoarderPath.fill()
            
            if thumbStart <= startXPosition {
                string.draw(in :CGRect(x:startXPosition, y: (insetRect.origin.y-(textLatestFont.pointSize+5)), width:textWidth, height:30), withAttributes:textLatestFontAttributes)
            } else if thumbStart >= newSliderWidth {
                string.draw(in :CGRect(x:(sliderWidth-25), y: (insetRect.origin.y-(textLatestFont.pointSize+5)), width:textWidth, height:30), withAttributes:textLatestFontAttributes)
            } else {
                string.draw(in :CGRect(x:thumbStart, y: (insetRect.origin.y - (textLatestFont.pointSize+5)), width:textWidth, height:30), withAttributes:textLatestFontAttributes)
            }
        }
    }
}
