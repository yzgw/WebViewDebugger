//
//  Setting.swift
//  WebViewPlayground
//
//  Created by Takuto Yoshikawa on 2022/09/24.
//

import Foundation

let use16vs9Key = "use16vs9"
let homeUrlKey = "homeUrlKey"
let openInspectorOnAppStartKey = "openInspectorOnAppStartKey"
let restoreUrlKey = "restoreUrlKey"
let lastUrlKey = "lastUrlKey"

class SettingRepository {

    init() {

        UserDefaults.standard.register(
            defaults: [
                openInspectorOnAppStartKey : true,
                restoreUrlKey: true,
                homeUrlKey: "http://www.google.com"
            ]
        )
    }

    func getUse16vs9() -> Bool {
        return UserDefaults.standard.bool(forKey: use16vs9Key)
    }

    func setUse16vs9(value: Bool) {
        UserDefaults.standard.set(value, forKey: use16vs9Key)
    }

    func getHomeUrl() -> String {
        return UserDefaults.standard.string(forKey: homeUrlKey) ?? "http://www.google.com"
    }

    func setHomeUrl(value: String) {
        UserDefaults.standard.set(value, forKey: homeUrlKey)
    }

    func getOpenInspectorOnAppStart() -> Bool {
        return UserDefaults.standard.bool(forKey: openInspectorOnAppStartKey)
    }

    func setOpenInspectorOnAppStart(value: Bool) {
        UserDefaults.standard.set(value, forKey: openInspectorOnAppStartKey)
    }

    func getRestoreUrl() -> Bool {
        return UserDefaults.standard.bool(forKey: restoreUrlKey)
    }

    func setRestoreUrl(value: Bool) {
        UserDefaults.standard.set(value, forKey: restoreUrlKey)
    }

    func getLastUrl() -> String {
        return UserDefaults.standard.string(forKey: lastUrlKey) ?? getHomeUrl()
    }

    func setLastUrl(value: String) {
        UserDefaults.standard.set(value, forKey: lastUrlKey)
    }
}

extension UserDefaults {
    @objc dynamic var use16vs9: Bool {
        return bool(forKey: use16vs9Key)
    }
}
