//
//  ModifyEventView.swift
//  Countdown
//
//  Created by Richard Robinson on 2020-07-24.
//

import SwiftUI



struct ModifyEventView: View {
    typealias Data = (name: String, start: Date, end: Date, emoji: String, image: UnsplashImage)
    
    let isEditing: Bool
    
    @State var name: String = ""
    @State var end: Date = Date()
    @State var emoji: String = "🎉"
    @State var image: UnsplashImage? = nil
    @State var inCalendar: Bool = true
    
    @State var isDisabled: Bool = true
    @State var showCalendar: Bool = false
    
    @State var images: [UnsplashImage] = []
        
    var onDismiss: (Data?) -> Void
    
    var formatter: DateFormatter {
        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .short
        return df
    }
    
    func loadDefaultImages() -> [UnsplashImage] {
        let path = Bundle.main.path(forResource: "defaultImages", ofType: "json")
        let json = try! String(contentsOfFile: path!)
        let result = try! JSONDecoder().decode(UnsplashResult.self, from: json.data(using: .utf8)!)
        return result.results
    }
    
    func imageView(_ image: UnsplashImage) -> some View {
        AsyncImage(color: image.overallColor, url: image.url(for: .small))
            .frame(width: 80, height: 80)
            .clipShape(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .strokeBorder(lineWidth: 3.0)
                    .foregroundColor(self.image == image ? .blue : .clear)
            )
            .scaleEffect(self.image == image ? 0.98 : 1.0)
            .onTapGesture {
                withAnimation(.linear(duration: 0.05)) {
                    self.image = image
                }
            }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    HStack {
                        Text("Event Name")
                        
                        TextField("New Year's Day", text: $name) {
                            let query = name
                                .filter(by: [.noun, .placeName])
                                .joined(separator: "%20")
                            
                            UnsplashResult.fetch(query: query) { result in
                                switch result {
                                case .success(let result):
                                    self.images.insert(contentsOf: result.results, at: 0)
                                    self.image = self.images.first!
                                    
                                case .failure(let error):
                                    fatalError(error.localizedDescription)
                                }
                            }
                        }
                        .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Text("Event Date")
                        
                        Spacer()
                        
                        Button {
                            withAnimation(.linear) {
                                showCalendar.toggle()
                            }
                        } label: {
                            Text(formatter.string(from: end))
                                .multilineTextAlignment(.trailing)
                        }
                    }
                    
                    if showCalendar {
                        DatePicker(selection: $end, displayedComponents: [.date, .hourAndMinute]) {
                        }
                        .height(350)
                        .datePickerStyle(GraphicalDatePickerStyle())
                    }
                    
                    Toggle("Add to Calendar", isOn: $inCalendar)
                        .toggleStyle(SwitchToggleStyle(tint: .accentColor))
                }
                
                Section {
                    HStack {
                        Text("Pick an Emoji")
                        
                        Spacer()
                        
                        EmojiPicker(emoji: $emoji)
                            .width(44)
                            .background(
                                RoundedRectangle(cornerRadius: 5.0)
                                    .strokeBorder()
                                    .opacity(0.1)
                            )
                    }
                    

                    VStack(alignment: .leading) {
                        Text("Select a Background")
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            LazyHStack(spacing: 16) {
                                ForEach(images, content: imageView)
                            }
                        }
                    }
                    .padding(.vertical, 5)
                }
            }
            .listStyle(GroupedListStyle())
            .environment(\.horizontalSizeClass, .regular)
            .navigationBarTitle(
                Text(!isEditing ? "Create Event" : "Edit Event"),
                displayMode: .inline
            )
            .navigationBarItems(
                leading: Button(action: {
                    onDismiss(nil)
                }) {
                    Text("Cancel").foregroundColor(.accentColor)
                },
                trailing: Button(action: {}) {
                    Text("Add").bold().foregroundColor(isDisabled ? .gray : .accentColor)
                }
                .disabled(isDisabled)
            )
        }
        .onAppear {
            self.images = loadDefaultImages()
            self.image = self.images.first!
        }
    }
    
//    var body: some View {
//        VStack(alignment: .leading) {
//            HStack {
//                Text("My Events").font(.title).bold()
//                Spacer()
//                Image(systemName: "xmark.circle.fill")
//                    .imageScale(.large)
//                    .scaleEffect(1.2)
//                    .onTapGesture {
//                        onDismiss(nil)
//                    }
//            }
//            .background(Color.white)
//            .padding(.top, 20)
//            .padding(.horizontal, 20)
//
//            Form {
//
//            }.edgesIgnoringSafeArea(.all)
//
////            Spacer().height(35)
////
////            StylizedTextField(text: $name, title: "What's the occasion?", placeholderText: "Title")
////
////            Spacer().height(35)
////
////            DatePicker("", selection: $end, in: .init()..., displayedComponents: [.date])
////                .font(Font.body.weight(.medium))
////
////            Spacer()
//        }
//    }
}

struct ModifyEventView_Previews: PreviewProvider {
    static var previews: some View {
        ModifyEventView(isEditing: false) { _ in }
    }
}
