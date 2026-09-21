import FoundationModels

extension Transcript {
    /// The text of the most recent prompt in this transcript, if there is one.
    ///
    /// A `Prompt` is opaque — there is no way to print one before it is sent. Reading it back out
    /// of the transcript afterwards is the supported way to see what a `PromptRepresentable`
    /// conformance actually produced, which makes it a useful thing to keep on screen while you
    /// are still shaping your prompts.
    ///
    /// Structured and attachment segments are skipped, because only text segments have a printable
    /// form. A transcript gains its prompt entry when a request completes, so this stays `nil`
    /// after a request that failed part-way through.
    var latestPromptText: String? {
        let promptEntry = last { entry in
            if case .prompt = entry { true } else { false }
        }

        guard case .prompt(let prompt) = promptEntry else { return nil }

        let lines = prompt.segments.compactMap { segment -> String? in
            if case .text(let text) = segment { text.content } else { nil }
        }

        return lines.isEmpty ? nil : lines.joined(separator: "\n")
    }
}
