//
//  DeckBuilderController.swift
//  CardsterEditor
//
//  Created by Jake Convery on 3/10/21.
//

import Foundation

struct DeckBuilder {
    
    // Local Cards
    var deck: [Card] = []
    
    // Append cards
    mutating func append(f front: String, b back: String) {
        let newCard = Card(front: front, back: back, isFlagged: false)
        deck.append(newCard)
    }
    
    // Generate a JSON
    func goToJSON() -> Data? {
        let cards = Cards(cards: deck)
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        do {
            // https://developer.apple.com/documentation/foundation/jsonencoder
            let data = try encoder.encode(cards)
            print(String(data: data, encoding: .utf8)!)
            return data
        }
        catch {
            print(error)
            return nil
        }
        
    }
    
    // Get the front of the card
    func getFront(for card: Int) -> String {
        return deck[card].front
    }
    
    // Get the back of the card
    func getBack(for card: Int) -> String {
        return deck[card].back
    }
    
    // Get the count of total cards
    func getCardCount() -> Int {
        return deck.count
    }
    
    // Remove a card
    mutating func removeCard(at index: Int) {
        deck.remove(at: index)
    }
    
}
