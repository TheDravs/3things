//
//  ContentView.swift
//  3things
//
//  Created by Matthieu Draveny on 01/01/2025.
//

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
    @State private var timeObserver: Any?
    @State private var showingSettings = false
    @State private var showOnlyEditedEntries: Bool = false
    
    // Computed property to find the selected entry
    var selectedEntry: Journal? {
        guard let selectedId = selection else { return nil }
        return entries.first { $0.id == selectedId }
    }
    
    private var filteredEntries: [Journal] {
           if showOnlyEditedEntries {
               return entries.filter { entry in
                   // For example, check if title or content is not empty
                   return !entry.wrappedTitle.isEmpty || !entry.wrappedContentUp.isEmpty ||
                          !entry.wrappedMemory1.isEmpty || !entry.wrappedMemory2.isEmpty ||
                          !entry.wrappedMemory3.isEmpty
               }
           } else {
               return Array(entries)
           }
       }
    
    // MARK: - Body
    var body: some View {
              let _ = print("ContentView is rendering")
              NavigationSplitView {
                  VStack {
                      // Filter toggle
                      Toggle("Show Only Edited", isOn: $showOnlyEditedEntries)
                          .padding(.horizontal)
                          .padding(.top, 8)
                      
                      // Journal entries list
                      List(filteredEntries, id: \.id, selection: $selection) { entry in
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
                  }
                  .toolbar {
                      ToolbarItem(placement: .automatic) {
                          // Version-compatible settings button
                          if #available(macOS 14.0, *) {
                              // Use SettingsLink for macOS 14 and newer
                              SettingsLink {
                                  Label("Settings", systemImage: "gear")
                              }
                          } else {
                              // Fallback for earlier macOS versions
                              Button {
                                  showSettings()
                              } label: {
                                  Label("Settings", systemImage: "gear")
                              }
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
              .onAppear {
                  // Set up notification observer for significant time changes
                  timeObserver = NotificationCenter.default.addObserver(
                      forName: .NSCalendarDayChanged,
                      object: nil,
                      queue: .main
                  ) { _ in
                      selectOrCreateTodayEntry()
                  }
              }
              .onDisappear {
                  // Clean up observer
                  if let observer = timeObserver {
                      NotificationCenter.default.removeObserver(observer)
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
              // If no entry exists for today, create one
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
      
      // Function to show settings for macOS versions earlier than 14.0
      private func showSettings() {
          let settingsView = NSHostingController(rootView: SettingsView().environmentObject(userSettings))
          let settingsWindow = NSWindow(
              contentRect: NSRect(x: 0, y: 0, width: 400, height: 300),
              styleMask: [.titled, .closable, .miniaturizable],
              backing: .buffered,
              defer: false
          )
          settingsWindow.contentViewController = settingsView
          settingsWindow.title = "Settings"
          settingsWindow.center()
          
          // Show the window
          if let mainWindow = NSApp.mainWindow {
              mainWindow.addChildWindow(settingsWindow, ordered: .above)
          } else {
              NSApp.runModal(for: settingsWindow)
          }
      }
  }
