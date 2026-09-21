import FoundationModels

/// A restriction the finished recipe has to respect.
///
/// `title` is what the cook sees in the UI; `requirement` is what the model reads. Keeping the
/// two apart is the main reason to reach for `PromptRepresentable`: the phrasing the model needs
/// is rarely the phrasing a person wants on screen.
struct DietaryNeed: Identifiable, Hashable {
    var title: String
    var requirement: String

    /// Whether the cook has asked for this restriction.
    var isRequired: Bool = false

    var id: String { title }
}

// MARK: - PromptRepresentable

extension DietaryNeed: PromptRepresentable {
    var promptRepresentation: Prompt {
        "- \(requirement)"
    }
}

// MARK: - Sample data

extension [DietaryNeed] {
    /// The restrictions offered on the composer screen.
    static var examples: [DietaryNeed] {
        [
            DietaryNeed(
                title: "Vegetarian",
                requirement: "The dish must contain no meat, poultry, or fish."
            ),
            DietaryNeed(
                title: "Gluten free",
                requirement: "The dish must contain no wheat, barley, rye, or anything made from them."
            ),
            DietaryNeed(
                title: "Dairy free",
                requirement: "The dish must contain no milk, butter, cheese, cream, or yoghurt."
            ),
            DietaryNeed(
                title: "Nut free",
                requirement: "The dish must contain no tree nuts or peanuts, including oils made from them."
            ),
            DietaryNeed(
                title: "Low sodium",
                requirement: "The dish must use no added salt and no cured or brined ingredients."
            )
        ]
    }
}
