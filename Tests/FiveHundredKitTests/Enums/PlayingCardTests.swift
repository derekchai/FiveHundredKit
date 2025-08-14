//
//  PlayingCardTests.swift
//  FiveHundredKit
//
//  Created by Derek Chai on 14/08/2025.
//

import Testing
@testable import FiveHundredKit

@Suite("Playing Card Tests")
struct PlayingCardTests {
    let fullDeck: [PlayingCard] = PlayingCard.shuffled500Deck
    
    let joker = PlayingCard.joker
    let _As = PlayingCard.standard(.ace, .spades)
    let _Ks = PlayingCard.standard(.king, .spades)
    let _Qs = PlayingCard.standard(.queen, .spades)
    let _Js = PlayingCard.standard(.jack, .spades)
    let _Ts = PlayingCard.standard(.ten, .spades)
    let _9s = PlayingCard.standard(.nine, .spades)
    
    let _Jc = PlayingCard.standard(.jack, .clubs)
    
    let _Ah = PlayingCard.standard(.ace, .hearts)
    let _4h = PlayingCard.standard(.four, .hearts)
    
    let _Ad = PlayingCard.standard(.ace, .diamonds)
    let _4d = PlayingCard.standard(.four, .diamonds)
    
    var spades: [PlayingCard] {
        fullDeck.filter {
            switch $0 {
            case .joker:
                return false
            case .standard(_, let suit):
                return suit == .spades
            }
        }
    }
    
    var trumps: [PlayingCard] {
        fullDeck.filter {
            switch $0 {
            case .joker:
                return true
            case .standard(let rank, let suit):
                if suit == .spades {
                    return true
                }
                
                if rank == .jack, suit == .clubs { // Off-jack
                    return true
                }
            }
            
            return false
        }
    }
    
    var hearts: [PlayingCard] {
        fullDeck.filter {
            switch $0 {
            case .joker:
                return false
            case .standard(_, let suit):
                return suit == .hearts
            }
        }
    }
    
    @Test("No-trumps card comparison")
    func testNoTrumpsCardComparison() async throws {
        fullDeck.filter { $0 != joker }.forEach {
            // Joker beats all cards
            #expect(joker.beats($0, leadSuit: .spades, trumps: .noTrumps))
            
            // No card beats joker
            #expect(!$0.beats(joker, leadSuit: .spades, trumps: .noTrumps))
        }
        
        // As beats all cards except joker
        fullDeck.filter { ![joker, _As].contains($0) }.forEach {
            #expect(_As.beats($0, leadSuit: .spades, trumps: .noTrumps))
        }
        
        spades.forEach {
            // On-suit 4h beats all offsuit cards except joker
            #expect(_4h.beats($0, leadSuit: .hearts, trumps: .noTrumps))
            
            // Off-suit hearts does not beat on-suit spades
            #expect(!_Ah.beats($0, leadSuit: .spades, trumps: .noTrumps))
        }
        
        // No bowers in no-trumps
        #expect(_Qs.beats(_Js, leadSuit: .spades, trumps: .noTrumps))
        
        // Does not beat if both cards are offsuit
        #expect(!_Ah.beats(_Jc, leadSuit: .spades, trumps: .noTrumps))
    }
    
    @Test("Trumps card comparison")
    func testTrumpsCardComparison() async throws {
        #expect(_As.beats(_Ks, leadSuit: .hearts, trumps: .trump(.spades)))
        
        #expect(!_As.beats(joker, leadSuit: .hearts, trumps: .trump(.spades)))
        
        #expect(!_Ah.beats(_9s, leadSuit: .hearts, trumps: .trump(.spades)))
        
        trumps.forEach {
            // All trump cards beat Ah when hearts led
            #expect($0.beats(_Ah, leadSuit: .hearts, trumps: .trump(.spades)))
            
            // All trump cards beat Ah when spades led
            #expect($0.beats(_Ah, leadSuit: .spades, trumps: .trump(.spades)))
        }
        
        hearts.forEach {
            // Lead suit beats off suit when no trumps played
            #expect(_4d.beats($0, leadSuit: .diamonds, trumps: .trump(.spades)))
            #expect(!_Ad.beats($0, leadSuit: .hearts, trumps: .trump(.spades)))
        }
        
        #expect(_Ah.beats(_4h, leadSuit: .hearts, trumps: .trump(.spades)))
        
        #expect(!_Ah.beats(_4h, leadSuit: .diamonds, trumps: .trump(.spades)))
    }
    
    @Test("Initialization by parsing string")
    func testInitializationByParsingString() async throws {
        #expect(PlayingCard(parsedFrom: "as")
                == PlayingCard.standard(.ace, .spades))
        #expect(PlayingCard(parsedFrom: "Tc")
                == PlayingCard.standard(.ten, .clubs))
        #expect(PlayingCard(parsedFrom: "9H")
                == PlayingCard.standard(.nine, .hearts))
        #expect(PlayingCard(parsedFrom: "8     d")
                == PlayingCard.standard(.eight, .diamonds))
        #expect(PlayingCard(parsedFrom: "Joker")
                == PlayingCard.joker)
        #expect(PlayingCard(parsedFrom: "J")
                == PlayingCard.joker)
    }
}
