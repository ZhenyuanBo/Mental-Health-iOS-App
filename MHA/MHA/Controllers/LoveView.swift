import UIKit

class LoveView: UIView {

    var path: UIBezierPath!
     
    override init(frame: CGRect) {
        super.init(frame: frame)
     
        self.backgroundColor = .white
    }
     
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    func createLoveLevel() {
        path = UIBezierPath()
        path.move(to: CGPoint(x: self.frame.width/5, y: 0.0))
        path.addLine(to: CGPoint(x: 0.0, y: self.frame.size.height))
        path.addLine(to: CGPoint(x: self.frame.size.width, y: self.frame.size.height))
        path.addLine(to: CGPoint(x: self.frame.size.width*4/5, y: 0.0))
        path.close()
    }
    
    
    override func draw(_ rect: CGRect) {
        self.createLoveLevel()
        
        let gradient = CAGradientLayer()
        gradient.frame = path.bounds
        gradient.startPoint = CGPoint(x: 0.0, y: 1.0)
        gradient.endPoint = CGPoint(x: 1.0, y: 1.0)
        let lightYellow = hexStringToUIColor(hex: "#FFFFB7")
        let darkYellow = hexStringToUIColor(hex: "#FFD400")
        gradient.colors = [lightYellow.cgColor, darkYellow.cgColor]

        let shapeMask = CAShapeLayer()
        shapeMask.path = path.cgPath

        gradient.mask = shapeMask
        self.layer.addSublayer(gradient)
    }

}

