//
//  RemoteImage.swift
//  Countdown
//
//  Created by Richard Robinson on 2020-09-10.
//

import SwiftUI

struct RemoteImage<Placeholder: View>: View {
    @ObservedObject private var loader: ImageLoader
    
    private let placeholder: () -> Placeholder
    private let configuration: (Image) -> Image
    
    @ViewBuilder private var image: some View {
        if let image = loader.image {
            configuration(Image(uiImage: image))
        } else {
            placeholder()
        }
    }
    
    init(
        _ url: URL,
        cache: ImageCache? = nil,
        placeholder: @escaping () -> Placeholder,
        configuration: @escaping (Image) -> Image
    ) {
        self.loader = ImageLoader(url, using: .shared, cache: cache)
        self.placeholder = placeholder
        self.configuration = configuration
    }
    
    var body: some View {
        image.onAppear(perform: loader.load)
    }
}
