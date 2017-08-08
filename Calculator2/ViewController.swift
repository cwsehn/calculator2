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
    
    private var brain = Calc2Brain()
    private var memoryStore = Memory()
    
    
    
    private var userIsTyping = false
    private var clearEntry = false
    private var isVariable = false
    private var descriptionText = ""
    private var decimalCount = 0
    private var variableAssignment: Double?
    private var variableDictionary: [String : Double]?
    
    private var evaluation: (result: Double?, isPending: Bool, description: String) = (nil, false, "")
    
    
    @IBAction func touchDigit(_ sender: UIButton) {
        
        if isVariable == false {
            
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
            }
            else {
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
    }
    
    
    
    private var displayValue: Double {
        get {
            if display.text != nil {
                return Double(display.text!)!
            } else { return 0 }
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
            descriptionDisplay.text = evaluation.description
        }
    }

    
    
    @IBAction func clearDisplay(_ sender: UIButton) {
        
        brain.setOperand(variable: sender.currentTitle!)
        memoryStore.storedDictionary = [:]
        evaluation = brain.evaluate()
        descriptionDisplayValue = evaluation.description
        displayValue = 0
        
    }
    
    

    @IBAction func performOperation(_ sender: UIButton) {
        
        if isVariable {
            brain.setOperand(variable: sender.currentTitle!)
            evaluation = brain.evaluate(using: memoryStore.storedDictionary)
            descriptionDisplayValue = evaluation.description
            isVariable = false
        }
            
        else if userIsTyping {
            
            userIsTyping = false
            decimalCount = 0
            
            brain.setOperand(variable: display.text!)
            brain.setOperand(variable: sender.currentTitle!)
            evaluation = brain.evaluate(using: memoryStore.storedDictionary)
            descriptionDisplayValue = evaluation.description
            
        } else {
            
            brain.setOperand(variable: sender.currentTitle!)
            evaluation = brain.evaluate(using: memoryStore.storedDictionary)
            descriptionDisplayValue = evaluation.description
        }
        if evaluation.result != nil {
            displayValue = evaluation.result!
        }
            
        else if !evaluation.isPending && evaluation.result == nil {
            displayValue = 0
        }
    }
    
        
      
    @IBAction func VariableInput(_ sender: UIButton) {
        
        if userIsTyping == false {
            brain.setOperand(variable: sender.currentTitle!)
            evaluation = brain.evaluate(using: memoryStore.storedDictionary)
            descriptionDisplayValue = evaluation.description
            
            if evaluation.result != nil {
                displayValue = evaluation.result!
            }
            
            isVariable = true
        }
}

   
    
    
    @IBAction func assignVariable(_ sender: UIButton) {
        
        userIsTyping = false
        variableAssignment = displayValue
        memoryStore.storedDictionary = ["M" : variableAssignment!]
        
        evaluation = brain.evaluate(using: memoryStore.storedDictionary)
        descriptionDisplayValue = evaluation.description
        
        if evaluation.result != nil {
            displayValue = evaluation.result!
        }
        else {
            displayValue = 0
        }
 
    }
    
    
    @IBAction func undoEntry(_ sender: UIButton) {
        brain.undo()
        evaluation = brain.evaluate(using: memoryStore.storedDictionary)
        descriptionDisplayValue = evaluation.description
        
        if evaluation.result != nil {
            displayValue = evaluation.result!
        }
        else {
            displayValue = 0
        }
        
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
    
    
    
}












