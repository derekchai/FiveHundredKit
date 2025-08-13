//
//  Player.swift
//  FiveHundred
//
//  Created by Derek Chai on 12/08/2025.
//

open class Player {
    /// The player's name.
    let name: String
    
    /// Initializes a player.
    /// - Parameter name: The player name.
    public init(name: String) {
        self.name = name
    }
}

extension Player: Hashable {
    public static func == (lhs: Player, rhs: Player) -> Bool {
        return lhs === rhs
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}

extension Player: CustomStringConvertible {
    public var description: String {
        return self.name
    }
}
