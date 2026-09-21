import SwiftUI

/// The composer screen: pick what is in the pantry, then let the model cook.
struct ContentView: View {
    @State private var suggester = RecipeSuggester()

    var body: some View {
        NavigationStack {
            Form {
                PantrySection(suggester: suggester)
                RequirementsSection(suggester: suggester)
                SuggestionSection(suggester: suggester)
                PromptTranscriptSection(transcript: suggester.promptTranscript)
            }
            .navigationTitle("Pantry Cook")
        }
    }
}

#Preview {
    ContentView()
}
