import SwiftUI

/// Renders a recipe while it is still being generated.
///
/// Every field of `Recipe.PartiallyGenerated` is optional, because the model fills them in one at
/// a time. Unwrapping each one is what produces the progressive reveal.
struct RecipeDraftView: View {
    let draft: Recipe.PartiallyGenerated

    var body: some View {
        VStack(alignment: .leading, spacing: AppLayout.groupSpacing) {
            VStack(alignment: .leading, spacing: AppLayout.tightSpacing) {
                if let name = draft.name {
                    Text(name)
                        .font(.headline)
                }

                if let summary = draft.summary {
                    Text(summary)
                        .foregroundStyle(.secondary)
                }

                if let activeMinutes = draft.activeMinutes {
                    Label(
                        "^[\(activeMinutes) minute](inflect: true) of active cooking",
                        systemImage: "clock"
                    )
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                }
            }

            if let ingredients = draft.ingredients, ingredients.isEmpty == false {
                VStack(alignment: .leading, spacing: AppLayout.rowSpacing) {
                    Text("You'll need")
                        .font(.subheadline)
                        .bold()

                    ForEach(ingredients, id: \.self) { ingredient in
                        Text(ingredient)
                    }
                }
            }

            if let steps = draft.steps, steps.isEmpty == false {
                VStack(alignment: .leading, spacing: AppLayout.rowSpacing) {
                    Text("Method")
                        .font(.subheadline)
                        .bold()

                    ForEach(steps.enumerated(), id: \.offset) { index, step in
                        Text("\(index + 1). \(step)")
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
