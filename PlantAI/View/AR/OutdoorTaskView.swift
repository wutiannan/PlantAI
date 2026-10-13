
import SwiftUI
import AVFoundation

struct OutdoorTaskView: View {
    @Environment(\.presentationMode) var presentationMode
    
    enum TaskState {
        case normal, exploring, recognized,failed
    }
    
    @State private var taskState: TaskState = .normal
    @State private var isInTaskRange = true
    @State private var goGestureSignInView = false
    
    @State private var camRunning = true
    @State private var zoom: CGFloat = 1.0
    @State private var cameraAccessGranted = false
    
    @State private var plantName = ""
    @State private var plantInfo = ""
    
    // 抓拍触发器与错误提示
    @State private var captureRequest: UUID? = nil
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var snapImage: UIImage?
    

    private let visionService = QwenVisionService()
    
    var body: some View {
        NavigationView{
            ZStack {
                // 背景图片
                Image("base_bg")
                    .resizable()
                    .ignoresSafeArea()
                
                VStack {
                    // 顶部导航
                    NavigationBar(title: "户外实地探索任务", onBack: {
                        presentationMode.wrappedValue.dismiss()
                    }, onMore: {})
                    ScrollView{
                        VStack(spacing: 16) {
                            // 识别态：通知条
                            if taskState == .recognized {
                                HStack(spacing: 8) {
                                    Image(systemName: "bell.fill")
                                        .foregroundColor(.white)
                                    Text("通知附近的小伙伴来此地集合打卡")
                                        .foregroundColor(.white)
                                        .font(.system(size: 14, weight: .semibold))
                                }
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(PlantColor.green)
                                .clipShape(Capsule())
                            }else{
                                Spacer().frame(height:20)
                            }
                            // 摄像头/提示
                            ZStack(alignment: .topLeading) {
                                // 取景框（AR 相机 测试时用Rectangle）
                                ARCameraView(
                                         zoom: $zoom,
                                         running: $camRunning,
                                         cameraAccessGranted: $cameraAccessGranted,
                                         captureRequest: $captureRequest,
                                         onPhotoCaptured: { data in
                                             uploadToQwen(imageData: data)
                                         }
                                     )
//                                Rectangle()
//                                    .fill(Color.gray.opacity(0.3))
                                    .frame(height: UIScreen.main.bounds.height * 0.6)
                                    .cornerRadius(30)
                                    .padding(.horizontal, 16)
                                    .overlay(alignment: .bottom) {
                        
                                        if taskState == .exploring {
                                            Image("magnifier").offset(y: 30)
                                            if let img = snapImage {
                                                Image(uiImage: img)
                                                    .resizable()
                                                    .scaledToFill()
                                                    .frame(width: 250, height: 250) 
                                                    .clipShape(Circle())
                                                    .padding()
                                            }
                                        }
                                        if taskState == .recognized {
                                            VStack{
                                                HStack(alignment: .center, spacing:20) {
                                                    DialogueBubble(
                                                        primaryText: bubbleText(for: taskState)
                                                    )
                                                    Image("charactor")
                                                        .resizable()
                                                        .frame(width: 140, height: 170)
                                                    Spacer()
                                                }
                                                .padding(.horizontal, 16)
                                                .offset(x:30,y:100)
                                                
                                                RecognizedResultOverlay(
                                                    title: plantName.isEmpty ? "蒲公英" : plantName,
                                                    description: plantInfo.isEmpty
                                                    ? "蒲公英是一种多年生草本植物，花开后会结成白色绒球，随风传播种子。全草可入药，有清热解毒的功效。"
                                                    : plantInfo,
                                                    previewImage: snapImage,
                                                    topSpacing: 100,
                                                    onPlay: {
                                                        // 播放/语音动作（可选）
                                                    }
                                                )
                                                .transition(.opacity)
                                            }
                                            
                                            
                                        }
                                    }
                                
                                // 小精灵 + 气泡覆盖在取景框上面
                                if taskState != .recognized {
                                    HStack(alignment: .center, spacing: 12) {
                                        Image("charactor")
                                            .resizable()
                                            .frame(width: 90, height: 110)
                                        
                                        DialogueBubble(
                                            primaryText: bubbleText(for: taskState)
                                        )
                                        Spacer()
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.top,-40)
                                }
                            }
                            
                            
                            // 底部按钮
                            bottomButtons
                            
                            // 状态提示条
                            BottomStatusBar(
                                text: statusText(for: taskState),
                                backgroundColor: PlantColor.cyan
                                )
                        }
                        
                    }
                    NavigationLink(destination: GestureSignInView(), isActive: $goGestureSignInView) {
                        EmptyView()
                    }
                }
            }
        }
        // 页面出现/消失时启动/停止相机
        .onAppear { camRunning = true }
        .onDisappear { camRunning = false }
        .navigationBarHidden(true)
        .alert(isPresented: $showError) {
             Alert(title: Text("提示"), message: Text(errorMessage), dismissButton: .default(Text("确定")))
         }
    }
    
    // MARK: - 底部按钮视图
    private var bottomButtons: some View {
        HStack(spacing: 60) {
            switch taskState {
            case .normal:
                CircleSolidButton(icon: "minus.circle.fill",fontWeight: .regular) {
                    guard cameraAccessGranted else {
                        errorMessage = "相机权限未开启，请在设置中允许访问相机。"
                        showError = true
                        return
                    }
                    zoom = max(1.0, zoom - 0.2)
                }
                CircleGradientButton(icon: "camera.viewfinder",fontWeight: .regular) {
                    guard cameraAccessGranted else {
                        errorMessage = "相机权限未开启，请在设置中允许访问相机。"
                        showError = true
                        return
                    }
                    taskState = .exploring
                    captureRequest = UUID() // 触发抓拍
                }
                CircleSolidButton(icon: "plus.circle.fill",fontWeight: .regular) {
                    guard cameraAccessGranted else {
                        errorMessage = "相机权限未开启，请在设置中允许访问相机。"
                        showError = true
                        return
                    }
                    zoom = min(8.0, zoom + 0.2)
                }
            case .exploring:
                CircleSolidButton(icon: "xmark.circle.fill", backgroundColor: .clear) {
                    taskState = .normal
                }
            case .failed:
                CircleSolidButton(icon: "arrow.counterclockwise") {
                    taskState = .normal
                }
            case .recognized:
                CircleSolidButton(icon: "arrowshape.turn.up.backward.fill", iconSize: 30) {
                    taskState = .normal
                    plantName = ""
                    plantInfo = ""
                    snapImage = nil
                }
                CircleSolidButton(icon: "circle.fill", backgroundColor: PlantColor.cyan) {
                    goGestureSignInView = true
                }
                CircleSolidButton(icon: "square.and.arrow.down", iconSize: 35) {
                    // 保存/下载逻辑
                }
            }
        }
        .offset(y: -45)
        .zIndex(1)
    }
    
    // MARK: - 状态栏文字
    private func statusText(for state: TaskState) -> String {
        switch state {
        case .normal:
            return "在任务点范围内"
        case .exploring:
            return "识别中，请稍后…"
        case .failed:
            return "没有识别到植物"
        case .recognized:
            return "识别成功！快去打卡吧"
        }
    }
    
    // MARK: - 对话内容
    private func bubbleText(for state: TaskState) -> String {
        switch state {
        case .normal:
            return "雪橇狗你太棒啦！这么快就找到了新植物，快快点击捕捉，看看会发生什么吧~"
        case .exploring:
            return "美好的结果值得耐心等待一下~快看看是不是我们要找的植物伙伴！"
        case .failed:
            return "对不起~没有发现植物噢…盆盆没办法为你科普~快去试试其他的！"
        case .recognized:
            return "哎呀呀，你眼神真好，被你发现啦！成功打卡后可以将植物放到培育房哦"
        }
    }
    
    // MARK: - 模拟识别
    private func simulatePlantRecognition() {
        taskState = .exploring
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            plantName = "蒲公英"
            plantInfo = "蒲公英是一种多年生草本植物，花开后会结成白色绒球，随风传播种子。全草可入药，有清热解毒的功效。"
            taskState = .recognized
        }
    }
    
    // MARK: - 千问识别图片 -植物识别
    private func uploadToQwen(imageData: Data) {
        self.snapImage = UIImage(data: imageData) // 预览用
        let prompt = """
        你是植物识别助手。请识别图片中的植物，并仅用一行中文输出，格式： 植物名，描述 示例：蒲公英，蒲公英是一种多年生草本植物，花开后会结成白色绒球，随风传播种子。全草可入药，有清热解毒的功效。
        如果没有识别到植物，请输出NO。
        """
        visionService.recognize(imageData: imageData, prompt: prompt) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let line): // 形如："植物名，描述"
                    let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
                    
                    // 如果输出里包含 NO，直接进入失败状态
                    if trimmed.uppercased().contains("NO") {
                        self.taskState = .failed
                        self.errorMessage = "未识别到植物"
                        self.showError = true
                        return
                    }
                    
                    let normalized = trimmed.replacingOccurrences(of: ",", with: "，")
                    let parts = normalized.split(separator: "，", maxSplits: 1, omittingEmptySubsequences: false)

                    let name = parts.first.map(String.init) ?? ""
                    let desc = parts.count > 1 ? String(parts[1]) : ""

                    self.plantName = name.isEmpty ? "未知植物" : name
                    self.plantInfo = desc.isEmpty ? "未获取到简介" : desc
                    self.taskState = .recognized

                case .failure(let err):
                    self.errorMessage = "识别失败：\(err.localizedDescription)"
                    self.showError = true
                    self.taskState = .failed
                }
            }
        }
    }


    // MARK: - 摄像头权限
//    private func checkCameraPermission() {
//        switch AVCaptureDevice.authorizationStatus(for: .video) {
//        case .authorized:
//            cameraAccessGranted = true
//        case .notDetermined:
//            AVCaptureDevice.requestAccess(for: .video) { granted in
//                DispatchQueue.main.async {
//                    cameraAccessGranted = granted
//                }
//            }
//        default:
//            cameraAccessGranted = false
//        }
//    }
    private struct RecognizedResultOverlay: View {
        let title: String
        let description: String
        let previewImage: UIImage?
        var topSpacing: CGFloat = 160
        var onPlay: (() -> Void)?
        var body: some View {
            let cardGradient = LinearGradient(colors: [PlantColor.green, PlantColor.cyan], startPoint: .leading, endPoint: .trailing)

            return VStack {
                Spacer().frame(height: topSpacing)

                VStack(spacing: 0) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 6)
                        .background(cardGradient)
                        .clipShape(Capsule())
                        .offset(y: 16)
                        .zIndex(1)

                    VStack(alignment: .leading, spacing: 12) {
                        HStack(alignment: .top, spacing: 12) {
                            Text(description)
                                .font(.system(size: 14))
                                .foregroundColor(.black)
                                .lineSpacing(4)
                                .offset(y: 16)

                            ZStack {
                                if let ui = previewImage {
                                     Image(uiImage: ui)
                                         .resizable()
                                         .scaledToFill()
                                         .frame(width: 120, height: 150)
                                         .clipShape(RoundedRectangle(cornerRadius: 12))
                                         .overlay(
                                             RoundedRectangle(cornerRadius: 12)
                                                 .stroke(cardGradient, lineWidth: 2)
                                         )
                                 } else {
                                     RoundedRectangle(cornerRadius: 12)
                                         .fill(Color.gray.opacity(0.2))
                                         .frame(width: 120, height: 150)
                                         .overlay(
                                             RoundedRectangle(cornerRadius: 12)
                                                 .stroke(cardGradient, lineWidth: 2)
                                         )
                                 }

//                                 中心聚焦：白心 + 渐变圆环
                                Image(systemName: "play.circle.fill")
                                    .font(.system(size: 36))
                                    .frame(width: 42, height: 42)
                                Image(systemName: "play.circle.fill")
                                    .font(.system(size: 36))
                                    .foregroundColor(PlantColor.green)
                            }
                        }
                    }
                    .padding(16)
                    .background(Color.white)
                    .overlay( // 卡片外框：渐变描边
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(cardGradient, lineWidth: 6)
                    )
                    .cornerRadius(14)
//                    .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 2)
                    .padding(.top, 0)
                    .padding(.horizontal, 16)
                }

                Spacer()
            }
        }
    }
}



struct OutdoorTaskView_Previews: PreviewProvider {
    static var previews: some View {
        OutdoorTaskView()
    }
}
