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
        title = "Recent URLs"
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let ac = UIAlertController(title: "Copy short URL for:", message: recentLinks[indexPath.row].long_url, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Copy link", style: .default, handler: { action in
            let link = self.recentLinks[indexPath.row].link
            UIPasteboard.general.string = link
        }))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(ac, animated: true)
    }
}
