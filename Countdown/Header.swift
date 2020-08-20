//
//  Header.swift
//  Countdown
//
//  Created by Richard Robinson on 2020-08-18.
//

import SwiftUI

struct Header<Content: View>: View {
    private let title: () -> Text
    private let content: () -> Content
    
    init(_ title: @escaping @autoclosure () -> Text, @ViewBuilder trailingItems: @escaping () -> Content) {
        self.title = title
        self.content = trailingItems
    }
    
    init<S: StringProtocol>(_ title: S, @ViewBuilder trailingItems: @escaping () -> Content) {
        self.init(Text(title), trailingItems: trailingItems)
    }
    
    init(_ titleKey: LocalizedStringKey, @ViewBuilder trailingItems: @escaping () -> Content) {
        self.init(Text(titleKey), trailingItems: trailingItems)
    }
    
    var body: some View {
        HStack(spacing: 25) {
            title().bold().font(.title)
            
            Spacer()
            
            content().font(.title)
        }
        .padding(.trailing, 3)
    }
}

struct Header_Previews: PreviewProvider {
    static var previews: some View {
        Header("") {
            Image(systemName: "xmark.circle.fill").onTapGesture { print("hi") }
        }
        .padding(20)
        .previewLayout(.fixed(width: 375, height: 100))
    }
}
