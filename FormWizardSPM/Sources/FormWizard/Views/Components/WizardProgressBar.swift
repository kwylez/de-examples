import SwiftUI

struct WizardProgressBar: View {
    let currentStep: Int
    let totalSteps: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                ForEach(0..<totalSteps, id: \.self) { index in
                    Capsule()
                        .fill(index <= currentStep ? Color.accentColor : Color(.systemFill))
                        .frame(height: 4)
                        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: currentStep)
                }
            }

            Text("Step \(currentStep + 1) of \(totalSteps)")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}
