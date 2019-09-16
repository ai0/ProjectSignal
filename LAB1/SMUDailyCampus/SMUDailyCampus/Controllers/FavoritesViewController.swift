//
//  FavoritesViewController.swift
//  SMUDailyCampus
//
//  Created by Jing Su on 9/8/19.
//  Copyright © 2019 Jing Su. All rights reserved.
//

import UIKit
import SafariServices

class FavoritesViewController: UIViewController {
    
    private var favoriteList: FavoriteList
    private var settingsManage: SettingsManage
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var navigationBar: UINavigationBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.async(execute: tableView.reloadData)
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
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return settingsManage.settings.titleBarDarkStyle ? UIStatusBarStyle.lightContent : UIStatusBarStyle.default
    }
    
    required init?(coder aDecoder: NSCoder) {
        favoriteList = FavoriteList.shared
        settingsManage = SettingsManage.shared
        super.init(coder: aDecoder)
    }
    
}

extension FavoritesViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favoriteList.getFavoriteCount()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FavoriteItem", for: indexPath) as! FavoriteCell
        if let item = favoriteList.getFavoriteItem(at: indexPath.row) {
            cell.title.text = item.title
        }
        return cell
    }
    
}

extension FavoritesViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (tableView.cellForRow(at: indexPath) != nil) {
            if let item = favoriteList.getFavoriteItem(at: indexPath.row) {
                let config = SFSafariViewController.Configuration()
                config.entersReaderIfAvailable = settingsManage.settings.autoRenderMode
                config.barCollapsingEnabled = false
                let vc = SFSafariViewController(url: URL.init(string: item.link)!, configuration: config)
                present(vc, animated: true)
            }
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        favoriteList.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }
    
}
