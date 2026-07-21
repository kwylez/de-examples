import SwiftUI

/// Result builder that assembles the steps passed to `FormWizardView`.
///
/// ```swift
/// FormWizardView { data in
///     ...
/// } steps: {
///     UserInfoStep()
///     ApplianceTypeStep()
/// }
/// ```
@resultBuilder
@MainActor
public struct FormWizardStepBuilder {
    public static func buildBlock<each S: FormWizardStep>(_ step: repeat each S) -> [AnyFormWizardStep] {
        var steps: [AnyFormWizardStep] = []
        repeat steps.append(AnyFormWizardStep(each step))
        return steps
    }
}
