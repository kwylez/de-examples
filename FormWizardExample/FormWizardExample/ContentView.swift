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
        FormWizardView { submission in
            print("Submitted by \(submission.name) — \(submission.applianceType.rawValue) on \(submission.scheduledDateTime)")
        }
    }
}

#Preview {
    ContentView()
}
