import UIKit

class SafetyView: UIView {

    var path: UIBezierPath!
     
    override init(frame: CGRect) {
        super.init(frame: frame)
     
        self.backgroundColor = .white
    }
     
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    func createSafeNeedsView() {
        path = UIBezierPath()
        path.move(to: CGPoint(x: self.frame.width/7, y: 0.0))
        path.addLine(to: CGPoint(x: 0.0, y: self.frame.size.height))
        path.addLine(to: CGPoint(x: self.frame.size.width, y: self.frame.size.height))
        path.addLine(to: CGPoint(x: self.frame.size.width*6/7, y: 0.0))
        path.close()
    }
    
    
    override func draw(_ rect: CGRect) {
        self.createSafeNeedsView()
        
        hexStringToUIColor(hex: Utils.baseColour).setFill()
        path.fill()
        
        let gradient = CAGradientLayer()
        gradient.frame = path.bounds
        gradient.startPoint = CGPoint(x: 0.0, y: 1.0)
        gradient.endPoint = CGPoint(x: 1.0, y: 1.0)
        gradient.locations = [0.0, 0.1, 0.2]
        
        let lightOrange = hexStringToUIColor(hex: Utils.safetyOrange1)
        let darkOrange = hexStringToUIColor(hex: Utils.safetyOrange5)
        let baseColour = hexStringToUIColor(hex: Utils.baseColour)
        
        gradient.colors = [lightOrange.cgColor, darkOrange.cgColor, darkOrange.cgColor, baseColour.withAlphaComponent(0.0).cgColor]
        
        let shapeMask = CAShapeLayer()
        shapeMask.path = path.cgPath

        gradient.mask = shapeMask
        self.layer.addSublayer(gradient)

    }

}
