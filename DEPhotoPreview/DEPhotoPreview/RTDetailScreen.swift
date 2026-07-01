import SwiftUI
import PhotosUI

// MARK: - Screen

/// A Red Tag detail screen: up to two photos, a safety toggle, a comment field,
/// and a history feed. History rows support swipe-to-delete using the iOS 27
/// `swipeActionsContainer()` API (swipe actions outside of `List`).
struct RTDetailScreen: View {
    /// The number of photo slots offered to the user.
    private static let slotCount = 2

    @State private var model = RTDetailModel()

    /// Selected images keyed by slot index; a missing key shows the placeholder.
    @State private var images: [Int: Image] = [:]

    /// The slot currently expanded full screen, if any.
    @State private var expandedSlot: Int?

    /// Drives the matched-geometry expand/collapse between a preview and its
    /// full-screen copy.
    @Namespace private var animation

    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 28) {
                    HStack(alignment: .top, spacing: 16) {
                        ForEach(0..<Self.slotCount, id: \.self) { slot in
                            RTPhotoSlot(
                                slot: slot,
                                image: imageBinding(for: slot),
                                isExpanded: expandedSlot == slot,
                                namespace: animation
                            ) {
                                withAnimation(.bouncy) {
                                    expandedSlot = slot
                                }
                            }
                        }
                    }

                    RTSafetyCard(model: model)

                    RTCommentCard(model: model)

                    RTHistorySection(model: model)
                }
                .padding(20)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Photos")
            .navigationBarTitleDisplayMode(.inline)
            // iOS 27: enables `swipeActions` on the history rows below, which live in
            // a LazyVStack rather than a List.
            .swipeActionsContainer()
            // Hide the navigation bar while a photo is expanded full screen.
            .toolbarVisibility(expandedSlot == nil ? .automatic : .hidden, for: .navigationBar)

            if let expandedSlot, let image = images[expandedSlot] {
                RTFullScreenPhoto(slot: expandedSlot, image: image, namespace: animation) {
                    withAnimation(.bouncy) {
                        self.expandedSlot = nil
                    }
                }
                .zIndex(1)
            }
        }
    }

    /// A two-way binding into `images` for a given slot, keeping one source of truth.
    private func imageBinding(for slot: Int) -> Binding<Image?> {
        Binding(
            get: { images[slot] },
            set: { images[slot] = $0 }
        )
    }
}

// MARK: - Model

/// Owns the Red Tag's safety status, in-progress comment, and history feed.
@MainActor
@Observable
final class RTDetailModel {
    /// Whether the Red Tag is currently marked safe (off = unsafe).
    var isSafe = false

    /// The comment the user is composing before adding it.
    var commentDraft = ""

    /// The history feed, newest first.
    private(set) var history: [HistoryEntry] = HistoryEntry.samples

    /// Whether the draft has enough content to add a comment.
    var canAddComment: Bool {
        !commentDraft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    /// Records the current safety status as its own history entry.
    func recordSafety() {
        history.insert(
            HistoryEntry(
                action: isSafe ? "Marked Safe" : "Marked Unsafe",
                actionSymbol: isSafe ? "checkmark.seal.fill" : "tag.fill",
                tint: isSafe ? .green : .red,
                note: "",
                author: "You",
                date: .now,
                thumbnails: []
            ),
            at: 0
        )
    }

    /// Records the draft as a free-form comment entry, then clears the draft.
    func addComment() {
        let note = commentDraft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !note.isEmpty else { return }

        history.insert(
            HistoryEntry(
                action: "Comment Added",
                actionSymbol: "text.bubble.fill",
                tint: .blue,
                note: note,
                author: "You",
                date: .now,
                thumbnails: []
            ),
            at: 0
        )
        commentDraft = ""
    }

    /// Removes a history entry (invoked by swipe-to-delete).
    func delete(_ entry: HistoryEntry) {
        history.removeAll { $0.id == entry.id }
    }
}

// MARK: - Photo slot

/// A single photo slot: a placeholder when empty, or the selected image with
/// stacked Change/Delete controls when filled.
private struct RTPhotoSlot: View {
    let slot: Int
    @Binding var image: Image?

    /// Whether this slot's photo is expanded full screen. While true, the preview
    /// yields a clear placeholder so the full-screen copy owns the matched id.
    let isExpanded: Bool
    let namespace: Namespace.ID

    /// Called when the user taps a filled preview to expand it full screen.
    let onTap: () -> Void

    @State private var pickerItem: PhotosPickerItem?

    var body: some View {
        Group {
            if let image {
                filled(image)
            } else {
                placeholder
            }
        }
        .task(id: pickerItem) {
            // Decode via UIImage to preserve EXIF orientation, then swap in.
            guard let pickerItem,
                  let data = try? await pickerItem.loadTransferable(type: Data.self),
                  let uiImage = UIImage(data: data)
            else { return }
            image = Image(uiImage: uiImage)
        }
    }

    private func filled(_ image: Image) -> some View {
        VStack(spacing: 8) {
            preview(image)

            // Stacked so each control spans the full (narrow) slot width.
            VStack(spacing: 8) {
                PhotosPicker(selection: $pickerItem, matching: .images) {
                    Label("Change", systemImage: "photo")
                        .lineLimit(1)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)

                Button(role: .destructive) {
                    self.image = nil
                    pickerItem = nil
                } label: {
                    Label("Delete", systemImage: "trash")
                        .lineLimit(1)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            }
            .controlSize(.small)
        }
    }

    @ViewBuilder
    private func preview(_ image: Image) -> some View {
        Group {
            if isExpanded {
                // Placeholder keeps the slot's layout while the full-screen copy
                // owns the matched-geometry id.
                Color.clear
            } else {
                RTSlotImage(image: image)
                    .matchedGeometryEffect(id: slot, in: namespace)
                    .onTapGesture(perform: onTap)
            }
        }
        .aspectRatio(3 / 2, contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var placeholder: some View {
        PhotosPicker(selection: $pickerItem, matching: .images) {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemGroupedBackground))
                .aspectRatio(3 / 2, contentMode: .fit)
                .overlay {
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(
                            Color(.separator),
                            style: StrokeStyle(lineWidth: 2, dash: [8])
                        )
                }
                .overlay {
                    VStack(spacing: 8) {
                        Image(systemName: "photo.badge.plus")
                            .font(.system(size: 36))
                        Text("Add Photo")
                            .font(.headline)
                    }
                    .foregroundStyle(.secondary)
                }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Safety card

/// The "Mark for Safety" toggle. Flipping it records the new status to History.
private struct RTSafetyCard: View {
    @Bindable var model: RTDetailModel

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Mark for Safety")
                    .font(.headline)

                Spacer()

                Text(model.isSafe ? "Safe" : "Unsafe")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(model.isSafe ? .green : .red)

                Toggle("Mark for Safety", isOn: $model.isSafe)
                    .labelsHidden()
                    .tint(.green)
            }

            Text("Changing the status adds an entry to History.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding(18)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 22))
        .onChange(of: model.isSafe) {
            model.recordSafety()
        }
    }
}

// MARK: - Comment card

/// A free-form comment entry with an Add Comment button that records to History.
private struct RTCommentCard: View {
    @Bindable var model: RTDetailModel

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Add a Comment")
                .font(.headline)

            VStack(alignment: .leading, spacing: 8) {
                if !model.canAddComment {
                    Label("The following field is required.", systemImage: "info.circle")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                TextField(
                    "How did you validate this Red Tag?",
                    text: $model.commentDraft,
                    axis: .vertical
                )
                .lineLimit(2...4)
                .textFieldStyle(.plain)
            }

            Button {
                model.addComment()
            } label: {
                Text("Add Comment")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(!model.canAddComment)
        }
        .padding(18)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 22))
    }
}

// MARK: - History section

/// The history feed. Each row supports swipe-to-delete via the iOS 27 swipe
/// actions API (enabled by `swipeActionsContainer()` on the enclosing ScrollView).
private struct RTHistorySection: View {
    let model: RTDetailModel

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("History (\(model.history.count))")
                .font(.title2.weight(.bold))
                .padding(.horizontal, 6)

            LazyVStack(spacing: 16) {
                ForEach(model.history) { entry in
                    HistoryCard(entry: entry)
                        .swipeActions {
                            Button(role: .destructive) {
                                model.delete(entry)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Slot image

/// Renders a selected photo filling its bounds. Shared by the slot preview and
/// the full-screen copy so the matched-geometry transition interpolates cleanly.
private struct RTSlotImage: View {
    let image: Image

    var body: some View {
        // Color.clear fixes the layout size to the proposed bounds so the filled
        // image is clipped to the frame rather than overflowing it.
        Color.clear
            .overlay {
                image
                    .resizable()
                    .scaledToFill()
            }
            .clipped()
    }
}

// MARK: - Full screen preview

/// A full-size view of a selected photo that expands from its slot via a matched
/// geometry effect, with a button to return to the detail screen.
private struct RTFullScreenPhoto: View {
    let slot: Int
    let image: Image
    let namespace: Namespace.ID
    let onClose: () -> Void

    var body: some View {
        RTSlotImage(image: image)
            .matchedGeometryEffect(id: slot, in: namespace)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea()
            .overlay(alignment: .topTrailing) {
                Button(action: onClose) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title)
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(.white, .black.opacity(0.5))
                        .padding()
                }
            }
    }
}

#Preview {
    NavigationStack {
        RTDetailScreen()
    }
}
