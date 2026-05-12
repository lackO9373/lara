//
//  MatrixTheme.swift
//  PartyUI
//
//  Created by Manus on 5/13/26.
//

import SwiftUI

public enum MatrixColors {
    public static let matrixGreen = Color(red: 0.0, green: 1.0, blue: 0.0)
    public static let matrixDarkGreen = Color(red: 0.0, green: 0.3, blue: 0.0)
    public static let matrixBlack = Color.black
    public static let matrixGray = Color(white: 0.2)
}

public struct MatrixBackground: ViewModifier {
    public func body(content: Content) -> some View {
        content
            .background(MatrixColors.matrixBlack)
            .preferredColorScheme(.dark)
    }
}

public extension View {
    func matrixBackground() -> some View {
        self.modifier(MatrixBackground())
    }
}
