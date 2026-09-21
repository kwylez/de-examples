import SwiftUI

/// Shows the text the ``PantryBrief`` turned into, once there is a transcript to read.
///
/// A `Prompt` is opaque, so there is no way to print one before it is sent. Reading the prompt
/// entry back out of `LanguageModelSession.transcript` afterwards is the supported way to see
/// what your `PromptRepresentable` conformances actually produced.
struct PromptTranscriptSection: View {
    let transcript: String?

    var body: some View {
        if let transcript {
            Section("Prompt sent to the model") {
                Text(transcript)
                    .font(.footnote)
                    .textSelection(.enabled)
            }
        }
    }
}

#Preview {
    Form {
        PromptTranscriptSection(transcript: "Suggest one dinner recipe I can cook tonight.")
    }
}
