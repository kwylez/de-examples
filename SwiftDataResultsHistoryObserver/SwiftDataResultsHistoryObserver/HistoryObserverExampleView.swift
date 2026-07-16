import SwiftUI
import SwiftData

/// Demonstrates `HistoryObserver`, which watches a model container for *remote*
/// changes (writes committed by another context, process, or CloudKit sync) and
/// bumps its `eventCounter` each time relevant history transactions arrive.
///
/// To produce those remote changes here, the buttons write through a *separate*
/// `ModelContext`, which the container reports back to the observer as history.
struct HistoryObserverExampleView: View {
    @Environment(\.modelContext) private var modelContext

    /// Current users, shown so the effect of a "remote" write is visible.
    @Query(sort: \User.createdAt, order: .reverse) private var users: [User]

    /// Created lazily in `.task` once the environment's context is available.
    @State private var observer: HistoryObserver?

    /// A human-readable log built by reacting to `eventCounter` changes.
    @State private var eventLog: [String] = []

    var body: some View {
        List {
            Section {
                LabeledContent("Event counter") {
                    Text(observer.map { "\($0.eventCounter)" } ?? "–")
                        .font(.title2.monospacedDigit().bold())
                        .foregroundStyle(.tint)
                        .contentTransition(.numericText())
                }
                LabeledContent("Users in store", value: "\(users.count)")
            } header: {
                Text("Observed State")
            } footer: {
                Text("`eventCounter` increments whenever the observer detects relevant remote history for `User`.")
            }

            Section("Simulate Remote Changes") {
                Button {
                    insertRemoteUser()
                } label: {
                    Label("Insert user (other context)", systemImage: "plus.circle")
                }

                Button(role: .destructive) {
                    deleteAllRemotely()
                } label: {
                    Label("Delete all (other context)", systemImage: "trash")
                }
                .disabled(users.isEmpty)
            }

            if !eventLog.isEmpty {
                Section("History Events") {
                    ForEach(Array(eventLog.enumerated()), id: \.offset) { _, entry in
                        Text(entry)
                            .font(.callout.monospaced())
                    }
                }
            }
        }
        .navigationTitle("HistoryObserver")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            guard observer == nil else { return }
            observer = try? HistoryObserver(
                observedModels: [User.self],
                modelContainer: modelContext.container
            )
        }
        // React to detected history events and record them in the log.
        .onChange(of: observer?.eventCounter) { _, newValue in
            guard let newValue else { return }
            eventLog.insert("Event #\(newValue): remote change detected", at: 0)
        }
    }

    /// Inserts a user through a *separate* context so the write reaches the
    /// container as a remote change that `HistoryObserver` can detect.
    private func insertRemoteUser() {
        let context = ModelContext(modelContext.container)
        context.insert(User.random())
        try? context.save()
    }

    private func deleteAllRemotely() {
        let context = ModelContext(modelContext.container)
        try? context.delete(model: User.self)
        try? context.save()
    }
}

#Preview {
    NavigationStack {
        HistoryObserverExampleView()
    }
    .modelContainer(for: User.self, inMemory: true)
}
