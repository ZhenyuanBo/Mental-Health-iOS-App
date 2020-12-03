/*
 Author: Zhenyuan Bo
 File Description: presents the activity time picker view
 Date: Nov 23, 2020
 */

import UIKit

protocol ActivityTimePickerDelegate: class {
    func pickerAlertSelected(t1: String, t2: String)
    func pickerAlertCancel()
}

class ActivityTimePicker: UIViewController {

    
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet var alertView: UIView!
    
    var delegate:ActivityTimePickerDelegate?
    
    var startTimes = [String]()
    var endTimes = [String]()
    let timeFormatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pickerView.delegate = self
        pickerView.dataSource = self
        
        timeFormatter.timeStyle = .short
        startTimes = getTimeList(from: 0)
        endTimes = getTimeList(from: 0)
        
        cancelButton.addTarget(self, action: #selector(cancelAction), for: .touchUpInside)
        doneButton.addTarget(self, action: #selector(doneAction), for: .touchUpInside)
    }
    
    @objc func cancelAction(){
        delegate?.pickerAlertCancel()
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func doneAction(){
        delegate?.pickerAlertSelected(t1: startTimes[pickerView.selectedRow(inComponent: 0)], t2: endTimes[pickerView.selectedRow(inComponent: 1)])
        self.dismiss(animated: true, completion: nil)
    }

}

extension ActivityTimePicker{
    func getTimeList(from: Int) -> [String] {
        let timeList: [String] = [
            "1:00","2:00","3:00","4:00","5:00", "6:00", "7:00", "8:00", "9:00","10:00","11:00", "12:00", "13:00", "14:00", "15:00", "16:00", "17:00", "18:00", "19:00", "20:00", "21:00", "22:00", "23:00", "0:00"]
        var list: [String] = []
        for i in from...timeList.count-1 {
            list.append(timeList[i])
        }
        return list
    }
}

extension ActivityTimePicker: UIPickerViewDelegate, UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component{
        case 0:
            return startTimes.count
        case 1:
            return endTimes.count
        default: return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var label: UILabel
       
        if let view = view as? UILabel {
            label = view
        } else {
            label = UILabel()
        }
       
        label.textColor = .black
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 15)
       
        var text = ""
       
        switch component {
        case 0:
            text = startTimes[row]
        case 1:
            text = endTimes[row]
        default:
            break
        }
       
        label.text = text
       
        return label
    }
   
    //this is for reloading the END times list, according to the value selected as the START time.
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if (component == 0) {
           
            endTimes = getTimeList(from: row)
            pickerView.reloadComponent(1)
        }
    }
}

