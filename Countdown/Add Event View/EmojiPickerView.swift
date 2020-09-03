//
//  EmojiView.swift
//  Countdown
//
//  Created by Richard Robinson on 2020-07-31.
//

import SwiftUI

fileprivate struct EmojiGroupView: View {
    var gridItems: [GridItem] {
        Array(repeating: .init(.fixed(44)), count: rows)
    }

    let group: [String]
    let rows: Int
    
    @Binding var selectedEmoji: String
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHGrid(rows: gridItems, spacing: 16) {
                ForEach(group, id: \.self) { emoji in
                    Text(emoji)
                        .font(.system(size: 30))
                        .onTapGesture {
                            self.selectedEmoji = emoji
                        }
                        .background(
                            Circle()
                                .fill(Color.blue)
                                .opacity(self.selectedEmoji == emoji ? 0.2 : 0)
                                .scaleEffect(1.3)
                        )
                        .accessibility(label: Text(emoji))
                }
            }
            .padding(.horizontal, 20)
        }
    }
}

fileprivate struct EmojiPickerView: View {
    let database: EmojiDatabase
        
    @State private var selectedCategory: EmojiCategory
    @State private var searchQuery: String = ""
    
    @Binding var selectedEmoji: String
    
    init(_ selectedEmoji: Binding<String>, database: EmojiDatabase) {
        self._selectedEmoji = selectedEmoji
        self.database = database
        
        self._selectedCategory = .init(initialValue: database.first!)
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            if let category = selectedCategory {
                Text(category.name)
                    .font(.caption)
                    .bold()
                    .textCase(.uppercase)
                    .foregroundColor(.init(UIColor.secondaryLabel))
                    .padding(.leading, 20)
                    .padding(.top, 25)
                
                EmojiGroupView(
                    group: category.elements,
                    rows: 5,
                    selectedEmoji: $selectedEmoji
                )
                .padding(.bottom, 13)
                .padding(.top, 5)
                            
                Picker("Category", selection: $selectedCategory) {
                    ForEach(database) {
                        Text($0.emoji).tag($0)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal, 20)
                .labelsHidden()
                .padding(.bottom, 20)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 25.0)
                .fill(Color.secondaryBackground)
                .shadow(color: Color.foreground.opacity(0.1), radius: 5)
        )
    }
}

struct EmojiOverlay: View {
    @Binding var isPresented: Bool
    @Binding var emoji: String
    
    let queue: DispatchQueue
    let database: EmojiDatabase
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                Rectangle()
                    .fill(Color.black)
                    .opacity(isPresented ? 0.1 : 0.0)
                    .transition(.opacity)
                    .zIndex(1)
                    .allowsHitTesting(isPresented)
                    .onTapGesture {
                        withAnimation {
                            isPresented = false
                        }
                    }
                
                if isPresented {
                    EmojiPickerView(
                        $emoji,
                        database: database
                    )
                    .onChange(of: emoji) { _ in
                        self.queue.asyncAfter(deadline: .now() + 0.1) {
                            withAnimation {
                                isPresented = false
                            }
                        }
                    }
                    .animation(Animation.spring().speed(2))
                    .transition(.move(edge: .bottom))
                    .padding(.horizontal, 14)
                    .zIndex(2)
                    .padding(.bottom, geometry.safeAreaInsets.bottom)
                }
            }
            .ignoresSafeArea(.all, edges: .all)
        }
    }
}

struct EmojiPickerViewPreviewHelper: View {
    @State var emoji = "😀"
    @State var show = true

    var body: some View {
        Rectangle().fill(Color.background)
            .overlay(
                Toggle("Toggle", isOn: $show).offset(x: 0, y: -100)
            )
            .overlay(
                EmojiOverlay(
                    isPresented: $show,
                    emoji: $emoji,
                    queue: .main,
                    database: EmojiProvider.shared.database
                )
            )
    }
}

struct EmojiPickerView_Previews: PreviewProvider {
    static var previews: some View {
        EmojiPickerViewPreviewHelper()
            .preferredColorScheme(.dark)
    }
}
