//
//  ViewExtensions.swift
//  Countdown
//
//  Created by Richard Robinson on 2020-08-07.
//

import Foundation
import SwiftUI

extension View {
    func extraSheet<Content: View>(
        isPresented: Binding<Bool>,
        onDismiss: (() -> Void)? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        self.background(EmptyView().sheet(isPresented: isPresented, onDismiss: onDismiss, content: content))
    }
}

extension View {
    func width(_ value: CGFloat) -> some View {
        self.frame(width: value)
    }
    
    func height(_ value: CGFloat) -> some View {
        self.frame(height: value)
    }
}

extension View {
    @ViewBuilder func applyIf<V: View>(_ condition: Bool, modifier: (Self) -> V) -> some View {
        if condition {
            modifier(self)
        } else {
            self
        }
    }
}

extension View {
    func eraseToAnyView() -> AnyView {
        self as? AnyView ?? AnyView(self)
    }
    
    @ViewBuilder func redacted(if condition: Bool, reason: RedactionReasons) -> some View {
        if condition {
            self.redacted(reason: reason)
        } else {
            self
        }
    }
}
