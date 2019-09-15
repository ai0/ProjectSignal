//
//  SMUDailyCampusClient.swift
//  SMUDailyCampus
//
//  Created by Jing Su on 9/8/19.
//  Copyright © 2019 Jing Su. All rights reserved.
//

import Just
import SwiftSoup
import JavaScriptCore

class SMUDailyCampusClient {

    private let firstPageURL = "https://www.smudailycampus.com/category/news"
    private var currentPage: UInt8!
    private var headers = [
        "pragma": "no-cache",
        "cache-control": "no-cache",
        "user-agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/76.0.3809.132 Safari/537.36",
        "accept": "text/html",
        "referer": "https://www.smudailycampus.com/",
        "accept-encoding": "identity"
    ]
    
    init() {
        currentPage = 1
    }
    
    lazy var currentPageURL = {
        return self.currentPage < 2 ?
            self.firstPageURL :
            "https://www.smudailycampus.com/category/news/page/\(self.currentPage ?? 2)"
    }
    
    private func fetchHTML(for url: String) -> String? {
        let request = Just.get(url, headers: headers)
        guard request.ok else {
            return nil
        }
        return request.text
    }
    
    // bypass the Sucuri Anti-crawlers WAF which SMU Daily Campus adopted
    private func bypassWAF(with script: String) -> Bool {
        let context = JSContext()
        context?.evaluateScript(script)
        let evalScript = context?.objectForKeyedSubscript("r")?.toString()!.replacingOccurrences(of: "document.cookie", with: "sucuriCookie")
        context?.evaluateScript(evalScript)
        let fullCookieString = context?.objectForKeyedSubscript("sucuriCookie")?.toString()
        guard fullCookieString!.count > 0 else {
            return false
        }
        let cookieString = fullCookieString?.split(separator: ";", maxSplits: 1, omittingEmptySubsequences: true)[0]
        guard cookieString != nil else {
            return false
        }
        headers["cookie"] = String(cookieString!)
        return true
    }
    
    private func fetch(for url: String) -> Document? {
        let htmlString = fetchHTML(for: url)
        guard htmlString != nil else {
            return nil
        }
        do {
            let doc: Document = try SwiftSoup.parse(htmlString!)
            let pageTitle: String = try doc.title()
            if pageTitle.contains("You are being redirected...") {
                // need to obtain the sucuri_cloudproxy_uuid cookie
                let script = try doc.select("script").html()
                if bypassWAF(with: script) {
                    return fetch(for: url)
                }
                return nil
            }
            return doc
        } catch {
            return nil
        }
    }
    
    func fetchNext() -> Document? {
        let url = currentPageURL()
        if let doc = fetch(for: url) {
            currentPage += 1
            return doc
        }
        return nil
    }
    
    func refresh() -> Document? {
        if let doc = fetch(for: firstPageURL) {
            return doc
        }
        return nil
    }
    
}
