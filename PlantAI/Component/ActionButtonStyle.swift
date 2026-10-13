//
//  ActionButtonStyle.swift
//  PlantAI
//
//  Created by nanci on 2025/9/7.
//


import SwiftUI

enum ActionButtonStyle {
    case left
    case right
    
    var backgroundImage: String {
        switch self {
        case .left: return "left_btn_bg"
        case .right: return "right_btn_bg"
        }
    }
}

struct ActionButton: View {
    let title: String
    let style: ActionButtonStyle
    
    var body: some View {
        ZStack(alignment: .center) {
            Image(style.backgroundImage)
                .resizable()
                .frame(width: 140, height: 45)
            
            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
        }
    }
}
struct ActionButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            ActionButton(title: "进入花园", style: .left)
            ActionButton(title: "前往兑换", style: .right)
        }
        .padding()
        .background(Color.gray.opacity(0.2))
    }
}
