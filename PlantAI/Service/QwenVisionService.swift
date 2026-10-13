//
//  QwenVisionService.swift
//  PlantAI
//
//  Created by nanci on 2025/9/3.
//

import Foundation
import UIKit

struct PlantResult: Decodable {
    let name: String
    let intro: String
}

final class QwenVisionService {
    private let apiKey = APIConfig.qwenVisionKey
    private let endpoint = URL(string: "https://dashscope.aliyuncs.com/api/v1/services/aigc/multimodal-generation/generation")!
    private let model = "qwen-vl-plus"

    /// 识别图片，prompt 由前端传入
    func recognize(imageData: Data, prompt: String, completion: @escaping (Result<String, Error>) -> Void) {
        let jpegData: Data = (UIImage(data: imageData)?.jpegData(compressionQuality: 0.8)) ?? imageData
        let b64 = jpegData.base64EncodedString()

        // 用调用方传入的 prompt
        let body: [String: Any] = [
            "model": model,
            "input": [
                "messages": [[
                    "role": "user",
                    "content": [
                        ["image": "data:image/jpeg;base64,\(b64)"],
                        ["text": prompt]
                    ]
                ]]
            ],
            "parameters": [
                "result_format": "text",
                "max_tokens": 160
            ]
        ]

        var req = URLRequest(url: endpoint)
        req.httpMethod = "POST"
        req.addValue("application/json", forHTTPHeaderField: "Content-Type")
        req.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        req.httpBody = try? JSONSerialization.data(withJSONObject: body)

        if let bodyData = req.httpBody, let bodyStr = String(data: bodyData, encoding: .utf8) {
            print("➡️ QwenVisionService request JSON:\n\(bodyStr)")
        }

        URLSession.shared.dataTask(with: req) { data, _, err in
            if let err = err {
                print("❌ QwenVisionService error:", err.localizedDescription)
                completion(.failure(err)); return
            }
            guard let data = data else {
                let e = NSError(domain: "net", code: -1, userInfo: [NSLocalizedDescriptionKey: "无响应数据"])
                print("❌ QwenVisionService error:", e.localizedDescription)
                completion(.failure(e)); return
            }
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                let output = (json?["output"] as? [String: Any]) ?? [:]
                let choices = (output["choices"] as? [[String: Any]]) ?? []
                let msg = (choices.first?["message"] as? [String: Any]) ?? [:]
                let contents = (msg["content"] as? [[String: Any]]) ?? []
                let text = contents.compactMap { $0["text"] as? String }.joined()
                print("✅ QwenVisionService result:", text)
                completion(.success(text))
            } catch {
                print("❌ QwenVisionService parse error:", error.localizedDescription)
                completion(.failure(error))
            }
        }.resume()
    }
}
