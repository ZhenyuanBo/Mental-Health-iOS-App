import UIKit
import Charts
import RealmSwift

class ResultsViewController: UIViewController {
    
    let realm = try! Realm()
    
    @IBOutlet weak var pieChartTitle: UILabel!
    @IBOutlet weak var pieChartView: PieChartView!
    
    @IBOutlet weak var flashCard: FlashCardView!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var frontView: UIView!
    
    //MARK: - Need Buttons
    @IBOutlet weak var freedomBtn: UIButton!
    @IBOutlet weak var recognitionBtn: UIButton!
    @IBOutlet weak var respectBtn: UIButton!
    @IBOutlet weak var intimacyBtn: UIButton!
    @IBOutlet weak var friendshipBtn: UIButton!
    @IBOutlet weak var healthBtn: UIButton!
    @IBOutlet weak var propertyBtn: UIButton!
    @IBOutlet weak var selfActualizationBtn: UIButton!
    @IBOutlet weak var clothingBtn: UIButton!
    @IBOutlet weak var statusBtn: UIButton!
    @IBOutlet weak var familyBtn: UIButton!
    @IBOutlet weak var resourcesBtn: UIButton!
    @IBOutlet weak var reproductionBtn: UIButton!
    @IBOutlet weak var sleepBtn: UIButton!
    @IBOutlet weak var shelterBtn: UIButton!
    @IBOutlet weak var foodBtn: UIButton!
    @IBOutlet weak var waterBtn: UIButton!
    @IBOutlet weak var airBtn: UIButton!
    @IBOutlet weak var employmentBtn: UIButton!
    @IBOutlet weak var personalSecBtn: UIButton!
    @IBOutlet weak var connectionBtn: UIButton!
    @IBOutlet weak var selfEsteemBtn: UIButton!
    @IBOutlet weak var strengthBtn: UIButton!
    
    @IBOutlet weak var flipButton: UIButton!
    
    private var activityCategoryMap:[String: Int] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadNeedSelectionResult()
        
        flashCard.duration = 2.0
        flashCard.flipAnimation = .flipFromLeft
        flashCard.frontView = frontView
        flashCard.backView = backView
        
        pieChartTitle.text = "# of Activities/Need Category"
        let decodedData = loadNeedActivityResult(date: Date())
        if let safeDecodedData = decodedData{
            for needType in Utils.needTypeList{
                if safeDecodedData[needType] != 0{
                    activityCategoryMap[needType] = safeDecodedData[needType]
                }
            }
            customizeChart(dataPoints: Array(activityCategoryMap.keys), values: Array(activityCategoryMap.values))
        }
    }
    @IBAction func categoryViewPressed(_ sender: UIButton) {
        flashCard.flip()
        if flashCard.backView!.isHidden{
            flipButton.setTitle("Category", for: .normal)
        }else{
            flipButton.setTitle("Chart", for: .normal)
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

    func loadNeedSelectionResult(){
        let decodedData = loadNeedSelectionMap(date: Date())
        if let safeDecodedData = decodedData{
            Utils.needTypeList.forEach { (need) in
                if safeDecodedData[need]{
                    switch need{
                    case "air":airBtn.setTitleColor(.black, for: .normal)
                    case "water": waterBtn.setTitleColor(.black, for: .normal)
                    case "clothing": clothingBtn.setTitleColor(.black, for: .normal)
                    case "employment": employmentBtn.setTitleColor(.black, for: .normal)
                    case "food": foodBtn.setTitleColor(.black, for: .normal)
                    case "family": familyBtn.setTitleColor(.black, for: .normal)
                    case "freedom": freedomBtn.setTitleColor(.black, for: .normal)
                    case "friendship": friendshipBtn.setTitleColor(.black, for: .normal)
                    case "intimacy": intimacyBtn.setTitleColor(.black, for: .normal)
                    case "connection": connectionBtn.setTitleColor(.black, for: .normal)
                    case "health": healthBtn.setTitleColor(.black, for: .normal)
                    case "personal_security":personalSecBtn.setTitleColor(.black, for: .normal)
                    case "property": propertyBtn.setTitleColor(.black, for: .normal)
                    case "recognition":recognitionBtn.setTitleColor(.black, for: .normal)
                    case "reproduction":reproductionBtn.setTitleColor(.black, for: .normal)
                    case "resources": resourcesBtn.setTitleColor(.black, for: .normal)
                    case "respect": respectBtn.setTitleColor(.black, for: .normal)
                    case "self_actualization":selfActualizationBtn.setTitleColor(.black, for: .normal)
                    case "self_esteem":selfEsteemBtn.setTitleColor(.black, for: .normal)
                    case "shelter":shelterBtn.setTitleColor(.black, for: .normal)
                    case "sleep":sleepBtn.setTitleColor(.black, for: .normal)
                    case "status": statusBtn.setTitleColor(.black, for: .normal)
                    case "strength":strengthBtn.setTitleColor(.black, for: .normal)
                    default: fatalError("No button found for this type:\(need)")
                    }
                }
            }
        }
    }
}
