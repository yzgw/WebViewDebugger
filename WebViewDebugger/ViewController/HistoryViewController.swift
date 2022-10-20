//
//  ViewController.swift
//  WebViewPlayground
//
//  Created by Takuto Yoshikawa on 2022/09/24.
//
import UIKit
import WebKit

protocol HistoryViewControllerDelegate {
    func open(url: String)
}

class HistoryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var delegate: HistoryViewControllerDelegate?

    @IBOutlet weak var table: UITableView!

    let resourceRepository = ResourceFileRepository()

    let historyRepository = HistoryRepository()

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func onClose(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView,
                   titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "ファイル" : "履歴"
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0) {
            return resourceRepository.get().count
        } else {
            return historyRepository.get().count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.section == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "historyCell", for: indexPath)
            let url = resourceRepository.get()[indexPath.row]
            cell.textLabel?.text = url.lastPathComponent
            cell.detailTextLabel?.text = url.absoluteString
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "historyCell", for: indexPath)
            let history = historyRepository.get()[indexPath.row]
            cell.textLabel?.text = history.title
            cell.detailTextLabel?.text = history.url
            return cell
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if (indexPath.section == 0) {
            let url = resourceRepository.get()[indexPath.row]
            delegate?.open(url: url.absoluteString)
            dismiss(animated: true)
        } else {
            let history = historyRepository.get()[indexPath.row]
            delegate?.open(url: history.url!)
            dismiss(animated: true)
        }

    }
}
