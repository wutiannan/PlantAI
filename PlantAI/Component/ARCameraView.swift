//
//  ARCameraView.swift
//  PlantAI
//
//  Created by nanci on 2025/8/31.
//

import SwiftUI
import AVFoundation
import UIKit

// 摄像头预览封装（修复：非单例会话，支持重复初始化）
struct ARCameraView: UIViewRepresentable {
    @Binding var zoom: CGFloat //缩放倍数
    @Binding var running: Bool //是否启动
    @Binding var cameraAccessGranted: Bool // 对外回传权限状态
    
    // 可选：抓拍能力（仅当使用带 capture 的 init 时才启用）
    private var captureRequest: Binding<UUID?>?
    private var onPhotoCaptured: ((Data) -> Void)?

    // 用于预览（不需要抓拍的地方使用这个 init）
    init(zoom: Binding<CGFloat>,
         running: Binding<Bool>,
         cameraAccessGranted: Binding<Bool>) {
        self._zoom = zoom
        self._running = running
        self._cameraAccessGranted = cameraAccessGranted
        self.captureRequest = nil
        self.onPhotoCaptured = nil
    }

    // 用于预览 + 抓拍（需要拍照的地方使用这个 init）
    init(zoom: Binding<CGFloat>,
         running: Binding<Bool>,
         cameraAccessGranted: Binding<Bool>,
         captureRequest: Binding<UUID?>,
         onPhotoCaptured: @escaping (Data) -> Void) {
        self._zoom = zoom
        self._running = running
        self._cameraAccessGranted = cameraAccessGranted
        self.captureRequest = captureRequest
        self.onPhotoCaptured = onPhotoCaptured
    }

    final class VideoPreviewView: UIView {
        override class var layerClass: AnyClass { AVCaptureVideoPreviewLayer.self }
        var previewLayer: AVCaptureVideoPreviewLayer { layer as! AVCaptureVideoPreviewLayer }
        override func layoutSubviews() {
            super.layoutSubviews()
            previewLayer.frame = bounds
            if let c = previewLayer.connection, c.isVideoOrientationSupported {
                c.videoOrientation = .portrait
            }
        }
    }

    final class Coordinator {
        let manager = CameraManager()
        let onAuthChanged: (Bool) -> Void
        var onPhotoCaptured: ((Data) -> Void)?
        var lastCaptureId: UUID?

        init(onAuthChanged: @escaping (Bool) -> Void,
             onPhotoCaptured: ((Data) -> Void)?) {
            self.onAuthChanged = onAuthChanged
            self.onPhotoCaptured = onPhotoCaptured
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(
            onAuthChanged: { granted in
                DispatchQueue.main.async { self.cameraAccessGranted = granted }
            },
            onPhotoCaptured: onPhotoCaptured
        )
    }

    func makeUIView(context: Context) -> VideoPreviewView {
        let v = VideoPreviewView()
        v.previewLayer.videoGravity = .resizeAspectFill
        v.previewLayer.session = context.coordinator.manager.session

        let status = AVCaptureDevice.authorizationStatus(for: .video)
        cameraAccessGranted = (status == .authorized)
        return v
    }

    func updateUIView(_ uiView: VideoPreviewView, context: Context) {
        // 启停与权限
        if running {
            context.coordinator.manager.authChanged = context.coordinator.onAuthChanged
            context.coordinator.manager.start()
        } else {
            context.coordinator.manager.stop()
        }

        // 变焦
        let minZ = context.coordinator.manager.minZoom
        let maxZ = context.coordinator.manager.maxZoom
        let clamped = min(max(zoom, minZ), maxZ)
        if clamped != zoom { zoom = clamped }
        context.coordinator.manager.setZoom(to: clamped, animated: true)

        // 可选：抓拍触发（仅当传入了 captureRequest 和回调时才处理）
        if let binding = captureRequest, let cb = context.coordinator.onPhotoCaptured {
            if let req = binding.wrappedValue, req != context.coordinator.lastCaptureId {
                context.coordinator.lastCaptureId = req
                context.coordinator.manager.capturePhoto { data in
                    if let data = data { cb(data) }
                    // 抓拍完成后清空触发器
                    DispatchQueue.main.async {
                        binding.wrappedValue = nil
                    }
                }
            }
        }
    }
    
    // 配置摄像头会话（输入：后置摄像头，输出：默认）
//    private func configureCameraSession() {
//        session.beginConfiguration() // 开始会话配置（原子操作）
//        session.sessionPreset = .high // 高画质预设
//        
//        // 获取后置摄像头
//        guard let backCamera = AVCaptureDevice.default(
//            .builtInWideAngleCamera,
//            for: .video,
//            position: .back
//        ) else {
//            print("错误：未检测到后置摄像头")
//            session.commitConfiguration()
//            return
//        }
//        
//        // 添加摄像头输入到会话
//        do {
//            let cameraInput = try AVCaptureDeviceInput(device: backCamera)
//            if session.canAddInput(cameraInput) {
//                session.addInput(cameraInput)
//            } else {
//                print("错误：无法添加摄像头输入")
//            }
//        } catch {
//            print("错误：创建摄像头输入失败 - \(error.localizedDescription)")
//        }
//        
//        session.commitConfiguration() // 提交会话配置
//    }
    
    // 检查权限并启动会话（子线程启动，避免阻塞UI）
//    private func startSessionIfAuthorized() {
//        switch AVCaptureDevice.authorizationStatus(for: .video) {
//        case .authorized:
//            DispatchQueue.global(qos: .userInitiated).async {
//                if !self.session.isRunning {
//                    self.session.startRunning()
//                }
//            }
//        case .notDetermined:
//            // 首次请求相机权限
//            AVCaptureDevice.requestAccess(for: .video) { granted in
//                if granted {
//                    DispatchQueue.global(qos: .userInitiated).async {
//                        self.session.startRunning()
//                    }
//                } else {
//                    print("提示：相机权限已被拒绝，请在设置中开启")
//                }
//            }
//        case .denied, .restricted:
//            print("提示：相机权限被拒绝（设置 > 隐私与安全性 > 相机）")
//        @unknown default:
//            break
//        }
//    }
    
}

final class CameraManager: NSObject {
    let session = AVCaptureSession()
    private var videoDeviceInput: AVCaptureDeviceInput!
    private(set) var videoDevice: AVCaptureDevice?
    private let rampRate: Float = 4.0
    
    private let photoOutput = AVCapturePhotoOutput()
    
    var authChanged: ((Bool) -> Void)?

    // 持有抓拍 delegate，避免提前释放
    private var inflightDelegates: [PhotoDelegate] = []

    override init() {
        super.init()
        configure()
    }
    /// - Parameter completion: 返回是否已授权
    public static func checkPermission(completion: @escaping (Bool) -> Void) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            completion(true)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    completion(granted)
                }
            }
        default:
            completion(false)
        }
    }
    
    private func configure() {
        session.beginConfiguration()
        session.sessionPreset = .photo

        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            print("无法获取摄像头设备")
            session.commitConfiguration()
            return
        }
        self.videoDevice = device

        do {
            videoDeviceInput = try AVCaptureDeviceInput(device: device)
            if session.canAddInput(videoDeviceInput) {
                session.addInput(videoDeviceInput)
            }
        } catch {
            print("配置摄像头输入失败: \(error.localizedDescription)")
        }

        if session.canAddOutput(photoOutput) {
            session.addOutput(photoOutput)
            photoOutput.isHighResolutionCaptureEnabled = true
        }

        session.commitConfiguration()
    }

    var minZoom: CGFloat { 1.0 }
    var maxZoom: CGFloat { min(videoDevice?.activeFormat.videoMaxZoomFactor ?? 1.0, 8.0) }

    func setZoom(to factor: CGFloat, animated: Bool) {
        guard let device = videoDevice else { return }
        let clamped = max(min(factor, maxZoom), minZoom)
        do {
            try device.lockForConfiguration()
            if animated {
                device.ramp(toVideoZoomFactor: clamped, withRate: rampRate)
            } else {
                device.videoZoomFactor = clamped
            }
            device.unlockForConfiguration()
        } catch {
            print("变焦失败: \(error.localizedDescription)")
        }
    }

    func start() {
        let startBlock = { [weak self] in
            guard let self = self else { return }
            if !self.session.isRunning {
                DispatchQueue.global(qos: .userInitiated).async {
                    self.session.startRunning()
                }
            }
        }
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            startBlock()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted { startBlock() } else {
                    self.authChanged?(false)
                    print("相机权限被拒绝")
                }
            }
        case .denied, .restricted:
            authChanged?(false)
            print("相机权限不可用（设置 > 隐私与安全性 > 相机）")
        @unknown default:
            authChanged?(false)
        }
    }

    func stop() {
        if session.isRunning {
            session.stopRunning()
        }
    }

    // 抓拍：修复闭包提前捕获问题
    func capturePhoto(completion: @escaping (Data?) -> Void) {
        let settings = AVCapturePhotoSettings()
        if videoDeviceInput?.device.isFlashAvailable == true {
            settings.flashMode = .auto
        }
        settings.isHighResolutionPhotoEnabled = true

        let delegate = PhotoDelegate(
            completion: { data in
                completion(data)
            },
            finished: { [weak self] delegate in
                guard let self = self else { return }
                if let idx = self.inflightDelegates.firstIndex(where: { $0 === delegate }) {
                    self.inflightDelegates.remove(at: idx)
                }
            }
        )
        inflightDelegates.append(delegate)
        photoOutput.capturePhoto(with: settings, delegate: delegate)
    }

    private final class PhotoDelegate: NSObject, AVCapturePhotoCaptureDelegate {
        let completion: (Data?) -> Void
        let finished: (PhotoDelegate) -> Void
        private var delivered = false

        init(completion: @escaping (Data?) -> Void,
             finished: @escaping (PhotoDelegate) -> Void) {
            self.completion = completion
            self.finished = finished
        }

        func photoOutput(_ output: AVCapturePhotoOutput,
                         didFinishProcessingPhoto photo: AVCapturePhoto,
                         error: Error?) {
            guard !delivered else { return }
            delivered = true

            if let error = error {
                print("拍照失败: \(error.localizedDescription)")
                completion(nil)
                return
            }
            if let data = photo.fileDataRepresentation() {
                completion(data)
            } else {
                completion(nil)
            }
        }

        func photoOutput(_ output: AVCapturePhotoOutput,
                         didFinishCaptureFor resolvedSettings: AVCaptureResolvedPhotoSettings,
                         error: Error?) {
            finished(self)
        }
    }
}
