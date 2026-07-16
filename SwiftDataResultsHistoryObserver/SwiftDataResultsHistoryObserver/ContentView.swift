import SwiftUI
import SwiftData

@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        // A single shared container backs both observer examples.
        .modelContainer(for: User.self)
    }
}

struct ContentView: View {
    var body: some View {
        NavigationStack {
            List {
                Section {
                    NavigationLink {
                        ResultsObserverExampleView()
                    } label: {
                        Label {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("ResultsObserver")
                                Text("Live-updating query results")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        } icon: {
                            Image(systemName: "list.bullet.rectangle")
                        }
                    }

                    NavigationLink {
                        HistoryObserverExampleView()
                    } label: {
                        Label {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("HistoryObserver")
                                Text("React to remote store changes")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        } icon: {
                            Image(systemName: "clock.arrow.circlepath")
                        }
                    }
                } header: {
                    Text("SwiftData Observers")
                } footer: {
                    Text("Examples of observing a model context and a model container's change history.")
                }

                Section {
                    NavigationLink {
                        RemoteUsersView()
                    } label: {
                        Label {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Cache-First Users")
                                Text("Show cache, sync remote, update live")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        } icon: {
                            Image(systemName: "arrow.clockwise.circle")
                        }
                    }
                } header: {
                    Text("Patterns")
                } footer: {
                    Text("Combines both observers: a cached list backed by a background remote fetch.")
                }
            }
            .navigationTitle("Observers")
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: User.self, inMemory: true)
}
