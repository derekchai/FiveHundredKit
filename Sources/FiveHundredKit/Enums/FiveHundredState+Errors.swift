//
//  FiveHundredState+Errors.swift
//  FiveHundredKit
//
//  Created by Derek Chai on 12/08/2025.
//

import Foundation

extension FiveHundredState {
    public enum BiddingError: Error, LocalizedError {
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
    
    public enum GameError: Error, LocalizedError {
        case noBidMade
        case playerNotFound
        
        public var errorDescription: String? {
            switch self {
            case .noBidMade:
                "No bid has been made"
            case .playerNotFound:
                "Player was not found"
            }
        }
    }
    
    public enum RuleError: Error, LocalizedError {
        case playerDoesNotHoldCard
        case mustFollowSuit
        case sameCardCannotBeDiscardedMultipleTimes
        case exactlyThreeCardsMustBeDiscarded
        
        public var errorDescription: String? {
            switch self {
            case .playerDoesNotHoldCard:
                "The player does not hold the specified card"
            case .mustFollowSuit:
                "Played card must follow suit"
            case .sameCardCannotBeDiscardedMultipleTimes:
                "The same card cannot be discarded multiple times"
            case .exactlyThreeCardsMustBeDiscarded:
                "Exactly 3 cards must be discarded"
            }
        }
    }
}
