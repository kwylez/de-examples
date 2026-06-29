import Foundation
import UIKit

public struct FormWizardSubmission: @unchecked Sendable {
    public let name: String
    public let address: String
    public let email: String
    public let phone: String
    public let applianceType: ApplianceType
    public let comment: String
    public let photos: [UIImage]
    public let scheduledDateTime: Date
}
