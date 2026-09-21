import FoundationModels
import SwiftUI

/// Explains why the on-device model can't be used right now.
///
/// Worth keeping in an example: `SystemLanguageModel` is unavailable in the Simulator and on
/// ineligible hardware, so this is the state you will see most often while developing.
struct ModelUnavailableView: View {
    let reason: SystemLanguageModel.Availability.UnavailableReason

    private var explanation: String {
        switch reason {
        case .deviceNotEligible:
            "This device doesn't support Apple Intelligence, so recipes can't be generated here."
        case .appleIntelligenceNotEnabled:
            "Turn on Apple Intelligence in Settings to generate recipes."
        case .modelNotReady:
            "The on-device model is still downloading. Try again shortly."
        @unknown default:
            "The on-device model isn't available right now."
        }
    }

    var body: some View {
        ContentUnavailableView(
            "Model Unavailable",
            systemImage: "exclamationmark.triangle",
            description: Text(explanation)
        )
    }
}

#Preview {
    ModelUnavailableView(reason: .deviceNotEligible)
}
