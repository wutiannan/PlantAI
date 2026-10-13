//
//  TopBarComponent.swift
//  PlantAI
//
//  Created by nanci on 2025/9/2.
//

import SwiftUI

// MARK: - Top Bar Component
struct TopBar: View {
    var body: some View {
        HStack(spacing: 16) {
            // 菜单按钮
            Button(action: {
                // 菜单跳转逻辑
                print("跳转到菜单页面")
            }) {
                Image("main_icon_menu")
                    .resizable()
                    .frame(width: 24, height: 24)
            }
            
            Spacer()
            
            // 头像
            Button(action: {
                // 头像跳转逻辑
                print("跳转到个人中心页面")
            }) {
                Image("avatar")
                    .resizable()
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, 16)
    }
}

// MARK: - Preview
struct TopBar_Previews: PreviewProvider {
    static var previews: some View {
        TopBar()
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
