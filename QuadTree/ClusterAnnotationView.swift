//
//  ClusterAnnotationView.swift
//  QuadTree
//
//  Created by Ramsundar Shandilya on 8/9/20.
//  Copyright © 2020 Ramsundar Shandilya. All rights reserved.
//

import UIKit
import MapKit

class ClusterAnnotation: NSObject, MKAnnotation {
    let coordinate: CLLocationCoordinate2D
    var count = 1

    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
    }
}

class ClusterAnnotationView: MKAnnotationView {

    let label: UILabel

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 12)
        label.textColor = .white
        label.textAlignment = .center

        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)

        frame = CGRect(x: 0, y: 0, width: 25, height: 25)
        label.frame = frame
        
        addSubview(label)
        backgroundColor = UIColor(named: "Annotation")
        layer.cornerRadius = bounds.height/2
        layer.borderColor = UIColor.white.cgColor
        layer.borderWidth = 1
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
