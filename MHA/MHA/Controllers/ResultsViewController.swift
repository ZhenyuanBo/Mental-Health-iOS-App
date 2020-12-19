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
    @IBOutlet weak var instructionButton: UIBarButtonItem!
    
    var selectedDate:Date = Date()
    
    private var currSelectedNeedLevel: String = ""
    private var activityNeed = [Utils.phyNeedName: 0, Utils.safetyNeedName: 0, Utils.loveBelongingNeedName: 0, Utils.esteemNeedName: 0, Utils.selfActualNeedName: 0]
    
    @IBAction func unwindToResults(_ unwindSegue: UIStoryboardSegue) {}
    
    let coachMarksController = CoachMarksController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.coachMarksController.dataSource = self
        self.coachMarksController.delegate = self
        
        instructionButton.isEnabled = false
        instructionButton.tintColor = .gray
        
        pieChartTitle.text = Utils.pieChartTitle
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        frontView.layer.cornerRadius = 25
        backView.layer.cornerRadius = 25
        
        if let currentThemeOwner = Auth.auth().currentUser?.email{
            loadAppTheme(withEmail: currentThemeOwner, view: view)
        }
        
//        self.coachMarksController.start(in: .viewController(self))
        
        configureFlashCard(flashCard: flashCard, front: frontView, back: backView)
    
        //create pie chart
        preparePieChart()
        
        //create maslow pyramid view
        createMaslowPyramidView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.coachMarksController.stop(immediately: true)
        
        for need in activityNeed.keys{
            activityNeed[need] = 0
        }
    }
    
    @IBAction func downloadPressed(_ sender: UIBarButtonItem) {
        let image = pieChartView.getChartImage(transparent: false)
        UIImageWriteToSavedPhotosAlbum(image!, nil, nil, nil)
    }
    
    @IBAction func flipPressed(_ sender: UIBarButtonItem) {
        flashCard.flip()
        if flashCard.showFront{
            configureBarButtonItem()
            PopUp.allowDisplayInstructionDialog(VC:self, message: Utils.resultsInstructionMsg)
        }else{
            configureBarButtonItem()
        }
    }
    
    @IBAction func instructionPressed(_ sender: UIBarButtonItem) {
        displayInstruction()
    }
    
    private func preparePieChart(){
        let decodedData = loadDailyActivityResult(date: selectedDate)
//        print("Decoded Data: \(decodedData)")/
        if let safeDecodedData = decodedData{
            for needType in Utils.needTypeList{
                if safeDecodedData[needType] > 0 {
                    if Utils.phyNeeds.contains(needType){
                        activityNeed[Utils.phyNeedName]! += safeDecodedData[needType]
                    }else if Utils.safetyNeeds.contains(needType){
                        activityNeed[Utils.safetyNeedName]! += safeDecodedData[needType]
                    }else if Utils.loveNeeds.contains(needType){
                        activityNeed[Utils.loveBelongingNeedName]! += safeDecodedData[needType]
                    }else if Utils.esteemNeeds.contains(needType){
                        activityNeed[Utils.esteemNeedName]! += safeDecodedData[needType]
                    }else if Utils.selfActualNeeds.contains(needType){
                        activityNeed[Utils.selfActualNeedName]! += safeDecodedData[needType]
                    }
                }
            }
            var finalActivityNeed:[String:Int] = [:]
            for need in activityNeed.keys{
                if activityNeed[need] != 0{
                    finalActivityNeed[need] = activityNeed[need]
                }
            }
            if finalActivityNeed.keys.isEmpty{
                pieChartView.data = nil
            }else{
                drawPieChart(dataPoints: Array(finalActivityNeed.keys), values: Array(finalActivityNeed.values))
            }
        }else{
            pieChartView.data = nil
        }
    }
    
    private func drawPieChart(dataPoints: [String], values: [Int]) {
        
        var dataEntries: [ChartDataEntry] = []
        for i in 0..<dataPoints.count {
            let dataEntry = PieChartDataEntry(value: Double(values[i]), label: dataPoints[i], data: dataPoints[i] as AnyObject)
            dataEntries.append(dataEntry)
        }
        let pieChartDataSet = PieChartDataSet(entries: dataEntries, label: nil)
        pieChartDataSet.colors = pieChartColorGenerator(dataPoints: dataPoints)
        
        let pieChartData = PieChartData(dataSet: pieChartDataSet)
        let format = NumberFormatter()
        format.numberStyle = .none
        let formatter = DefaultValueFormatter(formatter: format)
        pieChartData.setValueFormatter(formatter)
        
        pieChartView.data = pieChartData
        pieChartView.drawEntryLabelsEnabled = false
        pieChartView.drawHoleEnabled = false
        
        let legend = pieChartView.legend
        legend.horizontalAlignment = .right
        legend.verticalAlignment = .top
        legend.orientation = .vertical
        legend.font = .systemFont(ofSize: 11.0)
        legend.xEntrySpace = 0
        legend.yEntrySpace = 8
        
    }
    
    private func pieChartColorGenerator(dataPoints:[String])->[UIColor]{
        var colors: [UIColor] = []
        for index in 0..<dataPoints.count{
            if dataPoints[index] == Utils.phyNeedName{
                colors.append(phyColor)
            }else if dataPoints[index] == Utils.safetyNeedName{
                colors.append(safetyColor)
            }else if dataPoints[index] == Utils.loveBelongingNeedName{
                colors.append(loveColor)
            }else if dataPoints[index] == Utils.esteemNeedName{
                colors.append(esteemColor)
            }else if dataPoints[index] == Utils.selfActualNeedName{
                colors.append(selfActualColor)
            }
        }
        return colors
    }
    
    private func createMaslowPyramidView(){
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
        phyPopTip.show(text: Utils.phyNeedName, direction: .none, maxWidth: 200, in: backView, from: backView.subviews[5].frame)
        phyPopTip.bubbleColor = phyColor
        
        let safetyTap = UITapGestureRecognizer(target: self, action: #selector(self.handleSafetyTap(_:)))
        safetyView.addGestureRecognizer(safetyTap)
        safetyView.isUserInteractionEnabled = true
        safetyPopTip.show(text: Utils.safetyNeedName, direction: .none, maxWidth: 200, in: backView, from: backView.subviews[4].frame)
        safetyPopTip.bubbleColor = safetyColor
        
        let loveTap = UITapGestureRecognizer(target: self, action: #selector(self.handleLoveTap(_:)))
        loveBelongingView.addGestureRecognizer(loveTap)
        loveBelongingView.isUserInteractionEnabled = true
        loveBelongingPopTip.show(text: Utils.loveBelongingNeedName, direction: .none, maxWidth: 200, in: backView, from: backView.subviews[3].frame)
        loveBelongingPopTip.bubbleColor = loveColor
        
        let esteemTap = UITapGestureRecognizer(target: self, action: #selector(self.handleEsteemTap(_:)))
        esteemView.addGestureRecognizer(esteemTap)
        esteemView.isUserInteractionEnabled = true
        esteemPopTip.show(text: Utils.esteemNeedName, direction: .none, maxWidth: 200, in: backView, from: backView.subviews[2].frame)
        esteemPopTip.bubbleColor = esteemColor
        
        let selfActualizationTap = UITapGestureRecognizer(target: self, action: #selector(self.handleSelfActualizationTap(_:)))
        selfActualizationView.addGestureRecognizer(selfActualizationTap)
        selfActualizationView.isUserInteractionEnabled = true
        selfActualizationPopTip.show(text: Utils.selfActualNeedName, direction: .none, maxWidth: 200, in: backView, from: backView.subviews[1].frame)
        selfActualizationPopTip.bubbleColor = selfActualColor
    }

    private func displayInstruction(){
        PopUp.buildInstructionDialog(VC: self, message: Utils.resultsInstructionMsg)
    }
    
    private func configureBarButtonItem(){
        if flashCard.showFront{
            instructionButton.isEnabled = true
            instructionButton.tintColor = .systemBlue
            
            downloadButton.isEnabled = false
            downloadButton.tintColor = .gray
        }else{
            instructionButton.isEnabled = false
            instructionButton.tintColor = .gray
            
            downloadButton.isEnabled = true
            downloadButton.tintColor = .systemBlue
        }
    }
    
    
    //MARK: - Handle Tap
    @objc func handlePhyTap(_ sender: UITapGestureRecognizer) {
        currSelectedNeedLevel = Utils.phyNeedName
        DispatchQueue.main.asyncAfter(deadline: .now()+1, execute: {
            self.performSegue(withIdentifier: Utils.resultStatsSegue, sender: self)
        })
    }
    
    @objc func handleSafetyTap(_ sender: UITapGestureRecognizer){
        currSelectedNeedLevel = Utils.safetyNeedName
        DispatchQueue.main.asyncAfter(deadline: .now()+1, execute: {
            self.performSegue(withIdentifier: Utils.resultStatsSegue, sender: self)
        })
    }
    
    @objc func handleLoveTap(_ sender: UITapGestureRecognizer){
        currSelectedNeedLevel = Utils.loveBelongingNeedName
        DispatchQueue.main.asyncAfter(deadline: .now()+1, execute: {
            self.performSegue(withIdentifier: Utils.resultStatsSegue, sender: self)
        })
    }
    
    @objc func handleEsteemTap(_ sender: UITapGestureRecognizer){
        currSelectedNeedLevel = Utils.esteemNeedName
        DispatchQueue.main.asyncAfter(deadline: .now()+1, execute: {
            self.performSegue(withIdentifier: Utils.resultStatsSegue, sender: self)
        })
    }
    
    @objc func handleSelfActualizationTap(_ sender: UITapGestureRecognizer){
        currSelectedNeedLevel = Utils.selfActualNeedName
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
            coachViews.bodyView.hintLabel.text = "Flip card"
            coachViews.bodyView.nextLabel.text = "next"
        case 1:
            coachViews.bodyView.hintLabel.text = "Download as an image"
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

