/*
 Author: Zhenyuan Bo
 File Description: presents the results view
 Date: Nov 23, 2020
 */

import UIKit
import Charts
import AMPopTip
import RealmSwift
import Firebase
import FirebaseFirestore
import Instructions
import PopupDialog

class ResultsViewController: UIViewController, UIPopoverPresentationControllerDelegate{
    
    let realm = try! Realm()
    let popTip = PopTip()
    let phyPopTip = PopTip()
    let safetyPopTip = PopTip()
    let loveBelongingPopTip = PopTip()
    let esteemPopTip = PopTip()
    let selfActualizationPopTip = PopTip()
    
    let phyColor = hexStringToUIColor(hex: Utils.needColourMap[Utils.phyNeeds]!)
    let safetyColor = hexStringToUIColor(hex: Utils.needColourMap[Utils.safetyNeeds]!)
    let loveColor = hexStringToUIColor(hex: Utils.needColourMap[Utils.loveNeeds]!)
    let esteemColor = hexStringToUIColor(hex: Utils.needColourMap[Utils.esteemNeeds]!)
    let selfActualColor = hexStringToUIColor(hex: Utils.needColourMap[Utils.selfActualNeeds]!)
    
    @IBOutlet weak var pieChartTitle: UILabel!
    @IBOutlet weak var pieChartView: PieChartView!
    
    @IBOutlet weak var flashCard: FlashCardView!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var frontView: UIView!
    
    @IBOutlet weak var flipButton: UIBarButtonItem!
    
    @IBOutlet weak var downloadButton: UIBarButtonItem!
    
    var selectedDate:Date = Date()
    
    private var currSelectedNeedLevel: String = ""
    
    @IBAction func unwindToResults(_ unwindSegue: UIStoryboardSegue) {}
    
    let coachMarksController = CoachMarksController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.coachMarksController.dataSource = self
        self.coachMarksController.delegate = self
        
        pieChartTitle.text = "# of Activities/Need Category"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        self.coachMarksController.start(in: .viewController(self))
        
        flashCard.duration = 2.0
        flashCard.flipAnimation = .flipFromLeft
        flashCard.frontView = frontView
        flashCard.backView = backView
        
        frontView.layer.cornerRadius = 25
        backView.layer.cornerRadius = 25
        flashCard.layer.cornerRadius = 25
        
        let decodedData = loadDailyActivityResult(date: selectedDate)
        
        if let safeDecodedData = decodedData{
            var activityCategoryMap:[String: Int] = [:]
            for needType in Utils.needTypeList{
                if safeDecodedData[needType] != 0{
                    activityCategoryMap[needType] = safeDecodedData[needType]
                }
            }
            customizeChart(dataPoints: Array(activityCategoryMap.keys), values: Array(activityCategoryMap.values))
        }else{
            pieChartView.data = nil
        }
        
        if let currentThemeOwner = Auth.auth().currentUser?.email{
            loadAppTheme(withEmail: currentThemeOwner, view: view)
        }
        
        let width: CGFloat = 55.0
        let height: CGFloat = 80.0
        
        let pyramidTitle = UILabel(frame: CGRect(x: 0, y: 0, width: 300, height: 21))
        pyramidTitle.center = CGPoint(x: 190, y: 40)
        pyramidTitle.textAlignment = .center
        pyramidTitle.text = "Maslow's Hierarchy of Needs"
        pyramidTitle.font = pyramidTitle.font.withSize(20)
        
        let selfActualizationView = SelfActualizationView(frame: CGRect(x: 155,
                                                                        y: 100,
                                                                        width: width,
                                                                        height: height), date: selectedDate)
        
        let esteemView = EsteemView(frame: CGRect(x: 135, y:190, width: width+40, height: height), date: selectedDate)
        let loveBelongingView = LoveView(frame: CGRect(x: 95, y: 280, width: width+120, height: height), date: selectedDate)
        let safetyView = SafetyView(frame: CGRect(x:52, y: 370, width: width + 210, height: height), date: selectedDate)
        let physiologicalView = PhysiologicalView(frame: CGRect(x: 20, y: 460, width: width + 280, height: height), date: selectedDate)
        
        backView.addSubview(pyramidTitle)
        backView.addSubview(selfActualizationView)
        backView.addSubview(esteemView)
        backView.addSubview(loveBelongingView)
        backView.addSubview(safetyView)
        backView.addSubview(physiologicalView)
        
        let phyTap = UITapGestureRecognizer(target: self, action: #selector(self.handlePhyTap(_:)))
        physiologicalView.addGestureRecognizer(phyTap)
        physiologicalView.isUserInteractionEnabled = true
        phyPopTip.show(text: "Physiological needs", direction: .none, maxWidth: 200, in: backView, from: backView.subviews[5].frame)
        phyPopTip.bubbleColor = phyColor
        
        let safetyTap = UITapGestureRecognizer(target: self, action: #selector(self.handleSafetyTap(_:)))
        safetyView.addGestureRecognizer(safetyTap)
        safetyView.isUserInteractionEnabled = true
        safetyPopTip.show(text: "Satefy needs", direction: .none, maxWidth: 200, in: backView, from: backView.subviews[4].frame)
        safetyPopTip.bubbleColor = safetyColor
        
        let loveTap = UITapGestureRecognizer(target: self, action: #selector(self.handleLoveTap(_:)))
        loveBelongingView.addGestureRecognizer(loveTap)
        loveBelongingView.isUserInteractionEnabled = true
        loveBelongingPopTip.show(text: "Love & Belonging", direction: .none, maxWidth: 200, in: backView, from: backView.subviews[3].frame)
        loveBelongingPopTip.bubbleColor = loveColor
        
        let esteemTap = UITapGestureRecognizer(target: self, action: #selector(self.handleEsteemTap(_:)))
        esteemView.addGestureRecognizer(esteemTap)
        esteemView.isUserInteractionEnabled = true
        esteemPopTip.show(text: "Esteem", direction: .none, maxWidth: 200, in: backView, from: backView.subviews[2].frame)
        esteemPopTip.bubbleColor = esteemColor
        
        let selfActualizationTap = UITapGestureRecognizer(target: self, action: #selector(self.handleSelfActualizationTap(_:)))
        selfActualizationView.addGestureRecognizer(selfActualizationTap)
        selfActualizationView.isUserInteractionEnabled = true
        selfActualizationPopTip.show(text: "Self-Actualization", direction: .none, maxWidth: 200, in: backView, from: backView.subviews[1].frame)
        selfActualizationPopTip.bubbleColor = selfActualColor
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.coachMarksController.stop(immediately: true)
    }
    
    @IBAction func downloadPressed(_ sender: UIBarButtonItem) {
        let image = pieChartView.getChartImage(transparent: false)
        UIImageWriteToSavedPhotosAlbum(image!, nil, nil, nil)
    }
    
    @IBAction func flipPressed(_ sender: UIBarButtonItem) {
        flashCard.flip()
        if flashCard.showFront{
            showInstructionDialog()
        }
    }
    
    private func customizeChart(dataPoints: [String], values: [Int]) {
        
        var dataEntries: [ChartDataEntry] = []
        for i in 0..<dataPoints.count {
            let dataEntry = PieChartDataEntry(value: Double(values[i]), label: dataPoints[i], data: dataPoints[i] as AnyObject)
            dataEntries.append(dataEntry)
        }
        let pieChartDataSet = PieChartDataSet(entries: dataEntries, label: nil)
        pieChartDataSet.colors = colorsOfCharts(dataPoints: dataPoints)
        
        let pieChartData = PieChartData(dataSet: pieChartDataSet)
        let format = NumberFormatter()
        format.numberStyle = .none
        let formatter = DefaultValueFormatter(formatter: format)
        pieChartData.setValueFormatter(formatter)
        
        pieChartView.data = pieChartData
        pieChartView.drawEntryLabelsEnabled = true
        pieChartView.entryLabelFont = UIFont.systemFont(ofSize: 16)
        pieChartView.entryLabelColor = UIColor.white
        
        pieChartView.legend.enabled = false
        
    }
    
    private func colorsOfCharts(dataPoints:[String])->[UIColor]{
        var colors: [UIColor] = []
        for index in 0..<dataPoints.count{
            if Utils.phyNeeds.contains(dataPoints[index]){
                colors.append(phyColor)
            }else if Utils.safetyNeeds.contains(dataPoints[index]){
                colors.append(safetyColor)
            }else if Utils.loveNeeds.contains(dataPoints[index]){
                colors.append(loveColor)
            }else if Utils.esteemNeeds.contains(dataPoints[index]){
                colors.append(esteemColor)
            }else if Utils.selfActualNeeds.contains(dataPoints[index]){
                colors.append(selfActualColor)
            }
        }
        return colors
    }
    
    private func showInstructionDialog(){

        let title = "Instruction"
        let message = "1. Tap on label to dismiss it\n2. Tap inside each level to view detailed data\n3. Tap myself to dismiss"

        let popup = PopupDialog(title: title, message: message, buttonAlignment: .vertical)

        let understandButton = DefaultButton(title: "Understand", dismissOnTap: true) {}
        popup.addButtons([understandButton])
        
        let dialogAppearance = PopupDialogDefaultView.appearance()

        dialogAppearance.backgroundColor      = .white
        dialogAppearance.titleFont            = .boldSystemFont(ofSize: 30)
        dialogAppearance.titleColor           = UIColor(white: 0.4, alpha: 1)
        dialogAppearance.titleTextAlignment   = .center
        dialogAppearance.messageFont          = .systemFont(ofSize: 20)
        dialogAppearance.messageColor         = UIColor(white: 0.6, alpha: 1)
        dialogAppearance.messageTextAlignment = .center
        
        let containerAppearance = PopupDialogContainerView.appearance()

        containerAppearance.backgroundColor = UIColor(red:0.23, green:0.23, blue:0.27, alpha:1.00)
        containerAppearance.cornerRadius    = 10
        containerAppearance.shadowEnabled   = true
        containerAppearance.shadowColor     = .black
        containerAppearance.shadowOpacity   = 0.6
        containerAppearance.shadowRadius    = 20
        containerAppearance.shadowOffset    = CGSize(width: 0, height: 8)

        let buttonAppearance = DefaultButton.appearance()

        buttonAppearance.titleFont      = .systemFont(ofSize: 18)
        buttonAppearance.titleColor     = UIColor(red: 0.25, green: 0.53, blue: 0.91, alpha: 1)
        buttonAppearance.buttonColor    = .clear
        
        self.present(popup, animated: true, completion: nil)
    }
    
    
    //MARK: - Handle Tap
    @objc func handlePhyTap(_ sender: UITapGestureRecognizer) {
        currSelectedNeedLevel = "physiological"
        DispatchQueue.main.asyncAfter(deadline: .now()+1, execute: {
            self.performSegue(withIdentifier: Utils.resultStatsSegue, sender: self)
        })
    }
    
    @objc func handleSafetyTap(_ sender: UITapGestureRecognizer){
        currSelectedNeedLevel = "safety"
        DispatchQueue.main.asyncAfter(deadline: .now()+1, execute: {
            self.performSegue(withIdentifier: Utils.resultStatsSegue, sender: self)
        })
    }
    
    @objc func handleLoveTap(_ sender: UITapGestureRecognizer){
        currSelectedNeedLevel = "love"
        DispatchQueue.main.asyncAfter(deadline: .now()+1, execute: {
            self.performSegue(withIdentifier: Utils.resultStatsSegue, sender: self)
        })
    }
    
    @objc func handleEsteemTap(_ sender: UITapGestureRecognizer){
        currSelectedNeedLevel = "esteem"
        DispatchQueue.main.asyncAfter(deadline: .now()+1, execute: {
            self.performSegue(withIdentifier: Utils.resultStatsSegue, sender: self)
        })
    }
    
    @objc func handleSelfActualizationTap(_ sender: UITapGestureRecognizer){
        currSelectedNeedLevel = "selfActual"
        DispatchQueue.main.asyncAfter(deadline: .now()+1, execute: {
            self.performSegue(withIdentifier: Utils.resultStatsSegue, sender: self)
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! NeedDetailViewController
        destinationVC.needCategoryLevel = currSelectedNeedLevel
        destinationVC.selectedDate = selectedDate
    }
}

extension ResultsViewController: CoachMarksControllerDelegate, CoachMarksControllerDataSource{
    func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkViewsAt index: Int, madeFrom coachMark: CoachMark) -> (bodyView: (UIView & CoachMarkBodyView), arrowView: (UIView & CoachMarkArrowView)?) {
        let coachViews = coachMarksController.helper.makeDefaultCoachViews(withArrow: true, arrowOrientation: coachMark.arrowOrientation)
        switch index {
        case 0:
            coachViews.bodyView.hintLabel.text = "Flip card below"
            coachViews.bodyView.nextLabel.text = "next"
        case 1:
            coachViews.bodyView.hintLabel.text = "Download chart below as an image"
            coachViews.bodyView.nextLabel.text = "next"
        default: break
        }
        return (bodyView: coachViews.bodyView, arrowView: coachViews.arrowView)
    }
    
    func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkAt index: Int) -> CoachMark {
        switch index {
        case 0:
            let viewFlip = flipButton.value(forKey: "view") as! UIView
            return coachMarksController.helper.makeCoachMark(for: viewFlip)
        case 1:
            let viewDownload = downloadButton.value(forKey: "view") as! UIView
            return coachMarksController.helper.makeCoachMark(for: viewDownload)
        default: return coachMarksController.helper.makeCoachMark()
        }
    }
    
    func numberOfCoachMarks(for coachMarksController: CoachMarksController) -> Int {
        return 2
    }
    
}

