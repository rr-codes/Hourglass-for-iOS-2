//
//  SettingsView.swift
//  Countdown
//
//  Created by Richard Robinson on 2020-08-16.
//

import SwiftUI

struct ColorChooser<S>: View where S : ShapeStyle {
    let options: [S]
    @Binding var selectedIndex: Int
    
    private let rows = [GridItem](repeating: GridItem(.flexible()), count: 6)
    
    init(_ options: [S], selectedIndex: Binding<Int>) {
        precondition(!options.isEmpty)
        
        self.options = options
        self._selectedIndex = selectedIndex
    }
    
    var body: some View {
        LazyVGrid(columns: rows, alignment: .leading, spacing: 20) {
            ForEach(0..<options.count) { i in
                Circle()
                    .fill(options[i])
                    .overlay(
                        Circle()
                            .foregroundColor(.white)
                            .frame(
                                width: selectedIndex != i ? 0 : 7,
                                height: selectedIndex != i ? 0 : 7
                            )
                            .animation(
                                Animation.spring().speed(2)
                            )
                    )
                    .frame(width: 33, height: 33)
                    .onTapGesture { self.selectedIndex = i }
            }
        }
    }
}

struct SettingsView: View {
    @AppStorage("gradientIndex", store: .appGroup) var gradientIndex: Int?
    
    let onDismiss: () -> Void
        
    let url: URL? = {
        var components = URLComponents()
        
        components.scheme = "mailto"
        components.path = "robinson.ian.richard@gmail.com"
        components.queryItems = [
            "subject" : "Feedback for Hourglass"
        ]
                
        return components.url
    }()
    
    var linearGradients: [LinearGradient] {
        Gradient.all.map {
            LinearGradient(
                gradient: $0,
                startPoint: .topTrailing,
                endPoint: .bottomLeading
            )
        }
    }
    
    var gradientColor: Color {
        Gradient.all[gradientIndex ?? 0].colors.first!
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 44) {
            Header("Settings") {
                Image(systemName: "xmark.circle.fill").onTapGesture(perform: onDismiss)
            }
                        
            HStack(alignment: .top) {
                Image("icon")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 75, height: 75)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .shadow(color: Color.gray.opacity(0.4), radius: 5, x: 0, y: 0)
                
                Spacer().width(20)
                
                VStack(alignment: .leading) {
                    Spacer().height(10)
                    
                    (Text("Hourglass ") + Text("Beta").foregroundColor(gradientColor))
                        .font(.headline)
                    
                    Spacer().height(5)
                    
                    Text("Developed by Richard Robinson")
                        .font(.subheadline)
                        .opacity(0.7)
                }
            }
            .padding(.vertical, 20)
                        
            VStack(alignment: .leading) {
                Text("Widget Background Color")
                    .bold()
                    .padding(.bottom, 16)
                
                ColorChooser(linearGradients, selectedIndex: $gradientIndex ?? 0)
            }
                        
            VStack(alignment: .leading) {
                Text("Support")
                    .bold()
                    .padding(.bottom, 10)
                
                Link(destination: url!) {
                    Text("Contact Us")
                    
                    Spacer()
                    
                    Image(systemName: "arrow.up.right.square.fill")
                        .imageScale(.large)
                        .padding(.trailing, 3)
                }

            }
            .padding(.top)
            .accentColor(gradientColor)
            
            Spacer()
        }
        .padding(20)
        .onAppear {
            if gradientIndex == nil {
                gradientIndex = 0
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        EmptyView().sheet(isPresented: .constant(true), content: {
            SettingsView(onDismiss: { })
        })
    }
}
