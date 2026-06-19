import SwiftUI
import PhotosUI

// MARK: - Detail screen

/// Lets the user attach up to two photos from their library. Each slot starts as
/// a placeholder; once filled, the photo can be changed, deleted, or tapped to
/// expand into a full-size preview using the same matched-geometry transition
/// as the photo grid in `ContentView`.
struct DERTDetailScreen: View {
    /// The number of photo slots offered to the user.
    private static let slotCount = 2

    /// Selected images keyed by slot index. A missing key means that slot is
    /// still showing its placeholder.
    @State private var images: [Int: Image] = [:]

    /// The slot currently expanded full screen, if any.
    @State private var expandedSlot: Int?

    /// Drives the matched-geometry expand/collapse between a preview and its
    /// full-screen copy, mirroring the photo transition in `ContentView`.
    @Namespace private var animation

    /// Owns the Red Tag's safety status, comment draft, and history feed.
    @State private var model = RedTagModel()

    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 28) {
                    HStack(alignment: .top, spacing: 16) {
                        ForEach(0..<Self.slotCount, id: \.self) { slot in
                            PhotoSlotView(
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

                    SafetyControlCard(model: model)

                    CommentCard(model: model)

                    HistorySection(entries: model.history)
                }
                .padding(20)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Photos")
            .navigationBarTitleDisplayMode(.inline)
            // Hide the navigation bar (back button + title) while a photo is
            // expanded full screen; the overlay's close button is the way out.
            .toolbarVisibility(expandedSlot == nil ? .automatic : .hidden, for: .navigationBar)

            if let expandedSlot, let image = images[expandedSlot] {
                FullScreenPhotoView(slot: expandedSlot, image: image, namespace: animation) {
                    withAnimation(.bouncy) {
                        self.expandedSlot = nil
                    }
                }
                .zIndex(1)
            }
        }
    }

    /// A two-way binding into `images` for a given slot, keeping a single source
    /// of truth while each slot manages its own selection.
    private func imageBinding(for slot: Int) -> Binding<Image?> {
        Binding(
            get: { images[slot] },
            set: { images[slot] = $0 }
        )
    }
}

// MARK: - Photo slot

/// A single photo slot: a placeholder when empty, or the selected image with
/// change/delete controls and a tap-to-expand preview when filled.
private struct PhotoSlotView: View {
    let slot: Int
    @Binding var image: Image?

    /// Whether this slot's photo is currently expanded full screen. While true,
    /// the preview yields a clear placeholder so the full-screen copy owns the
    /// matched-geometry id.
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
            // Load the picked photo off the main actor. Decoding the raw Data
            // through UIImage preserves the photo's EXIF orientation, which
            // loading directly as `Image` can drop; the binding write then swaps
            // the placeholder for the selected image.
            guard let pickerItem,
                  let data = try? await pickerItem.loadTransferable(type: Data.self),
                  let uiImage = UIImage(data: data)
            else { return }
            image = Image(uiImage: uiImage)
        }
    }

    // MARK: Filled state

    private func filled(_ image: Image) -> some View {
        VStack(spacing: 8) {
            preview(image)

            // Stacked vertically so each control spans the full slot width.
            // Side-by-side, the labels wrap in the narrow half-width slot.
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
                // Placeholder keeps the slot's layout intact while the photo is
                // expanded full screen (the matched-geometry copy owns the id).
                Color.clear
            } else {
                SlotImage(image: image)
                    .matchedGeometryEffect(id: slot, in: namespace)
                    .onTapGesture(perform: onTap)
            }
        }
        .aspectRatio(3 / 2, contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: Empty state

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

// MARK: - Slot image

/// Renders a selected photo filling its bounds. Shared by the slot preview and
/// the full-screen copy so the matched-geometry transition interpolates cleanly.
private struct SlotImage: View {
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
private struct FullScreenPhotoView: View {
    let slot: Int
    let image: Image
    let namespace: Namespace.ID
    let onClose: () -> Void

    var body: some View {
        SlotImage(image: image)
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

// MARK: - Red Tag model

/// Owns the Red Tag's mutable state: its current safety status, the in-progress
/// comment, and the history feed that records each marking and comment.
@MainActor
@Observable
final class RedTagModel {
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
}

// MARK: - Safety control card

/// The "Mark for Safety" toggle. Flipping it records the new status to History
/// as an independent action. Styled to match the screen's dark cards.
private struct SafetyControlCard: View {
    @Bindable var model: RedTagModel

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

/// A free-form comment entry: the validation field plus an Add Comment button
/// that records the comment to History as an independent action.
private struct CommentCard: View {
    @Bindable var model: RedTagModel

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

#Preview {
    NavigationStack {
        DERTDetailScreen()
    }
}
