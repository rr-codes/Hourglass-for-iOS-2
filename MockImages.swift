//
//  MockImages.swift
//  Countdown
//
//  Created by Richard Robinson on 2020-07-23.
//

import Foundation

let jsonA = """
{
    "id": "Hli3R6LKibo",
    "color": "#0E070D",
    "urls": {
        "full": "https://images.unsplash.com/photo-1531956531700-dc0ee0f1f9a5?ixlib=rb-1.2.1&q=85&fm=jpg&crop=entropy&cs=srgb&ixid=eyJhcHBfaWQiOjE1MDY2Mn0",
        "regular": "https://images.unsplash.com/photo-1531956531700-dc0ee0f1f9a5?ixlib=rb-1.2.1&q=80&fm=jpg&crop=entropy&cs=tinysrgb&w=1080&fit=max&ixid=eyJhcHBfaWQiOjE1MDY2Mn0",
        "small": "https://images.unsplash.com/photo-1531956531700-dc0ee0f1f9a5?ixlib=rb-1.2.1&q=80&fm=jpg&crop=entropy&cs=tinysrgb&w=400&fit=max&ixid=eyJhcHBfaWQiOjE1MDY2Mn0",
    },
    "user": {
        "username": "adigold1",
        "links": {
            "self": "https://api.unsplash.com/users/adigold1",
            "html": "https://unsplash.com/@adigold1",
        }
    }
}
"""

let mockImageA = try! JSONDecoder().decode(UnsplashImage.self, from: jsonA.data(using: .utf8)!)
