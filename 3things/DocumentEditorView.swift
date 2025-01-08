import SwiftUI
import CoreData

struct DocumentEditorView: View {
    @ObservedObject var document: Journal
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var userSettings: UserSettings
    
    private var title: Binding<String> {
        Binding(
            get: { document.title ?? "" },
            set: { newValue in
                document.title = newValue
                saveDocument()
            }
        )
    }
    
    private var contentUp: Binding<String> {
        Binding(
            get: { document.contentUp ?? "" },
            set: { newValue in
                document.contentUp = newValue
                saveDocument()
            }
        )
    }
    
    private var contentDown: Binding<String> {
        Binding(
            get: { document.contentDown ?? "" },
            set: { newValue in
                document.contentDown = newValue
                saveDocument()
            }
        )
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Time greeting section
            TimeGreetingView()
                .padding(.bottom)
            
            HStack {
                Text(document.formattedDate)
                    .font(.title)
                    .padding()
                Spacer()
            }
            
            TextField("What's on your mind today?", text: title)
                .textFieldStyle(.plain)
                .font(.title2)
                .padding(.horizontal)
                .padding(.bottom)
            
            Divider()
                .padding(.bottom, 16)
            
            // Main content with ScrollView
            GeometryReader { geometry in
                ScrollView(showsIndicators: true) {
                    VStack(spacing: 20) {
                        // Journal section
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Journal")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            TextEditor(text: contentUp)
                                .font(.body)
                                .frame(height: 150)
                                .padding()
                                .background(Color(NSColor.textBackgroundColor))
                                .cornerRadius(8)
                        }
                        .padding(.horizontal)
                        
                        Divider()
                            .padding(.vertical, 8)
                        
                        // 3 things section
                        VStack(alignment: .leading, spacing: 8) {
                            Text("3 things I'll remember")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            VStack(alignment: .leading, spacing: 12) {
                                MemoryCheckboxRow(text: memory1, isChecked: memory1Checked)
                                MemoryCheckboxRow(text: memory2, isChecked: memory2Checked)
                                MemoryCheckboxRow(text: memory3, isChecked: memory3Checked)
                            }
                            .padding()
                            .background(Color(NSColor.textBackgroundColor))
                            .cornerRadius(8)
                        }
                        .padding(.horizontal)
                    }
                    .padding(.bottom, 20)
                }
            }
            .padding(.top)
        }
    }
    
    private func saveDocument() {
        document.updatedAt = Date()
        
        do {
            try viewContext.save()
        } catch {
            func handleError(_ error: Error) {
                DispatchQueue.main.async {
                    // Show alert or notification to user
                    let alert = NSAlert()
                    alert.messageText = "Error"
                    alert.informativeText = error.localizedDescription
                    alert.alertStyle = .warning
                    alert.runModal()
                }
            }
            
        }
    }
    
    private var memory1: Binding<String> {
        Binding(
            get: { document.memory1 ?? "" },
            set: { newValue in
                document.memory1 = newValue
                saveDocument()
            }
        )
    }
    
    private var memory1Checked: Binding<Bool> {
        Binding(
            get: { document.memory1Checked },
            set: { newValue in
                document.memory1Checked = newValue
                saveDocument()
            }
        )
    }
    
    private var memory2: Binding<String> {
        Binding(
            get: { document.memory2 ?? "" },
            set: { newValue in
                document.memory2 = newValue
                saveDocument()
            }
        )
    }
    
    private var memory2Checked: Binding<Bool> {
        Binding(
            get: { document.memory2Checked },
            set: { newValue in
                document.memory2Checked = newValue
                saveDocument()
            }
        )
    }
    
    private var memory3: Binding<String> {
        Binding(
            get: { document.memory3 ?? "" },
            set: { newValue in
                document.memory3 = newValue
                saveDocument()
            }
        )
    }
    
    private var memory3Checked: Binding<Bool> {
        Binding(
            get: { document.memory3Checked },
            set: { newValue in
                document.memory3Checked = newValue
                saveDocument()
            }
        )
    }
}

// MARK: - MemoryCheckboxRow
struct MemoryCheckboxRow: View {
    @Binding var text: String
    @Binding var isChecked: Bool
    
    var body: some View {
        HStack {
            Toggle("", isOn: $isChecked)
                .toggleStyle(CheckboxToggleStyle())
                .labelsHidden()
            
            TextField("Enter something you've learned today", text: $text)
                .textFieldStyle(.plain)
        }
    }
}
