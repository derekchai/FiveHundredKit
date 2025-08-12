//
//  FiveHundredState+Errors.swift
//  FiveHundredKit
//
//  Created by Derek Chai on 12/08/2025.
//

import Foundation

extension FiveHundredState {
    enum GameError: Error, LocalizedError {
        case invalidBid
        case biddingClosed
        
        public var errorDescription: String? {
            switch self {
            case .invalidBid:
                "Bid was invalid (e.g. too low)"
            case .biddingClosed:
                "Bidding has already closed (i.e. no new bids accepted)"
            }
        }
    }
}
