//
//  Calc2Brain.swift
//  Calculator2
//
//  Created by Chris William Sehnert on 7/23/17.
//  Copyright © 2017 InSehnDesigns. All rights reserved.
//

import Foundation

struct Memory {
    var storedDictionary: Dictionary<String, Double> = [:]
}



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
    
    
    /* Do Not Alter public funcs from Assignment 1! */
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
    
    /* Do Not Alter public funcs from Assignment 1! */
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
    
    /* Do Not Alter public vars from Assignment 1! */
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
    
    
    /*________________________________________
     Assignment 2 properties and methods Below
     -----------------------------------------*/
    
    
    private var opList: Array<String> = []
    
    mutating func undo () {        
        if !opList.isEmpty {
            opList.removeLast()
        }
    }
    
    
    mutating func setOperand (variable named: String) {
       
        if named == "C" {
            opList.removeAll()
            
        } else {
            opList.append(named)
        }
    }
    
    /*________________________________________________________________________________________
        func evaluate(using:) represents the core implementation of this version of Calculator2
            it utilizes both Operation Enum and operations Dictionary from original implementation...
            and combines those data structures with some internal functions of it's own allowing it 
            to be a non-mutating function in the scope of the overall Calc2Brain Struct....
     ------------------------------------------------------------------------------------------*/
    func evaluate (using variables: Dictionary<String,Double>? = nil)
        -> (result: Double?, isPending: Bool, description: String) {
            
        
            // these variables are ultimately returned by the evaluate (result:isPending:description:) tuple....
            var output: Double?
            var isPending: Bool = false
            var descriptor = " "
            
            // the following variables are mutated within the scope of the func evaluate(using:)
         
            var workingOps = [String]()
            var equalsIsSet: Bool = false
            var currentOperation: Operation?
            var operand1: Double?
            var operand2: Double?
            var variableValue: Double = 0
            var workingOp: String?
            var currentOp: String?
            var variableOperand: String?
            var pendingOperation: Operation?
            var binarys = ["+", "-", "÷", "×"]
            var constantsOrRandom = ["π", "e", "?#"]
            var isConstantOrRandom = false
            var isBinary = false
            var opSetOnValue = false
            var isVariable = false

            
            /*___________________________________________________________________________________
             nested methods .... func operationsSwitcher(op:op1:op2:) is called
             by the other nested method .... func evaluation(ops:)
             -------------------------------------------------------------*/
            func operationsSwitcher (op: Operation, op1: Double?, op2: Double?) -> Double? {
                
                switch op {
                case .constant(let value):
                    if operand1 == nil {
                        operand1 = value
                        opSetOnValue = true
                        descriptor = descriptor + "\(workingOp!)"
                    }
                    else if operand2 == nil {
                        operand2 = value
                        opSetOnValue = true
                        descriptor = descriptor + " \(workingOp!)"
                    }
                    
                    equalsIsSet = true
                    return value
                    
                    
                case .unaryOperation(let function):
                    
                    equalsIsSet = false
                    if op2 != nil {
                        if isVariable {
                            descriptor = descriptor + " \(workingOp!)(\(variableOperand!))"
                            isVariable = false
                        } else {
                            descriptor = descriptor + " \(workingOp!)(\(op2!))"
                        }
                        opSetOnValue = true
                        equalsIsSet = true
                        return function(op2!)
                    }
                    if op1 != nil {
                        descriptor = "\(workingOp!)(\(descriptor))"
                        opSetOnValue = true
                        equalsIsSet = true
                        return function(op1!)
                    } else {
                        descriptor = "\(workingOp!)(0)"
                        equalsIsSet = true
                        return function(0)
                    }
                case .binaryOperation(let function):
                    if workingOp == "=" || isConstantOrRandom {
                        workingOp = " "
                    }
                    
                    if equalsIsSet && output != nil {
                        equalsIsSet = false
                    }
                    if op1 == nil {
                        isPending = false
                        isBinary = false
                        return nil
                    }
                    else if op2 == nil {
                        descriptor = descriptor + " \(workingOp!)"
                        isPending = true
                        opSetOnValue = false
                        isVariable = false
                        return nil
                    }
                    else {
                        if opSetOnValue == true {
                            if workingOp == "=" {
                                workingOp = " "
                            }
                            descriptor = "(\(descriptor) )\(workingOp!)"
                            opSetOnValue = false
                        }
                        else if opSetOnValue == false {
                            if isVariable {
                                descriptor = "(\(descriptor) \(variableOperand!) )\(workingOp!)"
                                isVariable = false
                            }
                            else {
                                descriptor = "(\(descriptor) \(op2!) )\(workingOp!)"
                            }
                        }
                        return function(op1!, op2!)
                        
                    }
                case .equals:
                    
                    if isPending {
                        output = operationsSwitcher(op: pendingOperation!, op1: operand1, op2: operand2)
                        isPending = false
                        
                        return output
                        
                    } else {
                        if operand2 == nil {
                            output = operand1
                            isPending = false
                        } else {
                            output = operationsSwitcher(op: currentOperation!, op1: operand1, op2: operand2)
                            isPending = false
                            
                        }
                        return output
                        
                    }
                case .clear:
                    descriptor = "description... "
                    workingOps.removeAll()
                    isPending = false
                    operand1 = nil
                    operand2 = nil
                    return nil
                    
                default:
                    descriptor = " "
                    operand1 = nil
                    operand2 = nil
                    break
                    
                }
                return nil
            }
            
            // nested method.... func evaluation(ops:) is called with external "opList" array by conditional below.....
            func evaluation (ops: [String]) -> Double? {
                
                workingOps = ops
                
                
                while workingOps.count > 0 {
                    
                    workingOp = workingOps[0]
                    
                    if isPending && isBinary {
                        
                        pendingOperation = currentOperation ?? operations["C"]
                    }
                    
                    if let operation = operations[workingOp!] {
                        
                        if workingOp != "="  {
                            
                            if binarys.contains(workingOp!) {
                                isBinary = true
                                equalsIsSet = false
                                currentOperation = operation
                            } else {
                                isBinary = false
                            }
                            if constantsOrRandom.contains(workingOp!) {
                                isConstantOrRandom = true
                            } else {
                                isConstantOrRandom = false
                            }
                            
                        } else {
                            equalsIsSet = true
                            isBinary = false
                        }
                        if isConstantOrRandom {
                            if equalsIsSet {
                                operand1 = nil
                                operand2 = nil
                                isPending = false
                                descriptor = " "
                                equalsIsSet = false
                            }
                            output = operationsSwitcher(op: operation, op1: operand1, op2: operand2)
                            isConstantOrRandom = false
                            workingOps.removeFirst()
                            continue
                        }
                        
                        if isPending && workingOp != "=" {
                            if isBinary {
                                output = operationsSwitcher(op: pendingOperation!, op1: operand1, op2: operand2)
                                operand1 = output
                                operand2 = nil
                                isPending = true
                            } else {
                                output = operationsSwitcher(op: operation, op1: operand1, op2: operand2)
                                operand2 = output
                            }
                            
                        }
                        else {
                            output = operationsSwitcher(op: operation, op1: operand1, op2: operand2)
                            if output != nil {
                                operand1 = output
                                operand2 = nil
                            }
                        }
                        workingOps.removeFirst()
                    }
                        
                    else if Double(workingOp!) != nil {
                        if equalsIsSet {
                            operand1 = nil
                            operand2 = nil
                            equalsIsSet = false
                        }
                        if operand1 == nil {
                            output = nil
                            operand1 = Double(workingOp!)
                            descriptor = "\(workingOp!)"
                            equalsIsSet = true
                            
                        } else {
                            operand2 = Double(workingOp!)
                            equalsIsSet = true
                            
                        }
                        workingOps.removeFirst()
                    }
                    else {
                        isVariable = true
                        variableOperand = workingOp!
                        if equalsIsSet {
                            operand1 = nil
                            operand2 = nil
                            isPending = false
                            equalsIsSet = false
                        }
                        
                        if let varValue = variables?[variableOperand!] {
                            variableValue = varValue
                        }
                        
                        if operand1 == nil {
                            output = nil
                            operand1 = variableValue
                            descriptor = "\(workingOp!)"
                            
                            equalsIsSet = true
                            
                        } else {
                            operand2 = variableValue
                            equalsIsSet = true
                        }
                        
                        workingOps.removeFirst()
                    }
                }
            
                return output
            }
            
            
            /*________________________________________________________________________________
             this simple conditional statement accesses opList array of input from user...
             and calls the nested func evaluation(ops:)
             -------------------------------------------------*/
            if opList.isEmpty {
                output = nil
                isPending = false
                descriptor = "description= "
            } else {
                output = evaluation(ops: opList)
            }
            
            
            return (output, isPending, descriptor)
    }
    
    
    
}

































