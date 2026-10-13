import Foundation

class Plant: Identifiable, ObservableObject {
    let id = UUID()
    let name: String
    let enName: String
    let image: String
    let progress: Double
    let description: String
    let category: String
    @Published var isCollected: Bool
    @Published var isWishlist: Bool
    var isInCart: Bool
    let price: Double
    let cultivationDifficulty: String
    var difficulty: Int   // 难度等级，0~5

    
    init(
        name: String,
        enName: String,
        image: String,
        progress: Double,
        description: String,
        category: String,
        isCollected: Bool = false,
        isWishlist: Bool = false,
        isInCart: Bool = false,
        price: Double,
        cultivationDifficulty: String,
        difficulty: Int = 3
    ) {
        self.name = name
        self.enName = enName
        self.image = image
        self.progress = progress
        self.description = description
        self.category = category
        self.isCollected = isCollected
        self.isWishlist = isWishlist
        self.isInCart = isInCart
        self.price = price
        self.cultivationDifficulty = cultivationDifficulty
        self.difficulty = difficulty
    }
}

/// 植物列表数据
let plants: [Plant] = [
    Plant(
        name: "多肉",
        enName: "SUCCULENT",
        image: "plant_succulent",  
        progress: 0.8,
        description: "多肉植物也叫多浆植物，是指植物的根、茎、叶三种营养器官中叶是肥厚多汁并且具备储藏大量水分功能的植物。",
        category: "多肉",
//        isCollected: true,
        isWishlist: true,
        price: 100,
        cultivationDifficulty: "中等",
        difficulty: 1
    ),
    Plant(
        name: "菊花",
        enName: "CHRYSANTHEMUM",
        image: "plant_chrysanthemum",
        progress: 0.6,
        description: "菊花是中国十大传统名花、花中四君子之一，具有清寒傲雪的品格。",
        category: "鲜花",
//        isCollected: true,
        price: 100,
        cultivationDifficulty: "容易",
        difficulty: 1
    ),
    Plant(
        name: "捕蝇草",
        enName: "VENUS FLYTRAP",
        image: "plant_venus_flytrap",
        progress: 0.7,
        description: "捕蝇草是一种非常有趣的食虫植物，它的茎很短，在叶的顶端长有一个酷似“贝壳”的捕虫夹，且能分泌蜜汁。",
        category: "食虫植物",
        isCollected: true,
        price: 100,
        cultivationDifficulty: "困难",
        difficulty: 5
    ),
    Plant(
        name: "杜鹃",
        enName: "RHODODENDRON",
        image: "plant_rhododendron",
        progress: 0.5,
        description: "杜鹃花像会魔法的小喇叭！ 它的花瓣软软的、颜色超丰富，像彩虹落在枝头～",
        category: "鲜花",
        isCollected: true,
        price: 100,
        cultivationDifficulty: "中等",
        difficulty: 3
    ),
    Plant(
        name: "风铃草",
        enName: "CAMPANULA",
        image: "plant_campanula",
        progress: 0.9,
        description: "为桔梗科风铃草属的二年生草本植物，别名钟花、风铃花、挂钟草，花期4 - 6月，果期7 - 9月",
        category: "鲜花",
        isCollected: true,
        price: 100,
        cultivationDifficulty: "容易",
        difficulty: 1
    ),
    Plant(
        name: "蝴蝶兰",
        enName: "BUTTERFLY ORCHID",
        image: "plant_butterfly_orchid",
        progress: 0.7,
        description: "又名蝶兰，花期4—6月。蝴蝶兰希腊文的原意为“好似蝴蝶般的兰花”，花姿如蝴蝶飞舞得名。",
        category: "鲜花",
        isCollected: true,
        price: 100,
        cultivationDifficulty: "中等",
        difficulty: 3
    ),
    Plant(
        name: "栀子花",
        enName: "GARDENIA",
        image: "plant_gardenia",
        progress: 0.4,
        description: "茜草科、栀子属灌木植物，花芳香，单朵生于枝顶，花期3~7月，果期5月~翌年2月",
        category: "灌木",
        isCollected: true,
        price: 100,
        cultivationDifficulty: "容易",
        difficulty: 1
    ),
    Plant(
        name: "郁金香",
        enName: "TULIP",
        image: "plant_tulip",
        progress: 0.6,
        description: "百合科郁金香属多年生球根花卉，又名草麝香、旱荷花、洋荷花、洋水仙、郁香等花期4 - 5月",
        category: "鲜花",
        isCollected: true,
        price: 100,
        cultivationDifficulty: "中等",
        difficulty: 3
    ),
    Plant(
        name: "牡丹",
        enName: "PEONY",
        image: "plant_peony",
        progress: 0.8,
        description: "是芍药科、芍药属植物,花色泽艳丽，玉笑珠香，花期5月；果期6月",
        category: "鲜花",
        isCollected: true,
        price: 100,
        cultivationDifficulty: "困难",
        difficulty: 5
    ),
    Plant(
        name: "仙人掌",
        enName: "CACTUS",
        image: "plant_cactus",
        progress: 0.9,
        description: "仙人掌科仙人掌属草本植物，花碗状，黄色、花大明艳，花期集中在3—5月，果期在6—10月",
        category: "仙人掌类",
        isCollected: true,
        price: 100,
        cultivationDifficulty: "容易",
        difficulty: 1
    ),
    Plant(
        name: "鸢尾",
        enName: "IRIS",
        image: "plant_iris",
        progress: 0.5,
        description: "多年生草本植物，草质，边缘膜质，色淡，披针形或长卵圆形，花期4 - 5月，果期6 - 8月",
        category: "鲜花",
        isCollected: true,
        price: 100,
        cultivationDifficulty: "中等",
        difficulty: 3
    ),
    Plant(
        name: "含羞草",
        enName: "MIMOSA",
        image: "plant_mimosa",
        progress: 0.7,
        description: "豆科、含羞草属披散、亚灌木状草本植物，花期3 - 10月，果期5 - 11月",
        category: "灌木",
        isCollected: true,
        price: 100,
        cultivationDifficulty: "容易",
        difficulty: 1
    ),
    Plant(
        name: "草莓",
        enName: "STRAWBERRY",
        image: "plant_strawberry",
        progress: 0.0,
        description: "为蔷薇科草莓属多年生草本植物，小叶具短柄，倒卵形或菱形，叶柄密被开展黄色柔毛，花期4~5月，果期6~7月",
        category: "蔬菜",
        isCollected: true,
        price: 100,
        cultivationDifficulty: "中等",
        difficulty: 3
    )
]
