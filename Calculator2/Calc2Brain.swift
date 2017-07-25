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
    
    private var resultIsPending = false
    
    var description: String?
    
    private enum Operation {
        case constant(Double)
        case unaryOperation((Double) -> Double)
        case binaryOperation((Double,Double) -> Double)
        case equals
    }
    
    
    mutating func setOperand (_ operand: Double) {
        
        accumulator = operand
        description = "\(accumulator!) "
        
        
    }
    
    mutating func performOperation (_ symbol: String) {
        
        if let operation = operations[symbol] {
            switch operation {
            case .constant(let value):
                accumulator = value
                
            case .unaryOperation(let function):
                if accumulator != nil {
                    accumulator = function(accumulator!)
                }
            case .binaryOperation(let function):
                if accumulator != nil {
                    pendingBinaryOperation = PendingBinaryOperation(function: function, firstOperand: accumulator!)
                    accumulator = nil
                    resultIsPending = true
                }
            case .equals:
                performBinaryOperation()
            }

        }
    }
    
    private let operations: Dictionary<String,Operation> = [
    "π": .constant(Double.pi),
    "e": .constant(M_E),
    "√": .unaryOperation(sqrt),
    "±": .unaryOperation { -$0 },
    "%": .unaryOperation { $0 / 100 },
    "C": .constant( 0.0 ),
    "cos": .unaryOperation(cos),
    "sin": .unaryOperation(sin),
    "+": .binaryOperation { $0 + $1 },
    "-": .binaryOperation { $0 - $1 },
    "×": .binaryOperation { $0 * $1 },
    "÷": .binaryOperation { $0 / $1 },
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
        }
    }
    
    
    var result: Double? {
        get {
            return accumulator
        }
    }
    
}
