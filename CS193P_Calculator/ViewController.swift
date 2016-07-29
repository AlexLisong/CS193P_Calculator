//
//  ViewController.swift
//  Calculator
//
//  Created by Yuduo Zhang on 2016-07-23.
//  Copyright © 2016 Yuduo Zhang. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    private var brain = CalculatorBrain()
    private var userIsInTheMiddleOfTyping = false
    private var userIsInTheMiddleOfTypingFloatingNumber = false
    
    private let decimalFormatter = NSNumberFormatter()
        
    private var displayValue: Double {
        get {
            return Double(display.text!)!
        }
        set {
            display.text = decimalFormatter.stringFromNumber(newValue)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        decimalFormatter.numberStyle = NSNumberFormatterStyle.DecimalStyle
        decimalFormatter.maximumFractionDigits = 6
        decimalFormatter.minimumFractionDigits = 0
    }
    
    @IBOutlet private weak var display: UILabel!
    @IBOutlet weak var operationSequence: UILabel!
    
    @IBAction private func touchDigit(sender: UIButton) {
        let digit = sender.currentTitle!
        if userIsInTheMiddleOfTyping {
            let textCurrentlyInDisplay = display.text!
            display.text = textCurrentlyInDisplay + digit
        } else {
            display.text = digit
        }
        userIsInTheMiddleOfTyping = true
    }
    
    @IBAction private func touchDotButton(sender: UIButton) {
        // only valid in the middle of typing
        let dotButtonString = sender.currentTitle!
        
        if (userIsInTheMiddleOfTyping || display.text! == "0") && !userIsInTheMiddleOfTypingFloatingNumber {
            display.text = display.text! + dotButtonString
            userIsInTheMiddleOfTypingFloatingNumber = true
            userIsInTheMiddleOfTyping = true
        }
    }
    
    @IBAction private func performOperation(sender: UIButton) {
        if userIsInTheMiddleOfTyping {
            brain.setOperand(displayValue)
            userIsInTheMiddleOfTyping = false
            userIsInTheMiddleOfTypingFloatingNumber = false
        }
        if let mathematicalSymbol = sender.currentTitle {
            brain.performOperation(mathematicalSymbol)
        }
        displayValue = brain.result
        if brain.isPartialResult {
            operationSequence.text = "\(brain.description)..."
        } else {
            operationSequence.text = "\(brain.description)="
        }
    }
}


