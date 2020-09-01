//
//  QuadTreeView.swift
//  QuadTree
//
//  Created by Ramsundar Shandilya on 8/9/20.
//  Copyright © 2020 Ramsundar Shandilya. All rights reserved.
//

import UIKit

protocol QuadTreeViewDelegate: class {
    func quadTreeViewDidQuery(_ view: QuadTreeView)
}
class QuadTreeView: UIView {

    enum Mode {
        case addPoints
        case queryPoints
    }

    var mode: Mode = .addPoints {
        didSet {
            queryView.isHidden = mode == .addPoints
        }
    }

    var result = 0

    weak var delegate: QuadTreeViewDelegate?

    private lazy var quadTree: QuadTree = {
        return QuadTree(rect: bounds)
    }()

    private lazy var tapGestureRecognizer: UITapGestureRecognizer = {
        return UITapGestureRecognizer(target: self, action: #selector(viewTapped(_:)))
    }()

    private lazy var panGestureRecognizer: UIPanGestureRecognizer = {
        return UIPanGestureRecognizer(target: self, action: #selector(viewPanned(_:)))
    }()

    private lazy var queryView: UIView = {
        let view = UIView()
        view.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        view.backgroundColor = .clear
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.magenta.cgColor
        return view
    }()

    private var points: [CGPoint: UIView] = [:]
    private var boundaryRects: [CGRect: UIView] = [:]

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    func reset() {
        points.values.forEach { $0.removeFromSuperview() }
        points.removeAll()

        boundaryRects.values.forEach { $0.removeFromSuperview() }
        boundaryRects.removeAll()

        quadTree = QuadTree(rect: bounds)
    }

    private func setup() {
        addGestureRecognizer(tapGestureRecognizer)
        addGestureRecognizer(panGestureRecognizer)

        addSubview(queryView)
        queryView.isHidden = mode == .addPoints

        backgroundColor = .black
    }

    @objc func viewTapped(_ sender: UITapGestureRecognizer) {
        guard sender.state == .ended else { return }

        let position = sender.location(in: self)

        if mode == .addPoints {
            addPointView(at: position)
            quadTree.add(point: position)
            drawBoundary(quadTree)
        } else {
            queryView.center = position
        }
    }

    @objc func viewPanned(_ sender: UIPanGestureRecognizer) {
        guard sender.state == .changed else { return }

        let position = sender.location(in: self)

        if mode == .addPoints {
            addPointView(at: position)
            quadTree.add(point: position)
            drawBoundary(quadTree)
        } else {
            queryView.center = position

            let queryPoints = quadTree.points(inRect: queryView.frame)
            points.values.forEach { $0.backgroundColor = .white }

            for point in queryPoints {
                if let view = points[point] {
                    view.backgroundColor = UIColor(named: "Point Highlighted") ?? .green
                }
            }
            result = queryPoints.count
            delegate?.quadTreeViewDidQuery(self)
        }
    }

    private func drawBoundary(_ qTree: QuadTree) {
        if boundaryRects[qTree.rect] == nil {
            let boundary = UIView()
            boundary.backgroundColor = .clear
            boundary.isUserInteractionEnabled = false
            boundary.layer.borderWidth = 1
            boundary.layer.borderColor = UIColor.gray.cgColor

            boundary.frame = qTree.rect
            addSubview(boundary)

            boundaryRects[qTree.rect] = boundary
        }

        if qTree.isDivided {
            drawBoundary(qTree.topLeft!)
            drawBoundary(qTree.topRight!)
            drawBoundary(qTree.bottomLeft!)
            drawBoundary(qTree.bottomRight!)
        }
    }

    private func addPointView(at position: CGPoint) {
        guard points[position] == nil else { return }
        
        let size: CGFloat = 10
        let pointView = UIView()
        pointView.frame = CGRect(x: position.x - size/2, y: position.y - size/2, width: size, height: size)
        pointView.backgroundColor = .white
        pointView.layer.cornerRadius = size/2

        points[position] = pointView

        addSubview(pointView)
    }
}

extension CGPoint: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(x)
        hasher.combine(y)
    }
}

extension CGRect: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(origin.x)
        hasher.combine(origin.y)
        hasher.combine(size.width)
        hasher.combine(size.height)
    }
}
