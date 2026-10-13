//
//  TabBar.swift
//  PlantAI
//
//  Created by nanci on 2025/8/11.
//


import SwiftUI

struct TabBar: View {
    @Binding var selectedTab: String
    var titles: [String]

    var body: some View {
        HStack {
            ForEach(titles, id: \.self) { title in
                VStack(spacing: 2) {
                    Text(title)
                        .font(.system(size: 16, weight: selectedTab == title ? .bold : .regular))
                        .foregroundColor(.black)

                    if selectedTab == title {
                        Color(hex: "6EC82A")
                            .frame(height: 2)
                            .frame(maxWidth: 30)
                    }
                }
                .onTapGesture { selectedTab = title }
                .frame(maxWidth: 60)
            }
        }
        .padding(.horizontal, 22)
//        .frame(height: 60)
    }
}

// MARK: - Preview
struct TabBar_Previews: PreviewProvider {
    struct PreviewWrapper: View {
        @State private var selectedTab: String = "首页"
        private let tabs = ["首页", "花园", "我的"]

        var body: some View {
            VStack {
                TabBar(selectedTab: $selectedTab, titles: tabs)
                Spacer()
                Text("当前选中: \(selectedTab)")
                    .padding()
            }
            .previewLayout(.sizeThatFits)
        }
    }

    static var previews: some View {
        PreviewWrapper()
    }
}
