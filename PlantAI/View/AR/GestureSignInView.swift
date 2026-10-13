import SwiftUI
import AVFoundation

struct GestureSignInView: View {
    @Environment(\.presentationMode) var presentationMode
    
    enum GestureState {
        case normal, shooting, success, failed, finished
    }

    @State private var captureRequest: UUID? = nil
    @State private var snapImage: UIImage?
    @State private var errorMessage = ""
    @State private var showError = false

    @State private var gestureState: GestureState = .normal

    @State private var camRunning = true
    @State private var zoom: CGFloat = 1.0
    @State private var cameraAccessGranted = false
    
    @State private var plantCount: Int = 8
    @State private var totalPlants: Int = 30
    
    @State private var goNurseryRoom = false

    
    var body: some View {
        NavigationStack{
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
                        VStack(spacing: 16){
                            if gestureState == .success || gestureState == .finished {
                                HStack(spacing: 12) {
                                    NavigationLink(destination: HomePage()) {
                                        ActionButton(title: "回到主页", style: .left)
                                    }
                                    
                                    Spacer()
                                    
                                    ActionButton(title: "查看记录", style: .right)
                                    
                                }
                            }else{
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
                            }

                            // 取景框
                            ZStack(alignment: .bottomLeading)  {
//                                 取景框（AR 相机 测试时用Rectangle）
                                    ARCameraView(
                                        zoom: $zoom,
                                        running: $camRunning,
                                        cameraAccessGranted: $cameraAccessGranted,
                                        captureRequest: $captureRequest,
                                        onPhotoCaptured: { data in
                                            snapImage = UIImage(data: data)
                                            recognizeGesture(imageData: data)
                                        }
                                    )
//                                Rectangle()
//                                    .fill(Color.gray.opacity(0.3))
                                    .frame(height: UIScreen.main.bounds.height * 0.6)
                                    .cornerRadius(30)
                                    .padding(.horizontal, 16)
                                    .overlay(alignment:.center){
                                        if gestureState == .shooting {
                                            if let img = snapImage {
                                                Image(uiImage: img)
                                                    .resizable()
                                                    .scaledToFill()
                                                    .frame(width: 250, height: 250) 
                                                    .clipShape(Circle())
                                                    .padding()
                                            }
                                        }
                                        if gestureState == .normal {
                                            VStack{
                                                HStack {
                                                    Spacer() // 左边占位，推动手势图到右边
                                                    Image("gesture_hint")
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(width: 300, height: 300, alignment: .topTrailing)
                                                }
                                                Spacer()
                                            }
                                            
                                        }else if gestureState == .shooting {
                                            ProgressView("正在识别，请稍候…")
                                                .progressViewStyle(CircularProgressViewStyle(tint: PlantColor.cyan))
                                                .font(.system(size: 16, weight: .semibold))
                                        } else if gestureState == .success {
                                            VStack {
                                                ZStack {
                                                    Circle()
                                                        .fill(PlantColor.green)
                                                        .frame(width: 96, height: 96) // 控制圆的大小
                                                    
                                                    Text("打卡成功")
                                                        .font(.system(size: 20, weight: .bold))
                                                        .foregroundColor(.white)
                                                }
                                                
                                                RewardPanel()
                                                    .padding(.top, 20)
                                            }
                                        }
                                    }
                                HStack(alignment: .top, spacing: 0) {
                                    Image("charactor")
                                        .resizable()
                                        .frame(width: 156, height: 200)
                                    let texts = bubbleTexts(for: gestureState)
                                    DialogueBubble(
                                        primaryText: texts.0,
                                        secondaryText: texts.1
                                    )
                                }
                                .padding(.horizontal, 16)
                                .padding(.bottom,-60)
                            }
                            //底部按钮
                            bottomButtons
                            // 状态提示条
                            BottomStatusBar(
                                text: statusText(for: gestureState),
                                //                            backgroundColor: statusColor(for: gestureState)
                                backgroundColor: PlantColor.green
                                
                            )
                        }
                    }
                }
                NavigationLink(
                    destination: NurseryRoomPage(),
                    isActive: $goNurseryRoom
                ) {
                    EmptyView()
                }
                .hidden()
            }
        }

        .navigationBarHidden(true)
    }
    // MARK: - 底部按钮视图
    private var bottomButtons: some View {
        HStack(spacing: 60) {
            switch gestureState {
            case .normal:
                CircleSolidButton(icon: "circle.fill", backgroundColor: PlantColor.cyan) {
//                    guard cameraAccessGranted else {
//                        errorMessage = "相机权限未开启，请在设置中允许访问相机。"
//                        showError = true
//                        return
//                    }
                    gestureState = .shooting
                    captureRequest = UUID() // 触发抓拍
                }
            case .shooting:
                HStack(spacing: 65) {
                    Spacer().frame(height:50)
                }
            case .success:
                Spacer().frame(width:60)
                Spacer().frame(width:60)
                CircleSolidButton(icon: "square.and.arrow.down", iconSize: 35, backgroundColor: PlantColor.cyan) {
                    gestureState = .finished
                }
            case .failed:
                CircleSolidButton(icon: "arrow.counterclockwise", backgroundColor: PlantColor.cyan) {
                    gestureState = .normal
                }
            case .finished:
                Spacer().frame(width:60)
                Spacer().frame(width:60)
                CircleSolidButton(icon: "play.fill", iconSize: 35, backgroundColor: PlantColor.cyan) {
                    goNurseryRoom = true
                }
            }
        }
        .offset(y: -45)
        .zIndex(1)
    }
    
    // MARK: - 状态栏文字
    private func statusText(for state: GestureState) -> String {
        switch state {
        case .normal:
            return "点击进行打卡拍照"
        case .shooting:
            return "识别中，请稍后…"
        case .success:
            return "这是你打卡的第8种植物！距离“探索达人”还差22种，继续加油吧！"
        case .failed:
            return "识别失败，请重试"
        case .finished:
            return "已存入探索记录，可以在探索记录处看到打卡照片"
        }
    }
    
    // MARK: - 状态栏颜色
//    private func statusColor(for state: GestureState) -> Color {
//        switch state {
//        case .normal:
//            return PlantColor.green
//        case .shooting:
//            return PlantColor.cyan
//        case .success:
//            return PlantColor.green
//        }
//    }
    
    // MARK: - 气泡文案
    private func bubbleTexts(for state: GestureState) -> (String, String) {
        switch state {
        case .normal:
            return (
                "请根据上方提示打卡手势进行拍照打卡！",
                "手势不准确有可能造成打卡失败噢~"
            )
        case .shooting:
            return (
                "检测中……保持手势不要动！",
                "很快就能完成识别了"
            )
        case .success:
            return (
                "奖励只能选择2个哦！",
                "想要更多奖励，请继续寻找更多植物吧"
            )
        case .failed:
            return (
                "没有识别到正确手势哦",
                "不要气馁，再来一次吧"
            )
        case .finished:
            return (
                "点击跳转培育房……",
                "选择的植物奖励已经存入培育房"
            )
        }
    }

//    private func simulateRecognition() {
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
//            gestureState = .success
//        }
//    }
    private func recognizeGesture(imageData: Data) {
        let prompt = """
        你是手势识别助手。请识别图中的手势，如果是“✌️”手势，回答 YES，否则回答 NO。一定要看清楚，是只有食指和中指伸出，其他手指弯曲
        """
        let visionService = QwenVisionService()
        visionService.recognize(imageData: imageData, prompt: prompt) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let text):
                    if text.uppercased().contains("YES") {
                        gestureState = .success
                    } else {
                        gestureState = .failed
                    }
                case .failure(let err):
                    errorMessage = "识别失败：\(err.localizedDescription)"
                    showError = true
                    gestureState = .failed
                }
            }
        }
    }

}

// MARK: - Segment                               
private struct SegmentButton: View {
    let title: String
    let isSelected: Bool
    
    var body: some View {
        Text(title)
            .font(.system(size: 14, weight: .medium))
            .foregroundColor(isSelected ? .white : .black)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(isSelected ? PlantColor.green : Color.gray.opacity(0.2))
            .cornerRadius(6)
    }
}


// MARK: - 奖励面板
private struct RewardPanel: View {
    var body: some View {
        // 奖励选择面板
        VStack(spacing: 12) {
            Text("选择奖励")
                .font(.system(size: 16))
                .foregroundColor(.white)
            
            HStack(spacing: 20) {
                RewardItem(icon: "gift.fill", title: "随机礼包")
                RewardItem(icon: "drop.fill", title: "水滴养分")
                RewardItem(icon: "leaf.fill", title: "肥料养份")
            }
        }
        .padding()
        .background(LinearGradient(
            colors: [PlantColor.cyan, PlantColor.green],
            startPoint: .leading,
            endPoint: .trailing
        ))
        .cornerRadius(14)
    }
}

private struct RewardItem: View {
    let icon: String
    let title: String
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 26))
                .foregroundColor(PlantColor.cyan)
                .frame(width: 60, height: 60)
                .background(Color.white)
                .overlay(
                    Circle().stroke(PlantColor.cyan, lineWidth: 2)
                )
                .clipShape(Circle())
            
            Text(title)
                .font(.system(size: 14))
                .foregroundColor(.white)
        }
    }
}



struct GestureSignInView_Previews: PreviewProvider {
    static var previews: some View {
        GestureSignInView()
    }
}
