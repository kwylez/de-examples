import SwiftUI

/// Type-erased wrapper around a `FormWizardStep`. Produced by
/// `FormWizardStepBuilder` — you won't construct this directly.
@MainActor
public struct AnyFormWizardStep: Identifiable {
    public let id: String
    private let makeContent: (FormWizardData) -> AnyView
    private let validate: (FormWizardData) -> Bool

    init<S: FormWizardStep>(_ step: S) {
        id = step.id
        makeContent = { AnyView(step.content(data: $0)) }
        validate = { step.isValid(data: $0) }
    }

    func content(data: FormWizardData) -> AnyView {
        makeContent(data)
    }

    func isValid(data: FormWizardData) -> Bool {
        validate(data)
    }
}
