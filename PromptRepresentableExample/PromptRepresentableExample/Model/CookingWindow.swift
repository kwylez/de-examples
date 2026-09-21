import FoundationModels

/// How much active time the cook is willing to spend tonight.
///
/// An enum conforms to `PromptRepresentable` exactly as a struct does, which makes it a tidy
/// home for the wording each case should contribute to a prompt.
enum CookingWindow: String, CaseIterable, Identifiable {
    case quick
    case weeknight
    case leisurely

    var id: Self { self }

    /// The label shown in the picker.
    var title: String {
        switch self {
        case .quick: "Under 20 minutes"
        case .weeknight: "Around 40 minutes"
        case .leisurely: "An hour or more"
        }
    }

    /// The constraint the model has to work within.
    private var constraint: String {
        switch self {
        case .quick: "at or under 20 minutes"
        case .weeknight: "between 25 and 45 minutes"
        case .leisurely: "anywhere from 45 to 90 minutes"
        }
    }
}

// MARK: - PromptRepresentable

extension CookingWindow: PromptRepresentable {
    var promptRepresentation: Prompt {
        "Keep total active cooking time \(constraint)."
    }
}
