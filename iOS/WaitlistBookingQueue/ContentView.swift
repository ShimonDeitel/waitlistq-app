import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: Store
    @EnvironmentObject var purchases: PurchaseManager
    @State private var showingAdd = false
    @State private var showingSettings = false
    @State private var showingPaywall = false
    @State private var editingEntry: Entry?

    var body: some View {
        NavigationStack {
            List {
                ForEach(store.entries) { entry in
                    Button {
                        editingEntry = entry
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(entry.title)
                                    .font(Theme.bodyFont.bold())
                                    .foregroundStyle(Theme.textPrimary)
                                if entry.isFavorite {
                                    Image(systemName: "star.fill")
                                        .foregroundStyle(Theme.accent)
                                        .font(.caption)
                                }
                            }
                            if !entry.detail.isEmpty {
                                Text(entry.detail)
                                    .font(Theme.captionFont)
                                    .foregroundStyle(Theme.textSecondary)
                            }
                            Text(entry.date, style: .date)
                                .font(Theme.captionFont)
                                .foregroundStyle(Theme.textSecondary)
                        }
                    }
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            store.delete(entry)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                        Button {
                            store.toggleFavorite(entry)
                        } label: {
                            Label("Favorite", systemImage: "star")
                        }
                        .tint(Theme.accent)
                    }
                }
                .onDelete { offsets in
                    store.delete(at: offsets)
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Waitlist - Booking Queue")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                    }
                    .accessibilityIdentifier("settingsButton")
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        if store.canAddMore {
                            showingAdd = true
                        } else {
                            showingPaywall = true
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                    .accessibilityIdentifier("addEntryButton")
                }
            }
            .overlay {
                if store.entries.isEmpty {
                    ContentUnavailableView("No Clients Yet", systemImage: "tray", description: Text("Tap + to add your first entry."))
                }
            }
            .sheet(isPresented: $showingAdd) {
                EntryEditView(entry: nil)
            }
            .sheet(item: $editingEntry) { entry in
                EntryEditView(entry: entry)
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showingPaywall) {
                PaywallView()
            }
        }
    }
}

struct EntryEditView: View {
    @EnvironmentObject var store: Store
    @Environment(\.dismiss) var dismiss
    @FocusState private var isFocused: Bool

    let entry: Entry?
    @State private var title: String = ""
    @State private var detail: String = ""
    @State private var date: Date = Date()

    var body: some View {
        NavigationStack {
            Form {
                Section("Client") {
                    TextField("Name", text: $title)
                        .focused($isFocused)
                        .accessibilityIdentifier("entryNameField")
                    TextField("Details (wanted service, phone)", text: $detail)
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                }
            }
            .navigationTitle(entry == nil ? "Add Client" : "Edit Client")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        save()
                        dismiss()
                    }
                    .accessibilityIdentifier("entrySaveButton")
                    .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onTapGesture {
                isFocused = false
            }
            .onAppear {
                if let entry {
                    title = entry.title
                    detail = entry.detail
                    date = entry.date
                }
            }
        }
    }

    private func save() {
        if var entry {
            entry.title = title
            entry.detail = detail
            entry.date = date
            store.update(entry)
        } else {
            store.add(Entry(title: title, detail: detail, date: date))
        }
    }
}
