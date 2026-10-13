import SwiftUI
import UIKit

struct PlantIllustrationsPage: View {
    @State private var selectedCategory = "全部"
    @State private var selectedTab: String = "全部"
    @State private var searchText = ""
    
    @State private var plantListData: [Plant] = plants

    @Environment(\.presentationMode) var presentationMode

    private var filteredPlants: [Plant] {
        let tabFiltered = filterByTab(plants: plantListData)
        let categoryFiltered = filterByCategory(plants: tabFiltered)
        return filterBySearch(plants: categoryFiltered)
    }

    private func filterByTab(plants: [Plant]) -> [Plant] {
        switch selectedTab {
        case "全部": return plants
        case "已收集": return plants.filter { $0.isCollected }
        case "心愿单": return plants.filter { $0.isWishlist }
        default: return plants
        }
    }

    private func filterByCategory(plants: [Plant]) -> [Plant] {
        selectedCategory == "全部" ? plants : plants.filter { $0.category == selectedCategory }
    }

    private func filterBySearch(plants: [Plant]) -> [Plant] {
        searchText.isEmpty ? plants : plants.filter {
            $0.name.lowercased().contains(searchText.lowercased()) ||
            $0.description.lowercased().contains(searchText.lowercased())
        }
    }

    private var categories: [String] {
        var allCategories = Array(Set(plantListData.map { $0.category })).sorted()
        if let index = allCategories.firstIndex(of: "全部") {
            allCategories.remove(at: index)
        }
        return ["全部"] + allCategories
    }

    var body: some View {
        VStack(spacing: 8) {
            NavigationBar(title: "植物图鉴", onBack: {
                presentationMode.wrappedValue.dismiss()
            }, onMore: {})
            SearchBar(text: $searchText, placeholder: "搜索栏：搜索你想找的植物或分类")
            TabBar(selectedTab: $selectedTab, titles: ["全部", "已收集", "心愿单"])
            Spacer()
            HStack(spacing: 0) {
                categorySidebar
                plantListView
            }
            .background(
                Image("sidebar_bg")
                    .resizable()
            )
            .ignoresSafeArea()
        }
        .background(Color.white)
        .navigationBarHidden(true)
    }

    private var categorySidebar: some View {
        ScrollView {
            VStack(spacing: 12) {
                ForEach(categories, id: \.self) { category in
                    Button(action: { selectedCategory = category }) {
                        Text(category)
                            .foregroundColor(.black)
                            .padding(.vertical, 12)
                            .frame(width: 90)
                            .background(
                                selectedCategory == category
                                    ? Image("illustrations_active").resizable()
                                    : nil
                            )
                    }
                }
            }
            .padding(.vertical, 40)
        }
        .frame(width: 84)
    }

    private var plantListView: some View {
        VStack (spacing: 12) {
            ScrollView {
                if filteredPlants.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "leaf")
                            .font(.system(size: 40))
                            .foregroundColor(.gray)
                        Text("暂无植物")
                            .font(.system(size: 16))
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity) // 撑满
                } else {
                    ForEach(filteredPlants) { plant in
                        PlantCard(plant: plant) {
                            // 点击按钮后刷新 @State，列表自动更新
                            plantListData = plantListData.map { $0 }
                        }
                        .listRowBackground(Color.white)
                        .listRowSeparator(.hidden)
                    }
                }
            }
            .padding(.top, 15)
            .padding(.horizontal, 10)
        }
        .background(
            Color.white
                .clipShape(RoundedCorner(radius: 40, corners: [.topLeft, .topRight]))
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity) // 撑满父容器
    }

}

// 植物卡片
struct PlantCard: View {
    @ObservedObject var plant: Plant
    var onToggle: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(plant.name)
                    .font(.system(size: 16, weight: .bold))

                Text(plant.description)
                    .font(.system(size: 12))
                    .foregroundColor(.black)
                    .lineLimit(2)

                HStack(spacing: 12) {
                    Button(action: {
                        plant.isCollected.toggle()
                        onToggle()
                    }) {
                        Image(systemName: plant.isCollected ? "checkmark.circle.fill" : "checkmark.circle")
                            .foregroundColor(.black)
                            .font(.system(size: 20))
                    }

                    Button(action: {
                        plant.isWishlist.toggle()
                        onToggle()
                    }) {
                        Image(systemName: "heart.fill")
                            .foregroundColor(plant.isWishlist ? .red : Color(hex: "EFEFEF"))
                            .font(.system(size: 20))
                    }
                }
                .padding(.top, 4)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Image(plant.image)
                .resizable()
                .frame(width: 100, height: 120)
                .cornerRadius(8)
        }
        .padding(12)
        .background(
            Image("illustrations_card_bg").resizable()
        )
        .cornerRadius(20)
    }
}

// 预览
struct PlantIllustrationsPage_Previews: PreviewProvider {
    static var previews: some View {
        PlantIllustrationsPage()
    }
}
