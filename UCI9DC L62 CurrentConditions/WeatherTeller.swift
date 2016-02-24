//
//  WeatherTeller.swift
//  UCI9DC L62 CurrentConditions
//
//  Created by Stanislav Sidelnikov on 24/02/16.
//  Copyright © 2016 Stanislav Sidelnikov. All rights reserved.
//

import Foundation
import UIKit

class WeatherTeller {
    let server = "http://www.weather-forecast.com"
    func tellConditionsForCity(city: String, completionHandler: (String?, NSError?) -> Void) {
        var cityProccessed = city.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        cityProccessed = String(cityProccessed.characters.map {
            $0 == " " ? "-" : $0
        })
        let urlString = "\(server)/locations/\(cityProccessed)/forecasts/latest"
        guard let url = NSURL(string: urlString) else {
            let userInfo = [
                NSLocalizedDescriptionKey: "Request failed.",
                NSLocalizedFailureReasonErrorKey: String(format: "Cannot get NSURL from string %@.", urlString),
                NSLocalizedRecoverySuggestionErrorKey: ""
            ]
            let error = NSError(domain: "WeatherTellerError", code: 101, userInfo: userInfo)
            dispatch_async(dispatch_get_main_queue(), {
                completionHandler(nil, error)
            })
            return
        }
        let task = NSURLSession.sharedSession().dataTaskWithURL(url) { (data, response, error) -> Void in
            dispatch_async(dispatch_get_main_queue(), {
                (UIApplication.sharedApplication().delegate as! AppDelegate).hideNetworkActivityIndicator()
            })
            if let code = (response as? NSHTTPURLResponse)?.statusCode {
                if code == 404 {
                    let userInfo = [
                        NSLocalizedDescriptionKey: "Incorrect city.",
                        NSLocalizedFailureReasonErrorKey: "The site doesn't know such city.",
                        NSLocalizedRecoverySuggestionErrorKey: "Try entering another city"
                    ]
                    let err = NSError(domain: "WeatherTellerError", code: 404, userInfo: userInfo)
                    dispatch_async(dispatch_get_main_queue(), {
                        completionHandler(nil, err)
                    })
                    return
                } else if code != 200 {
                    var err = error
                    if err == nil {
                        let userInfo = [
                            NSLocalizedDescriptionKey: "Request failed.",
                            NSLocalizedFailureReasonErrorKey: "Unknown error.",
                            NSLocalizedRecoverySuggestionErrorKey: ""
                        ]
                        err = NSError(domain: "WeatherTellerError", code: code, userInfo: userInfo)
                    }
                    dispatch_async(dispatch_get_main_queue(), {
                        completionHandler(nil, err)
                    })
                    return
                }
            }
            guard let dataUnwrapped = data else {
                var err = error
                if err == nil {
                    let userInfo = [
                        NSLocalizedDescriptionKey: "Request failed.",
                        NSLocalizedFailureReasonErrorKey: "No data received.",
                        NSLocalizedRecoverySuggestionErrorKey: ""
                    ]
                    err = NSError(domain: "WeatherTellerError", code: 401, userInfo: userInfo)
                }
                dispatch_async(dispatch_get_main_queue(), {
                    completionHandler(nil, err)
                })
                return
            }
            guard let string = String(data: dataUnwrapped, encoding: NSUTF8StringEncoding) else {
                let userInfo = [
                    NSLocalizedDescriptionKey: "Data processing failed.",
                    NSLocalizedFailureReasonErrorKey: "Cannot convert received data to string.",
                    NSLocalizedRecoverySuggestionErrorKey: ""
                ]
                let err = NSError(domain: "WeatherTellerError", code: 402, userInfo: userInfo)
                dispatch_async(dispatch_get_main_queue(), {
                    completionHandler(nil, err)
                })
                return
            }
            guard let conditions = self.getCurrentConditionsFromString(string) else {
                let userInfo = [
                    NSLocalizedDescriptionKey: "Data processing failed.",
                    NSLocalizedFailureReasonErrorKey: "Cannot find current conditions in the string",
                    NSLocalizedRecoverySuggestionErrorKey: "Ask the developer"
                ]
                let err = NSError(domain: "WeatherTellerError", code: 403, userInfo: userInfo)
                dispatch_async(dispatch_get_main_queue(), {
                    completionHandler(nil, err)
                })
                return
            }
            dispatch_async(dispatch_get_main_queue(), {
                completionHandler(conditions, nil)
            })
        }
        (UIApplication.sharedApplication().delegate as! AppDelegate).showNetworkActivityIndicator()
        task.resume()
    }

    private func getCurrentConditionsFromString(string: String) -> String? {
        let parts = string.componentsSeparatedByString("<span class=\"phrase\">")
        guard parts.count > 1 else {
            return nil
        }
        let firstPartParts = parts[1].componentsSeparatedByString("</span>")
        guard firstPartParts.count > 0 else {
            return nil
        }
        var decodedString: String? = nil
        if let encodedData = firstPartParts[0].dataUsingEncoding(NSUTF8StringEncoding) {
            let attributedOptions: [String: AnyObject] = [
                NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
                NSCharacterEncodingDocumentAttribute: NSUTF8StringEncoding
            ]
            do {
                let attributedString = try NSAttributedString(data: encodedData, options:  attributedOptions, documentAttributes: nil)
                decodedString = attributedString.string
            } catch {

            }
        }
        return decodedString
    }
}
