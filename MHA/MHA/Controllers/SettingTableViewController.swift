/*
 Author: Zhenyuan Bo
 File Description: MHA App's Setting Configuration
 Date: Dec 1, 2020
 */

import UIKit

class SettingTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell?
        if indexPath.row == 0{
            cell = tableView.dequeueReusableCell(withIdentifier: "notificationCell", for: indexPath)
            cell!.showSeparator()
        }else if indexPath.row == 1{
            cell = tableView.dequeueReusableCell(withIdentifier: "generalCell", for: indexPath)
        }else if indexPath.row == 2{
            cell = tableView.dequeueReusableCell(withIdentifier: "logoutCell", for: indexPath)
        }
        return cell!
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension UITableViewCell {

  func hideSeparator() {
    self.separatorInset = UIEdgeInsets(top: 0, left: self.bounds.size.width, bottom: 0, right: 0)
  }

  func showSeparator() {
    self.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
  }
}
