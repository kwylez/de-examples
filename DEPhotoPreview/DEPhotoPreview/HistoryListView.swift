import SwiftUI

// MARK: - History model

/// A single entry in a Red Tag's history feed: an action taken on the tag, an
/// optional note, who performed it, when, and any photos involved.
struct HistoryEntry: Identifiable, Equatable {
    let id = UUID()
    let action: String
    let actionSymbol: String
    let tint: Color
    let note: String
    let author: String
    let date: Date
    let thumbnails: [HistoryThumbnail]
}

/// A small photo attached to a history entry, rendered as a tinted tile.
struct HistoryThumbnail: Identifiable, Equatable {
    let id = UUID()
    let tint: Color
    let systemImage: String
}

extension HistoryEntry {
    /// Builds a fixed calendar date for sample data (avoids depending on "now").
    private static func date(_ year: Int, _ month: Int, _ day: Int) -> Date {
        DateComponents(calendar: .current, year: year, month: month, day: day).date ?? .now
    }

    /// Seed entries for previews and as the initial Red Tag history.
    static let samples: [HistoryEntry] = [
        HistoryEntry(
            action: "Marked Unsafe",
            actionSymbol: "tag.fill",
            tint: .red,
            note: "Testing",
            author: "John Moore",
            date: date(2026, 1, 21),
            thumbnails: [
                HistoryThumbnail(tint: .pink, systemImage: "leaf.fill"),
                HistoryThumbnail(tint: .teal, systemImage: "drop.fill"),
            ]
        ),
        HistoryEntry(
            action: "Marked Safe",
            actionSymbol: "checkmark.seal.fill",
            tint: .green,
            note: "Re-inspected the area and cleared the tag.",
            author: "Jane Smith",
            date: date(2026, 1, 18),
            thumbnails: [
                HistoryThumbnail(tint: .orange, systemImage: "flame.fill"),
            ]
        ),
        HistoryEntry(
            action: "Comment Added",
            actionSymbol: "text.bubble.fill",
            tint: .blue,
            note: "Please re-check the east corner before sign-off.",
            author: "Carlos Reyes",
            date: date(2026, 1, 15),
            thumbnails: []
        ),
    ]
}

// MARK: - History list

/// A history feed whose rows reuse the visual language of `ListingCard`: a dark
/// rounded tile with a gradient icon, a title, and a secondary info row.
struct HistoryListView: View {
    private let entries = HistoryEntry.samples

    var body: some View {
        List {
            Section {
                ForEach(entries) { entry in
                    HistoryCard(entry: entry)
                        .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                }
            } header: {
                Text("History (\(entries.count))")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(.primary)
                    .textCase(nil)
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(Color(.systemGroupedBackground))
    }
}

// MARK: - History section

/// The history feed as a self-contained section for embedding inside an existing
/// `ScrollView` (e.g. below the photo previews on `DERTDetailScreen`). Uses a
/// `LazyVStack` rather than a `List` so it composes with the surrounding scroll
/// view, matching how `ContentView` lays out its listings.
struct HistorySection: View {
    let entries: [HistoryEntry]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("History (\(entries.count))")
                .font(.title2.weight(.bold))
                .padding(.horizontal, 6)

            LazyVStack(spacing: 16) {
                ForEach(entries) { entry in
                    HistoryCard(entry: entry)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - History card

/// A history entry styled like `ListingCard`: header (icon + action + photos),
/// the note, then an author/date footer in place of the listing's price row.
struct HistoryCard: View {
    let entry: HistoryEntry

    /// Link-style accent for the author name, matching the screenshot. Uses the
    /// system link color so it stays legible in both light and dark mode.
    private let authorTint = Color(.link)

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 14) {
                HistoryCardIcon(systemImage: entry.actionSymbol, tint: entry.tint)

                Text(entry.action)
                    .font(.title3.weight(.medium))
                    .foregroundStyle(entry.tint)
                    .lineLimit(1)

                Spacer(minLength: 8)

                HistoryThumbnails(thumbnails: entry.thumbnails)
            }

            if !entry.note.isEmpty {
                Text(entry.note)
                    .font(.subheadline)
                    .foregroundStyle(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            HStack(spacing: 4) {
                Text(entry.author)
                    .foregroundStyle(authorTint)
                Text("on \(entry.date, format: .dateTime.month(.wide).day().year())")
                    .foregroundStyle(.secondary)
                Spacer()
            }
            .font(.subheadline)
        }
        .padding(18)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 22))
    }
}

/// Rounded gradient tile with the action's SF Symbol, mirroring `ListingIcon`.
struct HistoryCardIcon: View {
    let systemImage: String
    let tint: Color

    var body: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(
                LinearGradient(
                    colors: [tint.opacity(0.9), tint.opacity(0.5)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay {
                Image(systemName: systemImage)
                    .font(.system(size: 52 * 0.45))
                    .foregroundStyle(.white)
            }
            .frame(width: 52, height: 52)
    }
}

/// The trailing cluster of photo thumbnails attached to a history entry.
struct HistoryThumbnails: View {
    let thumbnails: [HistoryThumbnail]

    var body: some View {
        HStack(spacing: 6) {
            ForEach(thumbnails) { thumbnail in
                RoundedRectangle(cornerRadius: 8)
                    .fill(
                        LinearGradient(
                            colors: [thumbnail.tint.opacity(0.9), thumbnail.tint.opacity(0.45)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay {
                        Image(systemName: thumbnail.systemImage)
                            .font(.system(size: 16))
                            .foregroundStyle(.white.opacity(0.9))
                    }
                    .frame(width: 36, height: 36)
            }
        }
    }
}

#Preview {
    HistoryListView()
}
