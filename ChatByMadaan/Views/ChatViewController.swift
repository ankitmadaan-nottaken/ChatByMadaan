//
//  ChatViewController.swift
//  ChatByMadaan
//
//  Created by Ankit Madan on 6/11/25.
//

import UIKit

class ChatViewController: UIViewController, UITableViewDataSource {
    var messages: [String] = ["Hi", "How are you?", "Hello"]
    

    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Chat"
        tableView.dataSource = self
    }
    

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatCell", for: indexPath)
        cell.textLabel?.text = messages[indexPath.row]
        return cell
    }


}
