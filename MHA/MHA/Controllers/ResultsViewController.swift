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

class ResultsViewController: UIViewController, UIPopoverPresentationControllerDelegate{
    
    let realm = try! Realm()
    let popTip = PopTip()
    
    @IBOutlet weak var pieChartTitle: UILabel!
    @IBOutlet weak var pieChartView: PieChartView!
    
    @IBOutlet weak var flashCard: FlashCardView!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var frontView: UIView!
    
    @IBOutlet weak var flipButton: UIBarButtonItem!
    
    var selectedDate:Date = Date()
    
    private var currSelectedNeedLevel: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        flashCard.duration = 2.0
        flashCard.flipAnimation = .flipFromLeft
        flashCard.frontView = frontView
        flashCard.backView = backView
        
        pieChartTitle.text = "# of Activities/Need Category"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
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
        
        let selfActualizationView = SelfActualizationView(frame: CGRect(x: 150,
                                                                        y: 100,
                                                                        width: width,
                                                                        height: height), date: selectedDate)
        
        let esteemView = EsteemView(frame: CGRect(x: 130, y:190, width: width+40, height: height), date: selectedDate)
        let loveBelongingView = LoveView(frame: CGRect(x: 90, y: 280, width: width+120, height: height), date: selectedDate)
        let safetyView = SafetyView(frame: CGRect(x:45, y: 370, width: width + 210, height: height), date: selectedDate)
        let physiologicalView = PhysiologicalView(frame: CGRect(x: 10, y: 460, width: width + 280, height: height), date: selectedDate)
        
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
        loveBelongingView.addGestureRecognizer(loveTap)
        loveBelongingView.isUserInteractionEnabled = true
        
        let esteemTap = UITapGestureRecognizer(target: self, action: #selector(self.handleEsteemTap(_:)))
        esteemView.addGestureRecognizer(esteemTap)
        esteemView.isUserInteractionEnabled = true
        
        let selfActualizationTap = UITapGestureRecognizer(target: self, action: #selector(self.handleSelfActualizationTap(_:)))
        selfActualizationView.addGestureRecognizer(selfActualizationTap)
        selfActualizationView.isUserInteractionEnabled = true
    }
    
    @IBAction func downloadPressed(_ sender: UIBarButtonItem) {
        let image = pieChartView.getChartImage(transparent: false)
        UIImageWriteToSavedPhotosAlbum(image!, nil, nil, nil)
    }
    
    @IBAction func flipPressed(_ sender: UIBarButtonItem) {
        flashCard.flip()
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
                let phyColor = hexStringToUIColor(hex: Utils.needColourMap[Utils.phyNeeds]!)
                colors.append(phyColor)
            }else if Utils.safetyNeeds.contains(dataPoints[index]){
                let safetyColor = hexStringToUIColor(hex: Utils.needColourMap[Utils.safetyNeeds]!)
                colors.append(safetyColor)
            }else if Utils.loveNeeds.contains(dataPoints[index]){
                let loveColor = hexStringToUIColor(hex: Utils.needColourMap[Utils.loveNeeds]!)
                colors.append(loveColor)
            }else if Utils.esteemNeeds.contains(dataPoints[index]){
                let esteemColor = hexStringToUIColor(hex: Utils.needColourMap[Utils.esteemNeeds]!)
                colors.append(esteemColor)
            }else if Utils.selfActualNeeds.contains(dataPoints[index]){
                let selfActualColor = hexStringToUIColor(hex: Utils.needColourMap[Utils.selfActualNeeds]!)
                colors.append(selfActualColor)
            }
        }
        return colors
    }
    
    //MARK: - Handle Tap
    @objc func handlePhyTap(_ sender: UITapGestureRecognizer) {
        currSelectedNeedLevel = "physiological"
        popTip.show(text: "Physiological needs", direction: .none, maxWidth: 200, in: backView, from: backView.subviews[4].frame)
        DispatchQueue.main.asyncAfter(deadline: .now()+1, execute: {
            self.performSegue(withIdentifier: Utils.resultStatsSegue, sender: self)
        })
    }
    
    @objc func handleSafetyTap(_ sender: UITapGestureRecognizer){
        currSelectedNeedLevel = "safety"
        popTip.show(text: "Satefy needs", direction: .none, maxWidth: 200, in: backView, from: backView.subviews[3].frame)
        DispatchQueue.main.asyncAfter(deadline: .now()+1, execute: {
            self.performSegue(withIdentifier: Utils.resultStatsSegue, sender: self)
        })
    }
    
    @objc func handleLoveTap(_ sender: UITapGestureRecognizer){
        currSelectedNeedLevel = "love"
        popTip.show(text: "Love & Belonging", direction: .none, maxWidth: 200, in: backView, from: backView.subviews[2].frame)
        DispatchQueue.main.asyncAfter(deadline: .now()+1, execute: {
            self.performSegue(withIdentifier: Utils.resultStatsSegue, sender: self)
        })
    }
    
    @objc func handleEsteemTap(_ sender: UITapGestureRecognizer){
        currSelectedNeedLevel = "esteem"
        popTip.show(text: "Esteem", direction: .none, maxWidth: 200, in: backView, from: backView.subviews[1].frame)
        DispatchQueue.main.asyncAfter(deadline: .now()+1, execute: {
            self.performSegue(withIdentifier: Utils.resultStatsSegue, sender: self)
        })
    }
    
    @objc func handleSelfActualizationTap(_ sender: UITapGestureRecognizer){
        currSelectedNeedLevel = "selfActual"
        popTip.show(text: "Self-Actualization", direction: .none, maxWidth: 200, in: backView, from: backView.subviews[0].frame)
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
