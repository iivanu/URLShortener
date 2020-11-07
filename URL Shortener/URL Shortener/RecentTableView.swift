//
//  RecentTableView.swift
//  URL Shortener
//
//  Created by Ivan Ivanušić on 20/10/2020.
//

import UIKit

class RecentTableView: UITableViewController {
    lazy var recentLinks: [ResponseDataOK] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Recent URLs"
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let row = indexPath.row
        guard self.isRowValid(row) else { fatalError("This row is out of index") }
        
        var text = self.recentLinks[row].long_url
        text = text.deletingPrefix("https://")
        text = text.deletingPrefix("www.")
        text = text.deletingSufix("/")
        text = text.capitalizingFirstLetter()
        cell.textLabel?.text = text
        cell.textLabel?.numberOfLines = 0
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recentLinks.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let ac = UIAlertController(title: "Copy short URL for:", message: self.recentLinks[indexPath.row].long_url, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Copy link", style: .default, handler: { [weak self] action in
            let link = self?.recentLinks[indexPath.row].link
            UIPasteboard.general.string = link
        }))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(ac, animated: true)
    }
    
    func isRowValid(_ row: Int) -> Bool {
        return 0 <= row && row <= (self.recentLinks.count - 1)
    }
}
