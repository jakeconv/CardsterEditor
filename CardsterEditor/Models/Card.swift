//
//  Card.swift
//  CardsterEditor
//
//  Created by Jake Convery on 3/10/21.
//

import Foundation


struct Card: Codable {
    let front: String
    let back: String
    var isFlagged = false
}

struct Cards: Codable {
    var cards: [Card]
}


