//
//  GardenPage.swift
//  PlantAI
//
//  Created by nanci on 2025/7/17.
//

import SwiftUI

struct GardenPage: View {
    @Environment(\.presentationMode) var presentationMode

    @State private var searchText: String = ""
    @State private var lightValue: Double = 0.54
    @State private var weatherValue: Double = 0.3

    private let topImageHeight: CGFloat = 420
    private let cardCornerRadius: CGFloat = 28
    private let horizontalPadding: CGFloat = 16

    var body: some View {
        VStack(spacing: 0) {
            NavigationBar(title: "花园", onBack: {
                presentationMode.wrappedValue.dismiss()
            }, onMore: {})
            .padding(.top, safeAreaTop())
            .background(Color.white)
//            .zIndex(2)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // 顶部图片区
                    ZStack {
                        Image("garden")
                            .resizable()
                            .scaledToFill()
                            .frame(height: topImageHeight)
                            .clipped()

                        VStack {
                            Spacer().frame(height: 10)
                            Text("‹  梦幻花园  ›")
                                .foregroundColor(.white.opacity(0.95))
                                .font(.system(size: 14))
                            Spacer()
                        }

                        VStack(spacing: 14) {
                            Spacer().frame(height: 110)
                            GP_FabButton(systemName: "sun.max.fill")
                            GP_FabButton(systemName: "cloud.rain.fill")
                            Spacer()
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 18)

                        VStack(spacing: 14) {
                            Spacer().frame(height: 90)
                            GP_FabButton(systemName: "list.bullet")
                            GP_FabButton(systemName: "scope")
                            GP_FabButton(systemName: "camera.fill")
                            Spacer()
                        }
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .padding(.trailing, 16)
                    }

                    // 白色内容卡片
                    VStack(spacing: 18) {
                        Capsule()
                            .fill(LinearGradient(gradient: Gradient(colors: [PlantColor.green, Color(hex: "9EE07A")]), startPoint: .leading, endPoint: .trailing))
                            .frame(width: 140, height:4)
                            .padding(.top, 10)

                        SearchBar(text: $searchText, placeholder: "搜索栏： 搜索培育出的植物")

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 18) {
                                ForEach(plants.indices, id: \.self) { idx in
                                    GP_PlantThumb(imageName: plants[idx].image)
                                }
                            }
                            .padding(.horizontal, horizontalPadding)
                            .padding(.vertical, 6)
                        }

                        // 光线时间 + ThemePicker 并排结构
                        HStack(alignment: .top, spacing: 12) {
                            // 光线时间
                            VStack{
                                VStack(spacing: 12) {
                                    HStack {
                                        Image(systemName: "sun.max")
                                            .font(.system(size: 20))
                                            .foregroundColor(Color(hex: "2FA84F"))
                                        HStack(spacing: 12) {
                                            Text("光线时间")
                                                .font(.system(size: 16, weight: .medium))
                                                .foregroundColor(.black)
                                        }
                                        Spacer()
                                        Text(timeString(from: lightValue))
                                            .font(.system(size: 14))
                                            .foregroundColor(.black)
                                    }
                                    GP_CustomSlider(value: $lightValue, trackColor: Color(hex: "E0E0E0"), progressColor: .white)
                                }
                                .padding(.all, 16)
                                .background(
                                    LinearGradient(gradient: Gradient(colors: [Color(hex: "BFFFCF"), Color(hex: "FFF9C4")]), startPoint: .leading, endPoint: .trailing)
                                )
                                .cornerRadius(16)
                                
                                // 天气调节面板
                                VStack(spacing: 12) {
                                    HStack {
                                        Text("天气调节")
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundColor(.black)
                                        Spacer()
                                        Text(weatherLabel(for: weatherValue))
                                            .font(.system(size: 14))
                                            .foregroundColor(.black)
                                    }
                                    HStack(spacing: 14) {
                                        ForEach(GP_WeatherIcons.indices, id: \.self) { idx in
                                            Image(systemName: GP_WeatherIcons[idx].symbol)
                                                .font(.system(size: 18))
                                                .foregroundColor(idx <= Int((weatherValue * Double(GP_WeatherIcons.count - 1)).rounded()) ? PlantColor.green : PlantColor.green.opacity(0.3))
                                        }
                                    }
                                    GP_CustomSlider(value: $weatherValue, trackColor: Color(hex: "E0E0E0"), progressColor: .white)
                                }
                                .padding(.all, 16)
                                .background(
                                    LinearGradient(gradient: Gradient(colors: [Color(hex: "BFFFCF"), Color(hex: "FFF9C4")]), startPoint: .leading, endPoint: .trailing)
                                )
                                .cornerRadius(16)
                            }
                            

                            ThemePicker(themes: ["翠林秘境","灵韵仙谷","星梦幻境","魔影幽域","冰封雪原"], currentIndex: 2)
                                .frame(width: 120)
                        }
//                        .padding(.horizontal, horizontalPadding)

                        
//                        Spacer(minLength: 24)
                    }
                    .background(Color.white)
//                    .cornerRadius(cardCornerRadius)
                    .padding(.top, -28)
//                    .padding(.bottom, 36)
                }
            }
        }
        .edgesIgnoringSafeArea(.top)
        .navigationBarHidden(true)
    }

    private func timeString(from value: Double) -> String {
        let totalMinutes = Int((value * 24.0 * 60.0).rounded())
        let h = (totalMinutes / 60) % 24
        let m = totalMinutes % 60
        return String(format: "%02d:%02d", h, m)
    }

    private func weatherLabel(for value: Double) -> String {
        let idx = Int((value * Double(GP_WeatherIcons.count - 1)).rounded())
        return GP_WeatherIcons[max(0, min(idx, GP_WeatherIcons.count - 1))].label
    }

    private func safeAreaTop() -> CGFloat {
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        return windowScene?.windows.first?.safeAreaInsets.top ?? 12
    }
}

fileprivate struct GP_FabButton: View {
    var systemName: String
    var body: some View {
        Button(action: {}) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
                    .frame(width: 48, height: 48)
                    .shadow(color: Color(hex: "000000").opacity(0.06), radius: 6, x: 0, y: 2)
                Image(systemName: systemName)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(PlantColor.green)
            }
        }
    }
}

fileprivate struct GP_PlantThumb: View {
    var imageName: String
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(hex: "F6FFFE"))
                .frame(width: 98, height: 98)
                .shadow(color: Color(hex: "000000").opacity(0.03), radius: 6, x: 0, y: 3)
            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 78, height: 78)
        }
    }
}

// 灰轨 + 白进度 + 白圆滑块
fileprivate struct GP_CustomSlider: View {
    @Binding var value: Double
    var trackColor: Color
    var progressColor: Color

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(trackColor)
                    .frame(height: 8)
                RoundedRectangle(cornerRadius: 4)
                    .fill(progressColor)
                    .frame(width: max(8, CGFloat(value) * geo.size.width), height: 8)
                Circle()
                    .fill(Color.white)
                    .frame(width: 20, height: 20)
                    .offset(x: max(0, CGFloat(value) * geo.size.width - 10))
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { g in
                                let x = min(max(0, g.location.x), geo.size.width)
                                value = Double(x / geo.size.width)
                            }
                    )
            }
        }
        .frame(height: 20)
    }
}

fileprivate let GP_WeatherIcons: [(symbol: String, label: String)] = [
    ("wind", "微风"),
    ("sun.max.fill", "晴"),
    ("cloud.fill", "多云"),
    ("cloud.rain.fill", "雨"),
    ("snow", "雪"),
    ("cloud.sun.fill", "阴")
]


fileprivate struct ThemePicker: View {
    var themes: [String]
    var currentIndex: Int = 0

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "chevron.up")
                .foregroundColor(Color(hex: "9AA6B0"))
                .padding(.vertical, 6)

            VStack(spacing: 6) {
                ForEach(themes.indices, id: \.self) { idx in
                    Text(themes[idx])
                        .font(.system(size: idx == currentIndex ? 18 : 14, weight: idx == currentIndex ? .semibold : .regular))
                        .foregroundColor(idx == currentIndex ? Color(hex: "2FA84F") : Color(hex: "9AA6B0"))
                        .multilineTextAlignment(.center)
                        .frame(width: 120)
                        .padding(.vertical, idx == currentIndex ? 6 : 4)
                }
            }
            .padding(.horizontal, 8)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(LinearGradient(gradient: Gradient(colors: [Color(hex: "FFFFFF"), Color(hex: "F3F7FF")]), startPoint: .top, endPoint: .bottom))
                    .shadow(color: Color(hex: "000000").opacity(0.03), radius: 6, x: 0, y: 4)
            )

            Image(systemName: "chevron.down")
                .foregroundColor(Color(hex: "9AA6B0"))
                .padding(.vertical, 6)
        }
        .frame(width: 120)
        .padding(.vertical, 6)
    }
}

// Preview
struct GardenPage_Previews: PreviewProvider {
    static var previews: some View {
        GardenPage()
    }
}
