//
//  LRUCache.swift
//  VideoPlayer
//
//  Created by Devansh Mohata on 15/08/24.
//

import Foundation

class LRUCache<Key: Hashable, Value> {
    private struct CacheItem {
        let key: Key
        var value: Value
    }
    
    private let capacity: Int
    private var list = LinkedList<CacheItem>()
    private var dictionary = [Key: LinkedList<CacheItem>.Node]()
    
    init(maxItems: Int) {
        self.capacity = maxItems
    }
    
    func getValue(forKey key: Key) -> Value? {
        guard let node = dictionary[key] else { return nil }
        list.moveToFront(node)
        return node.value.value
    }
    
    func setValue(_ value: Value, forKey key: Key) {
        if let existingNode = dictionary[key] {
            list.moveToFront(existingNode)
            existingNode.value.value = value
        } else {
            let cacheItem = CacheItem(key: key, value: value)
            let node = list.pushFront(cacheItem)
            dictionary[key] = node
            
            if list.count > capacity {
                removeLast()
            }
        }
    }
    
    func removeValue(forKey key: Key) {
        guard let node = dictionary[key] else { return }
        list.remove(node)
        dictionary[key] = nil
    }
    
    func removeOldest() -> (key: Key, value: Value)? {
        guard let oldestNode = list.tail else { return nil }
        let oldestItem = oldestNode.value
        list.remove(oldestNode)
        dictionary[oldestItem.key] = nil
        return (oldestItem.key, oldestItem.value)
    }
    
    private func removeLast() {
        guard let node = list.tail else { return }
        list.remove(node)
        dictionary[node.value.key] = nil
    }
}

class LinkedList<T> {
    class Node {
        var value: T
        var next: Node?
        var prev: Node?
        
        init(value: T) {
            self.value = value
        }
    }
    
    private(set) var count: Int = 0
    var head: Node?
    var tail: Node?
    
    func pushFront(_ value: T) -> Node {
        let node = Node(value: value)
        defer { count += 1 }
        guard let headNode = head else {
            head = node
            tail = node
            return node
        }
        headNode.prev = node
        node.next = headNode
        head = node
        return node
    }
    
    func moveToFront(_ node: Node) {
        guard node !== head else { return }
        remove(node)
        node.next = head
        node.prev = nil
        head?.prev = node
        head = node
        if tail == nil { tail = node }
    }
    
    func remove(_ node: Node) {
        defer { count -= 1 }
        node.prev?.next = node.next
        node.next?.prev = node.prev
        if node === head { head = node.next }
        if node === tail { tail = node.prev }
        node.prev = nil
        node.next = nil
    }
    
    func removeLast() -> T {
        guard let node = tail else { fatalError("Removing from empty list") }
        remove(node)
        return node.value
    }
}
