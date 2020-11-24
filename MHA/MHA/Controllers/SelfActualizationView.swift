import UIKit

class SelfActualizationView: UIView {
    
    var path: UIBezierPath!
    
    var activityList:[Int] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = .white
        
        let decodedData = loadNeedActivityResult(date: Date())
        if let safeDecodedData = decodedData{
            for needType in Utils.selfActualNeeds{
                if safeDecodedData[needType] != 0{
                    activityList.append(safeDecodedData[needType])
                }
            }
            activityList.sort(){$0 > $1}
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func createSelfActualizationLevel() {
        path = UIBezierPath()
        path.move(to: CGPoint(x: self.frame.width/2, y: 0.0))
        path.addLine(to: CGPoint(x: 0.0, y: self.frame.size.height))
        path.addLine(to: CGPoint(x: self.frame.size.width, y: self.frame.size.height))
        path.close()
    }
    
    override func draw(_ rect: CGRect) {
        self.createSelfActualizationLevel()
        
        hexStringToUIColor(hex: Utils.baseColour).setFill()
        path.fill()
        
        if activityList.count>0{
            let gradient = CAGradientLayer()
            gradient.frame = path.bounds
            gradient.startPoint = CGPoint(x: 0.0, y: 1.0)
            gradient.endPoint = CGPoint(x: 1.0, y: 1.0)
            
            var colors:[Any] = []
            let currColour = hexStringToUIColor(hex: Utils.esteemNeedColoursList[0]).cgColor
            colors.append(currColour)

            if activityList.count < 1{
                colors.append(hexStringToUIColor(hex: Utils.baseColour).cgColor)
            }
            
            gradient.colors = colors
            
            let shapeMask = CAShapeLayer()
            shapeMask.path = path.cgPath
            
            gradient.mask = shapeMask
            self.layer.addSublayer(gradient)
        }
        
    }
}
