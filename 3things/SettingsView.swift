//
//  SettingsView.swift
//  3things
//
//  Created by Matthieu Draveny on 07/01/2025.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var userSettings: UserSettings
    @State private var showingExportError = false
    @State private var showingDeleteConfirmation = false
    @State private var exportErrorMessage = ""
    
    // Add a state variable to control save panel presentation
    @State private var isExporting = false
    @State private var exportData: Data?
    
    var body: some View {
        Form {
            Section(header: Text("Account")) {
                TextField("Your Name", text: $userSettings.userName)
            }
            
            Section(header: Text("Data Management")) {
                Button("Export All Journal Entries") {
                    initiateExport()
                }
                
                Button("Delete All Data") {
                    showingDeleteConfirmation = true
                }
                .foregroundColor(.red)
            }
        }
        .padding()
        .frame(width: 400, height: 300)
        .alert("Delete All Data?", isPresented: $showingDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                DataManager.shared.deleteAllData()
            }
        } message: {
            Text("This action cannot be undone. All your journal entries will be permanently deleted.")
        }
        .alert("Export Status", isPresented: $showingExportError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(exportErrorMessage)
        }
        // Updated onChange modifier using the new syntax
        .onChange(of: isExporting) {
            if isExporting {
                showSavePanel()
            }
        }
    }
    
    // Rest of the implementation remains the same...
    private func initiateExport() {
        let result = DataManager.shared.exportData()
        
        switch result {
        case .success(let data):
            self.exportData = data
            self.isExporting = true
            
        case .failure(let error):
            DispatchQueue.main.async {
                switch error {
                case .noEntriesFound:
                    exportErrorMessage = "No journal entries found to export."
                case .serializationFailed:
                    exportErrorMessage = "Failed to prepare data for export."
                case .fetchFailed(let underlyingError):
                    exportErrorMessage = "Failed to fetch journal entries: \(underlyingError.localizedDescription)"
                }
                showingExportError = true
            }
        }
    }
    
    private func showSavePanel() {
        guard let data = exportData else { return }
        
        let savePanel = NSSavePanel()
        savePanel.nameFieldLabel = "Export as:"
        savePanel.nameFieldStringValue = "journal_entries.json"
        savePanel.allowedContentTypes = [.json]
        savePanel.canCreateDirectories = true
        
        if let mainWindow = NSApp.mainWindow {
            savePanel.beginSheetModal(for: mainWindow) { response in
                handleSavePanelResponse(response, savePanel: savePanel, data: data)
            }
        } else {
            savePanel.begin { response in
                handleSavePanelResponse(response, savePanel: savePanel, data: data)
            }
        }
        
        self.isExporting = false
    }
    
    private func handleSavePanelResponse(_ response: NSApplication.ModalResponse, savePanel: NSSavePanel, data: Data) {
        if response == .OK, let url = savePanel.url {
            do {
                try data.write(to: url)
                DispatchQueue.main.async {
                    exportErrorMessage = "Journal entries successfully exported!"
                    showingExportError = true
                }
            } catch {
                DispatchQueue.main.async {
                    exportErrorMessage = "Failed to save file: \(error.localizedDescription)"
                    showingExportError = true
                }
            }
        }
    }
}
