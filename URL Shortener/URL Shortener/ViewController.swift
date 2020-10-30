//
//  ViewController.swift
//  URL Shortener
//
//  Created by Ivan Ivanušić on 07/10/2020.
//

import UIKit
import SafariServices

class ViewController: UIViewController {
    @IBOutlet weak var urlEntry: UITextField!
    @IBOutlet weak var shortLinkView: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var copyButton: UIButton!
    @IBOutlet weak var openPageButton: UIButton!
    
    private var currentResponse: ResponseDataOK?
    private var notOKResponse: ResponseDataNotOK?
    private var recentLinks = [ResponseDataOK]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        let config = SFSafariViewController.Configuration()
        config.barCollapsingEnabled = true
        config.entersReaderIfAvailable = false
        
        let safariViewController = SFSafariViewController.init(url: url, configuration: config)
        self.present(safariViewController, animated: true, completion: nil)
    }
    
    func showAlert(title: String?, message: String?) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(ac, animated: true)
    }
    
    func fetchData(longURL: String?) {
        guard var longURL = longURL else { return }
        
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
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            
            guard let data = data, error == nil else {
                self.showAlert(title: "Error", message: error?.localizedDescription)
                return
            }
            
            guard self.parseIsDataOK(data: data) else {
                DispatchQueue.main.async {
                    self.showAlert(title: self.notOKResponse?.message, message: self.notOKResponse?.description)
                }
                return
            }
            
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
        
        guard let jsonResponse = try? decoder.decode(ResponseDataOK.self, from: data) else {
            let jsonResponse = try? decoder.decode(ResponseDataNotOK.self, from: data)
            self.notOKResponse = jsonResponse
            return false
        }
        
        self.currentResponse = jsonResponse
        return true
    }
    
    func isLinkAlreadySaved(link: String) -> Bool {
        return self.recentLinks.contains(where: { recentLink in
            recentLink.long_url == link
        })
    }
    
    func loadData() {
        let defaults = UserDefaults.standard
        guard let savedLinks = defaults.object(forKey: "links") as? Data else {
            return
        }
        
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

