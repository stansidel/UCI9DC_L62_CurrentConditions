//
//  ViewController.swift
//  UCI9DC L62 CurrentConditions
//
//  Created by Stanislav Sidelnikov on 2/23/16.
//  Copyright © 2016 Stanislav Sidelnikov. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {
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
        self.view.endEditing(true)
        guard let city = cityTextField.text where !city.isEmpty else {
            self.displayCondition("Enter city to see the weather conditions")
            return
        }
        let teller = WeatherTeller()
        teller.tellConditionsForCity(city) { (condition, error) -> Void in
            if condition != nil {
                self.displayCondition(condition!)
            } else {
                var errStr = "Error occured."
                if error != nil {
                    errStr += " \(error!.localizedDescription) \(error!.localizedFailureReason ?? "")"
                }
                self.displayError(errStr)
            }
        }
    }

    func displayCondition(condition: String) {
        self.ResultLabel.text = condition
        self.ResultLabel.textColor = UIColor.blackColor()
    }

    func displayError(errorText: String) {
        self.ResultLabel.text = errorText
        self.ResultLabel.textColor = UIColor.redColor()
    }

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }

    // MARK: - UITextFieldDelegate

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == cityTextField {
            textField.resignFirstResponder()
            showConiditions(textField)
        }
        return true
    }
}

