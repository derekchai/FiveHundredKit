import Testing
@testable import FiveHundredKit

@Test func example() async throws {
    let north = Player(name: "North")
    let east = Player(name: "East")
    let south = Player(name: "South")
    let west = Player(name: "West")
    
    let state = FiveHundredState(players: [north, east, south, west])
    
    #expect(state.playerToPlay === north)
    #expect(state.nextPlayer === east)
}

