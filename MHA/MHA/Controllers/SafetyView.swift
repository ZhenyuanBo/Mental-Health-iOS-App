import UIKit

class SafetyView: UIView {

    var path: UIBezierPath!
    
    var activityList:[Int] = []
     
    init(frame: CGRect, date: Date) {
        super.init(frame: frame)
     
        self.backgroundColor = .white
        
        let decodedData = loadDailyActivityResult(date: date)
        if let safeDecodedData = decodedData{
            for needType in Utils.safetyNeeds{
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
        
        if activityList.count>0{
            let gradient = CAGradientLayer()
            gradient.frame = path.bounds
            gradient.startPoint = CGPoint(x: 0.0, y: 1.0)
            gradient.endPoint = CGPoint(x: 1.0, y: 1.0)
            
            if activityList.count==1{
                gradient.locations = [0.0, 0.2]
            }else if activityList.count==2{
                gradient.locations = [0.0, 0.2, 0.4]
            }else if activityList.count==3{
                gradient.locations = [0.0, 0.2, 0.4, 0.6]
            }else if activityList.count==4{
                gradient.locations = [0.0, 0.2, 0.4, 0.6, 0.8]
            }else if activityList.count==5{
                gradient.locations = [0.0, 0.2, 0.4, 0.6, 0.8, 1.0]
            }
            
            var colors:[Any] = []
            var currColour:CGColor
            var j = 4
            for i in 0..<activityList.count{
                if i==0{
                    currColour = hexStringToUIColor(hex: Utils.safetyNeedColoursList[j]).cgColor
                    colors.insert(currColour, at: 0)
                }else if activityList[i] != activityList[i-1]{
                    j -= 1
                    currColour = hexStringToUIColor(hex: Utils.safetyNeedColoursList[j]).cgColor
                    colors.insert(currColour, at: 0)
                }else if activityList[i] == activityList[i-1]{
                    currColour = hexStringToUIColor(hex: Utils.safetyNeedColoursList[j]).cgColor
                    colors.insert(currColour, at: 0)
                }
            }
            
            if activityList.count < 5{
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
