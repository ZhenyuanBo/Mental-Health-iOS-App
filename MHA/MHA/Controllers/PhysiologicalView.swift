import UIKit
import AMPopTip

class PhysiologicalView: UIView {
    
    var path: UIBezierPath!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = .white
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    func createPhysiologicalLevel() {
        path = UIBezierPath()
        path.move(to: CGPoint(x: self.frame.width/11, y: 0.0))
        path.addLine(to: CGPoint(x: 0.0, y: self.frame.size.height))
        path.addLine(to: CGPoint(x: self.frame.size.width, y: self.frame.size.height))
        path.addLine(to: CGPoint(x: self.frame.size.width*10/11, y: 0.0))
        path.close()
    }
    
    
    override func draw(_ rect: CGRect) {
        

        self.createPhysiologicalLevel()
        
        hexStringToUIColor(hex: "#aaaaaa").setFill()
        path.fill()
        
        let gradient = CAGradientLayer()
        gradient.frame = path.bounds
        gradient.startPoint = CGPoint(x: 0.0, y: 1.0)
        gradient.endPoint = CGPoint(x: 0.5, y: 1.0)
        gradient.locations = [0.0, 0.2, 0.4]
        
        let lightRed = hexStringToUIColor(hex: "#E97452")
        let darkRed = hexStringToUIColor(hex: "#8B0001")
        let gray = hexStringToUIColor(hex: "#aaaaaa")
        
        gradient.colors = [lightRed.cgColor, darkRed.cgColor, darkRed.cgColor, gray.cgColor]
        
        let shapeMask = CAShapeLayer()
        shapeMask.path = path.cgPath
        
        gradient.mask = shapeMask
        self.layer.addSublayer(gradient)
        
    }
    
}
