import Foundation
import FoundationModels

/// Owns the composer state and drives the on-device model.
///
/// The view layer never builds a prompt string. It edits plain values, and this type hands the
/// resulting ``PantryBrief`` straight to `streamResponse` — the `PromptRepresentable` conformance
/// does the rest.
@MainActor
@Observable
final class RecipeSuggester {
    var ingredients: [Ingredient] = .examples
    var dietaryNeeds: [DietaryNeed] = .examples
    var cookingWindow: CookingWindow = .weeknight
    var note = ""

    /// The recipe as it arrives, field by field, while the model is still writing.
    private(set) var draft: Recipe.PartiallyGenerated?

    /// The text the ``PantryBrief`` actually turned into, read back from the session transcript.
    private(set) var promptTranscript: String?

    private(set) var errorMessage: String?
    private(set) var isSuggesting = false

    @ObservationIgnored private let model = SystemLanguageModel.default
    @ObservationIgnored private let session: LanguageModelSession

    init() {
        // `Instructions` has its own builder, matching `Prompt`'s. Anything durable about the
        // model's role belongs here rather than in a per-request prompt.
        session = LanguageModelSession {
            "You plan simple weeknight dinners for a home cook."
            "Use only the ingredients the cook says they have, plus salt, pepper, oil, and water."
            "Never invent an ingredient that is missing from their pantry."
        }
    }

    var availability: SystemLanguageModel.Availability {
        model.availability
    }

    /// The request assembled from the current composer state.
    var brief: PantryBrief {
        PantryBrief(
            ingredients: ingredients.filter(\.isInPantry),
            dietaryNeeds: dietaryNeeds.filter(\.isRequired),
            cookingWindow: cookingWindow,
            note: note.trimmingCharacters(in: .whitespacesAndNewlines)
        )
    }

    var canSuggest: Bool {
        availability == .available && isSuggesting == false && brief.ingredients.isEmpty == false
    }

    /// Streams a recipe for the current brief, replacing any previous result.
    func suggest() async {
        guard canSuggest else { return }

        isSuggesting = true
        errorMessage = nil
        draft = nil
        promptTranscript = nil
        defer { isSuggesting = false }

        let request = brief

        do {
            // `request` is a `PantryBrief`, and the closure is a `@PromptBuilder`. No `Prompt(...)`
            // wrapper and no string interpolation are needed — conformance is enough.
            let stream = session.streamResponse(generating: Recipe.self) {
                request
            }

            for try await snapshot in stream {
                draft = snapshot.content
            }
        } catch {
            errorMessage = error.localizedDescription
        }

        // Shows what the `PantryBrief` conformance actually produced, once the transcript has it.
        promptTranscript = session.transcript.latestPromptText
    }
}
