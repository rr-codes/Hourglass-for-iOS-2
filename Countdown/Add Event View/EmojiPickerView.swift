//
//  EmojiView.swift
//  Countdown
//
//  Created by Richard Robinson on 2020-07-31.
//

import SwiftUI

fileprivate struct EmojiGroupView: View {
    let gridItems = [GridItem](repeating: .init(.fixed(44)), count: 5)

    let group: [Emoji]
    
    @Binding var selectedEmoji: String
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHGrid(rows: gridItems, spacing: 16) {
                ForEach(group) { emoji in
                    Text(emoji.emoji)
                        .font(.system(size: 30))
                        .onTapGesture {
                            self.selectedEmoji = emoji.emoji
                        }
                        .background(
                            Circle()
                                .fill(Color.blue)
                                .opacity(self.selectedEmoji == emoji.emoji ? 0.2 : 0)
                                .scaleEffect(1.3)
                        )
                        .accessibility(label: Text(emoji.name))
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.bottom, 13)
        .padding(.top, 5)
    }
}

fileprivate struct EmojiPickerView: View {
    let database: EmojiDBProvider.Database
    let categories: [EmojiDBProvider.Category]
    
    @State private var selectedCategoryIndex: Int = 0
    @Binding var selectedEmoji: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(categories[selectedCategoryIndex].name)
                .font(.caption)
                .bold()
                .textCase(.uppercase)
                .foregroundColor(.init(UIColor.secondaryLabel))
                .padding(.leading, 20)
                .padding(.top, 25)
            
            EmojiGroupView(group: database[selectedCategoryIndex], selectedEmoji: $selectedEmoji)
                        
            Picker("Category", selection: $selectedCategoryIndex) {
                ForEach(categories) { category in
                    Text(category.emoji).tag(category.id)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal, 20)
            .labelsHidden()
            .padding(.bottom, 20)
        }
        .background(
            RoundedRectangle(cornerRadius: 25.0)
                .fill(Color.secondaryBackground)
                .shadow(color: Color.foreground.opacity(0.1), radius: 5)
        )
    }
}

struct EmojiOverlay: View {
    let database: EmojiDBProvider.Database
    let categories: [EmojiDBProvider.Category]
    
    @Binding var isPresented: Bool
    @Binding var emoji: String
    
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
                    EmojiPickerView(database: database, categories: categories, selectedEmoji: $emoji)
                        .animation(Animation.spring().speed(2))
                        .transition(.move(edge: .bottom))
                        .padding(.horizontal, 14)
                        .zIndex(2)
                        .padding(.bottom, geometry.safeAreaInsets.bottom)
                }
            }
            .edgesIgnoringSafeArea(.all)
        }
    }
}

struct EmojiPickerViewPreviewHelper: View {
    @Environment(\.emojiProvider) var provider: EmojiDBProvider
    
    @State var emoji = "😀"
    @State var show = true

    var body: some View {
        Rectangle().fill(Color.background)
            .overlay(
                Toggle("Toggle", isOn: $show).offset(x: 0, y: -100)
            )
            .overlay(
                EmojiOverlay(database: provider.database, categories: EmojiDBProvider.categories, isPresented: $show, emoji: $emoji)
            )
    }
}

struct EmojiPickerView_Previews: PreviewProvider {
    
    static var previews: some View {
        EmojiPickerViewPreviewHelper()
            .preferredColorScheme(.dark)
    }
}
