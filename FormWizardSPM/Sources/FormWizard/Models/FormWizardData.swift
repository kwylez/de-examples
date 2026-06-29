import SwiftUI
import UIKit

@Observable
@MainActor
final class FormWizardData {
    var name = ""
    var address = ""
    var email = ""
    var phone = ""
    var applianceType: ApplianceType? = nil
    var comment = ""
    var photos: [UIImage] = []
    var scheduledDateTime: Date = Calendar.current.date(
        byAdding: .day, value: 1, to: .now
    ) ?? .now
}
