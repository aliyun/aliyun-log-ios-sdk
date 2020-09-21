//
//  Queue.swift
//  AliyunLogProducer
//
//  Created by lichao on 2020/9/4.
//  Copyright © 2020 lichao. All rights reserved.
//

import Foundation

public struct Queue<T> {
    fileprivate var array = [T?]()
    fileprivate var head = 0
    fileprivate var maxCount :Int
  
    public init(_ maxCount: Int){
        self.maxCount = maxCount
    }
    
    public var isEmpty: Bool {
        return count == 0
    }

    public var count: Int {
        return array.count - head
    }

    public mutating func enqueue(_ element: T) {
        if self.count >= self.maxCount {
            _ = self.dequeue()
        }
        array.append(element)
    }

    public mutating func dequeue() -> T? {
        guard head < array.count, let element = array[head] else { return nil }
        array[head] = nil
        head += 1
        let percentage = Double(head)/Double(array.count)
        if array.count > 50 && percentage > 0.25 {
            array.removeFirst(head)
            head = 0
        }
        return element
    }

    public var front: T? {
        if isEmpty {
            return nil
        } else {
            return array[head]
        }
    }
}

