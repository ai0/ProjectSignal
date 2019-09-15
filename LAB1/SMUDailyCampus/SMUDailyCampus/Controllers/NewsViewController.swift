//
//  NewsViewController.swift
//  SMUDailyCampus
//
//  Created by Jing Su on 9/8/19.
//  Copyright © 2019 Jing Su. All rights reserved.
//

import UIKit
import SafariServices

class NewsViewController: UIViewController {
    
    var newsList: NewsList
    var favoriteList: FavoriteList
    private let refreshControl = UIRefreshControl()
    private let message = MessagePrompt()
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(refreshNews(_:)), for: .valueChanged)
        collectionView.refreshControl = refreshControl
        if !newsList.fetch() {
            message.prompt(theme: message.error, content: "🚫 Network error", duration: 0)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        newsList = NewsList()
        favoriteList = FavoriteList.shared
        super.init(coder: aDecoder)
    }
    
    @IBAction func addFavorite(_ sender: UIButton) {
        let buttonPosition = sender.convert(CGPoint(), to:collectionView)
        if let indexPath = collectionView.indexPathForItem(at: buttonPosition) {
            if let newsItem = newsList.getNewsItem(at: indexPath.row) {
                let favoriteItem = FavoriteItem(title: newsItem.title, link: newsItem.link)
                if favoriteList.addNew(item: favoriteItem) {
                    message.prompt(theme: message.success, content: "⭐ Saved!", duration: 1)
                } else {
                    message.prompt(theme: message.warning, content: "💥 Already existed!", duration: 1)
                }
            } else {
                message.prompt(theme: message.error, content: "🚫 Failed to save!", duration: 1)
            }
        }
    }

}

extension NewsViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return newsList.getNewsCount()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NewsItem", for: indexPath) as! NewsCell
        if let item = newsList.getNewsItem(at: indexPath.row) {
            configureNews(for: cell, with: item)
        }
        return cell
    }
    
    func configureNews(for cell: NewsCell, with item: NewsItem) {
        cell.thumbnail.image = item.thumbnail
        cell.title.text = item.title
        cell.author.text = item.author
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
        cell.date.text = formatter.string(from: item.date)
        cell.excerpt.text = item.excerpt
    }
    
    @objc private func refreshNews(_ sender: Any) {
        if newsList.refresh() {
            message.prompt(theme: message.success, content: "🎉 News updated!", duration: 1)
            collectionView.reloadData()
        }
        message.prompt(theme: message.warning, content: "👀 You’re already up-to-date!", duration: 1)
        refreshControl.endRefreshing()
    }
    
}

extension NewsViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if (collectionView.cellForItem(at: indexPath) != nil) {
            if let item = newsList.getNewsItem(at: indexPath.row) {
                let config = SFSafariViewController.Configuration()
                config.entersReaderIfAvailable = true
                let vc = SFSafariViewController(url: URL.init(string: item.link)!, configuration: config)
                present(vc, animated: true)
            }
            collectionView.deselectItem(at: indexPath, animated: true)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.row == newsList.getNewsCount() - 1 {
            if newsList.fetch() {
                DispatchQueue.main.async(execute: collectionView.reloadData)
            }
        }
    }
    
}
