import SwiftUI

struct ShopPage: View {
    @State private var selectedTab: String = "植物"
    @State private var searchText = ""
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack{
            Color.white.ignoresSafeArea(.all)
            
            VStack(spacing: 8) {
                // 顶部导航栏
                NavigationBar(
                    title: "植域商店",
                    onBack: { presentationMode.wrappedValue.dismiss() },
                    onMore: { /* 更多菜单逻辑 */ }
                )
                
                // 搜索栏
                SearchBar(text: $searchText, placeholder: "搜索栏: 搜索你想找的物品")
                
                // TabBar
                TabBar(selectedTab: $selectedTab, titles: ["植物", "花园", "周边"])
                
                // 主体内容
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        switch selectedTab {
                        case "植物":
                            plantGridView
                        case "花园":
                            gardenGridView
                        case "周边":
                            peripheralGridView
                        default:
                            plantGridView
                        }
                    }
                }
            }
        }
        .navigationBarHidden(true)
    }
    
    // 植物网格
    private var plantGridView: some View {
        let filtered = plants.filter {
            searchText.isEmpty ||
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.description.localizedCaseInsensitiveContains(searchText)
        }
        return LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 16) {
            ForEach(filtered) { plant in
                PlantCard2(plant: plant)
            }
        }
        .padding(16)
    }

    
    // 花园网格
    private var gardenGridView: some View {
        let filtered = gardens.filter {
            searchText.isEmpty ||
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.description.localizedCaseInsensitiveContains(searchText)
        }
        return LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 16) {
            ForEach(filtered) { garden in
                GardenCard(garden: garden)
            }
        }
        .padding(16)
    }
    
    // 周边网格（手写两列 + 整行）
    private var peripheralGridView: some View {
        let filtered = peripherals.filter {
            searchText.isEmpty ||
            $0.name.localizedCaseInsensitiveContains(searchText)
        }
        let spacing: CGFloat = 16
        let hPadding: CGFloat = 16
        let screenW = UIScreen.main.bounds.width
        let colW = (screenW - hPadding * 2 - spacing) / 2
        let rows = buildPeripheralRows(from: filtered)
        
        return VStack {
            ForEach(rows.indices, id: \.self) { i in
                let row = rows[i]
                if row.count == 1, let item = row.first, item.isFullWidth {
                    PeripheralCard(peripheral: item, isFullWidth: true)
                        .frame(width: screenW - hPadding * 2, height: 158)
                        .padding(.horizontal, hPadding)
                        .padding(.vertical, spacing)
                } else {
                    HStack(spacing: spacing) {
                        PeripheralCard(peripheral: row[0], isFullWidth: false)
                            .frame(width: colW, height: 209)
                        if row.count > 1 {
                            PeripheralCard(peripheral: row[1], isFullWidth: false)
                                .frame(width: colW, height: 209)
                        } else {
                            Color.clear.frame(width: colW, height: 209)
                        }
                    }
                    .padding(.horizontal, hPadding)
                    .padding(.vertical, spacing)
                }
            }
        }
        .padding(.vertical, spacing)
    }
    // 分行函数：两列排布，遇到 isFullWidth 独占一行
    private func buildPeripheralRows(from items: [Peripheral]) -> [[Peripheral]] {
        var rows: [[Peripheral]] = []
        var buffer: [Peripheral] = []
        for p in items {
            if p.isFullWidth {
                if !buffer.isEmpty {
                    rows.append(buffer)
                    buffer.removeAll()
                }
                rows.append([p]) // 整行
            } else {
                buffer.append(p)
                if buffer.count == 2 {
                    rows.append(buffer)
                    buffer.removeAll()
                }
            }
        }
        if !buffer.isEmpty {
            rows.append(buffer)
        }
        return rows
    }
}


// 植物卡片
struct PlantCard2: View {
    @ObservedObject var plant: Plant
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // 植物图片
            Image(plant.image)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
                .frame(height: 119)
            
            // 名称
            Text(plant.name)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.black)
            
            // 描述
            Text(plant.description)
                .font(.system(size: 10))
                .foregroundColor(.black.opacity(0.7))
                .fixedSize(horizontal: false, vertical: true)
            
            // 培养难度
            HStack(spacing: 4) {
                Text("培养难度:")
                    .font(.system(size: 10))
                    .foregroundColor(.black.opacity(0.7))
                
                HStack(spacing: 3) {
                    ForEach(0..<5, id: \.self) { index in
                        Capsule() // 椭圆形
                            .fill(index < plant.difficulty ? Color.green : Color.gray.opacity(0.3))
                            .frame(width: 6, height: 10)
                    }
                }
            }
            
            // 价格 & 按钮
            HStack(alignment: .firstTextBaseline) {
                Text("\(Int(plant.price))")
                    .font(.system(size: 20))
                    .foregroundColor(.black)
                Text("域币")
                    .font(.system(size: 10))
                    .foregroundColor(.black)
                
                Spacer()
                
                Button(action: { plant.isInCart.toggle() }) {
                    Image(systemName: "cart")
                        .foregroundColor(plant.isInCart ? .green : .gray)
                }
                
                Button(action: { plant.isCollected.toggle() }) {
                    Image(systemName: plant.isCollected ? "heart.fill" : "heart")
                        .foregroundColor(plant.isCollected ? Color(hex: "#46D7E7") : .gray)
                }
            }
            .padding(.top, 4)
        }
        .padding(12)
        .frame(height: 254)
        .background(
            Image("plantcard_bg")
                .resizable()
                .scaledToFill()
        )
        .cornerRadius(20)
        .clipped()
    }
}




// 花园卡片
struct GardenCard: View {
    @ObservedObject var garden: Garden
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // 背景图
            Image(garden.image)
                .resizable()
                .scaledToFill()
                .frame(height: 254)
                .clipped()
                .cornerRadius(20)
            
            // 半透明黑色渐变
            LinearGradient(
                gradient: Gradient(colors: [Color.black.opacity(0.0), Color.black.opacity(0.4)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .cornerRadius(20)
            
            VStack(alignment: .leading, spacing: 6) {
                // 名称
                Text(garden.name)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.top,120)
                
                // 描述
                Text(garden.description)
                    .font(.system(size: 10))
                    .foregroundColor(.white.opacity(0.85))
//                    .lineLimit(2)
                
                Spacer(minLength: 16)
                
                // 价格 & 按钮
                HStack(alignment: .bottom) {
                    HStack(alignment: .firstTextBaseline, spacing: 2) {
                        Text("\(Int(garden.price))")
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                        Text("域币")
                            .font(.system(size: 10))
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 12) {
                        // 购物车
                        Button(action: {
                            garden.isInCart.toggle()
                        }) {
                            Image(systemName: "cart.fill")
                                .foregroundColor(.white)
                        }
                        
                        // 收藏
                        Button(action: {
                            garden.isLiked.toggle()
                        }) {
                            Image(systemName: "heart.fill")
                                .foregroundColor(garden.isLiked ? Color(hex: "#46D7E7") : .white)
                        }
                    }
                    .font(.system(size: 20))
                }
            }
            .padding(16)
        }
        .frame(height: 254)
    }
}


// 周边卡片
struct PeripheralCard: View {
    @ObservedObject var peripheral: Peripheral
    var isFullWidth: Bool = false
    var body: some View {
        ZStack(alignment: .topTrailing) {
            // 背景图
            Image(peripheral.image)
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity)
                .clipped()

            // 右上角收藏
            Button(action: {
                peripheral.isLiked.toggle()
            }) {
                Image(systemName: "heart.fill")
                    .foregroundColor(peripheral.isLiked ? Color(hex: "#46D7E7") : .white)
                    .font(.system(size: 20))
                    .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1)
            }
            .padding(12)

            // 名称 + 价格
            VStack(spacing: 6) {
                Text(peripheral.name)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.black)
                Text("\(Int(peripheral.price))")
                    .font(.system(size: 20))
                    .foregroundColor(.black)
            }
            // 小卡片底部居中；整行卡片左下
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity,
                alignment: isFullWidth ? .topLeading : .bottom
            )
            .padding(.top,12)
            .padding(.bottom, 12)
            .padding(.leading, isFullWidth ? 12 : 0)
        }
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .contentShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}



struct ShopPage_Previews: PreviewProvider {
    static var previews: some View {
        ShopPage()
    }
}
