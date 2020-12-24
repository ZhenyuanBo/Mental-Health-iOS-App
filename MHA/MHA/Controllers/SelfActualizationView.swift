/*
 Author: Zhenyuan Bo & Anqi Luo
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
        
        let decodedData = Utils.loadDailyActivityResult(date: date)
        if let safeDecodedData = decodedData{
            for needType in Utils.SELF_ACTUAL_NEEDS{
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
        path.move(to: CGPoint(x: 0.0, y: 0.0))
        path.addLine(to: CGPoint(x: 0.0, y: self.frame.size.height))
        path.addLine(to: CGPoint(x: self.frame.size.width, y: self.frame.size.height))
        path.close()
    }
    
    override func draw(_ rect: CGRect) {
        self.createSelfActualizationLevel()
        
        if activityList.count>0{
            Utils.hexStringToUIColor(hex: Utils.SELF_ACTUAL_NEED_COLOUR_LIST[0]).setFill()
        }else{
            Utils.hexStringToUIColor(hex: Utils.BASE_COLOUR).setFill()
        }
        path.fill()
        
    }
}
