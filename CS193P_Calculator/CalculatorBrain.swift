//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Yuduo Zhang on 2016-07-26.
//  Copyright © 2016 Yuduo Zhang. All rights reserved.
//

import Foundation

class CalculatorBrain {
    
    var result : Double {
        get {
            return accumulator
        }
    }
    var description = " "
    var isPartialResult = false
    
    private var accumulator = 0.0
    private var formattedAccumulator: String {
        get {
            return decimalFormatter.stringFromNumber(accumulator)!
        }
    }
    private var buffer: String?
    
    private var pending: PendingBinaryOperationInfo?
    private let decimalFormatter = NSNumberFormatter()
    
    // The following bool flag is not necessary. 
    // To-do: use a buffer to handle the description output
    
    private var operations: Dictionary<String, Operation> = [
        "π" : Operation.Constant(M_PI),
    "e" : Operation.Constant(M_E),
        "C" : Operation.Constant(0.0),
        "√" : Operation.UnaryOperation(sqrt),
        "cos" : Operation.UnaryOperation(cos),
        "sin" : Operation.UnaryOperation(sin),
        "+/-" : Operation.UnaryOperation({ -$0 }),
        "%" : Operation.UnaryOperation({ $0 / 100 }),
        "×" : Operation.BinaryOperation({ $0 * $1 }),
        "÷" : Operation.BinaryOperation({ $0 / $1 }),
        "+" : Operation.BinaryOperation({ $0 + $1 }),
        "−" : Operation.BinaryOperation({ $0 - $1 }),
        "=" : Operation.Equals
    ]
    
    private enum Operation {
        case Constant(Double!)
        case UnaryOperation((Double) -> Double)
        case BinaryOperation((Double, Double) -> Double)
        case Equals
    }
    
    private struct PendingBinaryOperationInfo {
        var binaryFunction: (Double, Double) -> Double
        var firstOperand: Double
    }
    
    init() {
        decimalFormatter.numberStyle = NSNumberFormatterStyle.DecimalStyle
        decimalFormatter.maximumFractionDigits = 6
        decimalFormatter.minimumFractionDigits = 0
    }
    
    func setOperand(operand: Double) {
        accumulator = operand
        buffer = formattedAccumulator
        if !isPartialResult {
            description = " "
        }
    }
    
    func performOperation(symbol: String) {
        if let operation = operations[symbol] {
            switch operation {
            case .Constant(let value):
                accumulator = value
                buffer = symbol
                
                if symbol == "C" {
                    pending = nil
                    description = " "
                    buffer = nil
                    isPartialResult = false
                }
            case .UnaryOperation(let function):
                if isPartialResult {
                    description += "\(symbol)(\(buffer ?? formattedAccumulator))"
                    buffer = nil
                } else {
                    if (description == " ") {
                        description = "\(symbol)(\(buffer ?? "0"))"
                    } else {
                        description = "\(symbol)(\(description))"
                    }
                }
                accumulator = function(accumulator)
            case .BinaryOperation(let function):
                description += "\(buffer ?? formattedAccumulator)\(symbol)"
                buffer = nil
                
                executePendingBinaryOperation()
                pending = PendingBinaryOperationInfo(binaryFunction: function, firstOperand: accumulator)
                isPartialResult = true
            case .Equals:
                description += buffer ?? formattedAccumulator
                buffer = nil
                executePendingBinaryOperation()
            }
        }
    }

    private func executePendingBinaryOperation() {
        if pending != nil {
            accumulator = pending!.binaryFunction(pending!.firstOperand, accumulator)
            pending = nil
            isPartialResult = false
        }
    }
}