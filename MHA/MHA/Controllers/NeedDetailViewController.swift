/*
 Author: Zhenyuan Bo
 File Description: present the detailed stats view for each Maslow hierarchy level
 Date: Nov 23, 2020
 */

import UIKit
import Charts
import Foundation

class NeedDetailViewController: UIViewController{
    
    @IBOutlet weak var flashCardView: FlashCardView!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var barChartView: BarChartView!
    
    @IBOutlet weak var lineChartView: LineChartView!
    
    
    var needCategoryLevel: String = ""
    
    let decodedData = loadDailyActivityResult(date: Date())
    
    var coloursList:[String] = []
    var chartDescription: String = ""
    var sortedColours:[UIColor] = []
    var categoryColours:[UIColor] = [UIColor.white, UIColor.white, UIColor.white, UIColor.white, UIColor.white, UIColor.white, UIColor.white]
    
    var categoryValue: [Int] = []
    var sortedCategoryValue:[Int] = []
    var dataPoints:[String] = []
    var startIndex: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        populateCategoryValue()
        customizeChart(dataPoints: dataPoints, values: categoryValue)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    private func customizeChart(dataPoints: [String], values: [Int]) {

        var dataEntries: [BarChartDataEntry] = []
        for i in 0..<dataPoints.count {
          let dataEntry = BarChartDataEntry(x: Double(i), y: Double(values[i]))
          dataEntries.append(dataEntry)
        }
    
        let chartDataSet = BarChartDataSet(entries: dataEntries)
        let chartData = BarChartData(dataSet: chartDataSet)
        
        chartDataSet.valueFont = UIFont(name: "HelveticaNeue-Light", size: 20) ?? UIFont.systemFont(ofSize: 20)

        barChartView.data = chartData
        categoryColorMaker(startIndex: startIndex, coloursList: coloursList)
        chartDataSet.colors = categoryColours
        
        let formatter: CustomIntFormatter = CustomIntFormatter()
        barChartView.data?.setValueFormatter(formatter)
        
        barChartView.legend.enabled = false
        barChartView.rightAxis.enabled = false
        barChartView.xAxis.drawGridLinesEnabled = false
        barChartView.scaleYEnabled = true
        barChartView.scaleXEnabled = true
        barChartView.doubleTapToZoomEnabled = false
        barChartView.chartDescription?.font = UIFont.systemFont(ofSize: 20)
        barChartView.chartDescription?.text = chartDescription
        barChartView.xAxis.labelPosition = XAxis.LabelPosition.top
        barChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: dataPoints)
        
    }
    
    private func populateCategoryValue(){
        switch needCategoryLevel {
        case "physiological":
            if let safeDecodedData = decodedData{
                categoryValue = [Int](repeating: 0, count: 7)
                for needType in Utils.phyNeeds{
                    if safeDecodedData[needType] != 0{
                        let index = Utils.phyCategoryIndexMap[needType]
                        categoryValue[index!] = safeDecodedData[needType]
                    }
                }
                sortedCategoryValue = categoryValue
                sortedCategoryValue.sort(){$0>$1}
                startIndex = 6
                dataPoints = Utils.phyNeeds
                coloursList = Utils.phyNeedColoursList
                chartDescription = "Physiological Needs"
            }
        case "safety":
            if let safeDecodedData = decodedData{
                categoryValue = [Int](repeating: 0, count: 5)
                for needType in Utils.safetyNeeds{
                    if safeDecodedData[needType] != 0{
                        let index = Utils.safetyIndexMap[needType]
                        categoryValue[index!] = safeDecodedData[needType]
                    }
                }
                sortedCategoryValue = categoryValue
                sortedCategoryValue.sort(){$0>$1}
                startIndex = 4
                dataPoints = Utils.safetyNeeds
                coloursList = Utils.safetyNeedColoursList
                chartDescription = "Safety Needs"
            }
        case "love":
            if let safeDecodedData = decodedData{
                categoryValue = [Int](repeating: 0, count: 4)
                for needType in Utils.loveNeeds{
                    if safeDecodedData[needType] != 0{
                        let index = Utils.loveIndexMap[needType]
                        categoryValue[index!] = safeDecodedData[needType]
                    }
                }
                sortedCategoryValue = categoryValue
                sortedCategoryValue.sort(){$0>$1}
                startIndex = 3
                dataPoints = Utils.loveNeeds
                coloursList = Utils.loveNeedColoursList
                chartDescription = "Love & Belonging"
            }
        case "esteem":
            if let safeDecodedData = decodedData{
                categoryValue = [Int](repeating: 0, count: 6)
                for needType in Utils.esteemNeeds{
                    if safeDecodedData[needType] != 0{
                        let index = Utils.esteemIndexMap[needType]
                        categoryValue[index!] = safeDecodedData[needType]
                    }
                }
                sortedCategoryValue = categoryValue
                sortedCategoryValue.sort(){$0>$1}
                startIndex = 5
                dataPoints = Utils.esteemNeeds
                coloursList = Utils.esteemNeedColoursList
                chartDescription = "Esteem"
            }
        case "selfActual":
            if let safeDecodedData = decodedData{
                categoryValue = [Int](repeating: 0, count: 1)
                let needType = Utils.selfActualNeeds[0]
                if safeDecodedData[needType] != 0{
                    let index = Utils.selfActualIndexMap[needType]
                    categoryValue[index!] = safeDecodedData[needType]
                }
                sortedCategoryValue = categoryValue
                sortedCategoryValue.sort(){$0>$1}
                startIndex = 1
                dataPoints = Utils.selfActualNeeds
                coloursList = Utils.selfActualNeedColoursList
                chartDescription = "Self-Actualization"
            }
        default:
            fatalError("There is no such need category, \(needCategoryLevel)")
        }
    }
    
    private func categoryColorMaker(startIndex: Int, coloursList: [String]){
        var i = startIndex
        let sortedCategoryValueCopy = self.sortedCategoryValue
        var prevMax = self.sortedCategoryValue.max()

        for value in sortedCategoryValue{
            if value == prevMax{
                sortedColours.append(hexStringToUIColor(hex: coloursList[i]))
            }else{
                i = i-1
                sortedColours.append(hexStringToUIColor(hex: coloursList[i]))
                self.sortedCategoryValue.removeFirst()
                prevMax = sortedCategoryValue.max()
            }
        }

        for index in 0..<sortedCategoryValueCopy.count{
            let currVal = sortedCategoryValueCopy[index]
            for pos in 0..<categoryValue.count{
                if categoryValue[pos] == currVal{
                    categoryColours[pos] = self.sortedColours[index]
                    categoryValue[pos] = -1
                    break
                }
            }
        }
    }
}

//MARK: - Format chart data value to integer
class CustomIntFormatter: NSObject, IValueFormatter{
    public func stringForValue(_ value: Double, entry: ChartDataEntry, dataSetIndex: Int, viewPortHandler: ViewPortHandler?) -> String {
        let correctValue = Int(value)
        return String(correctValue)
    }
}

