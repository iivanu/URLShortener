//
//  ViewController.swift
//  URL Shortener
//
//  Created by Ivan Ivanušić on 07/10/2020.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet var urlEntry: UITextField!
    let token = "c798d97ad43267d09a2eab588a954fc52c0f84a4"
    let apiURL = URL(string: "https://api-ssl.bitly.com/v4/shorten")!
    @IBOutlet var shortLinkView: UITextField!
    @IBOutlet var submitButton: UIButton!
    @IBOutlet var copyButton: UIButton!
    @IBOutlet var openPageButton: UIButton!
    var shortLink: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "URL shortener"
        submitButton.layer.cornerRadius = 10
        copyButton.layer.cornerRadius = 10
        openPageButton.layer.cornerRadius = 10
    }
    
    @IBAction func submitTapped(_ sender: Any) {
        guard let longURL = urlEntry.text else { return }
        let json: [String: Any] = ["long_url": longURL, "domain": "bit.ly"]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)

        var request = URLRequest(url: apiURL)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue( "Bearer \(token)", forHTTPHeaderField: "Authorization")

        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let data = data, error == nil else {
                self?.showAlert(title: "Error", message: error?.localizedDescription)
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let responseJSON = responseJSON as? [String: Any] {
                if let link = responseJSON["link"] as? String {
                    DispatchQueue.main.async {
                        self?.shortLink = link
                        self?.shortLinkView.text = link
                        self?.reloadInputViews()
                    }
                } else {
                    if let error = responseJSON["message"] as? String, let description = responseJSON["description"] as? String  {
                        DispatchQueue.main.async {
                            self?.showAlert(title: error, message: description)
                        }
                    }
                }
            }
        }
        task.resume()
    }
    
    @IBAction func copyTapped(_ sender: Any) {
        guard shortLink != nil else { return }
        UIPasteboard.general.string = shortLink
        showAlert(title: "Short URL is generated and copied to clipboard", message: shortLink)
    }
    
    @IBAction func openPageTapped(_ sender: Any) {
        guard shortLink != nil else { return }
        guard let url = URL(string: shortLink!) else { return }
        UIApplication.shared.open(url)
    }
    
    func showAlert(title: String, message: String?) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
}

