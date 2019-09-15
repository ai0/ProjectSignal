//
//  FavoriteList.swift
//  SMUDailyCampus
//
//  Created by Jing Su on 9/15/19.
//  Copyright © 2019 Jing Su. All rights reserved.
//

import Foundation

class FavoriteList {
    
    static let shared = FavoriteList()
    
    private var favorites: [FavoriteItem] = []
    private var links: Set<String> = []
    
    init() {
        let defaults = UserDefaults.standard
        if let data = defaults.data(forKey: "FavoriteList") {
            do {
                if let unarchivedFavorites = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? [FavoriteItem] {
                    favorites = unarchivedFavorites
                    for favorite in favorites {
                        links.insert(favorite.link)
                    }
                }
            } catch {}
        }
    }
    
    func getFavoriteItem(at index: Int) -> FavoriteItem? {
        guard index < favorites.count else {
            return nil
        }
        return favorites[index]
    }
    
    func getFavoriteCount() -> Int {
        return favorites.count
    }
    
    private func save() {
        do {
            let encodedData = try NSKeyedArchiver.archivedData(withRootObject: favorites, requiringSecureCoding: false)
            UserDefaults.standard.set(encodedData, forKey: "FavoriteList")
        } catch {
            return
        }
    }
    
    func addNew(item: FavoriteItem) -> Bool {
        if !links.contains(item.link) {
            favorites.append(item)
            links.insert(item.link)
            save()
            return true
        }
        return false
    }
    
    func remove(at index: Int) {
        if index < favorites.count {
            links.remove(favorites[index].link)
            favorites.remove(at: index)
            save()
        }
    }
    
    func clear() {
        links.removeAll()
        favorites.removeAll()
        save()
    }
    
}
