//
//  ViewController.swift
//  Calculator2
//
//  Created by Chris William Sehnert on 7/23/17.
//  Copyright © 2017 InSehnDesigns. All rights reserved.
//

import UIKit

class ViewController: UIViewController {


    @IBOutlet weak var display: UILabel!

    var userIsTyping = false
    
    private var brain = Calc2Brain()
    
    private var decimalCount = 0
    
    @IBAction func touchDigit(_ sender: UIButton) {
        
        let digit = sender.currentTitle!
        
        if digit == "." {
            decimalCount += 1
        }
        
        if (decimalCount < 2 || digit != ".") {
            if userIsTyping {
                let currentlyInDisplay = display.text!
                display.text = currentlyInDisplay + digit
            } else {
                display.text = digit
                userIsTyping = true
            }
        }
        
    }
    
    
    var displayValue: Double {
        get {
            return Double(display.text!)!
        }
        set {
            if newValue.isInfinite {
                display.text = "Error"
            }
            if newValue == 0.0 {
                display.text = "0"
            } else {
                display.text = String(newValue)
            }
        }
    }
    
    
    @IBAction func performOperation(_ sender: UIButton) {
        if userIsTyping {
            brain.setOperand(displayValue)
            userIsTyping = false
            decimalCount = 0
        }
        if let mathematicalSymbol = sender.currentTitle {
            brain.performOperation(mathematicalSymbol)
        }
        if let result = brain.result {
            displayValue = result
        }
    }
}

        
