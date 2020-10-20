//
//  recentTableView.swift
//  URL Shortener
//
//  Created by Ivan Ivanušić on 20/10/2020.
//

import UIKit

class recentTableView: UITableViewController {

    var recentLinks = [ResponseDataOK]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = recentLinks[indexPath.row].long_url
        cell.textLabel?.numberOfLines = 0
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recentLinks.count
    }
}
