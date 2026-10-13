//
//  BottomStatusBar.swift
//  PlantAI
//
//  Created by nanci on 2025/9/3.
//


import SwiftUI

struct BottomStatusBar: View {
    let text: String
    var backgroundColor: Color = PlantColor.green
    var textColor: Color = .white
    var fontSize: CGFloat = 20
    var cornerRadius: CGFloat = 8
    
    var body: some View {
        Text(text)
            .font(.system(size: fontSize))
            .foregroundColor(textColor)
            .padding(12)
            .frame(maxWidth: .infinity)
            .background(backgroundColor)
            .cornerRadius(cornerRadius)
            .padding(.horizontal, 30)
            .offset(y: -25)
    }
}
