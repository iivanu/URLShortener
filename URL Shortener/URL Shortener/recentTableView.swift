//
//  recentTableView.swift
//  URL Shortener
//
//  Created by Ivan Ivanušić on 20/10/2020.
//

import UIKit

class recentTableView: UITableViewController {

    /// On this case I prefer  to user an optional var, but it's ok like this.
    /// Do this an optional doesn't add much difficulty when you need to handle it, BTW set it as *Lazy* it's also ok
    lazy var recentLinks: [ResponseDataOK] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Recent URLs"
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        /// Before to try to get a model from your array with an *IndexPath* take care about this index could be
        /// out of index, becase idk, the user did remove a cell, and you are doing this as a parallel action.
        let row = indexPath.row
        /// Fatal error allows to know (usually) before to release where could be a bug in your app,
        /// this method launch a crash on your app and helps to identify where is the problem.
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
        /// **Strong** references here with your class
        ac.addAction(UIAlertAction(title: "Copy link", style: .default, handler: { [weak self] action in
            let link = self?.recentLinks[indexPath.row].link
            UIPasteboard.general.string = link
        }))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(ac, animated: true)
    }
    
    // MARK: - Helper
    func isRowValid(_ row: Int) -> Bool {
        return 0 <= row && row <= (self.recentLinks.count - 1)
    }
}
