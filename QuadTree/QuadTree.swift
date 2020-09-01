//
//  QuadTree.swift
//  QuadTree
//
//  Created by Ramsundar Shandilya on 8/8/20.
//  Copyright © 2020 Ramsundar Shandilya. All rights reserved.
//

import Foundation
import CoreGraphics

class QuadTree {

    let capacity = 4
    let rect: CGRect

    var points: [CGPoint] = []

    var topLeft: QuadTree?
    var topRight: QuadTree?
    var bottomLeft: QuadTree?
    var bottomRight: QuadTree?


    var isDivided: Bool = false

    init(rect: CGRect) {
        self.rect = rect
    }

    @discardableResult
    func add(point: CGPoint) -> Bool {
        guard rect.contains(point) else {
            return false
        }

        if points.count < capacity {
            points.append(point)
        } else {
            if !isDivided {
                subdivide()
            }

            if topLeft!.add(point: point) ||
                topRight!.add(point: point) ||
                bottomLeft!.add(point: point) ||
                bottomRight!.add(point: point)  {
                return true
            }
        }

        return true
    }

    private func subdivide() {
        topLeft = QuadTree(rect: rect.topLeftRect)
        topRight = QuadTree(rect: rect.topRightRect)
        bottomLeft = QuadTree(rect: rect.bottomLeftRect)
        bottomRight = QuadTree(rect: rect.bottomRightRect)

        isDivided = true
    }

    func points(inRect queryRect: CGRect) -> [CGPoint] {
        guard rect.intersects(queryRect) else {
            return []
        }

        var result = [CGPoint]()

        for point in points {
            if queryRect.contains(point) {
                result.append(point)
            }
        }

        if let topLeft = topLeft {
            result += topLeft.points(inRect: queryRect)
        }

        if let topRight = topRight {
            result += topRight.points(inRect: queryRect)
        }

        if let bottomLeft = bottomLeft {
            result += bottomLeft.points(inRect: queryRect)
        }

        if let bottomRight = bottomRight {
            result += bottomRight.points(inRect: queryRect)
        }

        return result
    }
}
