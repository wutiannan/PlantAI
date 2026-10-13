//
//  WelcomeTextView.swift
//  PlantAI
//
//  Created by nanci on 2025/9/2.
//

import SwiftUI
// MARK: - Welcome Text Component
struct WelcomeText: View {
    let title: String      // 主标题
    let subtitle: String   // 副标题
    var titleFontSize: CGFloat = 24
    var subTitleFontSize: CGFloat = 18
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: titleFontSize))
                .foregroundColor(Color.black)

            Text(subtitle)
                .font(.system(size: subTitleFontSize))
                .foregroundColor(Color.gray)
        }
        
    }
}

// MARK: - Preview
struct WelcomeText_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            WelcomeText(
                title: "欢迎回来，看极光的雪橇狗！",
                subtitle: "今日运动量为360kcal"
            )
            .previewLayout(.sizeThatFits)
            .padding()
            
            WelcomeText(
                title: "Hi Nanci！",
                subtitle: "今日运动量为420kcal"
            )
            .previewLayout(.sizeThatFits)
            .padding()
        }
    }
}
