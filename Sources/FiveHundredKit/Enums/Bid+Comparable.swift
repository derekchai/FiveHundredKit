//
//  Bid+Comparable.swift
//  FiveHundredKit
//
//  Created by Derek Chai on 12/08/2025.
//

extension Bid: Comparable {
    static func == (lhs: Bid, rhs: Bid) -> Bool {
        return lhs.points == rhs.points
    }

    static func < (lhs: Bid, rhs: Bid) -> Bool {
        return lhs.points < rhs.points
    }
}
