//
//  Palette.swift
//  PlantAI
//
//  Created by nanci on 2025/9/2.
//


import SwiftUI
import UIKit

enum PlantColor {
    // 6EC82A
    static let green = Color(uiColor: #colorLiteral(red: 0.4314, green: 0.7843, blue: 0.1647, alpha: 1))
    // 46D7E7
    static let cyan  = Color(uiColor: #colorLiteral(red: 0.2745, green: 0.8431, blue: 0.9059, alpha: 1))

    // 常用渐变
    static let brandGradient = LinearGradient(
        colors: [PlantColor.green, PlantColor.cyan],
        startPoint: .leading,
        endPoint: .trailing
    )
}
