//
//  DialogueBubbleView.swift
//  PlantAI
//
//  Created by nanci on 2025/9/1.
//


import SwiftUI

struct DialogueBubble: View {
    var primaryText: String
    var secondaryText: String? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(primaryText)
                .font(.system(size: 15))
                .foregroundColor(.black)
            
            if let secondary = secondaryText, !secondary.isEmpty {
                Text(secondary)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
        }
        .padding(12)
        .background(
            Color.white.opacity(0.7)
        )
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(PlantColor.green.opacity(0.8), lineWidth: 1)
        )
    }
}

// 预览
struct DialogueBubble_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            // 背景示例，方便看毛玻璃效果
            Image("main_bg")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            DialogueBubble(
                primaryText: "我们到任务点啦！下方选择“放大镜”就可以开始你的探索咯，请注意是否在任务点范围内哦~",
                secondaryText: "快去点击吧！"
            )
            .padding()
        }
    }
}

