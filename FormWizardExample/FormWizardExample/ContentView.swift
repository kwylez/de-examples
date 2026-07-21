//
//  ContentView.swift
//  FormWizardExample
//
//  Created by Cory D. Wiles on 6/8/26.
//

import SwiftUI
import FormWizard

struct ContentView: View {
    var body: some View {
        FormWizardView { data in
            let submission = FormWizardSubmission(
                name: data.name,
                address: data.address,
                email: data.email,
                phone: data.phone,
                applianceType: data.applianceType ?? .washerDryer,
                comment: data.comment,
                photos: data.photos,
                scheduledDateTime: data.scheduledDateTime
            )
            print("Submitted by \(submission.name) — \(submission.applianceType.rawValue) on \(submission.scheduledDateTime)")
        } steps: {
            UserInfoStep()
            ApplianceTypeStep()
            PhotoSelectionStep()
            DateTimeStep()
        }
    }
}

#Preview {
    ContentView()
}
