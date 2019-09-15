//
//  NewsList.swift
//  SMUDailyCampus
//
//  Created by Jing Su on 9/8/19.
//  Copyright © 2019 Jing Su. All rights reserved.
//

import SwiftSoup

class NewsList {
    private var news: [NewsItem] = []
    private let client: SMUDailyCampusClient
    
    init() {
        client = SMUDailyCampusClient()
    }
    
    func getNewsItem(at index: Int) -> NewsItem? {
        guard index < news.count else {
            return nil
        }
        return news[index]
    }
    
    func getNewsCount() -> Int {
        return news.count
    }
    
    private func parseDocument(with doc: Document!) -> [NewsItem]? {
        do {
            let body: Element? = doc.body()
            let articles: Elements? = try body?.select("article.post")
            guard articles != nil else {
                return nil
            }
            let formatter = ISO8601DateFormatter()
            var news: [NewsItem] = []
            for article in articles! {
                let link = try article.select("div.thumbnail a").attr("href")
                let thumbnailURL = try article.select("div.thumbnail a img").attr("src")
                let caption = try article.select("div.caption")
                let title = try caption.select("h1.title").text()
                let meta = try caption.select("p.meta")
                let dateString = try meta.select("time").attr("datetime")
                let date = formatter.date(from: dateString)!
                let author = try meta.select("a.author").text()
                let excerpt = try caption.select("p.excerpt").text()
                let newsItem = NewsItem(title: title, thumbnailURL: thumbnailURL, author: author, excerpt: excerpt, date: date, link: link)
                guard newsItem.link.count > 0 else {
                    continue
                }
                news.append(newsItem)
            }
            return news
        } catch {
            return nil
        }
    }
    
    func fetch() -> Bool {
        let doc = client.fetchNext()
        guard doc != nil else {
            return false
        }
        if let parsedNews = parseDocument(with: doc!) {
            news += parsedNews
            return true
        }
        return false
    }
    
    func refresh() -> Bool {
        guard news.count > 0 else {
            return fetch()
        }
        let doc = client.refresh()
        guard doc != nil else {
            return false
        }
        if let parsedNews = parseDocument(with: doc!) {
            let currentFirstNewsLink = news.first?.link
            var checkpoint = 0
            for parsedNewsItem in parsedNews {
                if parsedNewsItem.link == currentFirstNewsLink {
                    print("break")
                    break
                }
                checkpoint += 1
            }
            guard checkpoint > 0 else {
                return false
            }
            news = parsedNews[...checkpoint] + news
            return true
        }
        return false
    }

}
