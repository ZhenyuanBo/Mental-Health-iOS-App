/*
 Author: Zhenyuan Bo
 File Description: presents the self-acutalization level
 Date: Nov 23, 2020
 */

import UIKit

class SelfActualizationView: UIView {
    
    var path: UIBezierPath!
    
    var activityList:[Int] = []
    
    init(frame: CGRect, date: Date) {
        super.init(frame: frame)
        
        self.backgroundColor = .white
        
        let decodedData = loadDailyActivityResult(date: date)
        if let safeDecodedData = decodedData{
            for needType in Utils.selfActualNeeds{
                if safeDecodedData[needType] != 0{
                    activityList.append(safeDecodedData[needType])
                }
            }
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
        
        if activityList.count>0{
            hexStringToUIColor(hex: Utils.selfActualNeedColoursList[0]).setFill()
        }else{
            hexStringToUIColor(hex: Utils.baseColour).setFill()
        }
        path.fill()
        
    }
}
