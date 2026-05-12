//
//  TerminalHeader.swift
//  PartyUI
//
//  Created by lunginspector on 3/3/26.
//

import SwiftUI

public struct TerminalHeader: View {
    var text: String
    var icon: String
    var color: Color
    var context: String
    
    public init(text: String, icon: String, color: Color = Color(.label), context: String = "") {
        self.text = text
        self.icon = icon
        self.color = color
        self.context = context
    }
    
    public var body: some View {
        VStack(alignment: .leading) {
            HStack {
                if icon != "showMeProgressPlease" {
                    Image(systemName: icon)
                        .foregroundStyle(color == Color(.label) ? MatrixColors.matrixGreen : color)
                        .frame(width: 22, height: 22, alignment: .center)
                } else {
                    ProgressView()
                        .frame(width: 22, height: 22, alignment: .center)
                        .offset(y: 0.5)
                        .tint(MatrixColors.matrixGreen)
                }
                Text(text)
                    .font(.system(.body, design: .monospaced))
                    .fontWeight(.bold)
                    .lineLimit(1)
                    .foregroundStyle(color == Color(.label) ? MatrixColors.matrixGreen : color)
            }
            if !context.isEmpty {
                Text(context)
                    .foregroundStyle(MatrixColors.matrixGreen.opacity(0.7))
                    .font(.system(.subheadline, design: .monospaced))
                    .lineLimit(2)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
