import SwiftUI
import UIKit
import PhotosUI

struct PhotoSelectionStep: View {
    @Bindable var data: FormWizardData
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var isLoadingPhotos = false

    private let maxPhotos = 3
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 3)

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                stepHeader(
                    title: "Upload Photos",
                    subtitle: "Add up to 3 photos of the appliance"
                )

                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(0..<maxPhotos, id: \.self) { index in
                        if index < data.photos.count {
                            PhotoThumbnail(image: data.photos[index]) {
                                data.photos.remove(at: index)
                                syncSelectedItems()
                            }
                        } else {
                            PhotoSlotPicker(
                                isEnabled: data.photos.count < maxPhotos,
                                selectedItems: $selectedItems,
                                existingCount: data.photos.count,
                                maxPhotos: maxPhotos
                            )
                        }
                    }
                }

                if isLoadingPhotos {
                    HStack {
                        ProgressView()
                            .scaleEffect(0.8)
                        Text("Loading photos…")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }

                HStack(spacing: 8) {
                    Image(systemName: "camera.fill")
                        .font(.footnote)
                        .foregroundStyle(.secondary)

                    Text("Clear, well-lit photos help us accurately assess the repair.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.tertiarySystemFill))
                .clipShape(.rect(cornerRadius: 10))
            }
            .padding(24)
        }
        .onChange(of: selectedItems) { _, newItems in
            loadPhotos(from: newItems)
        }
    }

    private func loadPhotos(from items: [PhotosPickerItem]) {
        isLoadingPhotos = true
        Task { @MainActor in
            var loaded: [UIImage] = []
            for item in items {
                if let data = try? await item.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    loaded.append(uiImage)
                }
            }
            data.photos = loaded
            isLoadingPhotos = false
        }
    }

    private func syncSelectedItems() {
        selectedItems = Array(selectedItems.prefix(data.photos.count))
    }
}

private struct PhotoThumbnail: View {
    let image: UIImage
    let onRemove: () -> Void

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity)
                .aspectRatio(1, contentMode: .fill)
                .clipShape(.rect(cornerRadius: 12))

            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .font(.title3)
                    .foregroundStyle(.white)
                    .shadow(radius: 2)
                    .padding(6)
            }
        }
    }
}

private struct PhotoSlotPicker: View {
    let isEnabled: Bool
    @Binding var selectedItems: [PhotosPickerItem]
    let existingCount: Int
    let maxPhotos: Int

    var body: some View {
        PhotosPicker(
            selection: $selectedItems,
            maxSelectionCount: maxPhotos,
            matching: .images,
            photoLibrary: .shared()
        ) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.tertiarySystemFill))
                    .aspectRatio(1, contentMode: .fill)

                Image(systemName: "plus")
                    .font(.title2)
                    .foregroundStyle(isEnabled ? Color.accentColor : Color(.systemFill))
            }
        }
        .disabled(!isEnabled)
    }
}
