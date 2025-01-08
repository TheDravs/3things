//
//  ContentView.swift
//  3things
//
//  Created by Matthieu Draveny on 01/01/2025.
//

import SwiftUI
import AppKit
import CoreData

struct ContentView: View {
    // MARK: - Properties
    @EnvironmentObject var userSettings: UserSettings
    @Environment(\.managedObjectContext) private var viewContext
    
    // Fetch request for all entries, sorted by creation date
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Journal.createdAt, ascending: false)],
        animation: .default)
    private var entries: FetchedResults<Journal>
    
    @State private var selection: UUID?
    @State private var entryToDelete: Journal?
    @State private var showingDeleteConfirmation = false
    
    // Computed property to find the selected entry
    var selectedEntry: Journal? {
        guard let selectedId = selection else { return nil }
        return entries.first { $0.id == selectedId }
    }
    
    // MARK: - Body
    var body: some View {
        let _ = print("ContentView is rendering")
        NavigationSplitView {
            List(entries, selection: $selection) { entry in
                VStack(alignment: .leading) {
                    Text(entry.formattedDate)
                        .font(.headline)
                    Text(entry.wrappedTitle.isEmpty ? "What's on your mind today?" : entry.wrappedTitle)
                        .font(.subheadline)
                        .foregroundColor(entry.wrappedTitle.isEmpty ? .secondary : .primary)
                }
                .tag(entry.id)
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    Button(role: .destructive) {
                        entryToDelete = entry
                        showingDeleteConfirmation = true
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
            .confirmationDialog(
                "Are you sure you want to delete this entry?",
                isPresented: $showingDeleteConfirmation,
                presenting: entryToDelete
            ) { entry in
                Button("Delete", role: .destructive) {
                    deleteEntry(entry)
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigation) {
                    Button(action: createTodayEntryIfNeeded) {
                        Label("New Entry", systemImage: "plus")
                    }
                }
                
                ToolbarItem(placement: .automatic) {
                                    SettingsLink {
                                        Label("Settings", systemImage: "gear")
                                    }
                                }
            }
            .task {
                selectOrCreateTodayEntry()
            }
        } detail: {
            if let entry = selectedEntry {
                DocumentEditorView(document: entry)
                    .id(entry.id)
            } else {
                VStack(spacing: 16) {
                    Text("Welcome to your Journal")
                        .font(.title)
                        .foregroundColor(.secondary)
                    Text("Select an entry or create a new one for today")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
        }
    }

    // MARK: - Helper Methods
    private func deleteEntry(_ entry: Journal) {
        withAnimation {
            if entry.id == selection {
                selection = nil
            }
            viewContext.delete(entry)
            try? viewContext.save()
        }
    }
    
    private func selectOrCreateTodayEntry() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // First, try to find today's entry
        if let existingEntry = entries.first(where: { entry in
            let entryDate = calendar.startOfDay(for: entry.wrappedCreatedAt)
            return calendar.compare(entryDate, to: today, toGranularity: .day) == .orderedSame
        }) {
            selection = existingEntry.id
        } else {
            // If not found, create new entry and select it
            let newEntry = Journal(context: viewContext)
            let newId = UUID()
            newEntry.id = newId
            newEntry.createdAt = Date()
            newEntry.updatedAt = Date()
            
            do {
                try viewContext.save()
                selection = newId
            } catch {
                print("Error creating today's entry: \(error)")
            }
        }
    }
    
    private func createTodayEntryIfNeeded() {
        selectOrCreateTodayEntry()
    }
}


