//
//  HomePage.swift
//  PlantAI
//
//  Created by nanci on 2025/7/17.
//

import SwiftUI
import Combine

struct HomePage: View {
    // MARK: - Banner
    @State private var currentBannerIndex = 0
    // 自动轮播定时器（可在 onDisappear 时 cancel）
    @State private var bannerTimer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()

    private let bannerList = HomePageData.banners
    private let cardList = HomePageData.cards

    var body: some View {
        ZStack {
            // 背景图片（保留不变）
            Image("main_bg")
                .resizable()
                .edgesIgnoringSafeArea(.all)
                .allowsHitTesting(false) // 避免遮挡子视图点击
            VStack(spacing: 8) {
                // 顶部栏：菜单 + 头像
                TopBar()
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                        WelcomeText(
                            title: "欢迎回来，看极光的雪橇狗！",
                            subtitle: "今日运动量为360kcal"
                        )
                        functionButtonsAndCharacter
                        carouselSection
                        waterfallSection
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 32)
                }
                .safeAreaInset(edge: .bottom) {
                    CustomTabBar(initialSelected: 0)
                }
            }
            .onReceive(bannerTimer) { _ in
                withAnimation(.easeInOut) {
                    currentBannerIndex = (currentBannerIndex + 1) % bannerList.count
                }
            }
            .onDisappear {
                bannerTimer.upstream.connect().cancel()
            }
        }
        .navigationBarHidden(true)
    }




    // MARK: - Function Buttons + Character
    var functionButtonsAndCharacter: some View {
        HStack(alignment: .top) {
            VStack(spacing: 14) {
                // 科普 pk - 绿色渐变胶囊
                Button(action: {
                    // 科普点击
                }) {
                    HStack(spacing: 12) {
                        Image("home_kepu")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 59)
                        
                        Text("科普PK")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                        
                        Spacer()
                    }
                    .padding(.vertical, 12)
                    .padding(.leading, 12)
                    .background(LinearGradient(colors: [Color(hex: "E0EF5A"), Color(hex: "29D329")], startPoint: .top, endPoint: .bottom))
                    .clipShape(RoundedCorner(radius: 16, corners: [.topLeft, .topRight, .bottomRight]))
                    .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 4)
                }

                // 探索记录 - 黄色渐变
                Button(action: {
                    // 探索点击
                }) {
                    HStack(spacing: 12) {
                        Text("探索记录")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                        Image("home_tansuo")
                            .resizable()
                            .frame(width: 100, height: 59)

                        Spacer()
                    }
                    .padding(.vertical, 10)
                    .padding(.leading, 12)
                    .background(LinearGradient(colors: [Color(hex: "#FFD100"), Color(hex: "FDFF8B")], startPoint: .top, endPoint: .bottom))
                    .clipShape(RoundedCorner(radius: 16, corners: [.topLeft, .bottomLeft, .bottomRight]))
                    .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 4)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Image("charactor")
                .resizable()
                .frame(width: 154, height: 195)
                .scaledToFit()
                .offset(x: 8, y: -6)
                .padding(.top,-10)
                .padding(.horizontal, 5)
        }
       
    }

    // MARK: - Carousel Section
    var carouselSection: some View {
        VStack(spacing: 8) {
            TabView(selection: $currentBannerIndex) {
                ForEach(bannerList.indices, id: \.self) { idx in
                    let banner = bannerList[idx]
                    ZStack(alignment: .bottomLeading) {
                        Image(banner.imagePath)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 160)
                            .clipped()
                            .cornerRadius(16)

                        VStack(alignment: .leading, spacing: 8) {
                            Text(banner.title)
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)

                            Text(banner.desc)
                                .font(.system(size: 12))
                                .foregroundColor(.white)
                                .lineLimit(3)

                            Button(action: {
                                // CTA 点击
                            }) {
                                HStack(spacing: 8) {
                                    Text(banner.buttonText)
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.white)
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(.white)
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(PlantColor.green)
                                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                            }
                        }
                        .padding(16)
                    }
                    .padding(.horizontal, 0)
                    .tag(idx)
                }
            }
            .frame(height: 160)
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never)) // 隐藏系统页码

            // 自定义指示器（绿色）
            HStack(spacing: 6) {
                ForEach(0..<bannerList.count, id: \.self) { idx in
                    Circle()
                        .fill(idx == currentBannerIndex ? PlantColor.green: Color.white.opacity(0.6))
                        .frame(width: idx == currentBannerIndex ? 10 : 8, height: idx == currentBannerIndex ? 10 : 8)
                        .animation(.easeInOut, value: currentBannerIndex)
                }
            }
            .frame(maxWidth: .infinity)
        }
    }

    // MARK: - Waterfall Section (手写，不使用 LazyVGrid)
    var waterfallSection: some View {
        VStack(spacing: 12) {
            // 将 cardList 按顺序转换为 Row（Full 或 Pair）
            ForEach(makeRows(from: cardList).indices, id: \.self) { rowIndex in
                let row = makeRows(from: cardList)[rowIndex]
                switch row {
                case .full(let card):
                    CardView(cardData: card)
//                        .frame(height: 200)
                case .pair(let left, let right):
                    HStack(spacing: 12) {
                        CardView(cardData: left)
//                            .frame(height: 180)
                        if let rightCard = right {
                            CardView(cardData: rightCard)
//                                .frame(height: 180)
                        } else {
                            // 保持两列视觉平衡：占位透明视图
                            Color.clear
//                                .frame(height: 180)
                        }
                    }
                }
            }
        }
    }

    // 将顺序数据转成行（Full / Pair）
    private func makeRows(from items: [CardDataModel]) -> [WaterfallRow] {
        var rows: [WaterfallRow] = []
        var i = 0
        while i < items.count {
            let item = items[i]
            if item.crossAxisCellCount == 2 {
                // 跨两列：单独一行
                rows.append(.full(item))
                i += 1
            } else {
                // 尝试取下一个非跨列项作为右侧
                var nextIndex = i + 1
                var rightItem: CardDataModel? = nil
                while nextIndex < items.count {
                    let candidate = items[nextIndex]
                    if candidate.crossAxisCellCount == 2 {
                        // 遇到跨列项则不作为配对，结束配对
                        break
                    } else {
                        rightItem = candidate
                        break
                    }
                }
                if let r = rightItem {
                    rows.append(.pair(left: item, right: r))
                    // 跳过右侧已被配对的项
                    // 找到 r at nextIndex: we consumed nextIndex (which is i+1 or later)
                    i += ( (nextIndex == i + 1) ? 2 : 1 )
                    // if nextIndex > i+1, it means intermediate items were cross==2 so we didn't pair — but by while logic nextIndex will only be i+1 when it's pairable, so safe to i += 2
                } else {
                    // 没有右侧可配对项，单独左侧占位
                    rows.append(.pair(left: item, right: nil))
                    i += 1
                }
            }
        }
        return rows
    }
}

// MARK: WaterfallRow
fileprivate enum WaterfallRow {
    case full(CardDataModel)
    case pair(left: CardDataModel, right: CardDataModel?)
}

// MARK: CardView (样式与设计图一致：白卡片、图片仅上角圆角、右上角图标组、阴影)
struct CardView: View {
    let cardData: CardDataModel

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .topTrailing) {
                Image(cardData.imagePath)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 120)
                    .clipped()
                    .cornerRadius(12, corners: [.topLeft, .topRight])

                HStack(spacing: 8) {
                    Image("home_icon_star")
                        .resizable()
                        .frame(width: 14, height: 14)
                    Image("home_icon_heart")
                        .resizable()
                        .frame(width: 14, height: 14)
                    Image("home_icon_comment")
                        .resizable()
                        .frame(width: 14, height: 14)
                }
                .padding(8)
                .background(Color.black.opacity(0.22))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .padding(10)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text(cardData.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color(hex: "0B2A16"))
                Text(cardData.desc)
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
                    .lineLimit(3)
            }
            .padding(12)
            .background(Color.white)
        }
        .background(Color.white)
        .cornerRadius(14)
        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
    }
}


// MARK: - Preview
struct HomePage_Previews: PreviewProvider {
    static var previews: some View {
        HomePage()
    }
}
