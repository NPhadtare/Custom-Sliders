import UIKit

@objc protocol NPLikertSliderDelegate: class {
    @objc optional func didValueChange(value: Float)
    @objc optional func didEndSliding(value: Float)
}

class NPLikertSlider: UIView {
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
    
    var lineSliderColor: UIColor = .lightGray { didSet { setNeedsDisplay() } }
    var thumbColor: UIColor = .darkGray { didSet { setNeedsDisplay() } }
    var textFont = UIFont.systemFont(ofSize: 20) { didSet { setNeedsDisplay() } }
    var textColor = UIColor.white { didSet { setNeedsDisplay() } }
    var textBgColor = UIColor.darkGray { didSet { setNeedsDisplay() } }
    var gradiantColors: [CGColor]?
    var showRange: Bool = false { didSet { setNeedsDisplay() } }
    var zoomSelectedValue: Bool = false { didSet { setNeedsDisplay() } }
    fileprivate var previouseZoomPoint: CGFloat = 0
    weak var delegate: NPLikertSliderDelegate?
    var sliderMinimumValue: Float = 0 {
        didSet {
            slider.minimumValue = sliderMinimumValue
            controlPoint = CGPoint(x: xPositionFromSliderValue(aSlider: slider), y: yPos-9)
            setNeedsDisplay()
        }
    }
    fileprivate var yPos: CGFloat = 30 {
        didSet {
            yPos = CGFloat(self.frame.size.height/2)
        }
    }
    
    var sliderValues: [String]? { didSet {
        setNeedsDisplay()
        slider.maximumValue = 0
        slider.maximumValue = Float((sliderValues?.count) ?? 0) - 1
        controlPoint = CGPoint(x: xPositionFromSliderValue(aSlider: slider), y: yPos-9)
        }}
    var sliderMaximumValue: Float = 1 {
        didSet {
            slider.maximumValue = sliderMaximumValue
            controlPoint = CGPoint(x: xPositionFromSliderValue(aSlider: slider), y: yPos-9)
            setNeedsDisplay()
        }
    }
    var slideInterval: Float = 0.1
    
    var slider: UISlider! {
        didSet {
            slider.minimumTrackTintColor = .clear
            slider.maximumTrackTintColor = .clear
            slider.thumbTintColor = .clear
        }
    }
    var sliderValue: CGFloat = 0.0 {
        didSet {
            slider.value = Float(sliderValue)
            if isUpadteControlpoint {
                controlPoint = CGPoint(x: xPositionFromSliderValue(aSlider: slider), y: yPos-9)
            }
            var interval = slideInterval
            var zoomX: CGFloat = 0
            if sliderValues != nil {
                let value = CGFloat(sliderValues?.count ?? 1)
                interval = Float((self.frame.size.width-10) / value)
                for _ in sliderValues! {
                    zoomX = zoomX + CGFloat(interval)
                    if zoomSelectedValue &&  controlPoint.x<zoomX && previouseZoomPoint<controlPoint.x {
                        let xpos = CGFloat(zoomX - CGFloat(interval)) + CGFloat(interval)/2
                        controlPoint.x = xpos
                        slider.value = Float(sliderValue)
                        sliderValue = getValuefromXposition(xpos: xpos)
                        break
                    }
                }
            }
            setNeedsDisplay()
            isAnimate = true
        }
    }
    var controlPoint = CGPoint.zero
    var isAnimate = false
    fileprivate var isUpadteControlpoint = true
    func roundValue(value: Float) -> String {
        
        let newValue  = round(value / slideInterval) * slideInterval
        return newValue.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", newValue) : String(format: "%.1f", newValue)
    }
    
    func roundValueInt(value: Float) -> Int {
        let newValue  = round(value / slideInterval) * slideInterval
        return Int(newValue)
    }
    
    func drawRanges(){
        var xPos: CGFloat = 20
        var end = CGPoint(x: CGFloat(xPos), y: yPos-5)
        var interval = slideInterval
        var zoomX: CGFloat = 0
        if sliderValues != nil {
            interval = Float((self.frame.size.width-10) / CGFloat(sliderValues?.count ?? 1))
            xPos = CGFloat(interval)/2
            for values in sliderValues! {
                //let path = UIBezierPath()
                end = CGPoint(x: CGFloat(xPos), y: yPos-5)
                // path.move(to: start)
                //path.addLine(to: end)
                // let shapeLayer = CAShapeLayer()
                // shapeLayer.path = path.cgPath
                zoomX = zoomX + CGFloat(interval)
                xPos = xPos + CGFloat(interval)
                //shapeLayer.fillColor = UIColor.clear.cgColor
                //shapeLayer.strokeColor = thumbColor.cgColor
                var textFontAttributes = [NSAttributedString.Key.font: textFont, NSAttributedString.Key.foregroundColor: textColor] as [NSAttributedString.Key : Any]
                var point = end
                point.y = point.y - CGFloat(textFont.pointSize+10)
                var font = textFont
                if zoomSelectedValue &&  controlPoint.x<zoomX && previouseZoomPoint<controlPoint.x {
                    font = font.withSize( font.pointSize * 1.5 )
                    textFontAttributes = [NSAttributedString.Key.font: font, NSAttributedString.Key.foregroundColor: textColor] as [NSAttributedString.Key : Any]
                    point.y = point.y - CGFloat(textFont.pointSize-10)
                }
                previouseZoomPoint = zoomX
                if previouseZoomPoint >= (self.frame.size.width-15){
                    previouseZoomPoint = 0
                }
                let string = values
                let textWidth = string.boundingRect(with: CGSize(width: 300, height: textFont.pointSize), options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil).width
                point.x = point.x - textWidth/2
                let textRect = CGRect(origin: point, size: CGSize(width: textWidth, height: CGFloat(font.pointSize+10)))
                let textLayer = CATextLayer()
                textLayer.frame = textRect
                textLayer.string = NSAttributedString(string: string, attributes: textFontAttributes)
                textLayer.alignmentMode = CATextLayerAlignmentMode.center
                self.layer.addSublayer(textLayer)
            }
        }
    }
    
    func drawText() {
        let textFontAttributes = [NSAttributedString.Key.font: textFont, NSAttributedString.Key.foregroundColor: textColor] as [NSAttributedString.Key : Any]
        var string = roundValue(value: slider.value)
        if let values = sliderValues {
            string = values[roundValueInt(value: slider.value)]
        }
        var point = controlPoint
        var textWidth = string.boundingRect(with: CGSize(width: 300, height: textFont.pointSize), options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: textFont], context: nil).width
        
        point.x = point.x - textWidth/2
        point.y = point.y - CGFloat(textFont.pointSize+10)
        let textRect = CGRect(origin: point, size: CGSize(width: textWidth, height: CGFloat(textFont.pointSize+10)))
        var pointBg = point
        pointBg.x = pointBg.x - 8
        pointBg.y =  pointBg.y - 5
        textWidth = textWidth+15
        if  textWidth < 25 {
            textWidth = 25
        }
        let bgRect = CGRect(origin: pointBg, size: CGSize(width: textWidth, height: CGFloat(textFont.pointSize+10)))
        let textBGBoarderPath = UIBezierPath(roundedRect: bgRect, cornerRadius: 7)
        let textBgShapeLayer = CAShapeLayer()
        textBgShapeLayer.path = textBGBoarderPath.cgPath
        textBgShapeLayer.shadowColor = UIColor.lightGray.cgColor
        textBgShapeLayer.shadowOpacity = 1.0
        textBgShapeLayer.shadowOffset = CGSize(width:-2, height: 2)
        textBgShapeLayer.shadowRadius = 2.0
        textBgShapeLayer.fillColor = textBgColor.cgColor
        self.layer.addSublayer(textBgShapeLayer)
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.gray.cgColor, UIColor.lightGray.cgColor]
        gradientLayer.locations = [0, 1]
        gradientLayer.startPoint = CGPoint(x: 1, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0, y: 1)
        gradientLayer.frame = bgRect
        gradientLayer.cornerRadius = 7
        textBgShapeLayer.addSublayer(gradientLayer)
        
        let textLayer = CATextLayer()
        textLayer.frame = textRect
        textLayer.string = NSAttributedString(string: string, attributes: textFontAttributes)
        textLayer.alignmentMode = CATextLayerAlignmentMode.center
        textBgShapeLayer.addSublayer(textLayer)
    }
    
    override func draw(_ rect: CGRect)  {
        super.draw(rect)
        yPos = rect.size.height/2
        controlPoint.y = yPos - 10
        if let allLayers = layer.sublayers {
            for sublayer in allLayers {
                if sublayer.isKind(of: UIBezierPath.self) ||  sublayer.isKind(of: CAShapeLayer.self ) || sublayer.isKind(of: CATextLayer.self) {
                    sublayer.removeFromSuperlayer()
                }
            }
        }
        let shapeWidth = CGFloat(2)
        let start = CGPoint(x: 10, y: yPos)
        let end = CGPoint(x: self.frame.size.width-10, y: yPos)
        let path = UIBezierPath()
        path.move(to: start)
        let p3 = CGPoint(x:controlPoint.x-26, y:yPos)
        let curveEnd = CGPoint(x:controlPoint.x+26, y:yPos)
        path.addLine(to: p3)
        let controlpoint1 = CGPoint(x:p3.x+10, y:yPos+2)
        let controlpoint2 = CGPoint(x:controlPoint.x-10, y:controlPoint.y)
        path.addCurve(to: controlPoint, controlPoint1: controlpoint1, controlPoint2: controlpoint2)
        let controlpoint3 = CGPoint(x:controlPoint.x+10, y:controlPoint.y)
        let controlpoint4 = CGPoint(x:controlPoint.x+10, y:controlPoint.y+10)
        path.addCurve(to: curveEnd, controlPoint1: controlpoint3, controlPoint2: controlpoint4)
        path.addLine(to: curveEnd)
        path.addLine(to: end)
        
        //design path in layer
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.lineWidth = 2.0
        shapeLayer.strokeColor = lineSliderColor.cgColor
        shapeLayer.fillColor = UIColor.clear.cgColor
        self.layer.addSublayer(shapeLayer)
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: controlPoint.x, y: yPos+9+shapeWidth), radius: CGFloat(14), startAngle: CGFloat(0), endAngle:CGFloat(Double.pi * 2), clockwise: true)
        let shapeLayerCircle = CAShapeLayer()
        shapeLayerCircle.path = circlePath.cgPath
        
        shapeLayerCircle.fillColor = UIColor.clear.cgColor
        shapeLayerCircle.strokeColor = thumbColor.cgColor
        shapeLayerCircle.lineWidth = 2.0//(UI_USER_INTERFACE_IDIOM() == .pad) ? 3.0 : 2.0
        shapeLayerCircle.shadowColor = UIColor.lightGray.cgColor
        shapeLayerCircle.shadowOpacity = 1.0
        shapeLayerCircle.shadowOffset = CGSize(width:-2, height: 2)
        shapeLayerCircle.shadowRadius = 2.0
        self.layer.addSublayer(shapeLayerCircle)
        
        let startDotPath = UIBezierPath(arcCenter: start, radius: CGFloat(3), startAngle: CGFloat(0), endAngle:CGFloat(Double.pi * 2), clockwise: true)
        let shapeLayerStartDot  = CAShapeLayer()
        shapeLayerStartDot.path = startDotPath.cgPath
        shapeLayerStartDot.fillColor = lineSliderColor.cgColor
        shapeLayerStartDot.strokeColor = lineSliderColor.cgColor
        shapeLayerStartDot.lineWidth = 1.0//(UI_USER_INTERFACE_IDIOM() == .pad) ? 3.0 : 2.0
        self.layer.addSublayer(shapeLayerStartDot)
        
        let endDotPath = UIBezierPath(arcCenter: end, radius: CGFloat(3), startAngle: CGFloat(0), endAngle:CGFloat(Double.pi * 2), clockwise: true)
        let shapeLayerEndDot  = CAShapeLayer()
        shapeLayerEndDot.path = endDotPath.cgPath
        shapeLayerEndDot.fillColor = lineSliderColor.cgColor
        shapeLayerEndDot.strokeColor = lineSliderColor.cgColor
        shapeLayerEndDot.lineWidth = 1.0//(UI_USER_INTERFACE_IDIOM() == .pad) ? 3.0 : 2.0
        self.layer.addSublayer(shapeLayerEndDot)
        
        setupUI()
        var sliderFrame = self.frame
        sliderFrame.origin.x = 0
        sliderFrame.origin.y = 5
        sliderFrame.size.width = self.frame.size.width-10
        slider.frame = sliderFrame
        self.bringSubviewToFront(slider)
        if !showRange {
            drawText()
        }
        if showRange {
            drawRanges()
        }
    }
    
    func setupUI() {
        if slider == nil {
            var sliderFrame = self.frame
            sliderFrame.origin.x = 0
            sliderFrame.size.width = self.frame.size.width-10
            slider = UISlider(frame: sliderFrame)
            sliderFrame.origin.y = yPos-CGFloat((slider.currentThumbImage?.size.height)!)+20
            slider.frame = sliderFrame
            slider.addTarget(self, action: #selector(sliderValueChange(sender:)), for: .valueChanged)
            slider.addTarget(self, action: #selector(sliderDidEndSliding(_:)), for: ([.touchUpInside,.touchUpOutside]))
            self.addSubview(slider)
        }
    }
    func getValuefromXposition(xpos: CGFloat) -> CGFloat {
        let percentage = xpos / slider.bounds.size.width
        let delta = percentage * CGFloat(slider.maximumValue - slider.minimumValue)
        let value = CGFloat(slider.minimumValue) + delta
        return value
    }
    
    @objc func sliderDidEndSliding(_ notification: NSNotification?){
        var interval = slideInterval
        var zoomX: CGFloat = 0
        if sliderValues != nil {
            interval = Float((self.frame.size.width-10) / CGFloat(sliderValues?.count ?? 1))
            for (index, _) in sliderValues!.enumerated() {
                zoomX = zoomX + CGFloat(interval)
                if zoomSelectedValue &&  controlPoint.x<zoomX && previouseZoomPoint<controlPoint.x {
                    let xpos = CGFloat(zoomX - CGFloat(interval)) + CGFloat(interval)/2
                    controlPoint.x = xpos
                    isUpadteControlpoint = false
                    sliderValue = getValuefromXposition(xpos: xpos)
                    slider.value = Float(sliderValue)
                    delegate?.didEndSliding?(value: Float(index))
                    break;
                }
            }
            setNeedsDisplay()
        }
    }
    func xPositionFromSliderValue(aSlider : UISlider) -> CGFloat {
        let sliderRange = aSlider.frame.size.width - (aSlider.currentThumbImage?.size.width)!
        let sliderOrigin = aSlider.frame.origin.x + ((aSlider.currentThumbImage?.size.width)! / 2.0)
        let sliderValueToPixels = (CGFloat((aSlider.value - aSlider.minimumValue)/(aSlider.maximumValue - aSlider.minimumValue)) * sliderRange) + sliderOrigin
        return sliderValueToPixels+5
    }
    @IBAction func sliderValueChange(sender: Any) {
        //        print("slidervalue :\(slider.value) ")
        //        print("x: \(xPositionFromSliderValue(aSlider: slider))")
        controlPoint.x = xPositionFromSliderValue(aSlider: slider)
        let value = Float(roundValue(value: slider.value))
        delegate?.didValueChange?(value: (value ?? 0))
        setNeedsDisplay()
    }
}
//var likertSlider = NPLikertSlider(frame: CGRect(x: 0, y: 0, width: 400, height: 80))
//likertSlider.sliderMinimumValue = 1
//likertSlider.sliderMaximumValue = 10
//likertSlider.sliderValue = 5.0
//likertSlider.slideInterval = 1.0
//
//PlaygroundPage.current.needsIndefiniteExecution = true
//PlaygroundPage.current.liveView = likertSlider






