import SwiftUI

/// A vertical, multi-step form wizard.
///
/// `FormWizardView` owns navigation, progress, and the Continue/Submit
/// button chrome. Each step's UI and validation are supplied by you via
/// `FormWizardStep` conformances, declared with a `@FormWizardStepBuilder`.
///
/// Present this view full-screen or in a sheet:
///
/// ```swift
/// .sheet(isPresented: $showWizard) {
///     FormWizardView { data in
///         print("Submitted:", data.name)
///     } steps: {
///         UserInfoStep()
///         ApplianceTypeStep()
///         PhotoSelectionStep()
///         DateTimeStep()
///     }
/// }
/// ```
public struct FormWizardView: View {
    private let onSubmit: (FormWizardData) -> Void
    private let steps: [AnyFormWizardStep]

    @State private var data = FormWizardData()
    @State private var currentStep = 0
    @State private var goingForward = true

    @MainActor
    public init(
        onSubmit: @escaping (FormWizardData) -> Void,
        @FormWizardStepBuilder steps: () -> [AnyFormWizardStep]
    ) {
        self.onSubmit = onSubmit
        self.steps = steps()
    }

    private var canProceed: Bool {
        steps[currentStep].isValid(data: data)
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

                WizardProgressBar(currentStep: currentStep, totalSteps: steps.count)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 16)

                ZStack {
                    steps[currentStep].content(data: data)
                        .id(steps[currentStep].id)
                        .transition(stepTransition)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipped()

                Divider()

                WizardButton(
                    title: currentStep == steps.count - 1 ? "Submit" : "Continue",
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
        if currentStep < steps.count - 1 {
            navigate(forward: true)
        } else {
            onSubmit(data)
        }
    }

    private func navigate(forward: Bool) {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
            goingForward = forward
            currentStep += forward ? 1 : -1
        }
    }
}

#Preview {
    FormWizardView { data in
        print("Submitted by \(data.name)")
    } steps: {
        UserInfoStep()
        ApplianceTypeStep()
        PhotoSelectionStep()
        DateTimeStep()
    }
}
