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
    
    
    @IBOutlet weak var descriptionDisplay: UILabel!
    
    
    
    private var userIsTyping = false
    
    private var clearEntry = false
    
    private var brain = Calc2Brain()
    
    private var evaluation: (result: Double?, isPending: Bool, description: String) = (nil, false, "")
    
    private var descriptionText = ""
    
    private var decimalCount = 0
    
    @IBAction func touchDigit(_ sender: UIButton) {
        
        
        let digit = sender.currentTitle!
        
        if digit == "CE" {
            clearEntry = true
        }
        
        if !clearEntry {
            
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
        } else {
            if !userIsTyping {
                clearEntry = false
            } else {
                if let currentDisplay = display.text {
                    var displayChars = currentDisplay.characters
                    if displayChars.count > 1 {
                        let removed = displayChars.removeLast()
                        if removed == "." {
                            decimalCount -= 1
                        }
                        display.text = String(displayChars)
                        clearEntry = false
                    }
                    else if displayChars.count == 1 {
                        display.text = "0"
                        userIsTyping = false
                        clearEntry = false
                        decimalCount = 0
                    }
                }
            }
        }
    }
    
    
    private var displayValue: Double {
        get {
            return Double(display.text!)!
        }
        set {
            display.text = formatDisplay(input: newValue)
        }
    }
    
    
    private var descriptionDisplayValue: String {
        get {
            return descriptionDisplay.text!
        }
        set {
            if evaluation.description == "" {
                descriptionText = ""
                descriptionDisplay.text = "description"
            } else {
                if evaluation.isPending {
                    descriptionText = "\(descriptionText) \(newValue)"
                    descriptionDisplay.text = "\(descriptionText)..."
                }
                else {
                    descriptionDisplay.text = "\(newValue)"
                }
            }
        }
    }
    
    
    @IBAction func performOperation(_ sender: UIButton) {
        if userIsTyping {
            
            userIsTyping = false
            decimalCount = 0
            brain.setOperand(variable: display.text!)
            evaluation = brain.evaluate()
            descriptionDisplayValue = evaluation.description
            brain.setOperand(variable: sender.currentTitle!)
            evaluation = brain.evaluate()
            descriptionDisplayValue = evaluation.description
        } else {
            
            brain.setOperand(variable: sender.currentTitle!)
            evaluation = brain.evaluate()
            descriptionDisplayValue = evaluation.description
        }
        if evaluation.result != nil {
            displayValue = evaluation.result!
        } else {
            displayValue = 0
        }
        
        
        
        
        
        
        
        
        
        
        
        
        
        /*
         // Deprecated Code from Assignment 1
         
        if let mathematicalSymbol = sender.currentTitle {
            brain.performOperation(mathematicalSymbol)
        }
        if let result = brain.result {
            if result.0 != nil {
                displayValue = result.0!
            }
            
            descriptionDisplayValue = result.1
        }
        */
    }
    
    
    private func formatDisplay (input: Double) -> String {
        let formatter = NumberFormatter()
        
        formatter.usesSignificantDigits = true
        formatter.minimumSignificantDigits = 1
        formatter.maximumSignificantDigits = 14
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 6
        formatter.positiveInfinitySymbol = "Undefined"
        let result = formatter.string(from: input as NSNumber)
        
        return result!
    }
    
    
    
    @IBAction func VariableInput(_ sender: UIButton) {
        
        if sender.currentTitle == "M" {
            brain.setOperand(variable: sender.currentTitle!)
        }
    
        let evaluation = brain.evaluate(using: ["M": displayValue])
        if evaluation.result != nil {
            displayValue = evaluation.result!
            }
        descriptionDisplayValue = evaluation.description
    }
    
    
    
}























