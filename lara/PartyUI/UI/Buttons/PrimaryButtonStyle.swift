//
//  PrimaryButtonStyle.swift
//  PartyUI
//
//  Created by lunginspector on 3/3/26.
//

import SwiftUI

public struct PrimaryButtonStyle: PrimitiveButtonStyle {
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
            .foregroundStyle(isEnabled ? MatrixColors.matrixBlack : .gray)
            .frame(maxWidth: useFullWidth ? .infinity : nil)
            .padding()
            .background(isEnabled ? MatrixColors.matrixGreen : Color(.systemGray).opacity(0.2), in: AnyShape(shape))
            .onTapGesture(perform: configuration.trigger)
            .modifier(FadeAnimation())
    }
}

