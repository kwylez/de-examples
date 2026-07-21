import SwiftUI
import UIKit

/// Shared, observable field state for a `FormWizardView` flow. Passed to each
/// `FormWizardStep`'s `content(data:)` and `isValid(data:)`.
@Observable
@MainActor
public final class FormWizardData {
    public var name = ""
    public var address = ""
    public var email = ""
    public var phone = ""
    public var applianceType: ApplianceType? = nil
    public var comment = ""
    public var photos: [UIImage] = []
    public var scheduledDateTime: Date = Calendar.current.date(
        byAdding: .day, value: 1, to: .now
    ) ?? .now

    public init() {}
}
