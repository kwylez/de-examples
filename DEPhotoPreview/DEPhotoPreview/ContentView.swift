import SwiftUI
import PhotosUI

// MARK: - Photo grid model

struct Photo: Identifiable {
    let id: Int
    let color: Color
    let systemImage: String
}

private let samplePhotos: [Photo] = [
    Photo(id: 1,  color: .blue,                                                    systemImage: "mountain.2.fill"),
    Photo(id: 2,  color: Color(hue: 0.35, saturation: 0.7, brightness: 0.55),     systemImage: "leaf.fill"),
    Photo(id: 3,  color: .orange,                                                  systemImage: "sun.max.fill"),
    Photo(id: 4,  color: .purple,                                                  systemImage: "moon.stars.fill"),
    Photo(id: 5,  color: Color(hue: 0.02, saturation: 0.8, brightness: 0.75),     systemImage: "flame.fill"),
    Photo(id: 6,  color: .teal,                                                    systemImage: "drop.fill"),
    Photo(id: 7,  color: .indigo,                                                  systemImage: "snowflake"),
    Photo(id: 8,  color: Color(hue: 0.12, saturation: 0.9, brightness: 0.85),     systemImage: "star.fill"),
    Photo(id: 9,  color: .pink,                                                    systemImage: "heart.fill"),
    Photo(id: 10, color: .cyan,                                                    systemImage: "camera.fill"),
    Photo(id: 11, color: Color(hue: 0.45, saturation: 0.6, brightness: 0.55),     systemImage: "map.fill"),
    Photo(id: 12, color: Color(hue: 0.07, saturation: 0.5, brightness: 0.45),     systemImage: "pawprint.fill"),
]

// MARK: - Listing model

/// A mockup real estate listing.
struct Listing: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let propertyType: String
    let location: String
    let systemImage: String
    let tint: Color
    let listPrice: Double
    let estimatedValue: Double
    let beds: Int
    let baths: Int
    let squareFeet: Int
    let summary: String

    /// List price expressed as a fraction of the estimated value, clamped to 0...1.
    /// Drives the accent progress bar on each card.
    var priceFraction: Double {
        guard estimatedValue > 0 else { return 0 }
        return min(max(listPrice / estimatedValue, 0), 1)
    }
}

private let sampleListings: [Listing] = [
    Listing(
        title: "Modern Lakeside Villa",
        propertyType: "Single Family",
        location: "Austin, TX",
        systemImage: "house.fill",
        tint: Color(hue: 0.58, saturation: 0.5, brightness: 0.7),
        listPrice: 1_250_000,
        estimatedValue: 1_310_000,
        beds: 4,
        baths: 3,
        squareFeet: 3_200,
        summary: "A bright, open-plan villa with floor-to-ceiling windows overlooking the lake. Chef's kitchen, infinity pool, and a private dock."
    ),
    Listing(
        title: "Downtown Glass Loft",
        propertyType: "Condo",
        location: "Seattle, WA",
        systemImage: "building.2.fill",
        tint: Color(hue: 0.72, saturation: 0.45, brightness: 0.7),
        listPrice: 720_000,
        estimatedValue: 695_000,
        beds: 2,
        baths: 2,
        squareFeet: 1_450,
        summary: "Industrial-chic loft in the heart of the city. Exposed brick, 14-foot ceilings, and skyline views from every room."
    ),
    Listing(
        title: "Suburban Family Home",
        propertyType: "Single Family",
        location: "Denver, CO",
        systemImage: "house.lodge.fill",
        tint: Color(hue: 0.35, saturation: 0.45, brightness: 0.65),
        listPrice: 545_000,
        estimatedValue: 560_000,
        beds: 3,
        baths: 2,
        squareFeet: 2_100,
        summary: "Move-in ready home on a quiet cul-de-sac. Fenced backyard, finished basement, and top-rated schools nearby."
    ),
    Listing(
        title: "Historic Brownstone",
        propertyType: "Townhouse",
        location: "Boston, MA",
        systemImage: "building.columns.fill",
        tint: Color(hue: 0.05, saturation: 0.45, brightness: 0.6),
        listPrice: 1_480_000,
        estimatedValue: 1_450_000,
        beds: 4,
        baths: 3,
        squareFeet: 2_850,
        summary: "Beautifully restored 19th-century brownstone with original molding, a chef's kitchen, and a landscaped garden patio."
    ),
    Listing(
        title: "Mountain Cabin Retreat",
        propertyType: "Cabin",
        location: "Aspen, CO",
        systemImage: "tent.fill",
        tint: Color(hue: 0.1, saturation: 0.5, brightness: 0.55),
        listPrice: 890_000,
        estimatedValue: 950_000,
        beds: 3,
        baths: 2,
        squareFeet: 1_900,
        summary: "Cozy timber cabin with panoramic mountain views, a stone fireplace, and ski-in/ski-out access to the slopes."
    ),
]

// MARK: - Currency formatting

private extension Double {
    var currency: String {
        formatted(.currency(code: "USD").precision(.fractionLength(2)))
    }
}

// MARK: - Main screen

struct ContentView: View {
    @Namespace private var animation
    @Namespace private var transition
    @State private var selectedPhoto: Photo?

    /// Images chosen from the user's library, keyed by the grid photo's id.
    /// When present, the selected image replaces the placeholder color + symbol.
    @State private var customImages: [Int: Image] = [:]
    @State private var photoPickerItem: PhotosPickerItem?

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 3)

    var body: some View {
        ZStack {
            NavigationStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 28) {
                        // Image grid
                        LazyVGrid(columns: columns, spacing: 12) {
                            ForEach(samplePhotos) { photo in
                                GridPhotoCell(
                                    photo: photo,
                                    customImage: customImageBinding(for: photo),
                                    isExpanded: selectedPhoto?.id == photo.id,
                                    namespace: animation
                                ) {
                                    withAnimation(.bouncy) {
                                        selectedPhoto = photo
                                    }
                                }
                            }
                        }

                        // Real estate listings, below the image grid
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Listings")
                                .font(.title2.weight(.bold))
                                .padding(.horizontal, 6)

                            LazyVStack(spacing: 16) {
                                ForEach(sampleListings) { listing in
                                    NavigationLink(value: listing) {
                                        ListingCard(listing: listing)
                                    }
                                    .buttonStyle(.plain)
                                    .matchedTransitionSource(id: listing.id, in: transition)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 6)
                }
                .contentMargins(10)
                .navigationTitle("Liked")
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        NavigationLink {
                            DERTDetailScreen()
                        } label: {
                            Image(systemName: "info.circle")
                        }
                    }
                }
                .navigationDestination(for: Listing.self) { listing in
                    ListingDetailView(listing: listing)
                        .navigationTransition(.zoom(sourceID: listing.id, in: transition))
                }
            }

            if let photo = selectedPhoto {
                fullScreenDetail(for: photo)
                    .zIndex(1)
            }
        }
    }

    // MARK: Photo grid

    /// A two-way binding into `customImages` for a given grid photo, letting each
    /// cell update its own image while keeping a single source of truth.
    private func customImageBinding(for photo: Photo) -> Binding<Image?> {
        Binding(
            get: { customImages[photo.id] },
            set: { customImages[photo.id] = $0 }
        )
    }

    private func fullScreenDetail(for photo: Photo) -> some View {
        PhotoContent(photo: photo, customImage: customImages[photo.id], iconSize: 80)
            .matchedGeometryEffect(id: photo.id, in: animation)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea()
            .overlay(alignment: .topTrailing) {
                Button {
                    withAnimation(.bouncy) {
                        selectedPhoto = nil
                    }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title)
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(.white, .black.opacity(0.5))
                        .padding()
                }
            }
            .overlay(alignment: .bottom) {
                PhotosPicker(selection: $photoPickerItem, matching: .images) {
                    Label("Change Photo", systemImage: "photo.on.rectangle")
                        .font(.headline)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(.ultraThinMaterial, in: Capsule())
                }
                .padding(.bottom, 50)
            }
            .task(id: photoPickerItem) {
                // Load the picked photo off the main actor, then store it for
                // this grid item so the thumbnail and detail both update.
                guard let photoPickerItem,
                      let image = try? await photoPickerItem.loadTransferable(type: Image.self)
                else { return }
                customImages[photo.id] = image
            }
    }

}

// MARK: - Photo grid cell

/// A single grid thumbnail with its own "Change" photo-library button beneath it.
private struct GridPhotoCell: View {
    let photo: Photo
    @Binding var customImage: Image?
    let isExpanded: Bool
    let namespace: Namespace.ID
    let onTap: () -> Void

    @State private var pickerItem: PhotosPickerItem?

    var body: some View {
        VStack(spacing: 6) {
            thumbnail
                .aspectRatio(1, contentMode: .fill)
                .clipShape(RoundedRectangle(cornerRadius: 10))

            PhotosPicker(selection: $pickerItem, matching: .images) {
                Label("Change", systemImage: "photo")
                    .font(.caption2)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .controlSize(.small)
        }
        .task(id: pickerItem) {
            // Load the picked photo off the main actor; the binding write updates
            // both this thumbnail and the shared full-screen detail.
            guard let pickerItem,
                  let image = try? await pickerItem.loadTransferable(type: Image.self)
            else { return }
            customImage = image
        }
    }

    @ViewBuilder
    private var thumbnail: some View {
        if isExpanded {
            // Placeholder keeps the grid layout intact while the photo is
            // expanded full screen (and lets the matched-geometry copy own the id).
            Color.clear
        } else {
            PhotoContent(photo: photo, customImage: customImage, iconSize: 28)
                .matchedGeometryEffect(id: photo.id, in: namespace)
                .onTapGesture(perform: onTap)
        }
    }
}

// MARK: - Photo content

/// Renders a grid photo: the user-selected image when present, otherwise the
/// placeholder color + SF Symbol. Shared by the grid cell and the full-screen detail.
private struct PhotoContent: View {
    let photo: Photo
    let customImage: Image?
    let iconSize: CGFloat

    var body: some View {
        if let customImage {
            // Color.clear fixes the layout size to the proposed bounds so the
            // filled image is clipped to the frame rather than overflowing it
            // (which would otherwise push the detail view's overlays off-screen).
            Color.clear
                .overlay {
                    customImage
                        .resizable()
                        .scaledToFill()
                }
                .clipped()
        } else {
            photo.color
                .overlay {
                    LinearGradient(
                        colors: [.clear, .black.opacity(0.3)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                }
                .overlay {
                    Image(systemName: photo.systemImage)
                        .font(.system(size: iconSize))
                        .foregroundStyle(.white.opacity(0.9))
                }
        }
    }
}

// MARK: - Listing card

struct ListingCard: View {
    let listing: Listing

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 14) {
                ListingIcon(listing: listing, size: 52, cornerRadius: 12)

                VStack(alignment: .leading, spacing: 2) {
                    Text(listing.title)
                        .font(.title3.weight(.medium))
                        .foregroundStyle(.primary)
                        .lineLimit(1)

                    Text("\(listing.propertyType) · \(listing.location)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                Spacer(minLength: 8)

                Image(systemName: "chevron.right")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.tertiary)
            }

            ProgressBar(fraction: listing.priceFraction)

            HStack {
                Text(listing.listPrice.currency)
                Spacer()
                Text(listing.estimatedValue.currency)
            }
            .font(.subheadline)
            .foregroundStyle(.primary)
        }
        .padding(18)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 22))
    }
}

/// The lavender accent bar shown beneath each listing's header.
struct ProgressBar: View {
    let fraction: Double

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color(.tertiarySystemFill))
                Capsule()
                    .fill(Color(hue: 0.72, saturation: 0.4, brightness: 0.85))
                    .frame(width: proxy.size.width * fraction)
            }
        }
        .frame(height: 4)
    }
}

/// Rounded property thumbnail with a subtle gradient and SF Symbol.
struct ListingIcon: View {
    let listing: Listing
    let size: CGFloat
    let cornerRadius: CGFloat

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(
                LinearGradient(
                    colors: [listing.tint.opacity(0.9), listing.tint.opacity(0.5)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay {
                Image(systemName: listing.systemImage)
                    .font(.system(size: size * 0.45))
                    .foregroundStyle(.white)
            }
            .frame(width: size, height: size)
    }
}

// MARK: - Full screen detail

struct ListingDetailView: View {
    let listing: Listing

    /// The photo chosen from the user's library, if any. When set, it replaces
    /// the gradient placeholder in the header.
    @State private var selectedImage: Image?
    @State private var pickerItem: PhotosPickerItem?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                header

                VStack(alignment: .leading, spacing: 24) {
                    PhotosPicker(selection: $pickerItem, matching: .images) {
                        Label("Change Photo", systemImage: "photo.on.rectangle")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(listing.tint)

                    VStack(alignment: .leading, spacing: 6) {
                        Text(listing.title)
                            .font(.largeTitle.weight(.bold))

                        Label(listing.location, systemImage: "mappin.and.ellipse")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                    }

                    statsRow

                    VStack(alignment: .leading, spacing: 8) {
                        Text("About this property")
                            .font(.headline)
                        Text(listing.summary)
                            .font(.body)
                            .foregroundStyle(.secondary)
                    }

                    priceSummary
                }
                .padding(20)
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(listing.propertyType)
        .navigationBarTitleDisplayMode(.inline)
        .task(id: pickerItem) {
            // Load the picked photo off the main actor; assigning the resulting
            // Image back on the main actor updates the header.
            guard let pickerItem,
                  let image = try? await pickerItem.loadTransferable(type: Image.self)
            else { return }
            selectedImage = image
        }
    }

    private var header: some View {
        headerBackground
            .frame(maxWidth: .infinity)
            .frame(height: 280)
            .clipped()
            .overlay(alignment: .bottomLeading) {
                Text(listing.propertyType.uppercased())
                    .font(.caption.weight(.bold))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(.ultraThinMaterial, in: Capsule())
                    .padding(16)
            }
    }

    @ViewBuilder
    private var headerBackground: some View {
        if let selectedImage {
            selectedImage
                .resizable()
                .scaledToFill()
        } else {
            LinearGradient(
                colors: [listing.tint.opacity(0.9), listing.tint.opacity(0.4)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .overlay {
                Image(systemName: listing.systemImage)
                    .font(.system(size: 96))
                    .foregroundStyle(.white.opacity(0.95))
            }
        }
    }

    private var statsRow: some View {
        HStack(spacing: 0) {
            stat(value: "\(listing.beds)", label: "Beds", systemImage: "bed.double.fill")
            divider
            stat(value: "\(listing.baths)", label: "Baths", systemImage: "shower.fill")
            divider
            stat(value: listing.squareFeet.formatted(), label: "Sq Ft", systemImage: "ruler.fill")
        }
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16))
    }

    private func stat(value: String, label: String, systemImage: String) -> some View {
        VStack(spacing: 4) {
            Image(systemName: systemImage)
                .font(.title3)
                .foregroundStyle(listing.tint)
            Text(value)
                .font(.headline)
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    private var divider: some View {
        Rectangle()
            .fill(Color(.separator))
            .frame(width: 1, height: 36)
    }

    private var priceSummary: some View {
        VStack(spacing: 12) {
            row(title: "List Price", value: listing.listPrice.currency, emphasized: true)
            Divider()
            row(title: "Estimated Value", value: listing.estimatedValue.currency, emphasized: false)
        }
        .padding(18)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16))
    }

    private func row(title: String, value: String, emphasized: Bool) -> some View {
        HStack {
            Text(title)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(emphasized ? .title3.weight(.semibold) : .body)
        }
    }
}

#Preview {
    ContentView()
}
