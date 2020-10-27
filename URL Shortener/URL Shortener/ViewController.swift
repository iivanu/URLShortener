//
//  ViewController.swift
//  URL Shortener
//
//  Created by Ivan Ivanušić on 07/10/2020.
//

import UIKit
/// Allow to summon a Safari View Controller, check the code below
import SafariServices

class ViewController: UIViewController {
    /// Always your UI elements should be **weak**, why? because your UI elements gonna take a **strong** reference from VC
    /// and your VC never gonna deallocate, although the view never appears again. This is called *memory leaks*.
    @IBOutlet weak var urlEntry: UITextField!
    @IBOutlet weak var shortLinkView: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var copyButton: UIButton!
    @IBOutlet weak var openPageButton: UIButton!
    
    /// All your variables should be private, to avoid other classes acces to it without your authorization,
    /// to authorize the access may could be interesting do a getter setter, or if it's necesary to access to
    /// some var, ok, make it public (not private), but try to privatize always your vars.
    private var currentResponse: ResponseDataOK?
    private var notOKResponse: ResponseDataNotOK?
    /// If you need to set a default value on a var, try always to put it as **Lazy**, this allow to the app
    /// ignore his value (do not initialize) until needed, what means this? More memory free, only used when you need
    private lazy var recentLinks: [ResponseDataOK] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /// Try to put always the self reference, taking this as an habit, code more readable, and easy to know where is your var/function…
        self.loadData()
        self.title = "URL shortener"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(self.shareTapped))
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Recent", style: .plain, target: self, action: #selector(self.recentTapped))
        
        self.submitButton.layer.cornerRadius = 10
        self.copyButton.layer.cornerRadius = 10
        self.openPageButton.layer.cornerRadius = 10
    }
    
    @IBAction func submitTapped(_ sender: Any) {
        self.fetchData(longURL: self.urlEntry.text)
    }
    
    @IBAction func copyTapped(_ sender: Any) {
        guard let link = self.currentResponse?.link else { return }
        UIPasteboard.general.string = link
        self.showAlert(title: "Short URL is generated and copied to clipboard", message: link)
    }
    
    @IBAction func openPageTapped(_ sender: Any) {
        guard let link = self.currentResponse?.link else { return }
        guard let url = URL(string: link) else { return }
        /// To improve the UX on your app, you can user the Safari View Controller, this allow to
        /// show webcontent without leaving the app. (The configuration is not mandatory)
        let config = SFSafariViewController.Configuration()
        config.barCollapsingEnabled = true
        config.entersReaderIfAvailable = false

        let safariViewController = SFSafariViewController.init(url: url, configuration: config)
        /// Is presented as modal beause the Safari View Controller already has his own "navigation bar"
        self.present(safariViewController, animated: true, completion: nil)
    }
    
    func showAlert(title: String?, message: String?) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(ac, animated: true)
    }
    
    func fetchData(longURL: String?) {
        guard var longURL = longURL else { return }
        /// On the first line you handle the nil value, and that it's ok, now to handle an empty value, check the
        /// content of yout String counting the number of characters she has inside, because a String is a characters array.
        /// To avoid if's without else cases and with and with and interrupted execurion try to use a guard, is more readable.
        guard !longURL.isEmpty else {
            self.showAlert(title: "URL is empty!", message: "Please enter valid URL.")
            return
        }
        
        if !longURL.hasPrefix("https://") {
            longURL = "https://" + longURL
        }
        
        if !longURL.hasSuffix("/") {
            longURL += "/"
        }

        let request = self.fillRequest(longURL: longURL)
        /// That [weak self] it's really cool because you can avoid strong references inside of your callback, this avoid the *memory leaks*
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            /// If you need to use self without handle the optionals, and avoid an strong reference, you can create a local self reference
            /// this will be deallocated when your callback finish his task.
            /// Other way to avoid optionals and strong references is changing [weak self] to [unowned self], but if your callback
            /// try to access to your self, and this is already deallocated your app will crash. unowned is useful if you are sure 100% about
            /// the allocate of your class (self).
            guard let self = self else { return }
            
            guard let data = data, error == nil else {
                self.showAlert(title: "Error", message: error?.localizedDescription)
                return
            }
            /// Again avoiding if's else, we can create a more readable code with a guard
            guard self.parseIsDataOK(data: data) else {
                DispatchQueue.main.async {
                    self.showAlert(title: self.notOKResponse?.message, message: self.notOKResponse?.description)
                }
                return
            }
            /// On this case the function don't need break the execution if the is no completed successfully
            if !self.isLinkAlreadySaved(link: longURL) {
                self.recentLinks.insert(self.currentResponse!, at: 0)
                self.saveData()
            }
            
            DispatchQueue.main.async { [weak self] in
                self?.shortLinkView.text = self?.currentResponse?.link
                self?.reloadInputViews()
            }
        }
        task.resume()
    }
    
    func fillRequest(longURL: String) -> URLRequest{
        let json: [String: Any] = ["long_url": longURL, "domain": "bit.ly"]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        
        /// Here is when you can check the user of prefix on your global constants, easily you can check if this is a local
        /// var or not.
        var request = URLRequest(url: k_apiURL)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue( "Bearer \(k_token)", forHTTPHeaderField: "Authorization")
        
        return request
    }
    
    func parseIsDataOK(data: Data) -> Bool {
        let decoder = JSONDecoder()
        
        /// Again more readable confitions with a guard instead an if else
        guard let jsonResponse = try? decoder.decode(ResponseDataOK.self, from: data) else {
            let jsonResponse = try? decoder.decode(ResponseDataNotOK.self, from: data)
            self.notOKResponse = jsonResponse
            return false
        }
        
        self.currentResponse = jsonResponse
        return true
    }
    
    func isLinkAlreadySaved(link: String) -> Bool {
        /// Here you can minimize the code and increase his readability changing the loop
        /// with an if nested, with the function contains. I guess the code is self explanatory.
        return self.recentLinks.contains(where: { recentLink in
            recentLink.long_url == link
        })
    }
    
    func loadData() {
        let defaults = UserDefaults.standard
        guard let savedLinks = defaults.object(forKey: "links") as? Data else {
            return
        }
        
        /// Here I decide to remove the initialization of a JSON decoder and initialize on the fly, because
        /// less code with the same readability is better.
        do {
            self.recentLinks = try JSONDecoder().decode([ResponseDataOK].self, from: savedLinks)
        } catch {
            print("Failed to load recent links - \(error.localizedDescription)")
        }
    }
    
    func saveData() {
        guard let savedLinks = try? JSONEncoder().encode(self.recentLinks) else {
            print("Failed to save link.")
            return
        }
        
        let defaults = UserDefaults.standard
        defaults.set(savedLinks, forKey: "links")
    }
    
    /// Nice update on @objc, I'm still finding the WWDC video, I contacted to Apple to locate it 😅
    @objc private func shareTapped() {
        guard let link = self.currentResponse?.link else { return }
        let vc = UIActivityViewController(activityItems: ["Here is my short link:\n\(link)"], applicationActivities: [])
        vc.popoverPresentationController?.barButtonItem = self.navigationItem.rightBarButtonItem
        self.present(vc, animated: true)
    }
    
    @objc private func recentTapped() {
        guard let vc = storyboard?.instantiateViewController(identifier: "Detail") as? recentTableView else {
            return
        }
        vc.recentLinks = self.recentLinks
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

