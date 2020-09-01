//
//  QuadTreeTests.swift
//  QuadTreeTests
//
//  Created by Ramsundar Shandilya on 8/8/20.
//  Copyright © 2020 Ramsundar Shandilya. All rights reserved.
//

import XCTest
@testable import QuadTree

class QuadTreeTests: XCTestCase {

    func testWithOnePoint() {
        let rect = CGRect(x: 0, y: 0, width: 10, height: 10)
        let quadtree = QuadTree(rect: rect)

        quadtree.add(point: CGPoint(x: 1, y: 1))
        let result1 = quadtree.points(inRect: CGRect(x: 0, y: 0, width: 2, height: 2))
        XCTAssertEqual(result1.count, 1)

        let result2 = quadtree.points(inRect: CGRect(x: 2, y: 2, width: 2, height: 2))
        XCTAssertEqual(result2.count, 0)
    }

    func testWithPointOnBoundary() {
        let rect = CGRect(x: 0, y: 0, width: 10, height: 10)
        let quadtree = QuadTree(rect: rect)

        //boundary
        quadtree.add(point: CGPoint(x: 1, y: 1))
        quadtree.add(point: CGPoint(x: 2, y: 2))
        let result1 = quadtree.points(inRect: CGRect(x: 0, y: 0, width: 2, height: 2))
        XCTAssertEqual(result1.count, 1)

        quadtree.add(point: CGPoint(x: 1.9, y: 1.9))
        let result2 = quadtree.points(inRect: CGRect(x: 0, y: 0, width: 2, height: 2))
        XCTAssertEqual(result2.count, 2)
    }

}
