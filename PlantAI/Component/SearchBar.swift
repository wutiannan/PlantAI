//
//  SearchBar.swift
//  PlantAI
//
//  Created by nanci on 2025/8/11.
//


import SwiftUI

struct SearchBar: View {
    @Binding var text: String
    var placeholder: String

    var body: some View {
        ZStack(alignment: .leading) {
            // 自定义 placeholder
            if text.isEmpty {
                Text(placeholder)
                    .font(.system(size: 14))
                    .foregroundColor(Color.black.opacity(0.6))
                    .padding(.leading, 12)
            }

            HStack {
                TextField("", text: $text)
                    .font(.system(size: 14))
                    .foregroundColor(.black)
                    .padding(.leading, 12)
                    .padding(.vertical, 10)

                Spacer()

                Image("icon_search")
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .foregroundColor(Color(hex: "6EC82A"))
                    .padding(.trailing, 12)
            }
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "46D7E7").opacity(0.46),
                    Color(hex: "FEFF04").opacity(0.2)
                ]),
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .cornerRadius(20)
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
    }
}

// MARK: - Preview
struct SearchBar_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            SearchBar(text: .constant(""), placeholder: "搜索栏：搜索培育出的植物")
            SearchBar(text: .constant("玫瑰"), placeholder: "搜索栏：搜索培育出的植物")
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
