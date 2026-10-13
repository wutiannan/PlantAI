import SwiftUI
import AVFoundation

struct ARNavigationView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @StateObject private var mapManager = MapManager()
    @State private var goOutdoorTask = false
    //相机
    @State private var camRunning = true
    @State private var zoom: CGFloat = 1.0
    @State private var cameraAccessGranted = false
    @State private var isArrive = false //是否到达目的地

    
    var body: some View {
        NavigationView {
            ZStack {
                // 背景图片
                Image("base_bg")
                    .resizable()
                    .ignoresSafeArea()
                
                VStack {
                    NavigationBar(
                        title: "户外实地探索任务",
                        onBack: { presentationMode.wrappedValue.dismiss() },
                        onMore: { isArrive.toggle()}
                    )
////                                 模拟位置切换（测试环境用）
//                    Toggle(isOn: $mapManager.useMockLocation) {
//                        Text("使用模拟位置")
//                            .font(.system(size: 14))
//                            .foregroundColor(.black)
//                    }
//                    .padding(.horizontal, 16)
//                    .onChange(of: mapManager.useMockLocation) { newValue in
//                        mapManager.setUseMock(newValue)
//                    }

                    ScrollView {
                        VStack(spacing: 16) {
                            // 角色对话
                            if !isArrive{
                                HStack(spacing: 12) {
                                    Image("charactor_map")
                                        .resizable()
                                        .frame(width: 150, height: 140)
                                    
                                    DialogueBubble(
                                        primaryText: "雪橇狗，你选择的任务点有机会打卡到神秘植物，打卡成功将获取额外奖励哦！",
                                        secondaryText: "交友组队或亲子协作打卡更有惊喜掉落！"
                                    )
                                }
                                .padding(.horizontal, 16)
                            }else{
                                Spacer().frame(height:20)
                            }
       
                            // 摄像头/半圆地图/提示
                            ZStack(alignment: .topLeading) {
                                if !mapManager.useMockLocation && AVCaptureDevice.default(for: .video) != nil {
                                    ARCameraView(zoom: $zoom, running: $camRunning, cameraAccessGranted: $cameraAccessGranted)
                                        .cornerRadius(30)
                                        .frame(height: UIScreen.main.bounds.height * 0.6)
                                        .padding(.horizontal, 16)
                                } else {
                                    Rectangle()
                                        .fill(Color.gray.opacity(0.3))
                                        .cornerRadius(30)
                                        .frame(height: UIScreen.main.bounds.height * 0.6)
                                        .padding(.horizontal, 16)
                                        .overlay(
                                            Text(mapManager.useMockLocation ? "摄像头预览（模拟）" : "摄像头不可用")
                                                .foregroundColor(.white)
                                                .font(.title)
                                        )
                                       
                                }
                                
                                if isArrive {
                                    HStack(alignment: .center, spacing: 12) {
                                        Image("charactor")
                                            .resizable()
                                            .frame(width: 90, height: 110)
                                        
                                        DialogueBubble(
                                            primaryText: "我们到任务点啦！下方选择“放大镜”就可以开始你的探索咯，请注意是否在任务点范围内哦~"
                                        )
                                        Spacer()
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.top,-40)
                                }
                                
                            }
                            // 按钮
                            bottomButtons
                            // 状态提示条
                            Text("已到达任务点范围内")
                                .font(.system(size: 20))
                                .foregroundColor(.white)
                                .padding(12)
                                .frame(maxWidth: .infinity)
                                .background(PlantColor.cyan)
                                .cornerRadius(8)
                                .padding(.horizontal, 30)
                                .offset(y: -25)
                            

                        }
                    }
                }
                // 半圆地图
                if !isArrive, mapManager.currentCoordinate != nil {
                    VStack {
                        Spacer()
                        if let _ = mapManager.currentCoordinate {
                            MapNavigationView(mapManager: mapManager)
                                .frame(height: UIScreen.main.bounds.height * 0.3)
                                .mask(HalfCircle())
                                .padding(.horizontal, 16)
                                .overlay(
                                    HStack(spacing: 16) {
                                        Text(mapManager.totalDistanceText)
                                        Text(mapManager.remainingDistanceText)
                                    }
                                    .padding(8)
                                    .background(Color.green.opacity(0.7))
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                                    .padding(.horizontal, 32)
                                    .padding(.bottom, 16)
                                )
                        }
                    }
                    .ignoresSafeArea(edges: .bottom)
                    .transition(.move(edge: .bottom))
                    .animation(.easeInOut, value: !isArrive)
                }
                
                NavigationLink(destination: OutdoorTaskView(), isActive: $goOutdoorTask) {
                    EmptyView()
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            mapManager.setUseMock(false) // 进入页面就使用真实位置
            mapManager.startUpdating()    // 开始定位并更新路线
        }

    }
    // MARK: - 底部按钮视图
    private var bottomButtons: some View {
        HStack(spacing: 60) {
            CircleSolidButton(icon: "exclamationmark.triangle.fill",iconSize: 35) {
            }
            CircleGradientButton(icon: "magnifyingglass",iconSize: 35) {
                goOutdoorTask = true
            }
            CircleSolidButton(icon: "lightbulb.min.badge.exclamationmark") {
            }
        }
        .offset(y: -45)
        .zIndex(1)
    }
    private struct HalfCircle: Shape {
        func path(in rect: CGRect) -> Path {
            var path = Path()
            path.addArc(
                center: CGPoint(x: rect.midX, y: rect.maxY),
                radius: rect.height,
                startAngle: .degrees(180),
                endAngle: .degrees(0),
                clockwise: false
            )
            path.closeSubpath()
            return path
        }
    }
}

// 预览
struct ARNavigationView_Previews: PreviewProvider {
    static var previews: some View {
        ARNavigationView()
    }
}
