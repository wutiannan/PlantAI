import Foundation

class Peripheral: Identifiable, ObservableObject {
    let id = UUID()
    let name: String
    let image: String
    let price: Double
    var isLiked: Bool {
        didSet { objectWillChange.send() }
    }
    var isFullWidth: Bool {
        didSet { objectWillChange.send() }
    }
    
    init(
        name: String,
        image: String,
        price: Double,
        isLiked: Bool = false,
        isFullWidth: Bool = false
    ) {
        self.name = name
        self.image = image
        self.price = price
        self.isLiked = isLiked
        self.isFullWidth = isFullWidth
    }
}

let peripherals: [Peripheral] = [
    Peripheral(
        name: "植物种子",
        image: "peripheral_plant_seed",
        price: 200,
        isLiked:false
    ),
    Peripheral(
        name: "定制卡片",
        image: "peripheral_custom_card",
        price: 100,
        isLiked:false
    ),
    Peripheral(
        name: "植域周边玩偶",
        image: "peripheral_toy",
        price: 1800,
        isLiked:false,
        isFullWidth:true
    ),
    Peripheral(
        name: "文具",
        image: "peripheral_stationery",
        price: 200,
        isLiked:false
    ),
    Peripheral(
        name: "小台灯",
        image: "peripheral_lamp",
        price: 100,
        isLiked:false
    ),
]
