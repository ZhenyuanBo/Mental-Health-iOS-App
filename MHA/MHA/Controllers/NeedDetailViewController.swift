import UIKit
import Charts
import AMPopTip
import Foundation

class NeedDetailViewController: UIViewController{
    
    @IBOutlet weak var flashCardView: FlashCardView!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var barChartView: BarChartView!
    
    @IBOutlet weak var lineChartView: LineChartView!
    
    
    var needCategoryLevel: String = ""
    
    let popTip = PopTip()
    
    let decodedData = loadNeedActivityResult(date: Date())
    
    var phyCategoryIndexMap = ["reproduction": 0, "air": 1, "shelter": 2,
                            "sleep": 3, "water": 4, "food": 5, "clothing": 6]
    
    var phyCategoryList = ["reproduction","air","shelter","sleep","water","food","clothing"]
    
    var phyCategoryValue = [0, 0, 0, 0, 0, 0, 0]
    
    var phyCategoryValueSorted:[Int] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        switch needCategoryLevel {
        case "physiological":
            if let safeDecodedData = decodedData{
                for needType in Utils.phyNeeds{
                    if safeDecodedData[needType] != 0{
                        let index = phyCategoryIndexMap[needType]
                        phyCategoryValue[index!] = safeDecodedData[needType]
//                        phyCategoryValueSorted[index!] = safeDecodedData[needType]
                    }
                }
                phyCategoryValueSorted = phyCategoryValue
                phyCategoryValueSorted.sort(){$0>$1}
            }
//        case "safety":
//            if let safeDecodedData = decodedData{
//                for needType in Utils.safetyNeeds{
//                    if safeDecodedData[needType] != 0{
//                        activityCategoryMap[needType] = safeDecodedData[needType]
//                    }
//                }
//            }
//        case "love":
//            if let safeDecodedData = decodedData{
//                for needType in Utils.loveNeeds{
//                    if safeDecodedData[needType] != 0{
//                        activityCategoryMap[needType] = safeDecodedData[needType]
//                    }
//                }
//            }
//        case "esteem":
//            if let safeDecodedData = decodedData{
//                for needType in Utils.esteemNeeds{
//                    if safeDecodedData[needType] != 0{
//                        activityCategoryMap[needType] = safeDecodedData[needType]
//                    }
//                }
//            }
//        case "selfActual":
//            if let safeDecodedData = decodedData{
//                for needType in Utils.selfActualNeeds{
//                    if safeDecodedData[needType] != 0{
//                        activityCategoryMap[needType] = safeDecodedData[needType]
//                    }
//                }
//            }
        default:
            fatalError("There is no such need category, \(needCategoryLevel)")
        }
        
        customizeChart(dataPoints: phyCategoryList, values: phyCategoryValue)
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
        let chartDataSet = BarChartDataSet(entries: dataEntries, label: "Physiological Need View")
        let chartData = BarChartData(dataSet: chartDataSet)
        
        chartDataSet.valueFont = UIFont(name: "HelveticaNeue-Light", size: 20) ?? UIFont.systemFont(ofSize: 20)
        
        barChartView.data = chartData
        
        var sortedColors:[UIColor] = []
        var categoryColors:[UIColor] = [UIColor.white, UIColor.white, UIColor.white, UIColor.white, UIColor.white, UIColor.white, UIColor.white]
//
//        var i=6
//        let phyCategoryValueSortedCopy = phyCategoryValueSorted
//        var prevMax = phyCategoryValueSorted.max()
//
//        for value in phyCategoryValueSorted{
//            if value == prevMax{
//                sortedColors.append(hexStringToUIColor(hex: Utils.phyNeedColoursList[i]))
//            }else{
//                i = i-1
//                sortedColors.append(hexStringToUIColor(hex: Utils.phyNeedColoursList[i]))
//                phyCategoryValueSorted.removeFirst()
//                prevMax = phyCategoryValueSorted.max()
//            }
//        }
//
//        for index in 0..<phyCategoryValueSortedCopy.count{
//            var currVal = phyCategoryValueSortedCopy[index]
//            for pos in 0..<phyCategoryValue.count{
//                if phyCategoryValue[pos] == currVal{
//                    categoryColors[pos] = sortedColors[index]
//                    phyCategoryValue[pos] = -1
//                    break
//                }
//            }
//        }

//        chartDataSet.colors = categoryColors
        
        
        
        chartDataSet.colors = [UIColor.red,UIColor.orange,UIColor.green,UIColor.red,UIColor.blue, UIColor.red, UIColor.red]
        
        let formatter: CustomIntFormatter = CustomIntFormatter()
        barChartView.data?.setValueFormatter(formatter)
        
        barChartView.rightAxis.enabled = false
        barChartView.xAxis.drawGridLinesEnabled = false
        barChartView.scaleYEnabled = true
        barChartView.scaleXEnabled = true
        barChartView.doubleTapToZoomEnabled = false
        barChartView.chartDescription?.text = ""
        barChartView.xAxis.labelPosition = XAxis.LabelPosition.top
        barChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: dataPoints)
    }
}

//MARK: - Format chart data value to integer
class CustomIntFormatter: NSObject, IValueFormatter{
    public func stringForValue(_ value: Double, entry: ChartDataEntry, dataSetIndex: Int, viewPortHandler: ViewPortHandler?) -> String {
        let correctValue = Int(value)
        return String(correctValue)
    }
}

