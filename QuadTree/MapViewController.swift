//
//  MapViewController.swift
//  QuadTree
//
//  Created by Ramsundar Shandilya on 8/9/20.
//  Copyright © 2020 Ramsundar Shandilya. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {

    private enum Mode {
        case addPoints
        case viewClustering
    }



    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var scrollLockButton: UIButton!
    @IBOutlet weak var modeSegmentedControl: UISegmentedControl!

    private var annotations = [ClusterAnnotation]()
    private var clusterAnnotations = [ClusterAnnotation]()

    private var mode: Mode = .addPoints {
        didSet {
            updateUI()
        }
    }
    
    private lazy var tapGestureRecognizer: UITapGestureRecognizer = {
        return UITapGestureRecognizer(target: self, action: #selector(mapTapped(_:)))
    }()

    private lazy var panGestureRecognizer: UIPanGestureRecognizer = {
        return UIPanGestureRecognizer(target: self, action: #selector(viewPanned(_:)))
    }()
    

    override func viewDidLoad() {
        super.viewDidLoad()

        setupMapView()
        mapView.addGestureRecognizer(tapGestureRecognizer)
        mapView.addGestureRecognizer(panGestureRecognizer)

        deleteButton.layer.cornerRadius = deleteButton.bounds.height/2

        updateUI()
    }

    private func setupMapView() {
        let center = CLLocationCoordinate2D(latitude: 37.779_379, longitude: -122.418_433)
        let region = MKCoordinateRegion(center: center, latitudinalMeters: 7000, longitudinalMeters: 7000)

        mapView.setRegion(region, animated: false)
        mapView.delegate = self
        mapView.register(ClusterAnnotationView.self, forAnnotationViewWithReuseIdentifier: "cluster")
        mapView.isRotateEnabled = false
        view.sendSubviewToBack(mapView)
    }

    private func updateUI() {
        switch mode {
        case .addPoints:
            tapGestureRecognizer.isEnabled = true
            panGestureRecognizer.isEnabled = true

            deleteButton.isHidden = false
            scrollLockButton.isHidden = false

            mapView.removeAnnotations(clusterAnnotations)
            mapView.addAnnotations(annotations)
            mapView.isScrollEnabled = !scrollLockButton.isSelected
            
        case .viewClustering:
            tapGestureRecognizer.isEnabled = false
            panGestureRecognizer.isEnabled = false

            deleteButton.isHidden = true
            scrollLockButton.isHidden = true

            mapView.removeAnnotations(annotations)
            clusterAnnotations = clusteredAnnotations(mapRect: mapView.visibleMapRect)
            mapView.addAnnotations(clusterAnnotations)
            mapView.isScrollEnabled = true
        }
    }

    @IBAction func modeChange(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            mode = .addPoints
        } else {
            mode = .viewClustering
        }
    }

    @IBAction func lockToggled(_ sender: UIButton) {
        sender.isSelected.toggle()
        if sender.isSelected {
            mapView.isScrollEnabled = false
        } else {
            mapView.isScrollEnabled = true
        }
    }
    
    @IBAction func deleteTapped(_ sender: Any) {
        mapView.removeAnnotations(annotations)
        annotations.removeAll()
    }

    @objc func mapTapped(_ sender: UITapGestureRecognizer) {
        guard sender.state == .ended else { return }

        let position = sender.location(in: mapView)
        let coordinate = mapView.convert(position, toCoordinateFrom: mapView)

        let annotation = ClusterAnnotation(coordinate: coordinate)
        annotations.append(annotation)
        mapView.addAnnotation(annotation)
    }

    @objc func viewPanned(_ sender: UIPanGestureRecognizer) {
        guard mode == .addPoints else { return }

        let position = sender.location(in: mapView)
        let coordinate = mapView.convert(position, toCoordinateFrom: mapView)

        let annotation = ClusterAnnotation(coordinate: coordinate)
        annotations.append(annotation)
        mapView.addAnnotation(annotation)
    }

    private func clusteredAnnotations(mapRect: MKMapRect) -> [ClusterAnnotation] {

        let minLong = floor(mapRect.minX)
        let minLat = floor(mapRect.minY)

        let maxLong = ceil(mapRect.maxX)
        let maxLat = ceil(mapRect.maxY)

        let boxWidth: Double = mapRect.width/4
        let boxHeight: Double = mapRect.height/4

        print("MapRect - ", mapRect)
        print("Min Long - ", minLong)
        print("Min Lat - ", minLat)
        print("Max Long - ", maxLong)
        print("Max Lat - ", maxLat)

        let rect = mapView.rectFromMapRect(mapRect)
        let quadTree = QuadTree(rect: CGRect(x: 0, y: 0, width: rect.width, height: rect.height))

        for annotation in annotations {
            let point = mapView.convert(annotation.coordinate, toPointTo: mapView)
            quadTree.add(point: point)
        }

        var clusterAnnotations = [ClusterAnnotation]()

        var i = minLong
        while i < maxLong + boxWidth {
            var j = minLat
            while j < maxLat + boxHeight {
                let boundaryRect = mapView.rectFromMapRect(MKMapRect(x: i, y: j, width: boxWidth, height: boxHeight))
                let points = quadTree.points(inRect: boundaryRect)

                let coordinate: CLLocationCoordinate2D

                if points.count == 1 {
                    coordinate = mapView.convert(points[0], toCoordinateFrom: mapView)
                } else if points.count > 1 {
                    //Averaging the position of clustered annotation
                    var totalLat: CLLocationDegrees = 0
                    var totalLong: CLLocationDegrees = 0

                    for point in points {
                        let coord = mapView.convert(point, toCoordinateFrom: mapView)
                        totalLat += coord.latitude
                        totalLong += coord.longitude
                    }

                    coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(totalLat/CLLocationDegrees(points.count)),
                                                            longitude: CLLocationDegrees(totalLong/CLLocationDegrees(points.count)))

                } else {
                    j += boxHeight
                    continue
                }

                let clusterAnnotation = ClusterAnnotation(coordinate: coordinate)
                clusterAnnotation.count = points.count
                clusterAnnotations.append(clusterAnnotation)

                j += boxHeight
            }
            i += boxWidth
        }

        return clusterAnnotations
    }
}

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let clusterAnnotation = annotation as? ClusterAnnotation else {
            return nil
        }

        guard let clusterAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "cluster", for: annotation) as? ClusterAnnotationView else {
            return ClusterAnnotationView(annotation: annotation, reuseIdentifier: "cluster")
        }

        clusterAnnotationView.label.text = "\(clusterAnnotation.count)"
        return clusterAnnotationView
    }

    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        guard modeSegmentedControl.selectedSegmentIndex == 1 else {
            return
        }
        mapView.removeAnnotations(clusterAnnotations)
        clusterAnnotations = clusteredAnnotations(mapRect: mapView.visibleMapRect)
        mapView.addAnnotations(clusterAnnotations)
    }


}

extension MKMapView {
    func rectFromMapRect(_ mapRect: MKMapRect) -> CGRect {
        let region = MKCoordinateRegion(mapRect)
        return convert(region, toRectTo: self)
    }
}
