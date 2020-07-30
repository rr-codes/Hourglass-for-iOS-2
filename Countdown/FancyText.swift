//
//  FancyText.swift
//  Countdown
//
//  Created by Richard Robinson on 2020-07-30.
//

import Foundation
import SwiftUI

enum TextType: Hashable {
    case normal(String)
    case link(String, url: URL?)
}

struct FancyText: View {
    typealias Body = TextBuilderView
    
    init(@TextBuilder builder: @escaping () -> Body) {
        self.body = builder()
    }
    
    var body: Body
}

@_functionBuilder struct TextBuilder {
    static func buildBlock(_ partialResults: TextType...) -> TextBuilderView {
        TextBuilderView(allText: partialResults)
    }
}

struct TextBuilderView: View {
    @Environment(\.openURL) var openURL
    @ScaledMetric(relativeTo: .caption) var spacing: CGFloat = 4
    
    let allText: [TextType]
    
    var body: some View {
        HStack(spacing: spacing) {
            ForEach(allText, id: \.self) { text in
                switch text {
                case .normal(let content):
                    Text(content)
                    
                case .link(let content, let url):
                    Button {
                        if let url = url {
                            openURL(url)
                        }
                    } label: {
                        Text(content).underline()
                    }
                }
            }
        }
    }
}
