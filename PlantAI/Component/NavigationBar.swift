//
//  TaskNavigationBar.swift
//  PlantAI
//
//  Created by nanci on 2025/7/29.
//


import SwiftUI

struct NavigationBar: View {
    // 可根据需要添加标题、返回按钮、更多按钮的自定义逻辑参数
    let title: String
    let onBack: () -> Void
    let onMore: () -> Void
    
    
    var body: some View {
        HStack {
            // 返回按钮
            Button(action: onBack) {
//                Image(systemName: "chevron.left")
                Image("main_icon_back")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.black)
            }
            
            Spacer()
            
            // 标题
            Text(title)
                .font(.system(size: 22))
                .foregroundColor(.black)
            
            Spacer()
            
            // 更多菜单按钮
            Button(action: onMore) {
//                Image(systemName: "line.3.horizontal")
                Image("main_icon_menu")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.black)
            }
        }
        .frame(height: 44)
        .padding(.horizontal, 16)
//        .background(Color(hex: "E6F7FB"))
    }
}

// 预览
struct TaskNavigationBar_Previews: PreviewProvider {
    static var previews: some View {
        NavigationBar(title: "户外实地探索任务", onBack: {}, onMore: {})
            .previewLayout(.sizeThatFits)
    }
}
