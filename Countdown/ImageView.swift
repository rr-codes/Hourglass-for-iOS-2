//
//  ImageView.swift
//  Countdown
//
//  Created by Richard Robinson on 2020-08-21.
//

import SwiftUI
import URLImage

struct AsyncImageView: View {
    let url: URL
    var color: Color = .white
    
    var body: some View {
        URLImage(url, incremental: true, placeholder: { _ in Rectangle().fill(color) }) { (proxy) in
            proxy.image
                .resizable()
                .aspectRatio(contentMode: .fill)
        }
    }
}

struct ImageView_Previews: PreviewProvider {
    static let path = "https://images.unsplash.com/photo-1530841377377-3ff06c0ca713?ixlib=rb-1.2.1&q=80&fm=jpg&crop=entropy&cs=tinysrgb&w=1080&fit=max&ixid=eyJhcHBfaWQiOjE1MDY2Mn0"
    
    static var previews: some View {
        AsyncImageView(url: URL(string: path)!)
    }
}
