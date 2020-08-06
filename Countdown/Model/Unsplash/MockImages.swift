//
//  MockImages.swift
//  Countdown
//
//  Created by Richard Robinson on 2020-07-23.
//

import Foundation

private let greeceJSON = """
{
    "id": "_vA2q0-NroU",
    "color": "#1B2028",
    "urls": {
        "full": "https://images.unsplash.com/photo-1530841377377-3ff06c0ca713?ixlib=rb-1.2.1&q=85&fm=jpg&crop=entropy&cs=srgb&ixid=eyJhcHBfaWQiOjE1MDY2Mn0",
        "regular": "https://images.unsplash.com/photo-1530841377377-3ff06c0ca713?ixlib=rb-1.2.1&q=80&fm=jpg&crop=entropy&cs=tinysrgb&w=1080&fit=max&ixid=eyJhcHBfaWQiOjE1MDY2Mn0",
        "small": "https://images.unsplash.com/photo-1530841377377-3ff06c0ca713?ixlib=rb-1.2.1&q=80&fm=jpg&crop=entropy&cs=tinysrgb&w=400&fit=max&ixid=eyJhcHBfaWQiOjE1MDY2Mn0"
    },
    "links": {
        "download_location": "https://api.unsplash.com/photos/_vA2q0-NroU/download"
    },
    "user": {
        "name": "Jonathan Gallegos",
        "links": {
            "html": "https://unsplash.com/@jonathangallegos"
        }
    }
}
"""

private let birthdayJSON = """
{
    "id": "Hli3R6LKibo",
    "color": "#0E070D",
    "urls": {
        "full": "https://images.unsplash.com/photo-1531956531700-dc0ee0f1f9a5?ixlib=rb-1.2.1&q=85&fm=jpg&crop=entropy&cs=srgb&ixid=eyJhcHBfaWQiOjE1MDY2Mn0",
        "regular": "https://images.unsplash.com/photo-1531956531700-dc0ee0f1f9a5?ixlib=rb-1.2.1&q=80&fm=jpg&crop=entropy&cs=tinysrgb&w=1080&fit=max&ixid=eyJhcHBfaWQiOjE1MDY2Mn0",
        "small": "https://images.unsplash.com/photo-1531956531700-dc0ee0f1f9a5?ixlib=rb-1.2.1&q=80&fm=jpg&crop=entropy&cs=tinysrgb&w=400&fit=max&ixid=eyJhcHBfaWQiOjE1MDY2Mn0",
    },
    "user": {
        "name": "Adi Goldstein",
        "links": {
            "html": "https://unsplash.com/@adigold1",
        }
    }
}
"""

private let christmasJSON = """
{
    "id": "-Qf9JKLysUg",
    "color": "#FEE5D6",
    "urls": {
        "full": "https://images.unsplash.com/photo-1512474932049-78ac69ede12c?ixlib=rb-1.2.1&q=85&fm=jpg&crop=entropy&cs=srgb&ixid=eyJhcHBfaWQiOjE1MDY2Mn0",
        "regular": "https://images.unsplash.com/photo-1512474932049-78ac69ede12c?ixlib=rb-1.2.1&q=80&fm=jpg&crop=entropy&cs=tinysrgb&w=1080&fit=max&ixid=eyJhcHBfaWQiOjE1MDY2Mn0",
        "small": "https://images.unsplash.com/photo-1512474932049-78ac69ede12c?ixlib=rb-1.2.1&q=80&fm=jpg&crop=entropy&cs=tinysrgb&w=400&fit=max&ixid=eyJhcHBfaWQiOjE1MDY2Mn0"
    },
    "user": {
        "name": "freestocks",
        "links": {
            "html": "https://unsplash.com/@freestocks"
        }
    }
}
"""

private let fireworksJSON = """
{
    "id": "gdTxVSAE5sk",
    "color": "#EBA199",
    "urls": {
        "full": "https://images.unsplash.com/photo-1498931299472-f7a63a5a1cfa?ixlib=rb-1.2.1&q=85&fm=jpg&crop=entropy&cs=srgb&ixid=eyJhcHBfaWQiOjE1MDY2Mn0",
        "regular": "https://images.unsplash.com/photo-1498931299472-f7a63a5a1cfa?ixlib=rb-1.2.1&q=80&fm=jpg&crop=entropy&cs=tinysrgb&w=1080&fit=max&ixid=eyJhcHBfaWQiOjE1MDY2Mn0",
        "small": "https://images.unsplash.com/photo-1498931299472-f7a63a5a1cfa?ixlib=rb-1.2.1&q=80&fm=jpg&crop=entropy&cs=tinysrgb&w=400&fit=max&ixid=eyJhcHBfaWQiOjE1MDY2Mn0"
    },
    "user": {
        "name": "Ray Hennessy",
        "links": {
            "html": "https://unsplash.com/@rayhennessy"
        }
    }
}
"""

private let anniversaryJSON = """
{
    "id": "UrF1Jf5PamQ",
    "color": "#160C09",
    "urls": {
        "full": "https://images.unsplash.com/photo-1581938165093-050aeb5ef218?ixlib=rb-1.2.1&q=85&fm=jpg&crop=entropy&cs=srgb&ixid=eyJhcHBfaWQiOjE1MDY2Mn0",
        "regular": "https://images.unsplash.com/photo-1581938165093-050aeb5ef218?ixlib=rb-1.2.1&q=80&fm=jpg&crop=entropy&cs=tinysrgb&w=1080&fit=max&ixid=eyJhcHBfaWQiOjE1MDY2Mn0",
        "small": "https://images.unsplash.com/photo-1581938165093-050aeb5ef218?ixlib=rb-1.2.1&q=80&fm=jpg&crop=entropy&cs=tinysrgb&w=400&fit=max&ixid=eyJhcHBfaWQiOjE1MDY2Mn0"
    },
    "user": {
        "name": "Ed Robertson",
        "links": {
            "html": "https://unsplash.com/@eddrobertson"
        }
    }
}
"""

struct MockImages {
    private static let decoder = JSONDecoder()
    
    static let anniversary = try! decoder.decode(UnsplashImage.self, from: anniversaryJSON.data(using: .utf8)!)
    static let birthday    = try! decoder.decode(UnsplashImage.self, from: birthdayJSON.data(using: .utf8)!)
    static let christmas   = try! decoder.decode(UnsplashImage.self, from: christmasJSON.data(using: .utf8)!)
    static let fireworks   = try! decoder.decode(UnsplashImage.self, from: fireworksJSON.data(using: .utf8)!)
    static let greece      = try! decoder.decode(UnsplashImage.self, from: greeceJSON.data(using: .utf8)!)
}

struct MockData {
    static let greece = Event(
        "Vacation in Greece",
        end: Date(timeIntervalSinceNow: 86400 - 60),
        image: MockImages.greece,
        emoji: "🇬🇷"
    )
    
    static let eventA = Event(
        "My Birthday",
        end: Date(timeIntervalSinceNow: 86400 - 60),
        image: MockImages.birthday,
        emoji: "😍"
    )

    static let eventB = Event(
        "New Year's Day",
        end: Date(timeIntervalSinceNow: 86400 * 42),
        image: MockImages.fireworks,
        emoji: "🎉"
    )

    static let eventC = Event(
        "Christmas",
        end: Date(timeIntervalSinceNow: 86400 * 300),
        image: MockImages.christmas,
        emoji: "🎄"
    )

    static let eventD = Event(
        "My Anniversary",
        end: Date(timeIntervalSinceNow: -60 * 70),
        image: MockImages.anniversary,
        emoji: "💍"
    )
    
    static let all: [Event] = [greece, eventA, eventB, eventC, eventD]
}
