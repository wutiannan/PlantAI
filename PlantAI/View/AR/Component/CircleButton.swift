//
//  CircleButton.swift
//  PlantAI
//
//  Created by nanci on 2025/9/2.
//


import SwiftUI

// MARK: - 通用按钮样式：按下缩小 + 半透明
struct CircleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .opacity(configuration.isPressed ? 0.7 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// MARK: - 圆形纯色按钮
struct CircleSolidButton: View {
    var icon: String
    var iconSize: CGFloat = 40
    var iconColor: Color = .white
    var backgroundColor: Color = PlantColor.green
    var fontWeight: Font.Weight = .bold
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .resizable()
                .scaledToFit()
                .frame(width: iconSize, height: iconSize)
                .fontWeight(fontWeight)
                .foregroundColor(iconColor)
                .frame(width: 60, height: 60)
                .background(backgroundColor)
                .clipShape(Circle())
        }
        .buttonStyle(CircleButtonStyle()) // ✅ 加入按下反馈
    }
}

// MARK: - 圆形渐变按钮
struct CircleGradientButton: View {
    var icon: String
    var iconSize: CGFloat = 40
    var fontWeight: Font.Weight = .bold
    var gradient: LinearGradient = LinearGradient(
        colors: [PlantColor.green, PlantColor.cyan],
        startPoint: .leading,
        endPoint: .trailing
    )
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .resizable()
                .scaledToFit()
                .frame(width: iconSize, height: iconSize)
                .fontWeight(fontWeight)
                .foregroundColor(.white)
                .frame(width: 60, height: 60)
                .background(gradient)
                .clipShape(Circle())
        }
        .buttonStyle(CircleButtonStyle()) // ✅ 加入按下反馈
    }
}

// MARK: - 预览
struct CircleButton_Previews: PreviewProvider {
    static var previews: some View {
        HStack(spacing: 20) {
            CircleSolidButton(icon: "minus", iconSize: 24){}
            CircleGradientButton(icon: "plus", iconSize: 24){}
            CircleSolidButton(icon: "arrow.right", iconSize: 28, backgroundColor:  PlantColor.cyan){}
        }
        .padding()
        .background(Color.gray.opacity(0.2))
    }
}
