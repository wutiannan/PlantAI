import Foundation

class Garden: Identifiable, ObservableObject {
    let id = UUID()
    let name: String
    let image: String
    let description: String
    let price: Double
    var isLiked: Bool {
        didSet { objectWillChange.send() }
    }
    var isInCart: Bool {
        didSet { objectWillChange.send() }
    }
    
    init(
        name: String,
        image: String,
        description: String,
        price: Double,
        isLiked: Bool = false,
        isInCart: Bool = false
    ) {
        self.name = name
        self.image = image
        self.description = description
        self.price = price
        self.isLiked = isLiked
        self.isInCart = isInCart
    }
}

let gardens: [Garden] = [
    Garden(
        name: "海边花园",
        image: "garden_seaside",
        description: "玩家将探索一片生机盎然的海边花园。这里四季如春，繁花似锦，蝴蝶翩翩起舞，海浪轻拍岸边，带来阵阵清凉。",
        price: 500,
        isLiked: false,
        isInCart: false,
        
    ),
    Garden(
        name: "悬浮岛屿",
        image: "garden_floating_island",
        description: "悬浮岛屿是一片神秘的天地。岛屿漂浮在云端之上，四周环绕着绚丽的极光和流动的星河。",
        price: 800,
        isLiked: false,
        isInCart: false,
    ),
    Garden(
        name: "星空花园",
        image: "garden_starlit_sky",
        description: "星空花园是一片神秘而美丽的场景。这里繁星点点，银河如练，各种奇异的植物在星光下生长，绽放出梦幻般的光彩。",
        price: 800,
        isLiked: false,
        isInCart: false,
    ),
    Garden(
        name: "欧式花园",
        image: "garden_european",
        description: "欧式花园场景以其精致典雅著称。这里绿树成荫，花香四溢，喷泉潺潺，雕塑点缀其间，仿佛步入了一个童话世界。",
        price: 800,
        isLiked: false,
        isInCart: false,
    )
]
