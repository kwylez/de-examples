import SwiftUI

struct UserInfoStep: View {
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
