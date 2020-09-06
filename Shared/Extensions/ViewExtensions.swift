//
//  ViewExtensions.swift
//  Countdown
//
//  Created by Richard Robinson on 2020-08-07.
//

import Foundation
import SwiftUI

extension View {
    @ViewBuilder func link(destination: URL?) -> some View {
        if let url = destination {
            Link(destination: url, label: { self })
        } else {
            self
        }
    }
}

extension View {
    func width(_ value: CGFloat) -> some View {
        self.frame(width: value)
    }
    
    func height(_ value: CGFloat) -> some View {
        self.frame(height: value)
    }
}

extension View {
    @ViewBuilder func applyIf<V: View>(_ condition: Bool, modifier: (Self) -> V) -> some View {
        if condition {
            modifier(self)
        } else {
            self
        }
    }
}

extension Gradient {
    static let all = [
        (#colorLiteral(red: 0.9654200673, green: 0.1590853035, blue: 0.2688751221, alpha: 1),#colorLiteral(red: 0.7559037805, green: 0.1139892414, blue: 0.1577021778, alpha: 1)), // red
        (#colorLiteral(red: 0.9338900447, green: 0.4315618277, blue: 0.2564975619, alpha: 1),#colorLiteral(red: 0.8518816233, green: 0.1738803983, blue: 0.01849062555, alpha: 1)), // deep orange
        (#colorLiteral(red: 0.9953531623, green: 0.54947716, blue: 0.1281470656, alpha: 1),#colorLiteral(red: 0.9409626126, green: 0.7209432721, blue: 0.1315650344, alpha: 1)), // orange
        (#colorLiteral(red: 0.9409626126, green: 0.7209432721, blue: 0.1315650344, alpha: 1),#colorLiteral(red: 0.8931249976, green: 0.5340107679, blue: 0.08877573162, alpha: 1)), // yellow
        (#colorLiteral(red: 0.2761503458, green: 0.824685812, blue: 0.7065336704, alpha: 1),#colorLiteral(red: 0, green: 0.6422213912, blue: 0.568986237, alpha: 1)), // teal
        (#colorLiteral(red: 0.2494148612, green: 0.8105323911, blue: 0.8425348401, alpha: 1),#colorLiteral(red: 0, green: 0.6073564887, blue: 0.7661359906, alpha: 1)), // light blue
        (#colorLiteral(red: 0.3045541644, green: 0.6749247313, blue: 0.9517192245, alpha: 1),#colorLiteral(red: 0.008423916064, green: 0.4699558616, blue: 0.882807076, alpha: 1)), // sky blue
        (#colorLiteral(red: 0.1774400771, green: 0.466574192, blue: 0.8732826114, alpha: 1),#colorLiteral(red: 0.00491155684, green: 0.287129879, blue: 0.7411141396, alpha: 1)), // blue
        (#colorLiteral(red: 0.4613699913, green: 0.3118675947, blue: 0.8906354308, alpha: 1),#colorLiteral(red: 0.3018293083, green: 0.1458326578, blue: 0.7334778905, alpha: 1)), // indigo
        (#colorLiteral(red: 0.7080290914, green: 0.3073516488, blue: 0.8653779626, alpha: 1),#colorLiteral(red: 0.5031493902, green: 0.1100070402, blue: 0.6790940762, alpha: 1)), // purple
        (#colorLiteral(red: 0.9495453238, green: 0.4185881019, blue: 0.6859942079, alpha: 1),#colorLiteral(red: 0.8123683333, green: 0.1657164991, blue: 0.5003474355, alpha: 1)), // pink
    ].map { a, b in
        Gradient(colors: [Color(a), Color(b)])
    }
    
    var colors: [Color] {
        self.stops.map(\.color)
    }
}

extension View {
    func eraseToAnyView() -> AnyView {
        self as? AnyView ?? AnyView(self)
    }
}
