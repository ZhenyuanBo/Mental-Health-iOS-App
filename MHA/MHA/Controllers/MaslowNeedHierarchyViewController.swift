
import UIKit
import AMPopTip

class MaslowNeedHierarchyView: UIViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let width: CGFloat = 55.0
        let height: CGFloat = 80.0
        
        let selfActualizationView = SelfActualizationView(frame: CGRect(x: 150,
                                              y: 100,
                                              width: width,
                                              height: height))
        
        let esteemView = EsteemView(frame: CGRect(x: 130, y:190, width: width+40, height: height))
        let loveBelongingView = LoveView(frame: CGRect(x: 90, y: 280, width: width+120, height: height))
        let safetyView = SafetyView(frame: CGRect(x:45, y: 370, width: width + 210, height: height))
        let physiologicalView = PhysiologicalView(frame: CGRect(x: 10, y: 460, width: width + 280, height: height))
        
        backView.addSubview(selfActualizationView)
        backView.addSubview(esteemView)
        backView.addSubview(loveBelongingView)
        backView.addSubview(safetyView)
        backView.addSubview(physiologicalView)
        
        let phyTap = UITapGestureRecognizer(target: self, action: #selector(self.handlePhyTap(_:)))
        physiologicalView.addGestureRecognizer(phyTap)
        physiologicalView.isUserInteractionEnabled = true
        
        let safetyTap = UITapGestureRecognizer(target: self, action: #selector(self.handleSafetyTap(_:)))
        safetyView.addGestureRecognizer(safetyTap)
        safetyView.isUserInteractionEnabled = true
        
        let loveTap = UITapGestureRecognizer(target: self, action: #selector(self.handleLoveTap(_:)))
    
    }
    
    //MARK: - Handle Tap
    let popTip = PopTip()
    @objc func handlePhyTap(_ sender: UITapGestureRecognizer) {
        popTip.show(text: "Physiological needs", direction: .up, maxWidth: 200, in: backView, from: backView.subviews[4].frame)
        
    }
    
    @objc func handleSafetyTap(_ sender: UITapGestureRecognizer){
        popTip.show(text: "Satefy needs", direction: .up, maxWidth: 200, in: backView, from: backView.subviews[3].frame)
    }
    
    @objc func handleLoveTap(_ sender: UITapGestureRecognizer){
        popTip.show(text: "Satefy needs", direction: .up, maxWidth: 200, in: backView, from: backView.subviews[2].frame)
    }
}
