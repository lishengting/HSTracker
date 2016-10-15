//
//  HearthpwnDeckBuilder.swift
//  HSTracker
//
//  Created by Benjamin Michotte on 25/02/16.
//  Copyright © 2016 Benjamin Michotte. All rights reserved.
//

import Foundation
import Kanna
import CleanroomLogger

struct HearthpwnDeckBuilder: HttpImporter {

    var siteName: String {
        return "HearthpPwn deckbuilder"
    }

    var handleUrl: String {
        return "hearthpwn\\.com\\/deckbuilder"
    }

    var preferHttps: Bool {
        return false
    }

    func loadDeck(doc: HTMLDocument, url: String) -> Deck? {
        var urlParts = url.componentsSeparatedByString("#")
        let split = urlParts[0].componentsSeparatedByString("/")

        guard let clazz = split.last,
            let playerClass = CardClass(rawValue: clazz.lowercaseString) else {
                Log.error?.message("Class not found")
                return nil
        }
        Log.verbose?.message("Got class \(playerClass)")

        guard let node = doc.at_xpath("//div[contains(@class,'deck-name-container')]/h2"),
            let deckName = node.innerHTML else {
                Log.error?.message("Deck name not found")
                return nil
        }
        Log.verbose?.message("Got deck name : \(deckName)")

        let deck = Deck(playerClass: playerClass, name: deckName)

        guard let cardIds = urlParts.last?.componentsSeparatedByString(";") else {
            Log.error?.message("Card list not found")
            return nil
        }
        for str in cardIds {
            let split = str.componentsSeparatedByString(":")
            if let id = split.first, let last = split.last,
                let count = Int(last),
                let node = doc.at_xpath("//tr[@data-id='\(id)']/td[1]/b"),
                let cardId = node.text,
                let card = Cards.by(englishName: cardId) {
                card.count = count
                Log.verbose?.message("Got card \(card)")
                deck.addCard(card)
            }
        }
        
        return deck
    }
}
