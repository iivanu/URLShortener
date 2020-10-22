//
//  ViewController.swift
//  URL Shortener
//
//  Created by Ivan Ivanušić on 07/10/2020.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet var urlEntry: UITextField!
    @IBOutlet var shortLinkView: UITextField!
    @IBOutlet var submitButton: UIButton!
    @IBOutlet var copyButton: UIButton!
    @IBOutlet var openPageButton: UIButton!
    
    var currentResponse: ResponseDataOK?
    var notOKResponse: ResponseDataNotOK?
    var recentLinks = [ResponseDataOK]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadData()
        title = "URL shortener"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareTapped))
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Recent", style: .plain, target: self, action: #selector(recentTapped))
        
        submitButton.layer.cornerRadius = 10
        copyButton.layer.cornerRadius = 10
        openPageButton.layer.cornerRadius = 10
    }
    
    @IBAction func submitTapped(_ sender: Any) {
        fetchData(longURL: urlEntry.text)
    }
    
    @IBAction func copyTapped(_ sender: Any) {
        guard let link = currentResponse?.link else { return }
        UIPasteboard.general.string = link
        showAlert(title: "Short URL is generated and copied to clipboard", message: link)
    }
    
    @IBAction func openPageTapped(_ sender: Any) {
        guard let link = currentResponse?.link else { return }
        guard let url = URL(string: link) else { return }
        UIApplication.shared.open(url)
    }
    
    func showAlert(title: String?, message: String?) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
    
    func fetchData(longURL: String?) {
        guard var longURL = longURL else { return }
        if longURL == "" {
            showAlert(title: "URL is empty!", message: "Please enter valid URL.")
            return
        }
        if !longURL.hasPrefix("https://") {
            longURL = "https://" + longURL
        }
        
        if !longURL.hasSuffix("/") {
            longURL += "/"
        }

        let request = fillRequest(longURL: longURL)
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let data = data, error == nil else {
                self?.showAlert(title: "Error", message: error?.localizedDescription)
                return
            }
            if self!.parseIsDataOK(data: data) {
                if !self!.isLinkAlreadySaved(link: longURL) {
                    self?.recentLinks.insert(self!.currentResponse!, at: 0)
                    self?.saveData()
                }
                DispatchQueue.main.async {
                    self?.shortLinkView.text = self?.currentResponse?.link
                    self?.reloadInputViews()
                }
            } else {
                DispatchQueue.main.async {
                    self?.showAlert(title: self?.notOKResponse?.message, message: self?.notOKResponse?.description)
                }
            }
        }
        task.resume()
    }
    
    func fillRequest(longURL: String) -> URLRequest{
        let json: [String: Any] = ["long_url": longURL, "domain": "bit.ly"]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)

        var request = URLRequest(url: apiURL)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue( "Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return request
    }
    
    func parseIsDataOK(data: Data) -> Bool {
        let decoder = JSONDecoder()
        
        if let jsonResponse = try? decoder.decode(ResponseDataOK.self, from: data) {
            currentResponse = jsonResponse
            return true
        } else if let jsonResponse = try? decoder.decode(ResponseDataNotOK.self, from: data) {
            notOKResponse = jsonResponse
        }
        
        return false
    }
    
    func isLinkAlreadySaved(link: String) -> Bool {
        for item in recentLinks {
            if item.long_url == link {
                return true
            }
        }
        
        return false
    }
    
    func loadData() {
        let defaults = UserDefaults.standard
        if let savedLinks = defaults.object(forKey: "links") as? Data {
            let jsonDecoder = JSONDecoder()
            do {
                recentLinks = try jsonDecoder.decode([ResponseDataOK].self, from: savedLinks)
            } catch {
                print("Failed to load recent links.")
            }
        }
    }
    
    func saveData() {
        let jsonEncoder = JSONEncoder()
        
        if let savedLinks = try? jsonEncoder.encode(recentLinks) {
            let defaults = UserDefaults.standard
            defaults.set(savedLinks, forKey: "links")
        } else {
            print("Failed to save link.")
        }
    }
    
    @objc func shareTapped() {
        guard let link = currentResponse?.link else { return }
        let vc = UIActivityViewController(activityItems: ["Here is my short link:\n\(link)"], applicationActivities: [])
        vc.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(vc, animated: true)
    }
    
    @objc func recentTapped() {
        if let vc = storyboard?.instantiateViewController(identifier: "Detail") as? recentTableView {
            vc.recentLinks = recentLinks
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}

