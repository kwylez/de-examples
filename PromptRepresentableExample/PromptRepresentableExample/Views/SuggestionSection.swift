import FoundationModels
import SwiftUI

/// The action button plus whatever the model has produced so far.
struct SuggestionSection: View {
    @Bindable var suggester: RecipeSuggester

    var body: some View {
        Section {
            Button("Suggest a Recipe", systemImage: "sparkles", action: suggest)
                .disabled(suggester.canSuggest == false)

            if suggester.isSuggesting {
                ProgressView("Cooking up an idea…")
                    .frame(maxWidth: .infinity)
            }
        }

        if case .unavailable(let reason) = suggester.availability {
            Section {
                ModelUnavailableView(reason: reason)
            }
        } else if let errorMessage = suggester.errorMessage {
            Section {
                ContentUnavailableView(
                    "Couldn't Suggest a Recipe",
                    systemImage: "exclamationmark.triangle",
                    description: Text(errorMessage)
                )
            }
        } else if let draft = suggester.draft {
            Section("Tonight's dinner") {
                RecipeDraftView(draft: draft)
            }
        }
    }

    private func suggest() {
        Task { await suggester.suggest() }
    }
}

#Preview {
    Form {
        SuggestionSection(suggester: RecipeSuggester())
    }
}
