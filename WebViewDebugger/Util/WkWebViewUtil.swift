//
//  WkWebViewUtil.swift
//  WebViewDebugger
//
//  Created by Takuto Yoshikawa on 2022/10/20.
//

import UIKit
import WebKit

class WkWebViewUtil {

    static func getConsoleInjectionScript() -> WKUserScript {
        return WKUserScript(
            source: """
const originalLog = window.console.log;
window.console.log = (msg) => {
    window.webkit.messageHandlers.logging.postMessage(msg);
    originalLog(msg);
}
""",
            injectionTime: .atDocumentStart,
            forMainFrameOnly: true
        )
    }
}
