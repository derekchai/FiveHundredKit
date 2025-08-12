//
//  FiveHundredState+Errors.swift
//  FiveHundredKit
//
//  Created by Derek Chai on 12/08/2025.
//

extension FiveHundredState {
    enum GameError: Error {
        case invalidBid
        case biddingClosed
    }
}
