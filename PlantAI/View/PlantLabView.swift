//
//  PlantLabView.swift
//  PlantAI
//
//  Created by nanci on 2025/7/17.
//

import SwiftUI

struct PlantLabView: View {
    // 控制提示框是否显示
    @State private var isTipShown = false
    // 记录点击位置的状态
    @State private var selectedPointIndex: Int? = nil

    // 圆点数据模型
    struct Point {
        var id = UUID()
        var position: CGPoint
        var isTapped: Bool = false
        var imageName: String? = nil // 点击后显示的图片名称
    }

    // 初始化圆点数据
    @State private var points: [Point] = [
        Point(position: CGPoint(x: 0.213, y: 0.56), imageName: "selected_image_1"),
        Point(position: CGPoint(x: 0.372, y: 0.6), imageName: "selected_image_2"),
        Point(position: CGPoint(x: 0.175, y: 0.94), imageName: "selected_image_1"),
        Point(position: CGPoint(x: 0.448, y: 0.953), imageName: "selected_image_2"),
        Point(position: CGPoint(x: 0.495, y: 0.45), imageName: "selected_image_1"),
        Point(position: CGPoint(x: 0.714, y: 0.45), imageName: "selected_image_2"),
        Point(position: CGPoint(x: 0.719, y: 0.634), imageName: "selected_image_1"),
        Point(position: CGPoint(x: 0.84, y: 0.735), imageName: "selected_image_2")
    ]

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // 背景图
                Image("xxzwkxj")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .edgesIgnoringSafeArea(.all)

                // 点击后显示的提示框
                if let index = selectedPointIndex, points[index].isTapped {
                    // 半透明蒙层
                    Color.black.opacity(0.3)
                        .edgesIgnoringSafeArea(.all)
                        .onTapGesture {
                            // 点击蒙层外部关闭弹窗
                            withAnimation {
                                points[index].isTapped = false
                                selectedPointIndex = nil
                            }
                        }

                    VStack(alignment: .leading, spacing: 12) {
                        // 显示点击位置的图片
                        if let imageName = points[index].imageName {
                            Image(imageName)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 120)
                                .cornerRadius(8)
                        }

                        Text("水分运输实验")
                            .font(.headline)
                            .foregroundColor(.white)

                        Text("来了解植物根茎的秘密！")
                            .font(.subheadline)
                            .foregroundColor(.white)

                        HStack {
                            ForEach(0..<5) { _ in
                                Image(systemName: "star.fill")
                                    .foregroundColor(.yellow)
                            }
                        }
                    }
                    .padding()
                    .background(Color(red: 70/255, green: 215/255, blue: 231/255))
                    .cornerRadius(16)
                    .shadow(radius: 8)
                    .position(x: geo.size.width * 0.5, y: geo.size.height * 0.5)
                    .transition(.scale(scale: 0.9).combined(with: .opacity))
                    .animation(.spring(), value: isTipShown)
                }

                // 显示圆点
                ForEach(0..<points.count, id: \.self) { index in
                    let point = points[index]

                    if !point.isTapped {
                        // 初始状态：透明圆点
                        Circle()
                            .fill(Color.white.opacity(0.3)) // 半透明白色
                            .frame(width: 24, height: 24)
                            .overlay(
                                Circle()
                                    .stroke(Color(red: 70/255, green: 215/255, blue: 231/255), lineWidth: 2)
                            )
                            .position(
                                x: geo.size.width * point.position.x,
                                y: geo.size.height * point.position.y
                            )
                            .onTapGesture {
                                // 点击后更新状态
                                withAnimation {
                                    points[index].isTapped = true
                                    selectedPointIndex = index
                                }
                            }
                            .animation(.spring(), value: points[index].isTapped)
                    } else {
                        // 点击后状态：显示图片
                        if let imageName = point.imageName {
                            Image(imageName)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 80, height: 80)
                                .cornerRadius(8)
                                .position(
                                    x: geo.size.width * point.position.x,
                                    y: geo.size.height * point.position.y
                                )
                                .transition(.scale)
                                .animation(.spring(), value: points[index].isTapped)
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    PlantLabView()
}
