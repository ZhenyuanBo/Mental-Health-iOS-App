import UIKit

public class FlashCardView: UIView {
    
    var animationInProgress:Bool = false
    var flipAnimation:FlipAnimations = .flipFromLeft
    var duration:Double = 1.0
    var showFront:Bool = true
    var frontView:UIView?
    var backView:UIView?
    
    func flip() {
        if frontView != nil && backView != nil
        {
            let fromView = showFront ? frontView : backView
            let toView = showFront ? backView : frontView
            backView?.isHidden = showFront
            UIView.transition(from: fromView!,
                              to: toView!,
                              duration: duration,
                              options: [flipAnimation.animationOption(), .showHideTransitionViews]) { (finish) in
                if finish {
                    self.showFront = !self.showFront
                    self.backView?.isHidden = self.showFront
                }
            }
        }
    }
}
