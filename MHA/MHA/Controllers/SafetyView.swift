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
        
        let gradient = CAGradientLayer()
        gradient.frame = path.bounds
        gradient.startPoint = CGPoint(x: 0.0, y: 1.0)
        gradient.endPoint = CGPoint(x: 1.0, y: 1.0)
        
        let lightOrange = hexStringToUIColor(hex: "#FDB777").cgColor
        let darkOrange = hexStringToUIColor(hex: "#FF6200").cgColor
        
        gradient.colors = [lightOrange, darkOrange]
        
        let shapeMask = CAShapeLayer()
        shapeMask.path = path.cgPath

        gradient.mask = shapeMask
        self.layer.addSublayer(gradient)

    }

}
