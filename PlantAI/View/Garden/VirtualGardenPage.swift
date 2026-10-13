//
//  VirtualGardenPage.swift
//  PlantAI
//
//  Created by nanci on 2025/7/17.
//


import SwiftUI

struct VirtualGardenPage: View {
    @Environment(\.presentationMode) var presentationMode
    var body: some View {
        NavigationView {
            ZStack {
                // 背景图片
                Image("main_bg")
                    .resizable()
                    .edgesIgnoringSafeArea(.all)
                    .allowsHitTesting(false) // 避免遮挡子视图点击
                VStack(spacing: 8) {
                    // 顶部栏：菜单 + 头像
                    TopBar()
                    
                    ScrollView {
                        VStack(alignment: .leading, spacing: 24) {
                            // 欢迎词
                            WelcomeText(
                                title: "来布置你的个性化“植域”吧！",
                                subtitle: "LET'S SET UP YOUR EXCLUSIVE 'PLANTING AREA'!",
                                subTitleFontSize:12
                            )
                            
                            // 花园横幅 + 进入花园按钮
                            gardenBanner
                            
                            // 功能按钮区：培育房 + 植物图鉴 + 植域商城
                            functionButtonsArea
                            //
                            // 植物卡片区
                            plantsCardArea
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 24)
                    }
                }
                .navigationBarHidden(true)
            }
            .safeAreaInset(edge: .bottom) {
                CustomTabBar(initialSelected: 2)
            }
        }
    }
}

// 子视图拆分
extension VirtualGardenPage {
    // 花园横幅
    private var gardenBanner: some View {
        ZStack(alignment: .topTrailing) {
            // 横幅图片
            Image("virtual_garden_banner")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 140)
                .cornerRadius(12)
            
            // 进入花园按钮（右上角）
            NavigationLink(destination: GardenPage()) {
                Text("进入花园")
                    .font(.system(size: 14))
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(20)
                    .padding(12)
            }
            
            // 横幅标题（左下角）
            Text("雪橇狗的花园")
                .font(.system(size: 16))
                .foregroundColor(.white)
                .padding(12)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
        }
    }
    
    // 功能按钮区
    private var functionButtonsArea: some View {
        HStack(alignment: .top,spacing: 23) {
            NavigationLink(destination: NurseryRoomPage()){
                VStack {
                    Image("garden_peiyu")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 157, height: 134)
                    
                    Text("培育房")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Spacer().frame(height: 10)
                }
                .padding(.horizontal,10)
                .background(LinearGradient(colors: [Color(hex: "A5FFED"), Color(hex: "4CD5FF")], startPoint: .top, endPoint: .bottom))
                .clipShape(RoundedCorner(radius: 16, corners: [.bottomLeft, .bottomRight]))
                .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 4)
                
            }
            VStack(spacing: 14) {
                // 植物图鉴
                NavigationLink(destination: PlantIllustrationsPage()) {
                    HStack(spacing: 12) {
                        Text("植物图鉴")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                        Image("garden_tujian")
                            .resizable()
                            .frame(width: 74, height: 68)

                        Spacer()
                    }
                    .padding(.vertical, 4)
                    .padding(.leading, 20)
                    .background(LinearGradient(colors: [Color(hex: "#FFD100"), Color(hex: "FDFF8B")], startPoint: .top, endPoint: .bottom))
                    .clipShape(RoundedCorner(radius: 16, corners: [.topLeft, .bottomLeft, .bottomRight]))
                    .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 4)
                }
                // 植域商城
                NavigationLink(destination: ShopPage()){
                    HStack(spacing: 12) {
                        Image("garden_shop")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 74, height: 68)
                        
                        Text("植域商城")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                        
                        Spacer()
                    }
                    .padding(.vertical, 4)
                    .padding(.leading, 20)
                    .background(LinearGradient(colors: [Color(hex: "E0EF5A"), Color(hex: "29D329")], startPoint: .top, endPoint: .bottom))
                    .clipShape(RoundedCorner(radius: 16, corners: [.topLeft, .topRight, .bottomRight]))
                    .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 4)
                }

            }
            .frame(maxWidth: .infinity, alignment: .leading)

        }
    }
    
    // 植物卡片区
    private var plantsCardArea: some View {
        HStack(spacing: 12) {
            PlantCard2(plant: Plant(
                name: "栀子花",
                enName: "GARDENIA",
                image: "plant_gardenia",
                progress: 0.4,
                description: "茜草科、栀子属灌木植物，花芳香，单朵生于枝顶，花期3~7月，果期5月~翌年2月",
                category: "灌木",
                isCollected: true,
                price: 100,
                cultivationDifficulty: "容易",
                difficulty: 1)
            )
            PlantCard2(plant: Plant(
                name: "草莓",
                enName: "STRAWBERRY",
                image: "plant_strawberry",
                progress: 0.6,
                description: "为蔷薇科草莓属多年生草本植物，小叶具短柄，倒卵形或菱形，叶柄密被开展黄色柔毛，花期4~5月，果期6~7月",
                category: "蔬菜",
                isCollected: true,
                price: 100,
                cultivationDifficulty: "中等",
                difficulty: 3
                )
            )
        }
    }
}

// 辅助定义
enum StarStatus {
    case filled
    case empty
}

#Preview {
    VirtualGardenPage()
}
