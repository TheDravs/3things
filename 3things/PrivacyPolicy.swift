//
//  PrivacyPolicy.swift
//  3things
//
//  Created by Matthieu Draveny on 07/01/2025.
//

import SwiftUI

struct PrivacyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Privacy Policy")
                    .font(.system(size: 24, weight: .bold))
                
                Group {
                    Text("Last Updated: January 7, 2025")
                        .foregroundColor(.secondary)
                    
                    Text("Data Collection and Storage")
                        .font(.headline)
                    Text("3things Journal is designed with your privacy in mind. All your journal entries and preferences are stored locally on your device using Apple's CoreData framework. We do not collect, transmit, or store any of your personal information on external servers.")
                    
                    Text("Data Usage")
                        .font(.headline)
                    Text("Your data is used exclusively to provide the journaling functionality within the app. This includes storing your journal entries, preferences, and app settings locally on your device.")
                    
                    Text("Data Protection")
                        .font(.headline)
                    Text("Your journal entries are protected by your device's built-in security features. The app uses Apple's standard data protection mechanisms to ensure your data remains private and secure.")
                    
                    Text("Analytics and Crash Reporting")
                        .font(.headline)
                    Text("We use Apple's built-in crash reporting tools to help improve app stability. These reports do not contain any of your personal information or journal content.")
                    
                    Text("Your Rights")
                        .font(.headline)
                    Text("You have full control over your data. You can export or delete all your journal entries at any time through the app's settings menu.")
                    
                    Text("Contact")
                        .font(.headline)
                    Text("If you have any questions about this privacy policy or our data practices, please contact us at privacy@3things-journal.com")
                }
                .padding(.bottom, 8)
            }
            .padding()
            .frame(maxWidth: 800)
        }
    }
}
