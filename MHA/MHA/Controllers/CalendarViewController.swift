import UIKit
import CalendarKit
import DateToolsSwift
import RealmSwift

class CalendarViewController: DayViewController, DatePickerControllerDelegate {
    
    let realm = try! Realm()

    var generatedEvents = [EventDescriptor]()
    var alreadyGeneratedSet = Set<Date>()
    var selectedActivitiyText: String?
    var selectedDate: Date?
    
    var colors = [UIColor.blue,
                  UIColor.yellow,
                  UIColor.green,
                  UIColor.red]
    
    lazy var customCalendar: Calendar = {
        let customNSCalendar = NSCalendar(identifier: NSCalendar.Identifier.gregorian)!
        customNSCalendar.timeZone = TimeZone(abbreviation: "EST")!
        let calendar = customNSCalendar as Calendar
        return calendar
    }()
    
    override func loadView() {
        calendar = customCalendar
        dayView = DayView(calendar: calendar)
        view = dayView
    }
    
    @IBAction func unwind(_ unwindSegue: UIStoryboardSegue) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Calendar"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Change Date",
                                                           style: .plain,
                                                           target: self,
                                                           action: #selector(presentDatePicker))
        navigationController?.navigationBar.isTranslucent = false
        dayView.autoScrollToFirstEvent = true
        reloadData()
    }
    
    @objc func presentDatePicker() {
        let picker = DatePickerController()
        picker.date = dayView.state!.selectedDate
        picker.delegate = self
        let navC = UINavigationController(rootViewController: picker)
        navigationController?.present(navC, animated: true, completion: nil)
        //    let picker = DatePickerController()
        //    //    let calendar = dayView.calendar
        //    //    picker.calendar = calendar
        //    //    picker.date = dayView.state!.selectedDate
        //    picker.datePicker.timeZone = TimeZone(secondsFromGMT: 0)!
        //    picker.delegate = self
        //    let navC = UINavigationController(rootViewController: picker)
        //    navigationController?.present(navC, animated: true, completion: nil)
    }
    
    func datePicker(controller: DatePickerController, didSelect date: Date?) {
        if let date = date {
            var utcCalendar = Calendar(identifier: .gregorian)
            utcCalendar.timeZone = TimeZone(secondsFromGMT: 0)!
            
            let offsetDate = dateOnly(date: date, calendar: dayView.calendar)
            
            print(offsetDate)
            dayView.state?.move(to: offsetDate)
        }
        controller.dismiss(animated: true, completion: nil)
    }
    
    func dateOnly(date: Date, calendar: Calendar) -> Date {
        let yearComponent = calendar.component(.year, from: date)
        let monthComponent = calendar.component(.month, from: date)
        let dayComponent = calendar.component(.day, from: date)
        let zone = calendar.timeZone
        
        let newComponents = DateComponents(timeZone: zone,
                                           year: yearComponent,
                                           month: monthComponent,
                                           day: dayComponent)
        let returnValue = calendar.date(from: newComponents)
        
        return returnValue!
    }
    
    // MARK: EventDataSource
    
    override func eventsForDate(_ date: Date) -> [EventDescriptor] {
        selectedDate = date
        if !alreadyGeneratedSet.contains(date) {
            alreadyGeneratedSet.insert(date)
            generatedEvents.append(contentsOf: generateEventsForDate(date))
        }
        return generatedEvents
    }
    
    private func generateEventsForDate(_ date: Date) -> [EventDescriptor] {
        
        let activities = loadActivity(date: date.dateFormatter(format: "yyyy-MM-dd"))
        
        var events = [Event]()
        
        if let safeActivities = activities{
            for (key,value) in safeActivities {
                let event = Event()
                
                let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                    dateFormatter.timeZone = TimeZone.current
                    dateFormatter.locale = Locale.current
                    
                let startDateStr = "\(date.dateFormatter(format: "yyyy-MM-dd"))T\(value[0]):00"
                let startDate = dateFormatter.date(from: startDateStr)
                
                let endDateStr = "\(date.dateFormatter(format: "yyyy-MM-dd"))T\(value[1]):00"
                let endDate = dateFormatter.date(from: endDateStr)

                event.startDate = startDate!
                event.endDate = endDate!

                let timezone = dayView.calendar.timeZone

                event.text = key
                event.color = colors[Int(arc4random_uniform(UInt32(colors.count)))]
//                event.isAllDay = Int(arc4random_uniform(2)) % 2 == 0

                if #available(iOS 12.0, *) {
                    if traitCollection.userInterfaceStyle == .dark {
                        event.textColor = textColorForEventInDarkTheme(baseColor: event.color)
                        event.backgroundColor = event.color.withAlphaComponent(0.6)
                    }
                }

                events.append(event)
            }
        }
        return events
    }
    
    private func textColorForEventInDarkTheme(baseColor: UIColor) -> UIColor {
        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        baseColor.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        return UIColor(hue: h, saturation: s * 0.3, brightness: b, alpha: a)
    }
    
    
    
    // MARK: DayViewDelegate
    
    private var createdEvent: EventDescriptor?
    
    override func dayViewDidSelectEventView(_ eventView: EventView) {
        guard let descriptor = eventView.descriptor as? Event else {
            return
        }
        selectedActivitiyText = eventView.textView.text!
        let alert = UIAlertController(title: "Do you want to edit/delete this activity?", message: "", preferredStyle: .alert)
        let editAction = UIAlertAction(title: "Yes", style: .default) { (action) in
            self.performSegue(withIdentifier: "unwindToUserInput", sender: self)
        }
        let cancelAction = UIAlertAction(title: "No", style: .default)
        alert.addAction(editAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    override func dayViewDidLongPressEventView(_ eventView: EventView) {
        guard let descriptor = eventView.descriptor as? Event else {
            return
        }
        endEventEditing()
        print("Event has been longPressed: \(descriptor) \(String(describing: descriptor.userInfo))")
        beginEditing(event: descriptor, animated: true)
    }
    
    override func dayView(dayView: DayView, didTapTimelineAt date: Date) {
        endEventEditing()
        print("Did Tap at date: \(date)")
    }
    
    override func dayViewDidBeginDragging(dayView: DayView) {
        print("DayView did begin dragging")
    }
    
    override func dayView(dayView: DayView, willMoveTo date: Date) {
        print("DayView = \(dayView) will move to: \(date)")
    }
    
    override func dayView(dayView: DayView, didMoveTo date: Date) {
        reloadData()
    }
    
    override func dayView(dayView: DayView, didUpdate event: EventDescriptor) {
        print("did finish editing \(event)")
        print("new startDate: \(event.startDate) new endDate: \(event.endDate)")
        
        if let _ = event.editedEvent {
            event.commitEditing()
        }
        
        if let createdEvent = createdEvent {
            createdEvent.editedEvent = nil
            generatedEvents.append(createdEvent)
            self.createdEvent = nil
            endEventEditing()
        }
        
        reloadData()
    }
    private func loadActivity(date: String)->[String:[String]]?{
        let activities = realm.objects(Activity.self).filter("dateCreated = '\(date)'")
        if activities.count>0{
            var validActivities:[String:[String]] = [:]
            for i in 0..<activities.count{
                var timeList: [String] = []
                let startTime = activities[i].startTime
                let endTime = activities[i].endTime
                timeList.append(startTime)
                timeList.append(endTime)
                validActivities[activities[i].activityText] = timeList
            }
            return validActivities
        }
        return nil
    }
}

