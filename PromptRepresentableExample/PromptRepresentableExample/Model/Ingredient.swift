import FoundationModels

/// A single pantry item the model is allowed to cook with.
struct Ingredient: Identifiable, Hashable {
    var name: String
    var quantity: String

    /// Whether the cook currently has this item on hand.
    var isInPantry: Bool

    var id: String { name }
}

// MARK: - PromptRepresentable

extension Ingredient: PromptRepresentable {
    /// Teaches Foundation Models how an `Ingredient` describes itself.
    ///
    /// The protocol requirement is declared as `@PromptBuilder var promptRepresentation: Prompt`,
    /// and Swift propagates that result builder onto the conformance below. That is why a bare
    /// `String` is a valid body here: `String` itself conforms to `PromptRepresentable`, so the
    /// builder's `buildExpression` accepts it.
    ///
    /// Once this exists, an `Ingredient` can be dropped directly into any `@PromptBuilder`
    /// block — no interpolation at the call site, and the wording lives with the type it
    /// describes rather than being duplicated across every prompt that mentions ingredients.
    var promptRepresentation: Prompt {
        "- \(quantity) \(name)"
    }
}

// MARK: - Sample data

extension [Ingredient] {
    /// The starting pantry shown when the app launches.
    static var examples: [Ingredient] {
        [
            Ingredient(name: "eggs", quantity: "6", isInPantry: true),
            Ingredient(name: "spinach", quantity: "2 large handfuls", isInPantry: true),
            Ingredient(name: "feta", quantity: "150 g", isInPantry: true),
            Ingredient(name: "orzo", quantity: "300 g", isInPantry: true),
            Ingredient(name: "cherry tomatoes", quantity: "1 punnet", isInPantry: false),
            Ingredient(name: "chorizo", quantity: "200 g", isInPantry: false),
            Ingredient(name: "lemon", quantity: "1", isInPantry: true),
            Ingredient(name: "greek yoghurt", quantity: "250 g", isInPantry: false)
        ]
    }
}
