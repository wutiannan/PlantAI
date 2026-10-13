import SwiftUI

struct PlantDetailPage: View {
    let plant: Plant  // 从导航传递的植物数据
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .top) {
                // 全屏背景图
                Image("base_bg")
                    .resizable()
                    .ignoresSafeArea()
                
                VStack(spacing: 8) {
                    // 顶部导航栏
                    NavigationBar(title: "植物详情", onBack: {
                        // 返回
                        presentationMode.wrappedValue.dismiss()
                    }, onMore: {
                        // 这里实现更多菜单逻辑，可弹出菜单等
                    })
                    
                    ScrollView {
                        VStack(alignment: .leading, spacing: 24) {
                            
                            // 植物信息区域（绿色竖条+文字）
                            HStack(alignment: .top, spacing: 12) {
                                // 绿色竖条
                                Rectangle()
                                    .fill(Color.green)
                                    .frame(width: 4, height: 120)
                                    .cornerRadius(2)
                                
                                // 植物名称和描述
                                VStack(alignment: .leading, spacing: 12) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(plant.name)
                                            .font(.system(size: 24, weight: .bold))
                                            .foregroundColor(.black)
                                        
                                        Text(plant.enName)
                                            .font(.system(size: 14))
                                            .foregroundColor(.gray)
                                    }
                                    
                                    Text(plant.description)
                                        .font(.system(size: 14))
                                        .lineSpacing(5.6) // 对应行高1.4
                                        .foregroundColor(.black)
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.top, 16)
                            
                            // 植物图片
                            Image(plant.image)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 200, height: 300)
                                .frame(maxWidth: .infinity)

                            
    //                        // 植物详细信息卡片
    //                        VStack(alignment: .leading, spacing: 16) {
    //                            // 培育进度
    //                            HStack {
    //                                Image(systemName: "chart.bar.fill")
    //                                    .foregroundColor(.green)
    //                                    .frame(width: 24, height: 24)
    //
    //                                Text("培育进度")
    //                                    .font(.system(size: 16, weight: .medium))
    //                                    .foregroundColor(.black)
    //
    //                                Spacer()
    //
    //                                Text("\(Int(plant.progress * 100))%")
    //                                    .font(.system(size: 16))
    //                                    .foregroundColor(.green)
    //                            }
    //
    //                            // 进度条
    //                            ProgressView(value: plant.progress)
    //                                .progressViewStyle(LinearProgressViewStyle(tint: .green))
    //                                .frame(height: 8)
    //
    //                            // 分类信息
    //                            HStack {
    //                                Image(systemName: "tag.fill")
    //                                    .foregroundColor(.green)
    //                                    .frame(width: 24, height: 24)
    //
    //                                Text("植物分类")
    //                                    .font(.system(size: 16, weight: .medium))
    //                                    .foregroundColor(.black)
    //
    //                                Spacer()
    //
    //                                Text(plant.category)
    //                                    .font(.system(size: 16))
    //                                    .foregroundColor(.gray)
    //                            }
    //
    //                            // 培育难度
    //                            HStack {
    //                                Image(systemName: "flame.fill")
    //                                    .foregroundColor(.green)
    //                                    .frame(width: 24, height: 24)
    //
    //                                Text("培育难度")
    //                                    .font(.system(size: 16, weight: .medium))
    //                                    .foregroundColor(.black)
    //
    //                                Spacer()
    //
    //                                Text(plant.cultivationDifficulty)
    //                                    .font(.system(size: 16))
    //                                    .foregroundColor(.gray)
    //                            }
    //
    //                            // 收藏状态
    //                            HStack {
    //                                Image(systemName: plant.isCollected ? "heart.fill" : "heart")
    //                                    .foregroundColor(plant.isCollected ? .red : .gray)
    //                                    .frame(width: 24, height: 24)
    //
    //                                Text("我的收藏")
    //                                    .font(.system(size: 16, weight: .medium))
    //                                    .foregroundColor(.black)
    //
    //                                Spacer()
    //
    //                                Button(action: {
    //                                    // 这里可以添加收藏/取消收藏的逻辑
    //                                }) {
    //                                    Text(plant.isCollected ? "已收藏" : "收藏")
    //                                        .font(.system(size: 16))
    //                                        .foregroundColor(plant.isCollected ? .red : .gray)
    //                                }
    //                            }
    //                        }
    //                        .padding(16)
    //                        .background(Color.white.opacity(0.8))
    //                        .cornerRadius(12)
    //                        .padding(.horizontal, 16)
                            
                            // 开始培养按钮
                            NavigationLink(destination: CultivationInteractionPage(plant: plant)) {
                                ZStack {
                                    Circle()
                                        .fill(Color.white.opacity(0.8))
                                        .frame(width: 60, height: 60)
                                        .shadow(color: Color.green.opacity(0.5), radius: 6, x: 0, y: 0)
                                    
                                    Circle()
                                        .stroke(Color.white, lineWidth: 2)
                                        .frame(width: 60, height: 60)
                                    
                                    Text("开始培养")
                                        .font(.system(size: 12))
                                        .foregroundColor(.black)
                                }
                            }
                            .frame(width: 60, height: 60)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.vertical, 32)
                        }
                        .padding(.bottom, 50)
                    }
                }
                
            }
        }
        .navigationBarHidden(true)
    }
}

// 预览
struct PlantDetailPage_Previews: PreviewProvider {
    static var previews: some View {
        // 使用plants数组中的第一个植物作为预览数据
        PlantDetailPage(plant: plants.first!)
    }
}
