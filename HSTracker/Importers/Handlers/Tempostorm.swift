//
//  Tempostorm.swift
//  HSTracker
//
//  Created by Benjamin Michotte on 9/10/16.
//  Copyright © 2016 Benjamin Michotte. All rights reserved.
//

import Foundation
import CleanroomLogger

struct Tempostorm: JsonImporter {

    var siteName: String {
        return "TempoStorm"
    }

    var handleUrl: String {
        return "tempostorm\\.com\\/hearthstone\\/decks"
    }

    var preferHttps: Bool {
        return true
    }

    func loadJson(url: String, completion: AnyObject? -> Void) {
        guard let match = url.matches("/decks/([^/]+)$").first else {
            completion(nil)
            return
        }
        let slug = match.value
        let url = "https://tempostorm.com/api/decks/findOne"
        let parameters: [String: String] = [
            "filter": "{\"where\":{\"slug\":\"\(slug)\"},\"fields\":{},\"include\":"
                + "[{\"relation\":\"cards\",\"scope\":{\"include\":[\"card\"]}}]}"
        ]

        Log.info?.message("Fetching \(url)")

        let http = Http(url: url)
        http.json(.get, parameters: parameters) { json in
            completion(json)
        }
    }

    func loadDeck(json: AnyObject, url: String) -> Deck? {
        guard let className = json["playerClass"] as? String,
            let playerClass = CardClass(rawValue: className.lowercaseString) else {
                Log.error?.message("Class not found")
                return nil
        }
        Log.verbose?.message("Got class \(playerClass)")

        guard let deckName = json["name"] as? String else {
            Log.error?.message("Deck name not found")
            return nil
        }
        Log.verbose?.message("Got deck name \(deckName)")

        let deck = Deck(playerClass: playerClass, name: deckName)
        let gameModeType = json["gameModeType"] as? String ?? "constructed"
        deck.isArena = gameModeType == "arena"

        guard let jsonCards = json["cards"] as? [[String: AnyObject]] else {
            Log.error?.message("Card list not found")
            return nil
        }
        for jsonCard: [String: AnyObject] in jsonCards {
            if let cardData = jsonCard["card"] as? [String: AnyObject],
                let name = cardData["name"] as? String,
                let card = Cards.by(englishNameCaseInsensitive: name),
                let count = jsonCard["cardQuantity"] as? Int {
                card.count = count
                Log.verbose?.message("Got card \(card)")
                deck.addCard(card)
            }
        }
        return deck
    }
}
