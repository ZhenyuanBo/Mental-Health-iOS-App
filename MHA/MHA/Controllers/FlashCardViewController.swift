//
//  FlashCardViewController.swift
//  MHA
//
//  Created by Zhenyuan Bo on 2020-11-09.
//

import UIKit

class FlashCardViewController: UIViewController{
    

    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var frontView: UIView!
    @IBOutlet weak var flashCard: FlashCardView!
    
    
//    @IBOutlet weak var activityText: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        title = setTitle(date: Date())
        flashCard.duration = 2.0
        flashCard.flipAnimation = .flipFromLeft
        flashCard.frontView = frontView
        flashCard.backView = backView
    }
    
    @IBAction func flipPressed(_ sender: UIButton) {
        flashCard.flip()
    }
    
    func setTitle(date: Date)->String{
        let month = date.dateFormatter(format: "MM")
        let monthName = Utils.monthMap[Int(month)!]!
        let dateNumber = date.dateFormatter(format: "d")
        let year = date.dateFormatter(format: "yyyy")
        let navBartitle = "\(monthName) \(dateNumber), \(year)"
        return navBartitle
    }
    
//    func setUpTriangle(){
//        let heightWidth = backView.frame.size.width
//        let path = CGMutablePath()
//
//        path.move(to: CGPoint(x: 0, y: heightWidth))
//        path.addLine(to: CGPoint(x:heightWidth/2, y: heightWidth/2))
//        path.addLine(to: CGPoint(x:heightWidth, y:heightWidth))
//        path.addLine(to: CGPoint(x:0, y:heightWidth))
//
//        let shape = CAShapeLayer()
//        shape.path = path
////        shape.fillColor = UIColor.blue.cgColor
//
//        backView.layer.insertSublayer(shape, at: 0)
//    }
    
    
}
