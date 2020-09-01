//
//  ViewController.swift
//  QuadTree
//
//  Created by Ramsundar Shandilya on 8/8/20.
//  Copyright © 2020 Ramsundar Shandilya. All rights reserved.
//

import UIKit

class ViewController: UIViewController, QuadTreeViewDelegate {
    
    @IBOutlet weak var quadTreeView: QuadTreeView!
    @IBOutlet weak var modeSegmentedControl: UISegmentedControl!
    @IBOutlet weak var resultLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        quadTreeView.delegate = self
        modeSegmentedControl.selectedSegmentIndex = 0
        resultLabel.isHidden = true
    }

    @IBAction func modeChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            quadTreeView.mode = .addPoints
            resultLabel.isHidden = true
        } else {
            quadTreeView.mode = .queryPoints
            resultLabel.isHidden = false
        }
    }

    @IBAction func deleteTapped(_ sender: Any) {
        quadTreeView.reset()
    }
    
    func quadTreeViewDidQuery(_ view: QuadTreeView) {
        resultLabel.text = "\(view.result) Points"
    }

}

