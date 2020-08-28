//
//  LocalImageProvider.swift
//  Countdown
//
//  Created by Richard Robinson on 2020-08-26.
//

import Foundation
import PhotosUI
import SwiftUI

struct LocalImagePicker: View {
    @Binding var isPresented: Bool
    @Binding var image: Data?
    
    private var configuration: PHPickerConfiguration {
        var config = PHPickerConfiguration()
        config.filter = .images
        return config
    }
    
    var body: some View {
        LocalImagePickerController(configuration: configuration, isPresented: $isPresented, image: $image)
    }
}

fileprivate struct LocalImagePickerController: UIViewControllerRepresentable {
    let configuration: PHPickerConfiguration
    
    @Binding var isPresented: Bool
    @Binding var image: Data?
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        let controller = PHPickerViewController(configuration: configuration)
        controller.delegate = context.coordinator
        return controller
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {
    }
    
    func makeCoordinator() -> LocalImagePickerCoordinator {
        LocalImagePickerCoordinator(self)
    }
}

fileprivate class LocalImagePickerCoordinator: PHPickerViewControllerDelegate {
    private let parent: LocalImagePickerController
    
    init(_ parent: LocalImagePickerController) {
        self.parent = parent
    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        if let provider = results.first?.itemProvider, provider.canLoadObject(ofClass: UIImage.self) {
            provider.loadObject(ofClass: UIImage.self) { (image, _) in
                if let image = image as? UIImage, let data = image.pngData() {
                    self.parent.image = data
                }
            }
        }
        
        parent.isPresented = false
    }
}
