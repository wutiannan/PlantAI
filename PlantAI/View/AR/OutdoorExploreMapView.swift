import SwiftUI
import MapKit

struct OutdoorExploreMapView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var region = MKCoordinateRegion(
    center: CLLocationCoordinate2D(latitude: 30.32, longitude: 120.07),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    @State private var searchText = ""
    @State private var selectedTask: TaskPoint?
    @State private var navigateToAR = false // 用于 NavigationLink push
    @State private var mapType: MKMapType = .standard
    @State private var userTrackingMode: MapUserTrackingMode = .none

    let taskPoints = [
        TaskPoint(
            id: UUID(),
            coordinate: CLLocationCoordinate2D(latitude: 30.32, longitude: 120.07),
            distance: 0.5,
            plants: ["法国梧桐", "睡莲"],
            hint: "这里可能掉落神秘礼品噢！",
            totalDistance: "2.6km",
            totalTime: "1.8h",
            collectedPlants: 7
        )
    ]

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                // 背景图
                Image("main_bg")
                    .resizable()
                    .edgesIgnoringSafeArea(.all)
                    .allowsHitTesting(false) // 避免遮挡子视图点击

                // 地图
                Map(
                    coordinateRegion: $region,
                    interactionModes: .all,
                    showsUserLocation: true,
                    userTrackingMode: $userTrackingMode,
                    annotationItems: taskPoints
                ) { point in
                    MapAnnotation(coordinate: point.coordinate) {
                        Button(action: {
                            selectedTask = point
                        }) {
                            Circle()
                                .fill(PlantColor.cyan)
                                .frame(width: 16, height: 16)
                        }
                    }
                }
                .edgesIgnoringSafeArea(.all)
                .padding(.top, 120)

                // 顶部UI：标题 + 搜索
                VStack(alignment: .leading,spacing: 8) {

                    // 顶部栏：菜单 + 头像
                    TopBar()

                    WelcomeText(
                        title: "户外实地探索任务",
                        subtitle: "今日运动量为360kcal"
                    )
                    .padding(.horizontal, 16)

//                    HStack {
//                        TextField("搜索你想去的位置查看是否有任务点", text: $searchText)
//                            .padding(.vertical, 10)
//                            .padding(.leading, 12)
//                            .background(Color.white.opacity(0.9))
//                            .cornerRadius(20)
//                            .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.gray.opacity(0.3), lineWidth: 1))
//                            .foregroundColor(.black)
//
//                        Image(systemName: "magnifyingglass")
//                            .foregroundColor(.green)
//                            .padding(12)
//                            .background(Color.white.opacity(0.9))
//                            .cornerRadius(20)
//                            .padding(.trailing, 16)
//                    }
//                    .padding(.horizontal, 16)
                }

                // 统计信息栏
                HStack(alignment: .center, spacing: 16) {
                    infoItem(title: "总路程", value: taskPoints.first?.totalDistance ?? "2.6km")
                    infoItem(title: "总时长", value: taskPoints.first?.totalTime ?? "1.8h")
                    infoItem(title: "收集植物", value: "\(taskPoints.first?.collectedPlants ?? 7)种")
                }
                .padding(12)
                .background(Color.white.opacity(0.9))
                .cornerRadius(16)
                .shadow(radius: 5)
                .padding(.horizontal, 16)
                .padding(.top, 150)

                // 如果选中任务，显示弹窗（使用 GeometryReader 定位到屏幕中间偏上一点）
                if let task = selectedTask {
                    GeometryReader { geo in
                        let x = geo.size.width * 0.5
                        let yMultiplier: CGFloat = 0.40 // 可调：越小越靠上，0.5 为正中
                        let y = geo.size.height * yMultiplier

                        taskPopup(task: task)
                            .frame(width: 320)
                            .position(x: x, y: y)
                            .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 4)
                            .transition(.scale.combined(with: .opacity))
                    }
                    .ignoresSafeArea()
                }

                // 右下角三个浮动按钮
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        VStack(spacing: 16) {
                            Button(action: toggleMapType) {
                                Image(systemName: mapType == .standard ? "map" : "map.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(PlantColor.green)
                                    .padding(12)
                                    .background(Color.white)
                                    .cornerRadius(28)
                                    .shadow(radius: 3)
                            }

                            Button(action: locateUser) {
                                Image(systemName: "location.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(PlantColor.green)
                                    .padding(12)
                                    .background(Color.white)
                                    .cornerRadius(28)
                                    .shadow(radius: 3)
                            }

                            Button(action: { /* 扫描逻辑 */ }) {
                                Image(systemName: "scope")
                                    .font(.system(size: 24))
                                    .foregroundColor(PlantColor.green)
                                    .padding(12)
                                    .background(Color.white)
                                    .cornerRadius(28)
                                    .shadow(radius: 3)
                            }
                        }
                        .padding(.bottom, 30)
                        .padding(.trailing, 16)
                    }
                }

                // 隐藏的 NavigationLink，用于 push 到 ARNavigationView
                NavigationLink(destination: ARNavigationView(), isActive: $navigateToAR) {
                    EmptyView()
                }
            }
            .navigationBarHidden(true)
            .safeAreaInset(edge: .bottom) {
                     CustomTabBar(initialSelected: 1)
            }
        }
    }

    // 统计信息项
    private func infoItem(title: String, value: String) -> some View {
        VStack(alignment: .center, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.black)
        }
        .frame(width: 80)
    }

    // 弹窗内容（绿色外框 + 白色内层）
    private func taskPopup(task: TaskPoint) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            // 顶部植物缩略图 + 更多
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(task.plants, id: \.self) { plant in
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.gray.opacity(0.08))
                                .frame(width: 60, height: 60)
                            Image(systemName: "leaf.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 36, height: 36)
                                .foregroundColor(PlantColor.green)
                        }
                    }
                    Button(action: { /* 更多植物 */ }) {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(PlantColor.green.opacity(0.12))
                            .frame(width: 60, height: 60)
                            .overlay(Image(systemName: "questionmark").foregroundColor(PlantColor.green))
                    }
                }
                .padding(.horizontal, 6)
                .padding(.top, 6)
            }

            // 分页点
            HStack(spacing: 6) {
                Spacer()
                Circle().fill(Color.gray.opacity(0.4)).frame(width: 6, height: 6)
                Circle().fill(PlantColor.green).frame(width: 8, height: 8)
                Circle().fill(Color.gray.opacity(0.4)).frame(width: 6, height: 6)
                Spacer()
            }
            .padding(.top, -6)

            // 提示文本
            Text(task.hint)
                .font(.subheadline)
                .foregroundColor(.black)
                .padding(EdgeInsets(top: 8, leading: 10, bottom: 8, trailing: 10))
                .background(PlantColor.green.opacity(0.08))
                .cornerRadius(6)

            Divider().background(Color.gray.opacity(0.2))

            // 距离 + 导航按钮（点击 push）
            HStack {
                Text("距离当前位置：\(String(format: "%.1f", task.distance))km")
                    .font(.subheadline)
                    .foregroundColor(.black)

                Spacer()

                Button(action: {
                    // 触发 push 到 ARNavigationView
                    navigateToAR = true
                }) {
                    HStack(spacing: 8) {
                        ZStack {
                            Circle()
                                .fill(PlantColor.green)
                                .frame(width: 36, height: 36)
                            Image(systemName: "arrowtriangle.up.fill")
                                .font(.system(size: 14))
                                .foregroundColor(.white)
                        }
                        Text("导航")
                            .foregroundColor(.black)
                            .font(.subheadline)
                    }
                    .padding(.vertical, 6)
                    .padding(.horizontal, 8)
                }
            }
        }
        .padding(12)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 18).fill(PlantColor.green) // 绿色边框层
                RoundedRectangle(cornerRadius: 14).fill(Color.white).padding(6) // 白色内层，padding 控制边框厚度
            }
        )
        .cornerRadius(18)
    }

    // 控件功能
    private func toggleMapType() {
        mapType = mapType == .standard ? .hybrid : .standard
    }

    private func locateUser() {
        userTrackingMode = .follow
    }
}

    struct TaskPoint: Identifiable {
        let id: UUID
        let coordinate: CLLocationCoordinate2D
        let distance: CLLocationDistance
        let plants: [String]
        let hint: String
        let totalDistance: String
        let totalTime: String
        let collectedPlants: Int
    }

struct OutdoorExploreMapView_Previews: PreviewProvider {
    static var previews: some View {
        OutdoorExploreMapView()
    }
}
