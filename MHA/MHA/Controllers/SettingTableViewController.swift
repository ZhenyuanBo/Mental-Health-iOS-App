/*
 Author: Zhenyuan Bo & Anqi Luo
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
        return 2
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell?
        if indexPath.row == 0{
            cell = tableView.dequeueReusableCell(withIdentifier: "themesCell", for: indexPath)
        }else if indexPath.row == 1{
            cell = tableView.dequeueReusableCell(withIdentifier: "logoutCell", for: indexPath)
        }
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0{
            performSegue(withIdentifier: "themeDetails", sender: self)
        }
    }

}

