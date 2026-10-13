import SwiftUI

struct NurseryRoomPage: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.white.ignoresSafeArea(.all)
                
                VStack(spacing: 0) {
                    //
                    // 顶部导航栏
                    NavigationBar(title: "培育房", onBack: {
                        // 返回
                        presentationMode.wrappedValue.dismiss()
                    }, onMore: {
                        // 这里实现更多菜单逻辑，可弹出菜单等
                    })
                    
                    // 操作按钮
                    HStack(spacing: 12) {
                        NavigationLink(destination: GardenPage()) {
                            ActionButton(title: "进入花园", style: .left)
                        }
                        
                        Spacer()
                        
                        NavigationLink(destination: ShopPage()) {
                            ActionButton(title: "前往兑换", style: .right)
                        }
                    }
                    .padding(.vertical, 16)
                    
                    // 植物卡片网格
                    ZStack {
                        // 背景图
                        Image("plant_nursery_bg")
                            .resizable()
                            .ignoresSafeArea()
                            .padding(.horizontal, 16)
                             .edgesIgnoringSafeArea(.bottom)
                        ScrollView {
                            // 直接从全局plants数组获取数据
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: 3), spacing: 0) {
                                ForEach(plants) { plant in
                                    NavigationLink(destination: PlantDetailPage(plant: plant)) {
                                        plantCard(plant: plant)
                                            .padding( .top ,12)
                                    }
    //                                .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding(12)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
    //                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }}
            }
        }
        .navigationBarHidden(true)
    }
       
    

    // 植物卡片
    private func plantCard(plant: Plant) -> some View {
        VStack(spacing: 4) {
            Text(plant.name)
                .font(.system(size: 14))
                .foregroundColor(.black)
            
            ZStack(alignment: .leading) {
                Rectangle()
                    .frame(width: 50, height: 3)
                    .foregroundColor(Color.gray.opacity(0.3))
                
                Rectangle()
                    .frame(width: 50 * plant.progress, height: 3)
                    .foregroundColor(.green)
            }
            
            Image(plant.image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 56, height: 80)
                .clipped()
            
            Rectangle()
                .frame(height: 6)
                .foregroundColor(.white)
        }
    }
}

// 预览
struct NurseryRoomPage_Previews: PreviewProvider {
    static var previews: some View {
        NurseryRoomPage()
    }
}
