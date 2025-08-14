//
//  Bid.swift
//  FiveHundredKit
//
//  Created by Derek Chai on 12/08/2025.
//

import Foundation

public enum Bid {
    case pass
    
    case misere
    case openMisere
    
    case noTrumps(Int)
    case standard(Int, Suit)
    
    /// Initializes a new ``Bid`` parsed from a string input. Throws if
    /// the input was unable to be parsed.
    ///
    /// `input` can be in the following format (whitespaces removed and
    /// lowercased (where _x_ is an integer between 6 and 10, inclusive):
    /// - Pass: `p`, `pass`
    /// - Misère: `m`, `misere`
    /// - Open misère: `o`, `om`, `openmisere`
    /// - No trumps: _x_`nt`, _x_`notrump`, _x_`notrumps`
    /// - Spades: _x_`s`, _x_`spade`, _x_`spades`
    /// - Clubs: _x_`c`, _x_`club`, _x_`clubs`
    /// - Diamonds: _x_`d`, _x_`diamond`, _x_`diamonds`
    /// - Hearts: _x_`h`, _x_`heart`, _x_`hearts`
    ///
    /// - Parameter input: The string input.
    public init?(parsedFrom input: String) {
        let string = input.lowercased()
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !string.isEmpty else {
            return nil
        }
        
        switch string {
        case "pass", "p":
            self = .pass
            
        case "misere", "m":
            self = .misere
            
        case "openmisere", "o", "om":
            self = .openMisere
            
        default:
            guard let firstCharacter = string.first,
                  let count = Int(String(firstCharacter)),
                  count >= 6, count <= 10 else {
                return nil
            }
            
            let i = string.index(after: string.startIndex)
            switch string[i...] {
            case "nt", "notrump", "notrumps":
                self = .noTrumps(count)
                
            case "s", "spade", "spades":
                self = .standard(count, .spades)
            case "c", "club", "clubs":
                self = .standard(count, .clubs)
            case "d", "diamond", "diamonds":
                self = .standard(count, .diamonds)
            case "h", "heart", "hearts":
                self = .standard(count, .hearts)
            default:
                return nil
            }
        }
    }
}

extension Bid {
    public var points: Int {
        switch self {
        case .pass:
            return 0
        case .misere:
            return 250
        case .openMisere:
            return 500
        case .noTrumps(let int):
            return 120 + (int - 6) * 100
        case .standard(let int, let suit):
            let summand: Int
            
            switch suit {
            case .spades:
                summand = 40
            case .clubs:
                summand = 60
            case .diamonds:
                summand = 80
            case .hearts:
                summand = 100
            }
            
            return summand + (int - 6) * 100
        }
    }
    
    public var trumps: Trump {
        switch self {
        case .pass, .misere, .openMisere, .noTrumps:
            return .noTrumps
        case .standard(_, let suit):
            return .trump(suit)
        }
    }
}

extension Bid: CustomStringConvertible {
    public var description: String {
        switch self {
        case .pass:
            "Pass"
        case .misere:
            "Misère"
        case .openMisere:
            "Open Misère"
        case .noTrumps(let int):
            "\(int)NT"
        case .standard(let int, let suit):
            "\(int)\(suit)"
        }
    }
}
