//
//  ViewController.swift
//  UCI9DC L62 CurrentConditions
//
//  Created by Stanislav Sidelnikov on 2/23/16.
//  Copyright © 2016 Stanislav Sidelnikov. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var ResultLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func showConiditions(sender: AnyObject) {
        guard let city = cityTextField.text else {
            return
        }
        guard let url = NSURL(string: "http://www.weather-forecast.com/locations/\(city)/forecasts/latest") else {
            return
        }
//        let session = NSURLSession.dataTaskWithURL(<#T##NSURLSession#>)
    }

}

