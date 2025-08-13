//
//  Player.swift
//  FiveHundred
//
//  Created by Derek Chai on 12/08/2025.
//

class Player {
    /// The player's name.
    let name: String
    
    /// Initializes a player.
    /// - Parameter name: The player name.
    init(name: String) {
        self.name = name
    }
}

extension Player: Hashable {
    static func == (lhs: Player, rhs: Player) -> Bool {
        return lhs === rhs
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}

extension Player: CustomStringConvertible {
    var description: String {
        return self.name
    }
}
