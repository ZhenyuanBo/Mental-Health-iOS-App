/*
 Author: Zhenyuan Bo & Anqi Luo
 File Description: presents the results view
 Date: Nov 23, 2020
 */

import UIKit
import Charts
import AMPopTip
import RealmSwift
import Firebase
import FirebaseFirestore
import PopupDialog

class ResultsViewController: UIViewController, UIPopoverPresentationControllerDelegate{
    
    let realm = try! Realm()
    
    let phyPopTip = PopTip()
    let safetyPopTip = PopTip()
    let loveBelongingPopTip = PopTip()
    let esteemPopTip = PopTip()
    let selfActualizationPopTip = PopTip()
    
    let phyColor = Utils.hexStringToUIColor(hex: Utils.NEED_COLOUR_MAP[Utils.PHY_NEEDS]!)
    let safetyColor = Utils.hexStringToUIColor(hex: Utils.NEED_COLOUR_MAP[Utils.SAFETY_NEEDS]!)
    let loveColor = Utils.hexStringToUIColor(hex: Utils.NEED_COLOUR_MAP[Utils.LOVE_NEEDS]!)
    let esteemColor = Utils.hexStringToUIColor(hex: Utils.NEED_COLOUR_MAP[Utils.ESTEEM_NEEDS]!)
    let selfActualColor = Utils.hexStringToUIColor(hex: Utils.NEED_COLOUR_MAP[Utils.SELF_ACTUAL_NEEDS]!)
    
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
    private var activityNeed = [Utils.PHY_NEED_NAME: 0, Utils.SAFETY_NEED_NAME: 0, Utils.LOVE_BELONGING_NEED_NAME: 0, Utils.ESTEEM_NEED_NAME: 0, Utils.SELF_ACTUAL_NEED_NAME: 0]
    
    @IBAction func unwindToResults(_ unwindSegue: UIStoryboardSegue) {}
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        instructionButton.isEnabled = false
        instructionButton.tintColor = .gray
        
        pieChartTitle.text = Utils.PIE_CHART_TITLE
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        frontView.layer.cornerRadius = 25
        backView.layer.cornerRadius = 25
            
        view.backgroundColor = Theme.current.background
        
        Utils.configureFlashCard(flashCard: flashCard, front: frontView, back: backView)
    
        //create pie chart
        preparePieChart()
        
        //create maslow pyramid view
        createMaslowPyramidView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
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
            PopUp.allowDisplayInstructionDialog(VC:self, message: Utils.RESULTS_INSTRUCTION_MSG)
        }else{
            configureBarButtonItem()
        }
    }
    
    @IBAction func instructionPressed(_ sender: UIBarButtonItem) {
        displayInstruction()
    }
    
    private func preparePieChart(){
        let decodedData = Utils.loadDailyActivityResult(date: selectedDate)
//        print("Decoded Data: \(decodedData)")/
        if let safeDecodedData = decodedData{
            for needType in Utils.NEED_TYPE_LIST{
                if safeDecodedData[needType] > 0 {
                    if Utils.PHY_NEEDS.contains(needType){
                        activityNeed[Utils.PHY_NEED_NAME]! += safeDecodedData[needType]
                    }else if Utils.SAFETY_NEEDS.contains(needType){
                        activityNeed[Utils.SAFETY_NEED_NAME]! += safeDecodedData[needType]
                    }else if Utils.LOVE_NEEDS.contains(needType){
                        activityNeed[Utils.LOVE_BELONGING_NEED_NAME]! += safeDecodedData[needType]
                    }else if Utils.ESTEEM_NEEDS.contains(needType){
                        activityNeed[Utils.ESTEEM_NEED_NAME]! += safeDecodedData[needType]
                    }else if Utils.SELF_ACTUAL_NEEDS.contains(needType){
                        activityNeed[Utils.SELF_ACTUAL_NEED_NAME]! += safeDecodedData[needType]
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
        legend.font = .systemFont(ofSize: 13.0)
        legend.xEntrySpace = 0
        legend.yEntrySpace = 10
        
    }
    
    private func pieChartColorGenerator(dataPoints:[String])->[UIColor]{
        var colors: [UIColor] = []
        for index in 0..<dataPoints.count{
            if dataPoints[index] == Utils.PHY_NEED_NAME{
                colors.append(phyColor)
            }else if dataPoints[index] == Utils.SAFETY_NEED_NAME{
                colors.append(safetyColor)
            }else if dataPoints[index] == Utils.LOVE_BELONGING_NEED_NAME{
                colors.append(loveColor)
            }else if dataPoints[index] == Utils.ESTEEM_NEED_NAME{
                colors.append(esteemColor)
            }else if dataPoints[index] == Utils.SELF_ACTUAL_NEED_NAME{
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
        
        let selfActualizationView = SelfActualizationView(frame: CGRect(x: 50,
                                                                        y: 100,
                                                                        width: width+10,
                                                                        height: height), date: selectedDate)
        
        let esteemView = EsteemView(frame: CGRect(x: 50, y:190, width: width+70, height: height), date: selectedDate)
        let loveBelongingView = LoveView(frame: CGRect(x: 50, y: 280, width: width+132, height: height), date: selectedDate)
        let safetyView = SafetyView(frame: CGRect(x: 50, y: 370, width: width + 190, height: height), date: selectedDate)
        let physiologicalView = PhysiologicalView(frame: CGRect(x: 50, y: 460, width: width + 250, height: height), date: selectedDate)
        
        backView.addSubview(pyramidTitle)
        backView.addSubview(selfActualizationView)
        backView.addSubview(esteemView)
        backView.addSubview(loveBelongingView)
        backView.addSubview(safetyView)
        backView.addSubview(physiologicalView)
        
        let phyTap = UITapGestureRecognizer(target: self, action: #selector(self.handlePhyTap(_:)))
        physiologicalView.addGestureRecognizer(phyTap)
        physiologicalView.isUserInteractionEnabled = true
        phyPopTip.show(text: Utils.PHY_NEED_NAME, direction: .none, maxWidth: 200, in: backView, from: backView.subviews[5].frame)
        phyPopTip.bubbleColor = phyColor
        
        let safetyTap = UITapGestureRecognizer(target: self, action: #selector(self.handleSafetyTap(_:)))
        safetyView.addGestureRecognizer(safetyTap)
        safetyView.isUserInteractionEnabled = true
        safetyPopTip.show(text: Utils.SAFETY_NEED_NAME, direction: .none, maxWidth: 200, in: backView, from: backView.subviews[4].frame)
        safetyPopTip.bubbleColor = safetyColor
        
        let loveTap = UITapGestureRecognizer(target: self, action: #selector(self.handleLoveTap(_:)))
        loveBelongingView.addGestureRecognizer(loveTap)
        loveBelongingView.isUserInteractionEnabled = true
        loveBelongingPopTip.show(text: Utils.LOVE_BELONGING_NEED_NAME, direction: .none, maxWidth: 200, in: backView, from: backView.subviews[3].frame)
        loveBelongingPopTip.bubbleColor = loveColor
        
        let esteemTap = UITapGestureRecognizer(target: self, action: #selector(self.handleEsteemTap(_:)))
        esteemView.addGestureRecognizer(esteemTap)
        esteemView.isUserInteractionEnabled = true
        esteemPopTip.show(text: Utils.ESTEEM_NEED_NAME, direction: .none, maxWidth: 200, in: backView, from: backView.subviews[2].frame)
        esteemPopTip.bubbleColor = esteemColor
        
        let selfActualizationTap = UITapGestureRecognizer(target: self, action: #selector(self.handleSelfActualizationTap(_:)))
        selfActualizationView.addGestureRecognizer(selfActualizationTap)
        selfActualizationView.isUserInteractionEnabled = true
        selfActualizationPopTip.show(text: Utils.SELF_ACTUAL_NEED_NAME, direction: .none, maxWidth: 200, in: backView, from: backView.subviews[1].frame)
        selfActualizationPopTip.bubbleColor = selfActualColor
    }

    private func displayInstruction(){
        PopUp.buildInstructionDialog(VC: self, message: Utils.RESULTS_INSTRUCTION_MSG)
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
        currSelectedNeedLevel = Utils.PHY_NEED_NAME
        DispatchQueue.main.asyncAfter(deadline: .now()+1, execute: {
            self.performSegue(withIdentifier: Utils.RESULTS_STATS_SEGUE, sender: self)
        })
    }
    
    @objc func handleSafetyTap(_ sender: UITapGestureRecognizer){
        currSelectedNeedLevel = Utils.SAFETY_NEED_NAME
        DispatchQueue.main.asyncAfter(deadline: .now()+1, execute: {
            self.performSegue(withIdentifier: Utils.RESULTS_STATS_SEGUE, sender: self)
        })
    }
    
    @objc func handleLoveTap(_ sender: UITapGestureRecognizer){
        currSelectedNeedLevel = Utils.LOVE_BELONGING_NEED_NAME
        DispatchQueue.main.asyncAfter(deadline: .now()+1, execute: {
            self.performSegue(withIdentifier: Utils.RESULTS_STATS_SEGUE, sender: self)
        })
    }
    
    @objc func handleEsteemTap(_ sender: UITapGestureRecognizer){
        currSelectedNeedLevel = Utils.ESTEEM_NEED_NAME
        DispatchQueue.main.asyncAfter(deadline: .now()+1, execute: {
            self.performSegue(withIdentifier: Utils.RESULTS_STATS_SEGUE, sender: self)
        })
    }
    
    @objc func handleSelfActualizationTap(_ sender: UITapGestureRecognizer){
        currSelectedNeedLevel = Utils.SELF_ACTUAL_NEED_NAME
        DispatchQueue.main.asyncAfter(deadline: .now()+1, execute: {
            self.performSegue(withIdentifier: Utils.RESULTS_STATS_SEGUE, sender: self)
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! NeedDetailViewController
        destinationVC.needCategoryLevel = currSelectedNeedLevel
        destinationVC.selectedDate = selectedDate
    }
}
