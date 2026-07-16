import SwiftUI
import SwiftData

/// Demonstrates `ResultsObserver`, which observes a collection of models in a
/// model context and keeps `results` synchronized as data changes.
///
/// Unlike `@Query`, the observer is created and held imperatively, so its
/// `filterBy` and `sortBy` can be reconfigured at runtime — here, via the
/// role picker.
struct ResultsObserverExampleView: View {
    @Environment(\.modelContext) private var modelContext

    /// Created lazily in `.task` once the environment's context is available.
    @State private var observer: ResultsObserver<User, Never>?

    /// `nil` means "show every role".
    @State private var roleFilter: UserType?

    var body: some View {
        Group {
            if let observer {
                resultsList(for: observer)
            } else {
                ProgressView()
            }
        }
        .navigationTitle("ResultsObserver")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    addUser()
                } label: {
                    Label("Add User", systemImage: "plus")
                }
            }
        }
        .task {
            guard observer == nil else { return }
            observer = try? ResultsObserver<User, Never>(
                sortBy: [SortDescriptor(\.createdAt, order: .reverse)],
                modelContext: modelContext
            )
        }
    }

    @ViewBuilder
    private func resultsList(for observer: ResultsObserver<User, Never>) -> some View {
        List {
            Section {
                Picker("Role", selection: $roleFilter) {
                    Text("All").tag(UserType?.none)
                    ForEach(UserType.allCases) { role in
                        Text(role.displayName).tag(UserType?.some(role))
                    }
                }
                .pickerStyle(.segmented)
            }

            Section {
                if observer.results.isEmpty {
                    ContentUnavailableView(
                        "No Users",
                        systemImage: "person.slash",
                        description: Text("Tap + to insert a user and watch the results update live.")
                    )
                } else {
                    ForEach(observer.results) { user in
                        UserRow(user: user)
                    }
                    .onDelete { offsets in
                        delete(offsets, from: observer)
                    }
                }
            } header: {
                Text("\(observer.results.count) result\(observer.results.count == 1 ? "" : "s")")
            }
        }
        // Reconfigure the live query whenever the selected role changes.
        .onChange(of: roleFilter) { _, newValue in
            if let newValue {
                observer.filterBy = #Predicate { $0.type == newValue }
            } else {
                observer.filterBy = nil
            }
        }
    }

    private func addUser() {
        modelContext.insert(User.random())
        try? modelContext.save()
    }

    private func delete(_ offsets: IndexSet, from observer: ResultsObserver<User, Never>) {
        for index in offsets {
            modelContext.delete(observer.results[index])
        }
        try? modelContext.save()
    }
}

/// A single row describing a user and their role.
private struct UserRow: View {
    let user: User

    var body: some View {
        HStack {
            Image(systemName: user.type.symbolName)
                .foregroundStyle(.tint)
                .frame(width: 28)
            VStack(alignment: .leading) {
                Text(user.fullName)
                Text(user.type.displayName)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text(user.createdAt, format: .relative(presentation: .named))
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
    }
}

#Preview {
    NavigationStack {
        ResultsObserverExampleView()
    }
    .modelContainer(for: User.self, inMemory: true)
}
