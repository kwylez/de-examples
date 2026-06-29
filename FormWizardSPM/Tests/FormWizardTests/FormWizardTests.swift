import Testing
import Foundation
@testable import FormWizard

@Suite("String Validation")
struct StringValidationTests {
    @Test func validEmails() {
        #expect("user@example.com".isValidEmail)
        #expect("name.surname@domain.co.uk".isValidEmail)
    }

    @Test func invalidEmails() {
        #expect(!"notanemail".isValidEmail)
        #expect(!"missing@".isValidEmail)
        #expect(!"@nodomain.com".isValidEmail)
    }

    @Test func blankStrings() {
        #expect("".isBlank)
        #expect("   ".isBlank)
        #expect("\n\t".isBlank)
        #expect(!"hello".isBlank)
    }
}

@Suite("ApplianceType")
struct ApplianceTypeTests {
    @Test func allCasesHaveIcons() {
        for type in ApplianceType.allCases {
            #expect(!type.icon.isEmpty)
            #expect(!type.subtitle.isEmpty)
        }
    }

    @Test func rawValuesMatchDisplay() {
        #expect(ApplianceType.washerDryer.rawValue == "Washer / Dryer")
        #expect(ApplianceType.fireplace.rawValue == "Fireplace")
        #expect(ApplianceType.grill.rawValue == "Grill")
    }
}
