import SwiftUI

@ViewBuilder
func stepHeader(title: String, subtitle: String) -> some View {
    VStack(alignment: .leading, spacing: 4) {
        Text(title)
            .font(.title2)
            .fontWeight(.bold)

        Text(subtitle)
            .font(.subheadline)
            .foregroundStyle(.secondary)
    }
}
