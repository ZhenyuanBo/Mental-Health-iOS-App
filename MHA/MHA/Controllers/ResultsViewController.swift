import UIKit
import Charts
import RealmSwift

class ResultsViewController: UIViewController {
    
    let realm = try! Realm()
    
    @IBOutlet weak var pieChartTitle: UILabel!
    @IBOutlet weak var pieChartView: PieChartView!
    
    private var activityCategoryMap:[String: Int] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
    
    private func customizeChart(dataPoints: [String], values: [Int]) {
        
        var dataEntries: [ChartDataEntry] = []
        for i in 0..<dataPoints.count {
            let dataEntry = PieChartDataEntry(value: Double(values[i]), label: dataPoints[i], data: dataPoints[i] as AnyObject)
            dataEntries.append(dataEntry)
        }
        let pieChartDataSet = PieChartDataSet(entries: dataEntries, label: nil)
        pieChartDataSet.colors = colorsOfCharts(numbersOfColor: dataPoints.count)
        
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
    
    
    private func colorsOfCharts(numbersOfColor: Int) -> [UIColor] {
        var colors: [UIColor] = []
        for _ in 0..<numbersOfColor {
            let red = Double(arc4random_uniform(256))
            let green = Double(arc4random_uniform(256))
            let blue = Double(arc4random_uniform(256))
            let color = UIColor(red: CGFloat(red/255), green: CGFloat(green/255), blue: CGFloat(blue/255), alpha: 1)
            colors.append(color)
        }
        return colors
    }
    
    //    func loadNeedResult(){
    //        let currDate = Date().dateFormatter(format: "yyyy-MM-dd")
    //        let selectedNeed = realm.objects(Need.self).filter("dateCreated = '\(currDate)'")
    //        if selectedNeed.count > 0{
    //            let selectedNeedResult = selectedNeed[0].needResult
    //            let jsonData = selectedNeedResult.data(using: .utf8)!
    //            let decoder = JSONDecoder()
    //            do{
    //                let decodedData = try decoder.decode(NeedData.self, from: jsonData)
    //                pyramidBtnPressedMap.keys.forEach { (key) in
    //                    if decodedData[key]{
    //                        pyramidBtnPressedMap[key] = true
    //                        switch key{
    //                        case "air":airBtn.setTitleColor(.black, for: .normal)
    //                        case "water": waterBtn.setTitleColor(.black, for: .normal)
    //                        case "clothing": clothingBtn.setTitleColor(.black, for: .normal)
    //                        case "employment": employmentBtn.setTitleColor(.black, for: .normal)
    //                        case "food": foodBtn.setTitleColor(.black, for: .normal)
    //                        case "freedom": freedomBtn.setTitleColor(.black, for: .normal)
    //                        case "health": healthBtn.setTitleColor(.black, for: .normal)
    //                        case "personal_security":personalSecBtn.setTitleColor(.black, for: .normal)
    //                        case "recognition":recognitionBtn.setTitleColor(.black, for: .normal)
    //                        case "reproduction":reproductionBtn.setTitleColor(.black, for: .normal)
    //                        case "resources": resourcesBtn.setTitleColor(.black, for: .normal)
    //                        case "respect": respectBtn.setTitleColor(.black, for: .normal)
    //                        case "self_actualization":selfActualizationBtn.setTitleColor(.black, for: .normal)
    //                        case "self_esteem":selfEsteemBtn.setTitleColor(.black, for: .normal)
    //                        case "shelter":shelterBtn.setTitleColor(.black, for: .normal)
    //                        case "sleep":sleepBtn.setTitleColor(.black, for: .normal)
    //                        case "status": statusBtn.setTitleColor(.black, for: .normal)
    //                        case "strength":strengthBtn.setTitleColor(.black, for: .normal)
    //                        default: fatalError("No button found for this type:\(key)")
    //                        }
    //                    }
    //                }
    //            }catch{
    //                print("Error retrieving decoded need result data, \(error)")
    //            }
    //        }
    //    }
    
}
