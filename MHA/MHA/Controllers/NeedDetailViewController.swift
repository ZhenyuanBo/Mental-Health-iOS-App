/*
 Author: Zhenyuan Bo
 File Description: presents the detailed stats view for each Maslow hierarchy level
 Date: Nov 23, 2020
 */

import UIKit
import Charts

class NeedDetailViewController: UIViewController, ChartViewDelegate{
    
    @IBOutlet weak var flashCard: FlashCardView!
    
    @IBOutlet weak var frontView: UIView!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var barChartView: BarChartView!
    @IBOutlet weak var lineChartView: LineChartView!
    
    
    var needCategoryLevel: String = ""
    var selectedDate:Date = Date()
    var decodedData: DailyActivityData?
    
    var coloursList:[String] = []
    var chartDescription: String = ""
    var sortedColours:[UIColor] = []
    var categoryColours:[UIColor] = [UIColor.white, UIColor.white, UIColor.white, UIColor.white, UIColor.white, UIColor.white, UIColor.white]
    let lineChartColours: [String] = ["#583d72", "#db6400", "#db6400", "#fd3a69", "#61b15a", "#af6b58", "#16a596"]
    
    var categoryValue: [Int] = []
    var sortedCategoryValue:[Int] = []
    var categories:[String] = []
    var startIndex: Int = 0
    
    var categoryTrendData:[String:[Int]] = [:]
    var dates:[String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        decodedData = loadDailyActivityResult(date: selectedDate)
        
        flashCard.duration = 2.0
        flashCard.flipAnimation = .flipFromLeft
        flashCard.frontView = frontView
        flashCard.backView = backView
        
        //build bar chart
        buildBarChart()
        
        //build line chart
        buildLineChart()
        
        self.lineChartView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    @IBAction func flipPressed(_ sender: UIBarButtonItem) {
        flashCard.flip()
    }
    
    private func buildBarChart(){
        populateCategoryValue()
        drawBarChart(dataPoints: categories, values: categoryValue)
    }
    
    private func buildLineChart(){
        dates = Date.getDates(forLastNDays: 7)
        var formattedDates:[String] = []
        
        for date in dates{
            let dateObj = Date.getDate(dateStr: date)
            formattedDates.append((dateObj?.dateFormatter(format: "MM/dd"))!)
        }
        populateWeeklyCategoryValue()
        drawLineChart(dataPoints: formattedDates, categoryTrendValues: categoryTrendData)
    }
    
    private func drawLineChart(dataPoints: [String], categoryTrendValues: [String:[Int]]){
        var datasets:[LineChartDataSet] = []
        for category in categoryTrendValues.keys{
            var dataEntries: [ChartDataEntry] = []
            for i in 0..<dataPoints.count {
                let dataEntry = ChartDataEntry(x: Double(i), y: Double(categoryTrendValues[category]![i]))
                dataEntries.append(dataEntry)
            }
            let lineChartDataSet = LineChartDataSet(entries: dataEntries, label: category)
            lineChartDataSet.valueFont = UIFont(name: "HelveticaNeue-Light", size: 20) ?? UIFont.systemFont(ofSize: 20)
            lineChartDataSet.colors = [hexStringToUIColor(hex: lineChartColours[Int(arc4random_uniform(UInt32(lineChartColours.count)))])]
            datasets.append(lineChartDataSet)
        }
        
        let lineChartData = LineChartData(dataSets: datasets)
        lineChartView.data = lineChartData
        
        let formatter: CustomIntFormatter = CustomIntFormatter()
        lineChartView.data?.setValueFormatter(formatter)
        
        lineChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: dataPoints)
    }
    
    private func drawBarChart(dataPoints: [String], values: [Int]) {
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
        
        barChartView.leftAxis.axisMinimum = 0.0
        
        barChartView.legend.enabled = false
        barChartView.rightAxis.enabled = false
        barChartView.xAxis.drawGridLinesEnabled = false
        barChartView.scaleYEnabled = true
        barChartView.scaleXEnabled = true
        barChartView.doubleTapToZoomEnabled = false
        title = chartDescription
        barChartView.xAxis.labelPosition = XAxis.LabelPosition.top
        barChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: dataPoints)
        barChartView.xAxis.granularityEnabled = true
        barChartView.xAxis.granularity = 1.0
        barChartView.xAxis.labelRotationAngle = -45
        barChartView.xAxis.labelFont = .systemFont(ofSize: 12.0)
        
    }
    
    private func populateCategoryValue(){
        switch needCategoryLevel {
        case Utils.phyNeedName:
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
                categories = Utils.phyNeeds
                coloursList = Utils.phyNeedColoursList
                chartDescription = Utils.phyNeedName
            }
        case Utils.safetyNeedName:
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
                categories = Utils.safetyNeeds
                coloursList = Utils.safetyNeedColoursList
                chartDescription = Utils.safetyNeedName
            }
        case Utils.loveBelongingNeedName:
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
                categories = Utils.loveNeeds
                coloursList = Utils.loveNeedColoursList
                chartDescription = Utils.loveBelongingNeedName
            }
        case Utils.esteemNeedName:
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
                categories = Utils.esteemNeeds
                coloursList = Utils.esteemNeedColoursList
                chartDescription = Utils.esteemNeedName
            }
        case Utils.selfActualNeedName:
            if let safeDecodedData = decodedData{
                categoryValue = [Int](repeating: 0, count: 1)
                let needType = Utils.selfActualNeeds[0]
                if safeDecodedData[needType] != 0{
                    let index = Utils.selfActualIndexMap[needType]
                    categoryValue[index!] = safeDecodedData[needType]
                }
                sortedCategoryValue = categoryValue
                sortedCategoryValue.sort(){$0>$1}
                startIndex = 0
                categories = Utils.selfActualNeeds
                coloursList = Utils.selfActualNeedColoursList
                chartDescription = Utils.selfActualNeedName
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
    
    private func populateWeeklyCategoryValue(){
        for category in categories{
            var categoryValues:[Int] = []
            for date in dates{
                let dateObj = Date.getDate(dateStr: date)
                let decodedData = loadDailyActivityResult(date: dateObj!)
                if let safeDecodedData = decodedData{
                    categoryValues.append(safeDecodedData[category])
                }else{
                    categoryValues.append(0)
                }
            }
            categoryTrendData[category] = categoryValues
        }
    }
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        let selectedCategory = Array(categoryTrendData.keys)[highlight.dataSetIndex]
        let marker = ChartMarker()
        marker.setSelectedCategory(selectedCategory: selectedCategory)
        lineChartView.marker = marker
    }
}

//MARK: - Format chart data value to integer
class CustomIntFormatter: NSObject, IValueFormatter{
    public func stringForValue(_ value: Double, entry: ChartDataEntry, dataSetIndex: Int, viewPortHandler: ViewPortHandler?) -> String {
        let correctValue = Int(value)
        return String(correctValue)
    }
}

//MARK: - Custom Chart Marker
class ChartMarker: MarkerView {
    private var text = String()
    
    private var category = ""
    
    public func setSelectedCategory(selectedCategory: String){
        category = selectedCategory
    }
    
    private let drawAttributes: [NSAttributedString.Key: Any] = [
        .font: UIFont.systemFont(ofSize: 20),
        .foregroundColor: UIColor.white,
        .backgroundColor: UIColor.darkGray
    ]
    
    override func refreshContent(entry: ChartDataEntry, highlight: Highlight) {
        text = category
    }
    
    override func draw(context: CGContext, point: CGPoint) {
        super.draw(context: context, point: point)
        
        let sizeForDrawing = text.size(withAttributes: drawAttributes)
        bounds.size = sizeForDrawing
        offset = CGPoint(x: -sizeForDrawing.width / 2, y: -sizeForDrawing.height - 4)
        
        let offset = offsetForDrawing(atPoint: point)
        let originPoint = CGPoint(x: point.x + offset.x, y: point.y + offset.y)
        let rectForText = CGRect(origin: originPoint, size: sizeForDrawing)
        drawText(text: text, rect: rectForText, withAttributes: drawAttributes)
    }
    
    private func drawText(text: String, rect: CGRect, withAttributes attributes: [NSAttributedString.Key: Any]? = nil) {
        let size = bounds.size
        let centeredRect = CGRect(
            x: rect.origin.x + (rect.size.width - size.width) / 2,
            y: rect.origin.y + (rect.size.height - size.height) / 2,
            width: size.width,
            height: size.height
        )
        text.draw(in: centeredRect, withAttributes: attributes)
    }
}

