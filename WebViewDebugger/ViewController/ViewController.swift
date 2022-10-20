//
//  ViewController.swift
//  WebViewPlayground
//
//  Created by Takuto Yoshikawa on 2022/09/24.
//
import UIKit
import WebKit
import Toast
import Photos

class ViewController: UIViewController, HistoryViewControllerDelegate, WKScriptMessageHandler {

    var timer: Timer?

    @IBOutlet var webView: WKWebView!

    @IBOutlet var urlBar: UITextField!

    @IBOutlet weak var webViewBottomConstraint: NSLayoutConstraint!

    @IBOutlet var backButton: UIBarButtonItem!

    @IBOutlet var forwardButton: UIBarButtonItem!

    @IBOutlet var reloadButton: UIBarButtonItem!

    @IBOutlet var inspector: UIView!

    @IBOutlet weak var inspectorTools: UIView!

    @IBOutlet weak var recordButton: UIButton!

    @IBOutlet weak var log: UILabel!

    private var _observers = [NSKeyValueObservation]()

    private var screenRecorder: ScreenRecorder?

    private var frameCount = 0

    private var timeToScreenshot = TimeInterval()

    private var timeToPushFrame = TimeInterval()

    @IBAction func onHome(_ sender: UIBarButtonItem) {
        goHome()
    }

    @IBAction func onBack(_ sender: UIBarButtonItem) {
        webView.goBack()
    }

    @IBAction func onForward(_ sender: UIBarButtonItem) {
        webView.goForward()
    }

    @IBAction func onReload(_ sender: UIBarButtonItem) {
        if (webView.isLoading) {
            webView.stopLoading()
        } else {
            webView.reload()
        }
    }

    @IBAction func onScreenshot(_ sender: UIButton) {
        let start = Date()
        let ss = webView.getImage()
        let elapsed = Date().timeIntervalSince(start)
        print(elapsed)
        UIImageWriteToSavedPhotosAlbum(ss, nil, nil, nil);
        self.view.makeToast("カメラロールに保存しました", duration: 0.5)

        let alert = UIAlertController(title: "かかった時間", message: elapsed.formatted(), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true, completion: nil)
    }

    @IBAction func onRecord(_ sender: UIButton) {
        if (timer != nil && timer!.isValid) {
            self.view.makeToast("録画を終了しました", duration: 0.5)
            recordButton.tintColor = nil
            print(timeToScreenshot, timeToPushFrame, frameCount)
            timer!.invalidate()
            screenRecorder!.finish(callback: {
                PHPhotoLibrary.shared().performChanges({
                    PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: self.screenRecorder!.getOutputUrl())
                }) { saved, error in
                    if saved {
                        print("カメラロールに保存しました", saved)
                    }
                }
            })
        } else {
            self.view.makeToast("録画を開始しました", duration: 0.5)
            recordButton.tintColor = UIColor.systemRed
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd.HH.mm.ss"
            let outputMovieURL = FileManager.default.urls(for: .documentDirectory, in:.userDomainMask).first?.appendingPathComponent("rec\(formatter.string(from: Date())).mov")
            screenRecorder = ScreenRecorder(outputMovieURL: outputMovieURL!)
            screenRecorder!.start()
            timer = Timer(timeInterval: 1 / 40, target: self, selector: #selector(saveFrame), userInfo: nil, repeats: true)
            RunLoop.main.add(timer!, forMode: RunLoop.Mode.common)
        }
    }

    @objc func saveFrame() {
        frameCount += 1
        let start = Date()
        let ss = webView.getImage()
        let elapsed = Date().timeIntervalSince(start)
        timeToScreenshot += elapsed
        self.screenRecorder!.append(image: ss)
        let elapsed2 = Date().timeIntervalSince(start)
        timeToPushFrame += elapsed2
    }

    @IBAction func onToggleInspector(_ sender: UIBarButtonItem) {
        inspector.isHidden = !inspector.isHidden
    }

    @IBAction func onUrlChanged(_ sender: UITextField) {
        if let url = URL(string: sender.text!) {
            print(url.absoluteString)
            webView.load(URLRequest(url: url))
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        webView.uiDelegate = self

        _observers.append(webView.observe(\.url, options: .new) { _, _ in
            if let url = self.webView.url {
                self.urlBar.text = url.absoluteString

                SettingRepository().setLastUrl(value: url.absoluteString)

                let history = History.create()
                history.title = self.webView.title
                history.url = url.absoluteString
                history.created = Date()
                let repository = HistoryRepository()
                repository.save(value: history)
            }
        })

        _observers.append(webView.observe(\.canGoBack, options: .new) { _, _ in
            self.backButton.isEnabled = self.webView.canGoBack
        })

        _observers.append(webView.observe(\.isLoading, options: .new) { _, _ in
            self.reloadButton.image = UIImage(systemName: self.webView.isLoading ? "xmark" : "arrow.triangle.2.circlepath")
        })

        _observers.append(UserDefaults.standard.observe(\.use16vs9, options: .new) { _, _ in
            self.updateWebViewLayout()
        })

        updateWebViewLayout()
        addInspectorBorder()
        enableConsoleLog()

        if (SettingRepository().getRestoreUrl()) {
            goLastUrl()
        } else {
            goHome()
        }

        inspector.isHidden = !SettingRepository().getOpenInspectorOnAppStart()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showHistory" {
            let nextView = segue.destination as! HistoryViewController
            nextView.delegate = self
        }
        if segue.identifier == "showSetting" {
            let nextView = segue.destination as! UINavigationController
            nextView.popoverPresentationController?.adaptiveSheetPresentationController.detents = [.medium()]
        }
    }

    func addInspectorBorder() {
        inspectorTools.addBorder(width: 0.5, color: UIColor.opaqueSeparator, position: .bottom)
        inspectorTools.addBorder(width: 0.5, color: UIColor.opaqueSeparator, position: .top)
    }

    func updateWebViewLayout() {
        if SettingRepository().getUse16vs9() {
            webViewBottomConstraint.priority = UILayoutPriority.defaultLow;
        } else {
            webViewBottomConstraint.priority = UILayoutPriority.required;
        }
    }

    func open(url: String) {
        if let url = URL(string: url) {
            webView.load(URLRequest(url: url))
        }
    }

    func enableConsoleLog() {
        webView.configuration.userContentController.add(self, name: "logging")
        webView.configuration.userContentController.addUserScript(WkWebViewUtil.getConsoleInjectionScript())
    }

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        log.text = (message.body as! String) + "\n" + log.text!
    }

    func goHome() {
        if let url = URL(string: SettingRepository().getHomeUrl()) {
            webView.load(URLRequest(url: url))
        }
    }

    func goLastUrl() {
        if let url = URL(string: SettingRepository().getLastUrl()) {
            print(url)
            webView.load(URLRequest(url: url))
        }
    }
}

extension ViewController: WKUIDelegate {
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let alertController = UIAlertController(title: "", message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default) { _ in
            completionHandler()
        }
        alertController.addAction(action)
        present(alertController, animated: true, completion: nil)
    }

    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        let alertController = UIAlertController(title: "", message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            completionHandler(false)
        }
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            completionHandler(true)
        }

        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }

    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
        let alertController  = UIAlertController(title: "", message: prompt, preferredStyle: .alert)
        let okHandler: () -> Void = {
            if let textField = alertController.textFields?.first {
                completionHandler(textField.text)
            } else {
                completionHandler("")
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            completionHandler(nil)
        }
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            okHandler()
        }
        alertController.addTextField { $0.text = defaultText }
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
}
