import SwiftUI
import SwiftData

// MARK: - Mock networking

/// The shape of a user as returned by the (mock) remote endpoint.
struct RemoteUser: Decodable, Identifiable {
    let id: Int
    let firstName: String
    let lastName: String
    let role: String
}

/// A stand-in for a real networking layer. Simulates latency and returns a
/// fixed catalog of users, as if decoding a JSON response.
enum MockUserService {
    /// The core set the endpoint always returns.
    private static let base: [RemoteUser] = [
        RemoteUser(id: 1, firstName: "Ada", lastName: "Lovelace", role: "admin"),
        RemoteUser(id: 2, firstName: "Alan", lastName: "Turing", role: "admin"),
        RemoteUser(id: 3, firstName: "Grace", lastName: "Hopper", role: "moderator"),
        RemoteUser(id: 4, firstName: "Linus", lastName: "Torvalds", role: "moderator"),
        RemoteUser(id: 5, firstName: "Margaret", lastName: "Hamilton", role: "regular"),
        RemoteUser(id: 6, firstName: "Dennis", lastName: "Ritchie", role: "regular"),
        RemoteUser(id: 7, firstName: "Katherine", lastName: "Johnson", role: "regular"),
        RemoteUser(id: 8, firstName: "Edsger", lastName: "Dijkstra", role: "admin"),
    ]

    /// Additional users the endpoint may include on any given request, so
    /// repeated refreshes surface new records over time (until all are seen).
    private static let extras: [RemoteUser] = [
        RemoteUser(id: 100, firstName: "Barbara", lastName: "Liskov", role: "moderator"),
        RemoteUser(id: 101, firstName: "Donald", lastName: "Knuth", role: "admin"),
        RemoteUser(id: 102, firstName: "Tim", lastName: "Berners-Lee", role: "regular"),
        RemoteUser(id: 103, firstName: "Radia", lastName: "Perlman", role: "moderator"),
        RemoteUser(id: 104, firstName: "Vint", lastName: "Cerf", role: "regular"),
        RemoteUser(id: 105, firstName: "Frances", lastName: "Allen", role: "admin"),
    ]

    static func fetchUsers() async throws -> [RemoteUser] {
        // Simulate network latency so the cache-first behavior is visible.
        try await Task.sleep(for: .seconds(1.5))

        // Return the base set plus a random handful of extras, mimicking an
        // endpoint whose data changes between requests.
        let sampledExtras = extras.shuffled().prefix(Int.random(in: 1...3))
        return base + sampledExtras
    }
}

// MARK: - Screen

/// A cache-first list of users.
///
/// The flow:
/// 1. A `ResultsObserver` shows any **cached** users from the store immediately.
/// 2. `.task` fetches from the (mock) remote endpoint in the background.
/// 3. New records are upserted through a **separate** `ModelContext`.
/// 4. That background save comes back to the container as history, so the
///    `HistoryObserver` bumps its counter and the `ResultsObserver` refreshes
///    the list automatically — no manual reload required.
struct RemoteUsersView: View {
    @Environment(\.modelContext) private var modelContext

    /// Drives the visible list; updated live as records are saved.
    @State private var results: ResultsObserver<User, Never>?

    /// Signals when background (remote) writes land in the store.
    @State private var history: HistoryObserver?

    @State private var syncState: SyncState = .idle

    enum SyncState: Equatable {
        case idle
        case syncing
        case synced(newCount: Int)
        case failed(String)
    }

    var body: some View {
        List {
            Section {
                syncStatusRow
                LabeledContent("Remote updates") {
                    Text(history.map { "\($0.eventCounter)" } ?? "0")
                        .font(.headline.monospacedDigit())
                        .foregroundStyle(.tint)
                        .contentTransition(.numericText())
                }
                .animation(.snappy, value: history?.eventCounter)
            } footer: {
                Text("\"Remote updates\" is `HistoryObserver.eventCounter` — it ticks up each time a background save lands in the store.")
            }

            Section("Users") {
                if let results {
                    if results.results.isEmpty && syncState == .syncing {
                        // First launch with an empty cache: nothing to show yet.
                        HStack {
                            ProgressView()
                            Text("Loading users…")
                                .foregroundStyle(.secondary)
                        }
                    } else if results.results.isEmpty {
                        ContentUnavailableView(
                            "No Users",
                            systemImage: "person.2.slash",
                            description: Text("Pull to refresh to fetch users from the remote endpoint.")
                        )
                    } else {
                        ForEach(results.results) { user in
                            RemoteUserRow(user: user)
                        }
                    }
                } else {
                    ProgressView()
                }
            }
        }
        .navigationTitle("Cache-First Users")
        .navigationBarTitleDisplayMode(.inline)
        .refreshable {
            await sync()
        }
        .task {
            setUpObservers()
            // Show cached rows first, then reconcile with the network.
            await sync()
        }
    }

    @ViewBuilder
    private var syncStatusRow: some View {
        switch syncState {
        case .idle:
            Label("Up to date", systemImage: "checkmark.circle")
                .foregroundStyle(.secondary)
        case .syncing:
            HStack {
                ProgressView()
                Text("Syncing with remote…")
            }
            .foregroundStyle(.secondary)
        case .synced(let newCount):
            Label(
                newCount == 0 ? "Up to date — no new users" : "Added \(newCount) new user\(newCount == 1 ? "" : "s")",
                systemImage: "arrow.down.circle.fill"
            )
            .foregroundStyle(.green)
        case .failed(let message):
            Label(message, systemImage: "exclamationmark.triangle.fill")
                .foregroundStyle(.red)
        }
    }

    // MARK: - Observers

    private func setUpObservers() {
        if results == nil {
            results = try? ResultsObserver<User, Never>(
                sortBy: [SortDescriptor(\.createdAt, order: .reverse)],
                modelContext: modelContext
            )
        }
        if history == nil {
            history = try? HistoryObserver(
                observedModels: [User.self],
                modelContainer: modelContext.container
            )
        }
    }

    // MARK: - Sync

    /// Fetches remote users and upserts any that aren't already cached.
    private func sync() async {
        syncState = .syncing
        do {
            let remoteUsers = try await MockUserService.fetchUsers()
            let newCount = try await save(remoteUsers, into: modelContext.container)
            syncState = .synced(newCount: newCount)
        } catch {
            syncState = .failed("Sync failed: \(error.localizedDescription)")
        }
    }

    /// Inserts only users whose `remoteID` isn't already present. Runs on a
    /// background context so fetching/saving stays off the view's context; the
    /// resulting save is reported back through history and observation.
    /// - Returns: the number of newly inserted users.
    private func save(_ remoteUsers: [RemoteUser], into container: ModelContainer) async throws -> Int {
        let context = ModelContext(container)

        let existing = try context.fetch(
            FetchDescriptor<User>(predicate: #Predicate { $0.remoteID != nil })
        )
        let existingIDs = Set(existing.compactMap(\.remoteID))

        var inserted = 0
        for remote in remoteUsers where !existingIDs.contains(remote.id) {
            context.insert(
                User(
                    remoteID: remote.id,
                    firstname: remote.firstName,
                    lastname: remote.lastName,
                    type: UserType(rawValue: remote.role) ?? .regular
                )
            )
            inserted += 1
        }

        if context.hasChanges {
            try context.save()
        }
        return inserted
    }
}

/// A single row for a synced (or cached) user.
private struct RemoteUserRow: View {
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
            VStack(alignment: .trailing) {
                if let remoteID = user.remoteID {
                    Text("#\(remoteID)")
                        .font(.caption.monospacedDigit())
                }
                Text(user.createdAt, format: .relative(presentation: .named))
                    .font(.caption2)
            }
            .foregroundStyle(.tertiary)
        }
    }
}

#Preview {
    NavigationStack {
        RemoteUsersView()
    }
    .modelContainer(for: User.self, inMemory: true)
}
