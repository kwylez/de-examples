import SwiftUI

/// A 4-step vertical form wizard for scheduling appliance repair appointments.
///
/// Present this view full-screen or in a sheet. The wizard walks the user through:
/// 1. Personal information
/// 2. Appliance type & comments
/// 3. Photo upload (up to 3)
/// 4. Date & time selection
///
/// ```swift
/// .sheet(isPresented: $showWizard) {
///     FormWizardView { submission in
///         print("Submitted:", submission.name)
///     }
/// }
/// ```
public struct FormWizardView: View {
    private let onSubmit: (FormWizardSubmission) -> Void

    @State private var data = FormWizardData()
    @State private var currentStep = 0
    @State private var goingForward = true

    private let totalSteps = 4

    public init(onSubmit: @escaping (FormWizardSubmission) -> Void) {
        self.onSubmit = onSubmit
    }

    private var canProceed: Bool {
        switch currentStep {
        case 0:
            !data.name.isBlank &&
            !data.address.isBlank &&
            data.email.isValidEmail &&
            !data.phone.isBlank
        case 1:
            data.applianceType != nil &&
            !data.comment.isBlank
        case 2:
            !data.photos.isEmpty
        case 3:
            true
        default:
            false
        }
    }

    private var stepTransition: AnyTransition {
        .asymmetric(
            insertion: .move(edge: goingForward ? .bottom : .top).combined(with: .opacity),
            removal: .move(edge: goingForward ? .top : .bottom).combined(with: .opacity)
        )
    }

    public var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                header

                Divider()

                WizardProgressBar(currentStep: currentStep, totalSteps: totalSteps)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 16)

                ZStack {
                    switch currentStep {
                    case 0:
                        UserInfoStep(data: data)
                            .transition(stepTransition)
                    case 1:
                        ApplianceTypeStep(data: data)
                            .transition(stepTransition)
                    case 2:
                        PhotoSelectionStep(data: data)
                            .transition(stepTransition)
                    case 3:
                        DateTimeStep(data: data)
                            .transition(stepTransition)
                    default:
                        EmptyView()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipped()

                Divider()

                WizardButton(
                    title: currentStep == totalSteps - 1 ? "Submit" : "Continue",
                    isEnabled: canProceed,
                    action: handleAction
                )
                .padding(24)
            }
            .background(.background)
            .clipShape(.rect(cornerRadius: 20))
            .shadow(color: .black.opacity(0.08), radius: 24, y: 8)
            .padding(.horizontal, 16)
            .padding(.vertical, 40)
        }
    }

    private var header: some View {
        HStack {
            Button {
                navigate(forward: false)
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.tint)
                    .frame(width: 44, height: 44)
            }
            .opacity(currentStep > 0 ? 1 : 0)
            .disabled(currentStep == 0)

            Spacer()

            Text("Repair Request")
                .font(.headline)

            Spacer()

            Color.clear.frame(width: 44, height: 44)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }

    private func handleAction() {
        if currentStep < totalSteps - 1 {
            navigate(forward: true)
        } else {
            submit()
        }
    }

    private func navigate(forward: Bool) {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
            goingForward = forward
            currentStep += forward ? 1 : -1
        }
    }

    private func submit() {
        guard let applianceType = data.applianceType else { return }
        onSubmit(FormWizardSubmission(
            name: data.name,
            address: data.address,
            email: data.email,
            phone: data.phone,
            applianceType: applianceType,
            comment: data.comment,
            photos: data.photos,
            scheduledDateTime: data.scheduledDateTime
        ))
    }
}

#Preview {
    FormWizardView { submission in
        print("Submitted by \(submission.name) — \(submission.applianceType.rawValue) on \(submission.scheduledDateTime)")
    }
}
