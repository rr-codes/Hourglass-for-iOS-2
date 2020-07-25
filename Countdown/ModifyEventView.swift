//
//  ModifyEventView.swift
//  Countdown
//
//  Created by Richard Robinson on 2020-07-24.
//

import SwiftUI

struct StylizedTextField: View {
    @Binding var text: String
    
    let title: String
    let placeholderText: String
    
    @State private var opacity: Double = 0.3
    
    var body: some View {
        Text(title)
            .bold()
            .padding(.bottom, 10)
        
        TextField(placeholderText, text: $text) { isEditing in
            opacity = isEditing ? 1.0 : 0.3
        } onCommit: {
            opacity = 0.3
        }
        .font(Font.body.weight(.medium))
        .padding(.bottom, 2)
        
        Rectangle()
            .height(1.5)
            .opacity(opacity)
    }
}

struct StylizedTextField2: View {
    @State var text: String
    
    var body: some View {
        Text("")
            .bold()
            .padding(.bottom, 10)
        
        Text(text)
        .font(Font.body.weight(.medium))
        .padding(.bottom, 2)
        
        Rectangle()
            .height(1.5)
            .opacity(1)
    }
}

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
        
    var onDismiss: (Data?) -> Void
    
    var formatter: DateFormatter {
        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .short
        return df
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    HStack {
                        Text("Event Name")
                        
                        TextField("New Year's Day", text: $name)
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
                        
                        EmojiTextField(emoji: $emoji)
                            .width(44)
                            .background(
                                RoundedRectangle(cornerRadius: 5.0)
                                    .strokeBorder()
                                    .opacity(0.1)
                            )
                    }
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
