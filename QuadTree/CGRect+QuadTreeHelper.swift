//
//  CGRect+QuadTreeHelper.swift
//  QuadTree
//
//  Created by Ramsundar Shandilya on 8/8/20.
//  Copyright © 2020 Ramsundar Shandilya. All rights reserved.
//

import Foundation
import CoreGraphics

//TODO: Write Tests

extension CGRect {
    var topLeftRect: CGRect {
        return CGRect(x: minX, y: minY, width: width/2, height: height/2)
    }

    var topRightRect: CGRect {
        return CGRect(x: midX, y: minY, width: width/2, height: height/2)
    }

    var bottomLeftRect: CGRect {
        return CGRect(x: minX, y: midY, width: width/2, height: height/2)
    }

    var bottomRightRect: CGRect {
        return CGRect(x: midX, y: midY, width: width/2, height: height/2)
    }
}
