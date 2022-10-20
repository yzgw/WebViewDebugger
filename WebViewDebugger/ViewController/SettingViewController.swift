//
//  SettingViewController.swift
//  WebViewPlayground
//
//  Created by Takuto Yoshikawa on 2022/09/24.
//

import UIKit
import WebKit
import Toast

class SettingViewController: UITableViewController {

    @IBOutlet weak var use16vs9toggle: UISwitch!
    
    @IBOutlet weak var openInspectorToggle: UISwitch!

    @IBOutlet weak var restoreUrlToggle: UISwitch!

    @IBAction func onUse16vs9Changed(_ sender: UISwitch) {
        SettingRepository().setUse16vs9(value: sender.isOn)
    }

    @IBAction func onHomeUrlChange(_ sender: UITextField) {
        if ((sender.text) != nil) {
            SettingRepository().setHomeUrl(value: sender.text ?? "")
        }
    }

    @IBAction func onOpenInspectorOnAppStartChange(_ sender: UISwitch) {
        SettingRepository().setOpenInspectorOnAppStart(value: sender.isOn)
    }

    @IBAction func onRestoreUrlChange(_ sender: UISwitch) {
        SettingRepository().setRestoreUrl(value: sender.isOn)
    }

    @IBAction func onResetCookie(_ sender: Any) {
        WKWebsiteDataStore.default().removeData(ofTypes: [WKWebsiteDataTypeCookies], modifiedSince: Date(timeIntervalSince1970: 0), completionHandler:{ })
        self.view.makeToast("リセットしました", duration: 0.5)
    }

    @IBAction func onResetLocalStorage(_ sender: Any) {
        WKWebsiteDataStore.default().removeData(ofTypes: [WKWebsiteDataTypeLocalStorage], modifiedSince: Date(timeIntervalSince1970: 0), completionHandler:{ })
        self.view.makeToast("リセットしました", duration: 0.5)
    }

    @IBAction func onResetAll(_ sender: Any) {
        WKWebsiteDataStore.default().removeData(ofTypes: [
            WKWebsiteDataTypeFetchCache, WKWebsiteDataTypeDiskCache, WKWebsiteDataTypeMemoryCache, WKWebsiteDataTypeOfflineWebApplicationCache, WKWebsiteDataTypeCookies, WKWebsiteDataTypeSessionStorage, WKWebsiteDataTypeLocalStorage, WKWebsiteDataTypeWebSQLDatabases, WKWebsiteDataTypeIndexedDBDatabases, WKWebsiteDataTypeServiceWorkerRegistrations
        ], modifiedSince: Date(timeIntervalSince1970: 0), completionHandler:{ })
        self.view.makeToast("リセットしました", duration: 0.5)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        use16vs9toggle.isOn = SettingRepository().getUse16vs9()
        openInspectorToggle.isOn = SettingRepository().getOpenInspectorOnAppStart()
        restoreUrlToggle.isOn = SettingRepository().getRestoreUrl()
    }
}
