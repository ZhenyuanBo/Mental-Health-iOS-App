import UIKit
import Charts
import Foundation

class NeedDetailViewController: UIViewController {
    
    @IBOutlet weak var flashCardView: FlashCardView!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var barChartView: BarChartView!
    
    @IBOutlet weak var lineChartView: LineChartView!
    
    var needCategoryLevel: String = ""
    
    let decodedData = loadNeedActivityResult(date: Date())
    
    var activityCategoryMap = ["air": 0, "water": 0, "food": 0,
                               "clothing": 0, "shelter":0, "sleep": 0, "reproduction": 0]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        switch needCategoryLevel {
        case "physiological":
            if let safeDecodedData = decodedData{
                for needType in Utils.phyNeeds{
                    if safeDecodedData[needType] != 0{
                        activityCategoryMap[needType] = safeDecodedData[needType]
                    }
                }
            }
        case "safety":
            if let safeDecodedData = decodedData{
                for needType in Utils.safetyNeeds{
                    if safeDecodedData[needType] != 0{
                        activityCategoryMap[needType] = safeDecodedData[needType]
                    }
                }
            }
        case "love":
            if let safeDecodedData = decodedData{
                for needType in Utils.loveNeeds{
                    if safeDecodedData[needType] != 0{
                        activityCategoryMap[needType] = safeDecodedData[needType]
                    }
                }
            }
        case "esteem":
            if let safeDecodedData = decodedData{
                for needType in Utils.esteemNeeds{
                    if safeDecodedData[needType] != 0{
                        activityCategoryMap[needType] = safeDecodedData[needType]
                    }
                }
            }
        case "selfActual":
            if let safeDecodedData = decodedData{
                for needType in Utils.selfActualNeeds{
                    if safeDecodedData[needType] != 0{
                        activityCategoryMap[needType] = safeDecodedData[needType]
                    }
                }
            }
        default:
            fatalError("There is no such need category, \(needCategoryLevel)")
        }
        customizeChart(dataPoints: Array(activityCategoryMap.keys), values: Array(activityCategoryMap.values))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func customizeChart(dataPoints: [String], values: [Int]) {

        var dataEntries: [BarChartDataEntry] = []
        for i in 0..<dataPoints.count {
          let dataEntry = BarChartDataEntry(x: Double(i), y: Double(values[i]))
          dataEntries.append(dataEntry)
        }
        let chartDataSet = BarChartDataSet(entries: dataEntries, label: "Bar Chart View")
        let chartData = BarChartData(dataSet: chartDataSet)
        
        barChartView.data = chartData
        barChartView.xAxis.drawGridLinesEnabled = false
        barChartView.leftAxis.drawGridLinesEnabled = false
        barChartView.pinchZoomEnabled = true
        barChartView.scaleYEnabled = true
        barChartView.scaleXEnabled = true
        barChartView.highlighter = nil
        barChartView.doubleTapToZoomEnabled = true
        barChartView.chartDescription?.text = ""
        barChartView.rightAxis.enabled = false
        barChartView.xAxis.labelPosition = XAxis.LabelPosition.bottom
        barChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: dataPoints)
        barChartView.gridBackgroundColor = NSUIColor.gray
        barChartView.xAxis.labelFont = UIFont.systemFont(ofSize: 10)
    }
    
}
