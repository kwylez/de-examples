import Foundation

public enum ApplianceType: String, CaseIterable, Sendable, Identifiable {
    case washerDryer = "Washer / Dryer"
    case fireplace = "Fireplace"
    case grill = "Grill"

    public var id: String { rawValue }

    var icon: String {
        switch self {
        case .washerDryer: "washer.fill"
        case .fireplace: "flame.fill"
        case .grill: "frying.pan.fill"
        }
    }

    var subtitle: String {
        switch self {
        case .washerDryer: "Washing machines & dryers"
        case .fireplace: "Gas, electric & wood-burning"
        case .grill: "Outdoor grills & BBQ equipment"
        }
    }
}
