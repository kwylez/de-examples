import SwiftUI

/// Collects the requester's name, address, email, and phone number.
public struct UserInfoStep: FormWizardStep {
    public init() {}

    public var id: String { "userInfo" }

    public func content(data: FormWizardData) -> some View {
        UserInfoStepView(data: data)
    }

    public func isValid(data: FormWizardData) -> Bool {
        !data.name.isBlank &&
        !data.address.isBlank &&
        data.email.isValidEmail &&
        !data.phone.isBlank
    }
}

private struct UserInfoStepView: View {
    @Bindable var data: FormWizardData

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                stepHeader(
                    title: "Personal Information",
                    subtitle: "Enter your contact details to get started"
                )

                VStack(spacing: 16) {
                    WizardTextField(
                        label: "Full Name",
                        placeholder: "Jane Smith",
                        text: $data.name,
                        textContentType: .name,
                        autocapitalization: .words
                    )

                    WizardTextField(
                        label: "Address",
                        placeholder: "123 Main St, City, State 00000",
                        text: $data.address,
                        textContentType: .fullStreetAddress,
                        autocapitalization: .words
                    )

                    WizardTextField(
                        label: "Email Address",
                        placeholder: "jane@example.com",
                        text: $data.email,
                        keyboardType: .emailAddress,
                        textContentType: .emailAddress,
                        autocapitalization: .never
                    )

                    WizardTextField(
                        label: "Phone Number",
                        placeholder: "(555) 000-0000",
                        text: $data.phone,
                        keyboardType: .phonePad,
                        textContentType: .telephoneNumber
                    )
                }
            }
            .padding(24)
        }
    }
}
