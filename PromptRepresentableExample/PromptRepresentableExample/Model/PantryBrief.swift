import FoundationModels

/// Everything the model needs to know in order to suggest tonight's dinner.
struct PantryBrief {
    var ingredients: [Ingredient]
    var dietaryNeeds: [DietaryNeed]
    var cookingWindow: CookingWindow

    /// A free-form aside from the cook, which may be empty.
    var note: String
}

// MARK: - PromptRepresentable

extension PantryBrief: PromptRepresentable {
    /// Composes the smaller `PromptRepresentable` values into one prompt.
    ///
    /// This is the payoff of the protocol. Because `Ingredient`, `DietaryNeed`, and
    /// `CookingWindow` all describe themselves, this body reads like an outline of the request
    /// instead of a pile of string building, and each piece of wording stays testable and
    /// reusable on its own.
    ///
    /// Four `PromptBuilder` features show up here:
    ///
    /// - Bare `String` literals, because `String` conforms to `PromptRepresentable`.
    /// - Whole arrays, because `Array` conforms wherever its `Element` does — so `ingredients`
    ///   expands to one fragment per item with no `for` loop.
    /// - `if`/`else`, which routes through `buildEither` and lets the prompt say something
    ///   different rather than falling silent when there are no restrictions.
    /// - A bare `if`, which routes through `buildOptional` and contributes nothing at all when
    ///   the cook left the note empty.
    var promptRepresentation: Prompt {
        "Suggest one dinner recipe I can cook tonight."

        "These are the only ingredients I have, beyond salt, pepper, oil, and water:"
        ingredients

        if dietaryNeeds.isEmpty {
            "I have no dietary restrictions."
        } else {
            "Every one of these restrictions must hold:"
            dietaryNeeds
        }

        cookingWindow

        if note.isEmpty == false {
            "One more thing to keep in mind: \(note)"
        }
    }
}
