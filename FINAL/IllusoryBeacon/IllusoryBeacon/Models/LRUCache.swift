//
//  LRUCache.swift
//  IllusoryBeacon
//
//  Created by Jing Su on 12/14/19.
//  Copyright © 2019 Jing Su. All rights reserved.
//

// FROM: https://github.com/raywenderlich/swift-algorithm-club/blob/master/LRU%20Cache/LRUCache.swift

import Foundation

public final class LRUCache<KeyType: Hashable> {
  private let maxSize: Int
  private var cache: [KeyType: Any] = [:]
  private var priority: LinkedList<KeyType> = LinkedList<KeyType>()
  private var key2node: [KeyType: LinkedList<KeyType>.LinkedListNode<KeyType>] = [:]
  
  public init(_ maxSize: Int) {
    self.maxSize = maxSize
  }
  
  public func get(_ key: KeyType) -> Any? {
    guard let val = cache[key] else {
      return nil
    }
    
    remove(key)
    insert(key, val: val)
    
    return val
  }
  
  public func set(_ key: KeyType, val: Any) {
    if cache[key] != nil {
      remove(key)
    } else if priority.count >= maxSize, let keyToRemove = priority.last?.value {
      remove(keyToRemove)
    }
    
    insert(key, val: val)
  }
  
  private func remove(_ key: KeyType) {
    cache.removeValue(forKey: key)
    guard let node = key2node[key] else {
      return
    }
    priority.remove(node: node)
    key2node.removeValue(forKey: key)
  }
  
  private func insert(_ key: KeyType, val: Any) {
    cache[key] = val
    priority.insert(key, at: 0)
    guard let first = priority.first else {
      return
    }
    key2node[key] = first as? LinkedList<KeyType>.LinkedListNode<KeyType>
  }
}
