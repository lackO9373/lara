//
//  SectionPlatter.swift
//  PartyUI
//
//  Created by lunginspector on 3/3/26.
//

import SwiftUI

// MARK: SectionPlatter
public struct SectionPlatter: ViewModifier {
    public init() {}
    
    public func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(MatrixColors.matrixDarkGreen.opacity(0.15), in: .rect(cornerRadius: cornerRad.platter))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRad.platter)
                    .stroke(MatrixColors.matrixGreen.opacity(0.3), lineWidth: 1)
            )
    }
}

