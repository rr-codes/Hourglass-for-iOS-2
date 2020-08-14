//
//  SearchBar.swift
//  Countdown
//
//  Created by Richard Robinson on 2020-08-11.
//

import Foundation
import SwiftUI

struct SearchBar: View {
    @Binding var text: String
    @Binding var isEditing: Bool
        
    var body: some View {
        HStack {
            TextField("Search", text: $text)
                .padding(7)
                .padding(.vertical, 1)
                .padding(.horizontal, 30)
                .background(Color.background)
                .cornerRadius(10)
                .overlay(
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 12)
                        
                        if isEditing && !text.isEmpty {
                            Button {
                                self.text = ""
                            } label: {
                                Image(systemName: "multiply.circle.fill")
                                    .foregroundColor(.gray)
                                    .padding(.trailing, 10)
                            }
                        }
                    }
                )
                .padding(.horizontal, 10)
                .onTapGesture {
                    self.isEditing = true
                }
        }
    }
}

struct SearchBar_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.gray
            SearchBar(text: .constant(""), isEditing: .constant(false))
        }
    }
}
