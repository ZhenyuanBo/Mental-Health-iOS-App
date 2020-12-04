import UIKit

class ThemesViewController: UITableViewController {
    
    let themes = ["Light", "Natural Elegance", "Fiery Red Landscape",
                         "Summer Blueberries", "Dock of Bay", "Earthy Greens",
                         "Berries Galore", "Tropical", "Lemon",
                         "Romantic", "Winter Barn"]

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return themes.count
    }
    
//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        <#code#>
//    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "themeCell", for: indexPath)
        cell.textLabel?.text = themes[indexPath.row]
        return cell
    }

}
