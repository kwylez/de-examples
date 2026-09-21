import FoundationModels

/// The structured answer the model generates from a ``PantryBrief``.
///
/// `PromptRepresentable` describes what goes *into* the model; `Generable` describes what comes
/// back out. Pairing them means neither direction needs hand-written parsing.
@Generable
struct Recipe {
    @Guide(description: "An appetising name for the finished dish")
    var name: String

    @Guide(description: "One sentence describing how the finished dish tastes")
    var summary: String

    @Guide(description: "The pantry items this recipe uses, with quantities", .count(2...8))
    var ingredients: [String]

    @Guide(description: "Preparation steps in the order they should be performed", .count(3...6))
    var steps: [String]

    @Guide(description: "Total active cooking time in minutes", .range(5...120))
    var activeMinutes: Int
}
