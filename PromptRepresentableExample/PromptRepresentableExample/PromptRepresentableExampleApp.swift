import SwiftUI

/// A worked example of `PromptRepresentable` from the Foundation Models framework.
///
/// The interesting code lives in `Model`: `Ingredient`, `DietaryNeed`, and
/// `CookingWindow` each teach the framework how to describe *themselves*, and
/// `PantryBrief` composes them into a single prompt without any string
/// concatenation at the call site.
@main
struct PromptRepresentableExampleApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
