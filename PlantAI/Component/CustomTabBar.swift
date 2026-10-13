import SwiftUI

struct CustomTabBar: View {
    @State private var selected: Int
    
    init(initialSelected: Int = 0) {
        _selected = State(initialValue: initialSelected)
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 32)
                .fill(Color.white.opacity(0.7))
                .frame(width: 319, height: 64)
                .shadow(color: .gray.opacity(0.2), radius: 10)
            
            HStack(spacing: 60) {
                navBtn(0, "main_icon_home", "main_icon_home_active")
                navBtn(1, "main_icon_camera", "main_icon_camera_active")
                navBtn(2, "main_icon_plant", "main_icon_plant_active")
            }
        }
        .padding(.bottom, 10)
        .onChange(of: selected) { newValue in
            switch newValue {
            case 0:
                UIApplication.shared.windows.first?.rootViewController =
                    UIHostingController(rootView: HomePage())
            case 1:
                UIApplication.shared.windows.first?.rootViewController =
                    UIHostingController(rootView: OutdoorExploreMapView())
            case 2:
                UIApplication.shared.windows.first?.rootViewController =
                    UIHostingController(rootView: VirtualGardenPage())
            default:
                break
            }
        }
    }
    
    private func navBtn(_ idx: Int, _ normal: String, _ active: String) -> some View {
        Button { selected = idx } label: {
            Image(selected == idx ? active : normal)
                .frame(width: selected == idx ? 74 : 48,
                       height: selected == idx ? 74 : 48)
                .padding(.bottom, selected == idx ? 35 : 0)
        }
    }
}


// 用于预览
struct CustomTabBar_Previews: PreviewProvider {
    static var previews: some View {
        CustomTabBar(initialSelected: 0)
            .previewLayout(.sizeThatFits)
    }
}
