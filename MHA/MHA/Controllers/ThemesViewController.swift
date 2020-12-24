/*
 Author: Zhenyuan Bo
 File Description: MHA App's Themes Configuration
 Date: Dec 4, 2020
 */
import UIKit
import Firebase
import FirebaseFirestore

class ThemesViewController: UITableViewController {
    
    let db = Firestore.firestore()
    
    var selectedThemeName = ""

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        selectedThemeName = Theme.current.themeName
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Utils.themes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "themeCell", for: indexPath)
        cell.textLabel?.text = Array(Utils.themes.keys).sorted(by: <)[indexPath.row]
        if cell.textLabel?.text == selectedThemeName{
            cell.accessoryType = .checkmark
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType = .checkmark
            let selectedTheme = Array(Utils.themes.keys).sorted(by: <)[indexPath.row]
            Theme.current = Utils.themes[selectedTheme]!
            if let themeOwner = Auth.auth().currentUser?.email{
                db.collection(Utils.FStore.collectionName).whereField(Utils.FStore.themeOwner, isEqualTo: themeOwner).getDocuments { (querySnapshot, error) in
                    if let e = error{
                        print("Error with retrieving current theme, \(e)", to: &Log.log)
                    }else{
                        if let snapshotDocuments = querySnapshot?.documents{
                            if snapshotDocuments.count<1{
                                self.db.collection(Utils.FStore.collectionName).addDocument(
                                    data:[Utils.FStore.themeOwner: themeOwner,
                                          Utils.FStore.selectedTheme: selectedTheme]) { (error) in
                                    if let e = error{
                                        print("There was an issue saving selected theme to firestore, \(e)", to: &Log.log)
                                    }
                                }
                            }else{
                                snapshotDocuments.first?.reference.updateData([Utils.FStore.selectedTheme: selectedTheme])
                            }
                        }
                    }
                }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType = .none
        }
    }
        
}
