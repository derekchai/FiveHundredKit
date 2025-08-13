//
//  GameStateRepresentable.swift
//  FiveHundred
//
//  Created by Derek Chai on 12/08/2025.
//

public protocol GameStateRepresentable {
    associatedtype Move: MoveRepresentable
    
    /// The players in the game.
    var players: [Player] { get set }
    
    /// The player whose turn it is to play.
    var playerToPlay: Player { get set }
    
    /// The player whose turn it is next to play (after the player to play).
    var nextPlayer: Player { get }
    
    /// A list of all possible moves playable from this state.
    var moves: [Move] { get }
    
    /// Plays a move. Must update `playerToPlay`. Throws if an illegal move
    /// played.
    /// - Parameter \_: The move to play.
    mutating func play(_: Move) throws
}
