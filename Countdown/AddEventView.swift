//
//  AddEventView.swift
//  Countdown
//
//  Created by Richard Robinson on 2020-07-25.
//

import SwiftUI

struct StylizedTextField: View {
    @Binding var text: String
    @Binding var emoji: String
    
    let onCommit: () -> Void
        
    var body: some View {
        Text("What's the occasion?")
            .bold()
            .padding(.bottom, 10)
        
        HStack {
            TextField("New Year's Day", text: $text, onCommit: onCommit)
                .padding(.leading, 10)
                .font(Font.body.weight(.medium))
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.black.opacity(0.05))
                        .padding(.vertical, -10)
            )
            .padding(.trailing, 10)
            
            EmojiPicker(emoji: $emoji)
                .background(
                    Circle()
                        .fill(Color.black.opacity(0.03))
                )
                .width(44)
        }
        .height(44)
    }
}

struct DateView: View {
    @Binding var date: Date
    
    @State private var show: Bool = false
    
    var formatter: DateFormatter {
        let df = DateFormatter()
        df.dateStyle = .long
        df.timeStyle = .short
        return df
    }
        
    var body: some View {
        Text("When's it happening?")
            .bold()
            .padding(.bottom, 10)
        
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.black.opacity(0.05))
                .height(40)
            
            Text(formatter.string(from: date))
                .padding(.leading, 10)
                .font(Font.body.weight(.medium))
                .onTapGesture {
                    withAnimation {
                        self.show.toggle()
                    }
                }
        }
        
        if show {
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.black.opacity(0.03))

                DatePicker(selection: $date, displayedComponents: [.date, .hourAndMinute]) {
                }
                .datePickerStyle(GraphicalDatePickerStyle())
            }
            .height(350)
            .mask(Rectangle().height(show ? 350 : 0))
        }
    }
}

struct ImagePicker: View {
    @Binding var allImages: [UnsplashImage]
    @Binding var selectedImage: UnsplashImage?
    
    private let rows = [GridItem](repeating: GridItem(.flexible()), count: 2)
    
    private func imageView(_ image: UnsplashImage) -> some View {
        AsyncImage(color: image.overallColor, url: image.url(for: .small))
            .frame(width: 100, height: 100)
            .clipShape(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .strokeBorder(lineWidth: 3.0)
                    .foregroundColor(self.selectedImage == image ? .blue : .clear)
            )
            .scaleEffect(self.selectedImage == image ? 0.98 : 1.0)
            .onTapGesture {
                withAnimation(.linear(duration: 0.05)) {
                    self.selectedImage = image
                }
            }
    }
    
    var body: some View {
        Text("Choose a background")
            .bold()
            .padding(.bottom, 10)
        
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHGrid(rows: rows) {
                ForEach(allImages, content: imageView)
            }
        }
        .height(210)
        .onChange(of: allImages) { newValue in
            self.selectedImage = newValue.first!
        }
    }
}

struct AddEventView: View {
    @State var name: String = ""
    @State var emoji: String = "🎉"
    @State var date: Date = Date()
    @State var image: UnsplashImage? = nil
    
    @State var allImages: [UnsplashImage] = []
    
    let onDismiss: ((name: String, emoji: String, date: Date, image: UnsplashImage)?) -> Void
    
    private func loadDefaultImages() {
        let path = Bundle.main.path(forResource: "defaultImages", ofType: "json")
        let json = try! String(contentsOfFile: path!)
        let result = try! JSONDecoder().decode(UnsplashResult.self, from: json.data(using: .utf8)!)
        
        self.allImages = result.results
    }
    
    private func loadRelevantImages() {
        let query = name
            .filter(by: [.noun, .placeName])
            .joined(separator: "%20")
        
        UnsplashResult.fetch(query: query) { result in
            switch result {
            case .success(let result):
                self.allImages.insert(contentsOf: result.results, at: 0)
                
            case .failure(let error):
                fatalError(error.localizedDescription)
            }
        }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Create Event").font(.title).bold()
                Spacer()
                Image(systemName: "xmark.circle.fill")
                    .imageScale(.large)
                    .scaleEffect(1.2)
                    .onTapGesture {
                        onDismiss(nil)
                    }
                    .offset(x: 0, y: -1)
            }
            .background(Color.white)
            .padding(.top, 20)
            .padding(.bottom)
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading) {
                    StylizedTextField(text: $name, emoji: $emoji, onCommit: loadRelevantImages)
                    
                    Spacer().height(35)
                    
                    DateView(date: $date)

                    Spacer().height(35)
                    
                    ImagePicker(allImages: $allImages, selectedImage: $image)
                    
                    Spacer().height(50)

                    Button {
                        let data = (name: name, emoji: emoji, date: date, image: image!)
                        onDismiss(data)
                    } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(Color.black)
                            
                            Text("Create Event")
                                .font(Font.body.weight(.semibold))
                                .foregroundColor(.white)
                        }
                        .height(46)
                    }
                }
            }
        }
        .padding(.horizontal, 20)
        .onAppear {
            loadDefaultImages()
        }
    }
}

struct AddEventView_Previews: PreviewProvider {
    static var previews: some View {
        AddEventView { _ in }
    }
}
