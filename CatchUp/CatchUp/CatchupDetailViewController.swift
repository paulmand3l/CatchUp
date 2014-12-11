//
//  DetailViewController.swift
//  CatchUp
//
//  Created by Paul Mandel on 12/8/14.
//  Copyright (c) 2014 Mandelbrot Makers. All rights reserved.
//

import Foundation
import UIKit

class CatchupDetailViewController: UIViewController {
    @IBOutlet var frequencyLabel: UILabel!
    @IBOutlet var periodLabel: UILabel!
    
    var catchupFrequency : Int?
    var catchupPeriod : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        frequencyLabel.text = String(self.catchupFrequency ?? 1)

        periodLabel.text = self.catchupPeriod ?? "month"
    }
}