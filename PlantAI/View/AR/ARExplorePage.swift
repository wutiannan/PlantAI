//
//  ARExplorePage.swift
//  PlantAI
//
//  Created by nanci on 2025/7/17.
//
// 此页面暂时废弃
import SwiftUI
import UIKit

struct ARExplorePage: View {
    var body: some View {
        NavigationView {
            ZStack {
                // 背景图片
                Image("main_bg")
                    .resizable()
                    .edgesIgnoringSafeArea(.all)
                    .allowsHitTesting(false) // 避免遮挡子视图点击
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // 顶部栏：菜单 + 头像
                        HStack(spacing: 16) {
                            Button(action: {
                                // 菜单按钮逻辑
                            }) {
                                Image("main_icon_menu")
                                    .resizable()
                                    .frame(width: 24, height: 24)
                            }
                            
                            TextField("搜索感兴趣的探索任务", text: .constant(""))
                                .padding(.horizontal, 12)
                                .frame(height: 40)
                                .background(Color.white)
                                .cornerRadius(8)
                                .shadow(color: Color.gray.opacity(0.1), radius: 4, x: 0, y: 2)
                            
                            Image("avatar")
                                .resizable()
                                .frame(width: 40, height: 40)
                                .clipShape(Circle())
                        }
                        .padding(.top, -20)
                        
                        // 标题区域
                        VStack(alignment: .leading, spacing: 8) {
                            Text("快来选择你的探索任务吧！")
                                .font(.system(size: 24, weight: .medium))
                                .foregroundColor(.black)
                            
                            Text("今日运动量为360kcal")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                        }
                        
                        // 虚拟主题探索乐园
                        Text("虚拟主题探索乐园")
                            .font(.system(size: 16))
                        
                        VStack(spacing: 12) {
                            HStack(spacing: 12) {
                                virtualCard(imagePath: "explore_jurassic", title: "侏罗纪植物大冒险")
                                virtualCard(imagePath: "explore_travel", title: "穿越时空的植物朋友")
                            }
                            
                            // 从竖屏页以 push/present 的方式展示 PlantLab（横屏全屏）
                            Button(action: {
                                presentPlantLab()
                            }) {
                                virtualCard(imagePath: "explore_lab", title: "小小植物科学家实验室", isFullWidth: true)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        
                        // 户外实地探索任务
                        Text("户外实地探索任务")
                            .font(.system(size: 16))
                        
                        HStack(spacing: 12) {
                            // 使用 NavigationLink 包裹任务卡片
                            NavigationLink(destination: TodoTaskPage()) {
                                taskCard(imagePath: "explore_todo_bg", title: "计划任务")
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            NavigationLink(destination: OutdoorExploreMapView()) {
                                taskCard(imagePath: "explore_nearby_bg", title: "附近推荐任务")
                            }
                            
                            NavigationLink(destination: InvitedTaskPage()) {
                                taskCard(imagePath: "explore_invited_bg", title: "受邀任务")
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 24)
                }
            }
            .navigationBarHidden(true)
        }
    }
    
    // 构建虚拟主题探索乐园卡片
    func virtualCard(imagePath: String, title: String, isFullWidth: Bool = false) -> some View {
        ZStack(alignment: .bottom) {
            Image(imagePath)
                .resizable()
                .frame(height: isFullWidth ? 160 : 120)
                .cornerRadius(12)
            
            Rectangle()
                .fill(Color(red: 70/255, green: 215/255, blue: 231/255).opacity(0.85))
                .frame(height: 38)
                .cornerRadius(12, corners: [.bottomLeft, .bottomRight])
            
            Text(title)
                .foregroundColor(.white)
                .font(.system(size: 14))
                .padding(.bottom, 12)
        }
        .frame(maxWidth: isFullWidth ? .infinity : nil)
        .shadow(color: Color.gray.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    // 重构为普通视图组件（不再接收 action 参数）
    func taskCard(imagePath: String, title: String) -> some View {
        ZStack(alignment: .bottom) {
            Image(imagePath)
                .resizable()
                .scaledToFill() // 确保图片填充整个区域
                .frame(height: 167)
                .clipped() // 裁剪超出部分
                .cornerRadius(12)
            
            VStack {
                Spacer()
                Text(title)
                    .foregroundColor(.white)
                    .font(.system(size: 14))
            }
            .padding(12)
        }
        .frame(maxWidth: .infinity) // 确保卡片占满可用宽度
    }
}

// 定义各个目标页面
struct OutdoorExplorePage: View {
    var body: some View {
        Text("户外探索页面")
            .navigationTitle("附近推荐任务")
            .navigationBarTitleDisplayMode(.inline)
    }
}

struct TodoTaskPage: View {
    var body: some View {
        Text("计划任务页面")
            .navigationTitle("计划任务")
            .navigationBarTitleDisplayMode(.inline)
    }
}

struct InvitedTaskPage: View {
    var body: some View {
        Text("受邀任务页面")
            .navigationTitle("受邀任务")
            .navigationBarTitleDisplayMode(.inline)
    }
}

// ---------- 以下为本文件内新增的辅助类 / 函数，便于 push/present PlantLabView 为横屏 ----------

extension UIApplication {
    func topMostViewController() -> UIViewController? {
        let scenes = self.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .filter { $0.activationState == .foregroundActive }
        guard let windowScene = scenes.first,
              let window = windowScene.windows.first(where: { $0.isKeyWindow }) else {
            return self.keyWindow?.rootViewController
        }

        var top = window.rootViewController
        while let presented = top?.presentedViewController {
            top = presented
        }
        return top
    }
}

// 一个支持横屏的 UIHostingController 子类（承载 PlantLabView）
// 当用户点击系统返回（pop）或该控制器被 dismiss 时，viewWillDisappear 会恢复为竖屏
class LandscapeHostingController<Content: View>: UIHostingController<Content> {
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscapeRight // 或 .landscape
    }

    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .landscapeRight
    }

    override var shouldAutorotate: Bool { true }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // 恢复为竖屏
        UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
        UIViewController.attemptRotationToDeviceOrientation()
    }
}

// present/push 的包装函数（在本文件内）
func presentPlantLab() {
    // 包装 PlantLabView 到只支持横屏的 hosting controller
    let host = LandscapeHostingController(rootView: PlantLabView())
    host.modalPresentationStyle = .fullScreen

    // 强制旋转到横屏（尝试使系统切换方向）
    UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue, forKey: "orientation")
    UIViewController.attemptRotationToDeviceOrientation()

    guard let top = UIApplication.shared.topMostViewController() else {
        print("presentPlantLab: 无法找到顶层控制器")
        return
    }

    // 优先尝试 push 到 navigationController（显示系统 Back）
    if let nav = top as? UINavigationController {
        nav.pushViewController(host, animated: true)
    } else if let nav = top.navigationController {
        nav.pushViewController(host, animated: true)
    } else {
        // fallback：modal present（fullScreen）
        top.present(host, animated: true, completion: nil)
    }
}


#Preview {
    ARExplorePage()
}
