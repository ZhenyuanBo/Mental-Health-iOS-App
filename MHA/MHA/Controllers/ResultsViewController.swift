import UIKit
import Charts
import RealmSwift

class ResultsViewController: UIViewController {
    
    let realm = try! Realm()

    @IBOutlet weak var pieChartView: PieChartView!
    
    private var needList = ["air","water","food","clothing",
                            "shelter","sleep","reproduction",
                            "personal_security","employment",
                            "resources","property","health",
                            "family","respect", "status",
                            "friendship","self_esteem","recognition",
                            "strength","freedom","self_actualization"]
    
    private var activityCategoryMap:[String: Int] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()
        loadNeedActivityResult()
        customizeChart(dataPoints: Array(activityCategoryMap.keys), values: Array(activityCategoryMap.values))
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
    
    private func loadNeedActivityResult(){
        let currDate = Date().dateFormatter(format: "yyyy-MM-dd")
        let selectedNeedActivity = realm.objects(NeedActivity.self).filter("dateCreated = '\(currDate)'")
        if selectedNeedActivity.count > 0{
            let selectedNeedResult = selectedNeedActivity[0].numActivityResult
            let jsonData = selectedNeedResult.data(using: .utf8)!
            let decoder = JSONDecoder()
            do{
                let decodedData = try decoder.decode(NeedActivityData.self, from: jsonData)
                for need in needList{
                    if decodedData[need] != 0{
                        activityCategoryMap[need] = decodedData[need]
                    }
                }
            }catch{
                print("Error retrieving decoded need result data, \(error)")
            }
        }
    }
}
