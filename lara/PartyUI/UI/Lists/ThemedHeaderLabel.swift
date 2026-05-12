//
//  ThemedHeaderLabel.swift
//  PartyUI
//
//  Created by lunginspector on 3/3/26.
//

import SwiftUI

public struct ThemedHeaderLabel: View {
    var text: String
    var icon: String
    
    public init(text: String, icon: String) {
        self.text = text
        self.icon = icon
    }
    
    public var body: some View {
        HStack {
            Image(systemName: icon)
                .frame(width: 24, alignment: .center)
            Text(text.uppercased())
                .font(.system(.body, design: .monospaced))
        }
        .foregroundStyle(MatrixColors.matrixGreen)
        .fontWeight(.bold)
        .opacity(0.8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top)
    }
}
