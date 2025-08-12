//
//  BidCount.swift
//  FiveHundredKit
//
//  Created by Derek Chai on 12/08/2025.
//

@propertyWrapper
struct BidCount {
    private var bidCount = 6
    
    var wrappedValue: Int {
        get { bidCount }
        set {
            if newValue > 10 { bidCount = 10}
            else if newValue < 6 { bidCount = 6 }
            else { bidCount = newValue }
        }
    }
}
