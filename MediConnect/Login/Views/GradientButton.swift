import SwiftUI

struct GradientButton: View {
    
    var title: String
    var icon: String
    var onClick: () -> ()
    
    var body: some View {
        Button(action: onClick) {
            HStack(spacing: 15) {
                Text(title)
                Image(systemName: icon)
            }
            .fontWeight(.bold)
            .foregroundStyle(.black)
            .padding(.vertical, 12)
            .padding(.horizontal, 35)
            .background(.linearGradient(colors: [.appYellow, .appYellow, .gray], startPoint: .top, endPoint: .bottom), in: .capsule)
        }
    }
}
