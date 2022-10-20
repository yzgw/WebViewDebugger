//
//  LocalFileRepository.swift
//  WebViewPlayground
//
//  Created by Takuto Yoshikawa on 2022/09/25.
//

import Foundation

class ResourceFileRepository {
    func get() -> [URL] {
        return Bundle.main.urls(forResourcesWithExtension: "html", subdirectory: "/") ?? []
    }
}
