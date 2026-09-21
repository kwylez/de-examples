import SwiftUI

/// Lets the cook tick off what they actually have in the cupboard.
struct PantrySection: View {
    @Bindable var suggester: RecipeSuggester

    var body: some View {
        Section {
            ForEach($suggester.ingredients) { $ingredient in
                Toggle(isOn: $ingredient.isInPantry) {
                    VStack(alignment: .leading, spacing: AppLayout.tightSpacing) {
                        Text(ingredient.name)
                        Text(ingredient.quantity)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        } header: {
            Text("Pantry")
        } footer: {
            Text("Only the items you tick are described to the model.")
        }
    }
}

#Preview {
    Form {
        PantrySection(suggester: RecipeSuggester())
    }
}
