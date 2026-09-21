import SwiftUI

/// Collects the restrictions, time budget, and free-form note that shape the prompt.
struct RequirementsSection: View {
    @Bindable var suggester: RecipeSuggester

    var body: some View {
        Section("Restrictions") {
            ForEach($suggester.dietaryNeeds) { $need in
                Toggle(need.title, isOn: $need.isRequired)
            }
        }

        Section("Time") {
            Picker("Tonight I have", selection: $suggester.cookingWindow) {
                ForEach(CookingWindow.allCases) { window in
                    Text(window.title).tag(window)
                }
            }
        }

        Section("Anything else?") {
            TextField(
                "For example: my partner hates coriander",
                text: $suggester.note,
                axis: .vertical
            )
            .lineLimit(2...)
        }
    }
}

#Preview {
    Form {
        RequirementsSection(suggester: RecipeSuggester())
    }
}
