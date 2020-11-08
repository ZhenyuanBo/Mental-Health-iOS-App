import UIKit
import MJRefresh
import RealmSwift

class NotesListTableViewController: UITableViewController {

    @IBOutlet weak var currentYearButton: UIBarButtonItem!
    
//    let realm = try! Realm()
//    var historyNotes: Results<HistoryNote>?
    
    let dateFormat = "yyyy-MM-dd"

    let weekCellHeight: CGFloat = 40
    let imageCellHeight: CGFloat = 120
    
    var pageSize = 10
    var startIndex = 0, endIndex = 0
    var cellHeightMap: [String:CGFloat] = [:]
    var tableData: [NoteCell] = []
    var selectedCell:NoteCell?

    var isFirstTimeLoading = true
    
    
    // MARK: - View lifecycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
        refreshData()
        initializeData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Data Init & Table View Data Source / Delegate Methods
    private func initializeData() {
        if startIndex == 0{
            loadRefresh(number: pageSize/2, scrollDir: Utils.downDirection)
        }
        if endIndex == 0{
            loadRefresh(number: pageSize, scrollDir: Utils.upDirection)
        }
        if isFirstTimeLoading{
            let weekIndex = Date().firstDayOfWeek().dateFormatter(format: dateFormat)
            if !cellHeightMap.keys.contains(weekIndex){
                cellHeightMap[weekIndex] = weekCellHeight
            }
            isFirstTimeLoading = false
            self.navigationItem.leftBarButtonItem?.title = Date().dateFormatter(format: "yyyy/MM")
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
                    let monWKStartDate = start.components(separatedBy: " ")
                    weekCell.monthLabel.text = monWKStartDate[0]
                    weekCell.monthView.backgroundColor = hexStringToUIColor(hex: Utils.monthColourMap[monWKStartDate[0]]!)
                    weekCell.dateRangeLabel.text = "\(monWKStartDate[1]) - \(end)"
                default:
                    fatalError("The current cell is not a week cell!")
            }
            cell = weekCell
        }else if tableData[indexPath.row].cellType == .month{
            let monCell = tableView.dequeueReusableCell(withIdentifier: Utils.monthCell, for: indexPath) as! MonthCell
            switch tableData[indexPath.row].cellContent {
                case .monthImg(let img):
                    monCell.monthImgView.image = img
                default:
                    fatalError("The current cell is not a month cell!")
            }
            cell = monCell
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        var cellHeight: CGFloat = 0
        if tableData[indexPath.row].cellType == .week {
            let cellId = tableData[indexPath.row].cellId
            guard let height = cellHeightMap[cellId] else {
                fatalError("Invalid Cell Height, id = \(cellId)")
            }
            cellHeight = height
        }else if tableData[indexPath.row].cellType == .month{
            cellHeight = imageCellHeight
        }
        return cellHeight
    }
    
    //MARK: - Navigate to Daily Notes View
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedCell = tableData[indexPath.row]
        performSegue(withIdentifier: Utils.dailyNotesSegue, sender: self)
    }
    
    // MARK: - View Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! DailyNotesTableViewController
        if let cell = selectedCell{
            if cell.cellType == .week{
                switch cell.cellContent{
                case .weekRange(let start,_, let firstDay, let lastDay):
                    destinationVC.firstDay = firstDay.dateFormatter(format: "d")
                    destinationVC.lastDay = lastDay.dateFormatter(format: "d")
                    destinationVC.year = firstDay.dateFormatter(format: "yyyy")
                    destinationVC.month = start.components(separatedBy: " ")[0]
                default:
                    fatalError("The selected cell is not a week cell!")
                }
            }
        }
    }

    // MARK: - Data Refresh Handlers
    
    private func refreshData() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.mj_header = MJRefreshGifHeader()
        tableView.mj_header?.setRefreshingTarget(self, refreshingAction: #selector(scrollDownRefresh))
        tableView.mj_footer = MJRefreshAutoGifFooter()
        tableView.mj_footer?.setRefreshingTarget(self, refreshingAction: #selector(scrollUpRefresh))
    }
    
    @objc private func scrollDownRefresh() {
        loadRefresh(number: pageSize, scrollDir: Utils.downDirection)
        updateMonYearTitle()
    }
   
    @objc private func scrollUpRefresh() {
        loadRefresh(number: pageSize, scrollDir: Utils.upDirection)
        updateMonYearTitle()
    }
    
    private func populateTableData(cellId: String, cellType: CellType, cellContent: CellContent, dir: String){
        if dir == "up"{
            tableData.append(NoteCell(cellId: cellId, cellType: cellType, cellContent: cellContent))
        }else if dir == "down"{
            tableData.insert(NoteCell(cellId: cellId, cellType: cellType, cellContent: cellContent), at: 0)
        }
    }
    
    private func loadRefresh(number: Int, scrollDir: String){

        if scrollDir == "up" {
            for i in (endIndex ..< (endIndex + number)){
                let date = Date().daysOffset(by: 7 * i)
                let firstDay = date.firstDayOfWeek()
                let lastDay = date.lastDayOfWeek()
                let monStart = Utils.monthMap[Int(firstDay.dateFormatter(format: "M"))!]!
                let monEnd = Utils.monthMap[Int(lastDay.dateFormatter(format: "M"))!]!

                let id = firstDay.dateFormatter(format: dateFormat)
                
                if monStart == monEnd {
                    populateTableData(cellId: id, cellType: .week, cellContent: CellContent.weekRange("\(monStart) \(firstDay.dateFormatter(format:"d"))", "\(lastDay.dateFormatter(format: "d"))", firstDay, lastDay), dir: scrollDir)
                    endIndex += 1
                    
                    if !cellHeightMap.keys.contains(id){
                        cellHeightMap[id] = weekCellHeight
                    }

                    if lastDay.dateFormatter(format: "yyyyMMdd") == date.lastDayOfMonth().dateFormatter(format: "yyyyMMdd") {
                        var index = Int(monEnd)! + 1
                        if index == 12 { index = 1 }
                        populateTableData(cellId: "\(id)m", cellType:.month, cellContent: CellContent.monthImg(UIImage(named: monStart)!), dir: scrollDir)
                        endIndex += 1
                    }
                }else {
                    populateTableData(cellId: id, cellType: .week, cellContent: CellContent.weekRange("\(monStart) \(firstDay.dateFormatter(format:"d"))", "\(lastDay.dateFormatter(format: "d"))", firstDay, lastDay), dir:scrollDir)
                    endIndex += 1
                    if !cellHeightMap.keys.contains(id) {
                        cellHeightMap[id] = weekCellHeight
                    }
                    populateTableData(cellId: id, cellType:.month, cellContent: CellContent.monthImg(UIImage(named: monEnd)!), dir: scrollDir)
                    endIndex += 1
                }
            }
            tableView.reloadData()
            tableView.mj_footer!.endRefreshing()
        }else {
            for i in ((startIndex - number) ..< startIndex).reversed(){
                let date = Date().daysOffset(by: 7 * i)
                let firstDay = date.firstDayOfWeek()
                let lastDay = date.lastDayOfWeek()
                let monStart = Utils.monthMap[Int(firstDay.dateFormatter(format: "M"))!]!
                let monEnd = Utils.monthMap[Int(lastDay.dateFormatter(format: "M"))!]!

                let id = firstDay.dateFormatter(format: dateFormat)

                if monStart == monEnd {
                    populateTableData(cellId: id, cellType: .week, cellContent: CellContent.weekRange("\(monStart) \(firstDay.dateFormatter(format:"d"))", "\(lastDay.dateFormatter(format: "d"))", firstDay, lastDay), dir: scrollDir)
                    startIndex -= 1
                    if !cellHeightMap.keys.contains(id) {
                        cellHeightMap[id] = weekCellHeight
                    }
                    if firstDay.dateFormatter(format: "yyyyMMdd") == date.firstDayOfMonth().dateFormatter(format: "yyyyMMdd") {
                        populateTableData(cellId: id, cellType: .month, cellContent: CellContent.monthImg(UIImage(named: monStart)!), dir: scrollDir)
                        startIndex -= 1
                    }
                } else {
                    populateTableData(cellId: id, cellType: .month, cellContent: CellContent.monthImg(UIImage(named: monEnd)!), dir: scrollDir)
                    populateTableData(cellId: id, cellType: .week, cellContent: CellContent.weekRange("\(monStart) \(firstDay.dateFormatter(format:"d"))", "\(lastDay.dateFormatter(format: "d"))", firstDay, lastDay), dir: scrollDir)
                    startIndex -= 2
                    if !cellHeightMap.keys.contains(id) {
                        cellHeightMap[id] = weekCellHeight
                    }
                }
            }
            tableView.reloadData()
            tableView.mj_header!.endRefreshing()
        }
    }
    
    
    // MARK: - Actions
    private func updateMonYearTitle() {
        guard let indexes = tableView.indexPathsForVisibleRows else {
            fatalError("No rows available!")
        }
        if indexes.count > 0 {
            let indexPath = indexes[Int(indexes.count / 3)]
            if tableData[indexPath.row].cellType == .week{
                switch tableData[indexPath.row].cellContent{
                case .weekRange(_, _, let start, _):
                    self.navigationItem.leftBarButtonItem?.title = start.dateFormatter(format: "yyyy/MM")
                default: fatalError("Cell content is invalid")
                }
            }
        }
    }
    
    
    @IBAction func currentWKPressed(_ sender: UIBarButtonItem) {
        tableView.scrollToRow(at: findCurrentWK(), at: .middle, animated: true)
    }
    
    private func findCurrentWK() -> IndexPath{
        let index = Date().firstDayOfWeek().dateFormatter(format: dateFormat)
        let currWKIndex = tableData.firstIndex { (notecell) -> Bool in
            notecell.cellId == index
        }
        return IndexPath(row: currWKIndex!, section: 0)
    }
}
