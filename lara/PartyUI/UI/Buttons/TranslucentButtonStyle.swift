//
//  TranslucentButtonStyle.swift
//  PartyUI
//
//  Created by lunginspector on 3/3/26.
//

import SwiftUI

public struct TranslucentButtonStyle: PrimitiveButtonStyle {
    var color: Color = .accentColor
    var shape: Shape
    var useFullWidth: Bool
    @Environment(\.isEnabled) private var isEnabled
    
    public init(color: Color = .accentColor, foregroundStyle: Color = .accentColor, shape: Shape = .rect(cornerRadius: cornerRad.component), useFullWidth: Bool = true) {
        self.color = color
        self.shape = shape
        self.useFullWidth = useFullWidth
    }
    
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .buttonStyle(.plain)
            .foregroundStyle(isEnabled ? MatrixColors.matrixGreen : .gray)
            .frame(maxWidth: useFullWidth ? .infinity : nil)
            .padding()
            .background(isEnabled ? MatrixColors.matrixDarkGreen.opacity(0.4) : Color(.systemGray).opacity(0.2), in: AnyShape(shape))
            .overlay(
                AnyShape(shape)
                    .stroke(isEnabled ? MatrixColors.matrixGreen.opacity(0.5) : .gray.opacity(0.2), lineWidth: 1)
            )
            .onTapGesture(perform: configuration.trigger)
            .modifier(FadeAnimation())
    }
}
