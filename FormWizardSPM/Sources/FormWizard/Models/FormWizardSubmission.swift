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

    public init(
        name: String,
        address: String,
        email: String,
        phone: String,
        applianceType: ApplianceType,
        comment: String,
        photos: [UIImage],
        scheduledDateTime: Date
    ) {
        self.name = name
        self.address = address
        self.email = email
        self.phone = phone
        self.applianceType = applianceType
        self.comment = comment
        self.photos = photos
        self.scheduledDateTime = scheduledDateTime
    }
}
