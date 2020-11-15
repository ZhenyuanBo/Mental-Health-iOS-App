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
    
    @IBOutlet weak var flipButton: UIBarButtonItem!
    
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
    
    @IBAction func downloadPressed(_ sender: UIBarButtonItem) {
        let image = pieChartView.getChartImage(transparent: false)
        UIImageWriteToSavedPhotosAlbum(image!, nil, nil, nil)
    }
    
    @IBAction func categoryPressed(_ sender: UIBarButtonItem) {
        flashCard.flip()
        if flashCard.backView!.isHidden{
            flipButton.title = "Category"
        }else{
            flipButton.title = "Chart"
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
        var selectedNeedCategory:[String] = []
        if  let safeDecodedData = decodedData{
            Utils.needTypeList.forEach { (need) in
                if safeDecodedData[need]{
                    selectedNeedCategory.append(need)
                }
            }
        }
        for topView in self.view.subviews as [UIView] {
            for lowerView in topView.subviews as [UIView]{
                for innerView in lowerView.subviews as [UIView]{
                    if let needButton = innerView as? UIButton {
                        let buttonLabel = needButton.titleLabel?.text
                        if buttonLabel == "personal security"{
                            if selectedNeedCategory.contains("personal_security"){
                                needButton.setTitleColor(.black, for: .normal)
                            }
                        }else if buttonLabel == "self-esteem"{
                            if selectedNeedCategory.contains("self_esteem"){
                                needButton.setTitleColor(.black, for: .normal)
                            }
                        }else if buttonLabel == "Self Actualization"{
                            if selectedNeedCategory.contains("self_actualization"){
                                needButton.setTitleColor(.black, for: .normal)
                            }
                        }else{
                            if selectedNeedCategory.contains(buttonLabel!){
                                needButton.setTitleColor(.black, for: .normal)
                            }
                        }
                    }
                }
            }
        }
    }
}
