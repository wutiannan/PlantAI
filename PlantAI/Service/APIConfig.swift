import Foundation

struct APIConfig {
    // Configure QWEN_API_KEY locally in Xcode build settings.
    static let qwenVisionKey = Bundle.main.object(forInfoDictionaryKey: "QWEN_API_KEY") as? String ?? ""
}
