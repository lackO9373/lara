//
//  FancyButtonStyle.swift
//  PartyUI
//
//  Created by lunginspector on 4/20/26.
//

import SwiftUI

public struct FancyButtonStyle: PrimitiveButtonStyle {
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
            .background(isEnabled ? MatrixColors.matrixDarkGreen.opacity(0.6) : Color(.systemGray).opacity(0.2), in: AnyShape(shape))
            .overlay(
                AnyShape(shape)
                    .stroke(isEnabled ? MatrixColors.matrixGreen : .gray.opacity(0.2), lineWidth: 2)
            )
            .onTapGesture(perform: configuration.trigger)
            .modifier(FadeAnimation())
    }
    
}

