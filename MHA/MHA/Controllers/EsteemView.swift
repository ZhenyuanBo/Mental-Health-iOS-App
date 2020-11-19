import UIKit

class EsteemView: UIView {

    var path: UIBezierPath!
     
    override init(frame: CGRect) {
        super.init(frame: frame)
     
        self.backgroundColor = .white
    }
     
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    func createEsteemLevel() {
        path = UIBezierPath()
        path.move(to: CGPoint(x: self.frame.width/5, y: 0.0))
        path.addLine(to: CGPoint(x: 0.0, y: self.frame.size.height))
        path.addLine(to: CGPoint(x: self.frame.size.width, y: self.frame.size.height))
        path.addLine(to: CGPoint(x: self.frame.size.width*4/5, y: 0.0))
        path.close()
    }
    
    
    override func draw(_ rect: CGRect) {
        self.createEsteemLevel()
        
        let gradient = CAGradientLayer()
        gradient.frame = path.bounds
        gradient.startPoint = CGPoint(x: 0.0, y: 1.0)
        gradient.endPoint = CGPoint(x: 1.0, y: 1.0)
        let greenStartColor = hexStringToUIColor(hex: "#B7FFBF")
        let greenEndColor = hexStringToUIColor(hex: "#00AB08")
        gradient.colors = [greenStartColor.cgColor, greenEndColor.cgColor]

        let shapeMask = CAShapeLayer()
        shapeMask.path = path.cgPath

        gradient.mask = shapeMask
        self.layer.addSublayer(gradient)
    }

}
