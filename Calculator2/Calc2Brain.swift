//
//  Calc2Brain.swift
//  Calculator2
//
//  Created by Chris William Sehnert on 7/23/17.
//  Copyright © 2017 InSehnDesigns. All rights reserved.
//

import Foundation


struct Calc2Brain {
    
    private var accumulator: Double? = 0.0
    private var randomDouble: String?
    var resultIsPending = false
    
    private var operatorSetOnAccumulator = false
    
    private var description: String = ""
    
    
    private enum Operation {
        case constant(Double)
        case unaryOperation((Double) -> Double)
        case binaryOperation((Double,Double) -> Double)
        case random
        case equals
        case clear
    }
    
    
    mutating func setOperand (_ operand: Double) {
        
        if operatorSetOnAccumulator {
            description = ""
        }
        
        accumulator = operand
        operatorSetOnAccumulator = false
        
        if description == "" {
            description = "\(description) \(format(accumulator!)) "
        }
    }
    
    
    mutating func performOperation (_ symbol: String) {
        
        if let operation = operations[symbol] {
            switch operation {
                
            case .constant(let value):
                description = "\(description)\(symbol) "
                accumulator = value
                operatorSetOnAccumulator = true
                
            case .unaryOperation(let function):
                if resultIsPending && accumulator != nil {
                    description = "\(description) \(symbol)(\(format(accumulator!))) "
                    operatorSetOnAccumulator = true
                    accumulator = function(accumulator!)
                } else {
                    description = "\(symbol)(\(description)) "
                    if accumulator != nil {
                        accumulator = function(accumulator!)
                        operatorSetOnAccumulator = true
                    }
                }
            case .binaryOperation(let function):
                if accumulator != nil {
                    if resultIsPending {
                        if !operatorSetOnAccumulator {
                            description = "\(description) \(format(accumulator!)) "
                        }
                        performBinaryOperation()
                    }
                    pendingBinaryOperation = PendingBinaryOperation(function: function, firstOperand: accumulator!)
                    description = "\(description) \(symbol) "
                    accumulator = nil
                    resultIsPending = true
                    operatorSetOnAccumulator = false
                }
            case .equals:
                if (!operatorSetOnAccumulator && accumulator != nil) {
                    description = "\(description) \(format(accumulator!)) "
                }
                if resultIsPending {
                    performBinaryOperation()
                }
                
            case .random:
                accumulator = nextRandom()
                operatorSetOnAccumulator = true
                
                description = "\(description) \(format(accumulator!)) "
                
            case .clear:
                accumulator = nil
                operatorSetOnAccumulator = false
                description = ""
                resultIsPending = false
            }
            
        }
    }
    
    private let operations: Dictionary<String,Operation> = [
        "π": .constant(Double.pi),
        "e": .constant(M_E),
        "√": .unaryOperation(sqrt),
        "±": .unaryOperation { -$0 },
        "%": .unaryOperation { $0 / 100 },
        "C": .clear,
        "cos": .unaryOperation(cos),
        "sin": .unaryOperation(sin),
        "+": .binaryOperation { $0 + $1 },
        "-": .binaryOperation { $0 - $1 },
        "×": .binaryOperation { $0 * $1 },
        "÷": .binaryOperation { $0 / $1 },
        "?#": .random,
        "=": .equals
    ]
    
    
    private struct PendingBinaryOperation {
        let function: (Double,Double) -> Double
        let firstOperand: Double
        
        func perform(with secondOperand: Double) -> Double {
            
            return function(firstOperand, secondOperand)
        }
    }
    
    private var pendingBinaryOperation: PendingBinaryOperation?
    
    private mutating func performBinaryOperation () {
        if (pendingBinaryOperation != nil && accumulator != nil) {
            accumulator = pendingBinaryOperation!.perform(with: accumulator!)
            pendingBinaryOperation = nil
            resultIsPending = false
            operatorSetOnAccumulator = false
        }
    }
    
    
    var result: (Double?, String)? {
        get {
            if description == "" {
                return (0.0, "description")
            }
            else  {
                return (accumulator, description)
            }
        }
    }
    
    
    private func format (_ input: Double) -> String {
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
    
    
    private func nextRandom() -> Double {
        
        let numerator = Double (arc4random())
        let denominator = Double(arc4random())
        
        if numerator == 0.0 || denominator == 0.0 {
            return 0
        }
        
        if numerator > denominator {
            return denominator / numerator
        } else {
            return numerator / denominator
        }
    }
    
    
    
    
    /*
     // using default ?? values with optionals...
     let nickName: String? = "Johnny"
     let fullName: String = "John Appleseed"
     let informalGreeting = "Hi \(nickName ?? fullName)"
     
     */
    /*______________________________
     Assignment 2 methods Below
     -------------------------------*/
    
    
    func setOperand (variable named: String) {
        // allow for variable input ...
    }
    
    func evaluate (using variables: Dictionary<String,Double>? = nil)
        -> (result: Double?, isPending: Bool, description: String) {
            
            return (accumulator, resultIsPending, description)
    }
    
    
    
    
    
    
    
}





























