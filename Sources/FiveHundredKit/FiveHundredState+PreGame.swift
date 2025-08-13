//
//  FiveHundredState+PreGame.swift
//  FiveHundredKit
//
//  Created by Derek Chai on 13/08/2025.
//

extension FiveHundredState {
    public mutating func bid(_ bid: Bid) throws {
        guard acceptingBids else {
            throw BiddingError.biddingClosed
        }
        
        if let lastValuedBid = bids.last(where: { $0.bid != .pass }),
           bid != .pass {
            guard bid > lastValuedBid.bid else {
                throw BiddingError.invalidBid
            }
        }
        
        if bid != .pass {
            self.bid = (playerToPlay, bid)
        }
        
        bids.append((playerToPlay, bid))
        playerToPlay = nextPlayer
        
        guard bids.count == players.count else { return }
        
        if bids.count(where: { $0.bid == .pass }) == players.count {
            guard let lastValuedBid = self.bid else {
                // Dead hand. Re-deal.
                deal()
                bids.removeAll()
                return
            }
            
            // Bid won
            playerToPlay = lastValuedBid.player
            acceptingBids = false
            hands[lastValuedBid.player]?.append(contentsOf: kitty)
            kitty.removeAll()
        } else {
            bids.removeAll()
        }
    }
    
    /// Resets kitty and hands and deals the entire 500 deck to all players
    /// and the kitty.
    public mutating func deal() {
        // Reset kitty and hands
        kitty.removeAll()
        for player in hands.keys {
            hands[player]?.removeAll()
        }
        
        var deck = PlayingCard.shuffled500Deck
        
        for _ in 1...3 {
            kitty.append(deck.removeFirst())
        }
        
        var i = 0
        while !deck.isEmpty {
            hands[players[i]]?.append(deck.removeFirst())
            i = (i + 1) % players.count
        }
        
        for player in players {
            hands[player]?.sort(by: FiveHundredState.handSortingPredicate)
        }
    }
    
    public mutating func setHand(of player: Player,
                                 to cards: [PlayingCard]) throws {
        guard hands.keys.contains(player) else {
            throw GameError.playerNotFound
        }
        
        hands[player] = cards
    }
}
