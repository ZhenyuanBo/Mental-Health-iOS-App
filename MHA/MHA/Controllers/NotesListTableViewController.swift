import UIKit
import MJRefresh
import RealmSwift

class NotesListTableViewController: UITableViewController {

    @IBOutlet weak var currentYearButton: UIBarButtonItem!
    
    let realm = try! Realm()
    var historyNotes: Results<HistoryNote>?
    
    let dateFormat = "yyyy-MM-dd"

    let weekCellHeight: CGFloat = 40
    let eventCellHeight: CGFloat = 55
    let imageCellHeight: CGFloat = 120
    
    var pageSize = 10
    var startIndex = 0, endIndex = 0
    var cellHeightMap: [String:CGFloat] = [:]
    var tableData: [NoteCell] = []
    var noteLists: [String: [NoteActivityCell]] = [:]

    var isFirstTimeLoading = true
    
    
    // MARK: - View lifecycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
//        refreshData()
        initializeData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadNotes()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        saveNote()
    }

    // MARK: - Data Init & Table View Data Source
    private func initializeData() {
        if startIndex == 0{
            loadRefresh(number: pageSize/2, direction: false)
        }
        if endIndex == 0{
            loadRefresh(number: pageSize, direction: true)
        }
        if isFirstTimeLoading{
            let weekIndex = Date().firstDayOfWeek().getAsFormat(format: dateFormat)
            if !cellHeightMap.keys.contains(weekIndex){
                cellHeightMap[weekIndex] = weekCellHeight
            }
            cellHeightMap[weekIndex]! += (eventCellHeight+1)
            isFirstTimeLoading = false
            self.navigationItem.leftBarButtonItem?.title = Date().getAsFormat(format: "yyyy/MM")
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        if tableData[indexPath.row].cellType == .week{
            let weekCell = tableView.dequeueReusableCell(withIdentifier: Utils.weekCell, for: indexPath) as! WeekCell
            switch tableData[indexPath.row].cellContent {
                case .weekRange(let start, let end, _, _):
                    weekCell.weekLabel.text = "\(start) - \(end)"
                default:
                    fatalError("Table data type incompatible!")
            }
            cell = weekCell
        }else if tableData[indexPath.row].cellType == .month{
            let monCell = tableView.dequeueReusableCell(withIdentifier: Utils.monthCell, for: indexPath) as! MonthCell
            switch tableData[indexPath.row].cellContent {
                case .monthImg(let img):
                    monCell.monthImgView.image = img
                default:
                    fatalError("Table data type incompatible!")
            }
            cell = monCell
        }
        
        //display each single day within this week
        
//        let evWidth = cell.bounds.width - 100
//        let evX = cell.bounds.minX + 10
//        let index = tableData[indexPath.row].id
//        if eventViews.keys.contains(index){
//            eventViews[index]!.sort(by: {$0.sequenceNumber! < $1.sequenceNumber!})
//            for (index, view) in eventViews[index]!.enumerated() {
//                var evY = cell.bounds.minY + weekCellHeight
//                evY += (CGFloat(index) * (eventViewHeight + 1))
//                view.frame = CGRect(x: evX, y: evY, width: evWidth, height: eventViewHeight)
//                cell.addSubview(view)
//            }
//            
//        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        var cellHeight: CGFloat = 0
        if tableData[indexPath.row].cellType == .week {
            let cellId = tableData[indexPath.row].cellId
            guard let height = cellHeightMap[cellId] else {
                fatalError("Cell height not set, id = \(cellId)")
            }
            cellHeight = height
        }else if tableData[indexPath.row].cellType == .month{
            cellHeight = imageCellHeight
        }
        return cellHeight
    }
    
    // MARK: - Data Refresh Handlers
    
    private func refreshData() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.mj_header = MJRefreshGifHeader()
        tableView.mj_header?.setRefreshingTarget(self, refreshingAction: #selector(downPullRefresh))
        tableView.mj_footer = MJRefreshAutoGifFooter()
        tableView.mj_footer?.setRefreshingTarget(self, refreshingAction: #selector(upPullRefresh))
    }
    
    @objc private func downPullRefresh() {
        loadRefresh(number: pageSize, direction: false)
        updateYearButton()
    }
   
    @objc private func upPullRefresh() {
        loadRefresh(number: pageSize, direction: true)
        updateYearButton()
    }
    
    private func populateTableData(cellId: String, cellType: CellType, cellContent: CellContent, dir: Bool){
        if dir{
            tableData.append(NoteCell(cellId: cellId, cellType: cellType, cellContent: cellContent))
        }else{
            tableData.insert(NoteCell(cellId: cellId, cellType: cellType, cellContent: cellContent), at: 0)
        }
    }
    
    private func loadRefresh(number: Int, direction: Bool){

        if direction {
            for i in (endIndex ..< (endIndex + number)){
                let date = Date().daysOffset(by: 7 * i)
                print(date)
                print(i)
                let firstDay = date.firstDayOfWeek()
                let lastDay = date.lastDayOfWeek()
                let monStart = Utils.monthMap[Int(firstDay.getAsFormat(format: "M"))!]!
                let monEnd = Utils.monthMap[Int(lastDay.getAsFormat(format: "M"))!]!

                let id = firstDay.getAsFormat(format: dateFormat)
                
                if monStart == monEnd {
                    populateTableData(cellId: id, cellType: .week, cellContent: CellContent.weekRange("\(monStart) \(firstDay.getAsFormat(format:"d"))", "\(lastDay.getAsFormat(format: "d"))", firstDay, lastDay), dir: direction)
                    endIndex += 1
                    
                    if !cellHeightMap.keys.contains(id){
                        cellHeightMap[id] = weekCellHeight
                    }

                    if lastDay.getAsFormat(format: "yyyyMMdd") == date.lastDayOfMonth().getAsFormat(format: "yyyyMMdd") {
                        var index = Int(monEnd)! + 1
                        if index == 12 { index = 1 }
                        populateTableData(cellId: "\(id)-mon", cellType:.month, cellContent: CellContent.monthImg(UIImage(named: monStart)!), dir: direction)
                        endIndex += 1
                    }
                    print(endIndex)
                }else {
                    populateTableData(cellId: id, cellType: .week, cellContent: CellContent.weekRange("\(monStart) \(firstDay.getAsFormat(format:"d"))", "\(lastDay.getAsFormat(format: "d"))", firstDay, lastDay), dir:direction)
                    endIndex += 1
                    if !cellHeightMap.keys.contains(id) {
                        cellHeightMap[id] = weekCellHeight
                    }
                    populateTableData(cellId: "\(id)-mon", cellType:.month, cellContent: CellContent.monthImg(UIImage(named: monEnd)!), dir: direction)
                    endIndex += 1
                }
            }
            tableView.reloadData()
//            tableView.mj_footer!.endRefreshing()
        }else {
            for i in ((startIndex - number) ..< startIndex).reversed(){
                let date = Date().daysOffset(by: 7 * i)
                let firstDay = date.firstDayOfWeek()
                let lastDay = date.lastDayOfWeek()
                let monStart = Utils.monthMap[Int(firstDay.getAsFormat(format: "M"))!]!
                let monEnd = Utils.monthMap[Int(lastDay.getAsFormat(format: "M"))!]!

                let id = firstDay.getAsFormat(format: dateFormat)

                if monStart == monEnd {
                    populateTableData(cellId: id, cellType: .week, cellContent: CellContent.weekRange("\(monStart) \(firstDay.getAsFormat(format:"d"))", "\(lastDay.getAsFormat(format: "d"))", firstDay, lastDay), dir: direction)
                    startIndex -= 1
                    if !cellHeightMap.keys.contains(id) {
                        cellHeightMap[id] = weekCellHeight
                    }
                    if firstDay.getAsFormat(format: "yyyyMMdd") == date.firstDayOfMonth().getAsFormat(format: "yyyyMMdd") {
                        populateTableData(cellId: "\(id)-mon", cellType: .month, cellContent: CellContent.monthImg(UIImage(named: monStart)!), dir: direction)
                        startIndex -= 1
                    }
                } else {
                    populateTableData(cellId: "\(id)-mon", cellType: .month, cellContent: CellContent.monthImg(UIImage(named: monEnd)!), dir: direction)
                    populateTableData(cellId: id, cellType: .week, cellContent: CellContent.weekRange("\(monStart) \(firstDay.getAsFormat(format:"d"))", "\(lastDay.getAsFormat(format: "d"))", firstDay, lastDay), dir: direction)
                    startIndex -= 2
                    if !cellHeightMap.keys.contains(id) {
                        cellHeightMap[id] = weekCellHeight
                    }
                }
            }
            tableView.reloadData()
//            tableView.mj_header!.endRefreshing()
        }
    }
    
   
    

    // MARK: - Core data handlers
    private func loadNotes() {}
    private func saveNote() {}

    
    
    // MARK: - View Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {}
    
    
    // MARK: - Actions
    @IBAction func backToToday(_ sender: UIBarButtonItem) {
//        tableView.scrollToRow(at: findToday(), at: .middle, animated: true)
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        updateLeftBarButtonItemTitle()
    }
    
    
    //MARK: - Other Actions
    private func updateYearButton() {}
    
//    private func findToday() -> IndexPath {
////        let index = today.startDate.firstDayOfWeek().getAsFormat(format: dateIndexFormat)
////        let todayIndex = tableData.firstIndex(where: {cellData in
////            return cellData.id == index
////        })
////        guard todayIndex != nil else {
////            fatalError("Today index not found!")
////        }
////        return IndexPath(row: todayIndex!, section: 0)
//        return 0
//    }
    
 
}
