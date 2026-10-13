import SwiftUI

struct CultivationInteractionPage: View {
    @State private var plant: Plant
    @Environment(\.presentationMode) var presentationMode

    // 本 View 内维护的可变进度（0...100）
    @State private var progress: Double

    @State private var humidity: Double = 60
    @State private var temperature: Double = 20
    @State private var light: Double = 16000

    // 当前要显示的图标名称（无论系统或自定义都放在这里）
    @State private var actionIconName: String? = nil
    // 标记当前 actionIconName 是否为系统图标（Image(systemName:)）
    @State private var actionIconIsSystem: Bool = false
    @State private var hideWorkItem: DispatchWorkItem?

    init(plant: Plant) {
        self.plant = plant
        self._progress = State(initialValue: plant.progress)
    }

    // 用来驱动动画的标识（系统/自定义合并）
    private var displayIconID: String? {
        guard let name = actionIconName else { return nil }
        return (actionIconIsSystem ? "s:\(name)" : "a:\(name)")
    }

    var body: some View {
        ZStack {
            Image("base_bg")
                .resizable()
                .ignoresSafeArea()
            VStack(spacing: 8) {
                // 顶部导航栏
                NavigationBar(title: "培养互动", onBack: {
                    // 返回
                    presentationMode.wrappedValue.dismiss()
                }, onMore: {
                    // 这里实现更多菜单逻辑，可弹出菜单等
                })
                

            ScrollView {
                VStack(spacing: 20) {
                    HStack(alignment: .center, spacing: 40) {
                        VStack(spacing: 20) {
                            // 示例：按钮使用自定义资产图作为按钮视觉，但点击后显示系统图标 sun.max.fill
                            circleIconButton(buttonIsSystem: false,
                                             buttonIcon: "icon_sun",
                                             tooltip: "阳光",
                                             actionIcon: "sun.max.fill",
                                             actionIsSystem: true) {}

                            // 雨水：显示系统符号 cloud.rain.fill
                            circleIconButton(buttonIsSystem: false,
                                             buttonIcon: "icon_rain",
                                             tooltip: "雨水",
                                             actionIcon: "cloud.rain.fill",
                                             actionIsSystem: true) {}
                        }

                        ZStack(alignment: .topTrailing) {
                            Image(plant.image)
                                .resizable()
                                .frame(width: 180, height: 220)
                                .shadow(radius: 4)

                            // 优先显示系统图标（如果 actionIconIsSystem == true）否则显示自定义 asset
                            if let _ = displayIconID {
                                if actionIconIsSystem, let sys = actionIconName {
                                    Image(systemName: sys)
                                        .font(.system(size: 38))
                                        .foregroundColor(PlantColor.green)
                                        .background(Color.white.opacity(0.0001))
                                        .transition(.scale.combined(with: .opacity))
                                } else if let asset = actionIconName {
                                    Image(asset)
                                        .resizable()
                                        .frame(width: 40, height: 40)
                                        .background(Color.white.opacity(0.0001))
                                        .transition(.scale.combined(with: .opacity))
                                }
                            }
                        }

                        VStack(spacing: 20) {
                            // 除虫：按钮视觉用资产 icon_spray，点击显示“药剂瓶”系统符号（vial.fill）
                            circleIconButton(buttonIsSystem: false,
                                             buttonIcon: "icon_spray",
                                             tooltip: "除虫",
                                             actionIcon: "icon_spray",
                                             actionIsSystem: false) {}

                            // 施肥：显示自定义临时图标（例如自定义 icon_fertilizer）
                            circleIconButton(buttonIsSystem: false,
                                             buttonIcon: "icon_fertilizer",
                                             tooltip: "施肥",
                                             actionIcon: "leaf.fill",
                                             actionIsSystem: true) {}

                            // 清洁：示例使用系统符号 sparkles
                            circleIconButton(buttonIsSystem: false,
                                             buttonIcon: "icon_clean",
                                             tooltip: "清洁",
                                             actionIcon: "sparkles",
                                             actionIsSystem: true) {}
                        }
                    }
                    // 使用 displayIconID 驱动动画值变化
                    .animation(.easeInOut, value: displayIconID)

                    // 培育进度
                    VStack(spacing: 6) {
                        Text("培育进度")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                        ProgressView(value: progress / 100.0)
                            .progressViewStyle(LinearProgressViewStyle(tint: PlantColor.green))
                            .frame(height: 6)
                            .background(Color.gray.opacity(0.3))
                            .cornerRadius(3)
                    }
                    .padding(.horizontal, 50)

                    // 植物切换栏
                    HStack {
                        Image("chevron_left_icon")
                            .renderingMode(.template)
                            .foregroundColor(PlantColor.green)
                        Spacer()
                        Text(plant.name)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(PlantColor.green)
                        Spacer()
                        Image("chevron_right_icon")
                            .renderingMode(.template)
                            .foregroundColor(PlantColor.green)
                    }
                    .padding(.horizontal, 12)
                    .frame(height: 36)
                    .background(Color.white)
                    .cornerRadius(18)
                    .overlay(RoundedRectangle(cornerRadius: 18).stroke(PlantColor.green, lineWidth: 1))
                    .padding(.horizontal, 40)

                    // 提示栏
                    HStack(spacing: 8) {
                        Image("warning_icon")
                            .resizable()
                            .frame(width: 20, height: 20)
                        Text("目前您的这株植物所需阳光还差5份噢！")
                            .font(.system(size: 14))
                            .foregroundColor(.white)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(PlantColor.green)
                    .cornerRadius(8)
                    .padding(.horizontal, 20)

                    // 控制卡片
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        controlCard(icon: "humidity_icon", title: "湿度控制", value: "\(Int(humidity))%RH",
                                    progress: $humidity, min: 0, max: 100)

                        controlCard(icon: "pest_icon", title: "虫害检查", value: "健康无害虫", isSlider: false)

                        controlCard(icon: "temp_icon", title: "温度控制", value: "\(Int(temperature))°C",
                                    progress: $temperature, min: 10, max: 40)

                        controlCard(icon: "light_icon", title: "光照控制", value: "\(Int(light))LUX",
                                    progress: $light, min: 10000, max: 20000)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationBarHidden(true)
    }
        
    }
    // 点击操作：显示指定图标（系统或自定义）3 秒消失，并增加进度 +5（上限100）
    private func performOperation(showIcon name: String, isSystem: Bool, extraAction: (() -> Void)? = nil) {
        extraAction?()
        progress = min(100, progress + 5)

        hideWorkItem?.cancel()

        withAnimation(.easeInOut) {
            actionIconName = name
            actionIconIsSystem = isSystem
        }

        let work = DispatchWorkItem {
            DispatchQueue.main.async {
                withAnimation(.easeInOut) {
                    self.actionIconName = nil
                }
            }
        }
        hideWorkItem = work
        DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: work)
    }

    // 圆形按钮：buttonIsSystem 控制按钮自身是否使用系统图标做视觉（否则使用 asset）
    private func circleIconButton(buttonIsSystem: Bool = false,
                                  buttonIcon: String,
                                  tooltip: String,
                                  actionIcon: String,
                                  actionIsSystem: Bool = false,
                                  extraAction: (() -> Void)? = nil) -> some View {
        Button(action: {
            performOperation(showIcon: actionIcon, isSystem: actionIsSystem, extraAction: extraAction)
        }) {
            ZStack {
                Circle().fill(Color.white).frame(width: 40, height: 40)
                if buttonIsSystem {
                    Image(systemName: buttonIcon)
                        .font(.system(size: 18))
                        .foregroundColor(PlantColor.green)
                        .frame(width: 20, height: 20)
                } else {
                    Image(buttonIcon)
                        .resizable()
                        .frame(width: 20, height: 20)
                }
            }
        }
        .accessibilityLabel(Text(tooltip))
    }

    // 控制卡片（保持不变）
    private func controlCard(icon: String, title: String, value: String,
                             progress: Binding<Double>? = nil,
                             min: Double = 0, max: Double = 100,
                             isSlider: Bool = true) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            ZStack {
                Circle().fill(PlantColor.green).frame(width: 40, height: 40)

                Image(icon)
                    .renderingMode(.template)
                    .resizable()
                    .frame(width: 40, height: 40)
                    .foregroundColor(.white)
            }

            HStack {
                Text(title)
                    .font(.system(size: 14))
                    .foregroundColor(.black)
                Spacer()
                Text(value)
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }

            if isSlider, let binding = progress {
                Slider(value: binding, in: min...max)
                    .accentColor(PlantColor.green)
            }else{
                Spacer()
            }
        }
        .padding()
        .frame(height: 137)
        .background(LinearGradient(colors: [Color(hex: "CCFFFF"), Color(hex: "FFFACD")],
                                   startPoint: .leading, endPoint: .trailing))
        .cornerRadius(12)
    }
}

    // 预览
struct CultivationInteractionPage_Previews: PreviewProvider {
    static var previews: some View {
        // 使用plants数组中的第一个植物作为预览数据
        CultivationInteractionPage(plant: plants.first!)
    }
}


