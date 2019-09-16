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
    
    private var newsList: NewsList
    private var favoriteList: FavoriteList
    private var settingsManage: SettingsManage
    private let refreshControl = UIRefreshControl()
    private let message = MessagePrompt()
    private var autoRefreshTimer: Timer?
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(refreshNewsPuller(_:)), for: .valueChanged)
        collectionView.refreshControl = refreshControl
        if !newsList.fetch() {
            message.prompt(theme: message.error, content: "🚫 Network error", duration: 0)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupAutoRefreshTimer()
        if settingsManage.settings.titleBarDarkStyle {
            navigationBar.barStyle = .black
            let statusBar: UIView = UIApplication.shared.value(forKey: "statusBar") as! UIView
            statusBar.backgroundColor = .black
        } else {
            navigationBar.barStyle = .default
            let statusBar: UIView = UIApplication.shared.value(forKey: "statusBar") as! UIView
            statusBar.backgroundColor = .white
        }
        let attrs = [
            NSAttributedString.Key.font: UIFont(name: "Futura-Medium", size: CGFloat.init(settingsManage.settings.titleBarFontSize))
        ]
        navigationBar.largeTitleTextAttributes = attrs as [NSAttributedString.Key : Any]
        navigationBar.topItem?.title = settingsManage.settings.getCurrentTitle()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return settingsManage.settings.titleBarDarkStyle ? UIStatusBarStyle.lightContent : UIStatusBarStyle.default
    }

    required init?(coder aDecoder: NSCoder) {
        newsList = NewsList()
        favoriteList = FavoriteList.shared
        settingsManage = SettingsManage.shared
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
    
    @objc func refreshNews() {
        if newsList.refresh() {
            message.prompt(theme: message.success, content: "🎉 News updated!", duration: 1)
            collectionView.reloadData()
        }
        message.prompt(theme: message.warning, content: "👀 You’re already up-to-date!", duration: 1)
    }
    
    @objc private func refreshNewsPuller(_ sender: Any) {
        refreshNews()
        refreshControl.endRefreshing()
    }
    
    func setupAutoRefreshTimer() {
        if autoRefreshTimer != nil {
            autoRefreshTimer?.invalidate()
        }
        let refreshInterval = settingsManage.settings.autoRefreshInterval
        if refreshInterval > 0 {
            autoRefreshTimer = Timer.scheduledTimer(timeInterval: refreshInterval, target: self, selector: #selector(refreshNews), userInfo: nil, repeats: true)
        }
    }
    
}

extension NewsViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if (collectionView.cellForItem(at: indexPath) != nil) {
            if let item = newsList.getNewsItem(at: indexPath.row) {
                let config = SFSafariViewController.Configuration()
                config.entersReaderIfAvailable = settingsManage.settings.autoRenderMode
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

extension NewsViewController: UIScrollViewDelegate {
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        UIView.animate(withDuration: 0.5, animations: {
            self.navigationBar.prefersLargeTitles = (velocity.y < 0)
        })
    }
    
}
