// Copyright (c) nami.ai

import SwiftUI
import NamiPairingFramework

struct PlaceDevicesListView: View {
    init(viewModel: PlaceDevicesListViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if let bssid = viewModel.state.bssid {
                    VStack {
                        Text("BSSID Pin: " + bssid.map { String(format: "%02.2hhx", $0) }.joined(separator: ":"))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                    }
                }
                
                if viewModel.state.devices.isEmpty == false {
                    List {
                        ForEach(viewModel.state.devices, id: \.id.rawValue) { device in
                            deviceRow(for: device)
                        }
                    }
                } else {
                    Text("Use the menu to start pairing or setup.")
                        .padding()
                    Spacer()
                }
            }
            .navigationTitle("Place devices list")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button("Add Single Device") {
                            viewModel.presentPairing()
                        }
                        Button("Start Setup Guide") {
                            viewModel.presentSetupGuide()
                        }
                        Divider()
                        Button("Show settings") {
                            viewModel.presentSettings()
                        }
                        Button("Show settings with parameter") {
                            viewModel.presentEntityPicker()
                        }
                        Button("Update Wi-Fi credentials") {
                            viewModel.presentUpdateWiFiCredentials()
                        }
                        Button("Create PIN") {
                            viewModel.presentPinCreation()
                        }
                        Button("System test") {
                            viewModel.presentSystemCheckup()
                        }
                        Button("Entry & Exit delay") {
                            viewModel.presentEntryExitDelays()
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                    }
                }
            }
            .sheet(isPresented: Binding(
                get: { viewModel.state.isEntityPickerPresented },
                set: { viewModel.state.isEntityPickerPresented = $0 }
            )) {
                entityPickerSheet
            }
        }
    }

    /// Entity picker for settings with a parameter.
    ///
    /// Lists the place's zones, rooms and devices with the backend mapping keys that point at
    /// each; only those keys resolve. The ID field takes any other id, e.g. to check that an
    /// unmapped one is rejected.
    @ViewBuilder
    private var entityPickerSheet: some View {
        let entityId = viewModel.state.manualEntityId.trimmingCharacters(in: .whitespacesAndNewlines)
        NavigationView {
            Form {
                Section("Entity ID") {
                    TextField("alarm_dot_com:mz:<uuid>", text: $viewModel.state.manualEntityId)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .font(.system(.footnote, design: .monospaced))
                    Button("Open settings for this ID") {
                        viewModel.presentSettings(forEntity: entityId)
                    }
                    .disabled(entityId.isEmpty)
                }
                mappedEntitySections
            }
            .navigationTitle("Entity ID")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        viewModel.state.isEntityPickerPresented = false
                    }
                }
            }
        }
    }

    /// One section per zone, then the mapping keys that match no loaded entity.
    @ViewBuilder
    private var mappedEntitySections: some View {
        if viewModel.state.partnerId == nil {
            Section {
                Text("The session has no partner_id, so there is no mapping to list.")
                    .foregroundStyle(.secondary)
            }
        } else if let tree = viewModel.state.entityPickerTree {
            ForEach(tree.zones) { zone in
                Section {
                    entityRow(title: zone.title, systemImage: "square", externalIds: zone.externalIds, indent: 0)
                    ForEach(zone.rooms) { room in
                        entityRow(title: room.title, systemImage: "square.split.bottomrightquarter", externalIds: room.externalIds, indent: 1)
                        ForEach(room.devices) { device in
                            entityRow(title: device.title, systemImage: "sensor", externalIds: device.externalIds, indent: 2)
                        }
                    }
                }
            }
            if tree.unmatched.isEmpty == false {
                Section("Mapped to entities not in the loaded place") {
                    ForEach(tree.unmatched) { externalId in
                        externalIdButton(externalId)
                    }
                }
            }
        } else {
            Section {
                ProgressView("Loading place and external ID mapping")
            }
        }
    }

    /// An entity's label followed by one button per mapping key that points at it.
    ///
    /// - Parameters:
    ///   - title: The entity's display name.
    ///   - systemImage: The SF Symbol for the entity kind.
    ///   - externalIds: The mapping keys whose URN is this entity's URN.
    ///   - indent: Nesting depth below the zone.
    /// - Returns: The entity's rows.
    @ViewBuilder
    private func entityRow(title: String, systemImage: String, externalIds: [EntityPickerTree.ExternalID], indent: Int) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Label(title, systemImage: systemImage)
                .font(indent == 0 ? .headline : .subheadline)
            if externalIds.isEmpty {
                Text("No external ID")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            ForEach(externalIds) { externalId in
                externalIdButton(externalId)
            }
        }
        .padding(.leading, CGFloat(indent) * 16)
    }

    /// A button that opens settings for a mapping key, showing the key and its mapped URN.
    ///
    /// - Parameter externalId: The mapping key and its URN.
    /// - Returns: The button.
    private func externalIdButton(_ externalId: EntityPickerTree.ExternalID) -> some View {
        Button {
            viewModel.presentSettings(forEntity: externalId.externalId)
        } label: {
            VStack(alignment: .leading, spacing: 2) {
                Text(externalId.externalId)
                    .font(.system(.footnote, design: .monospaced))
                Text("→ \(externalId.urn)")
                    .font(.system(.caption2, design: .monospaced))
                    .foregroundStyle(.secondary)
            }
        }
        .buttonStyle(.borderless)
    }

    @ViewBuilder
    private func deviceRow(for device: Device) -> some View {
        HStack {
            VStack(alignment: .leading) {
                Text(device.name)
                    .font(.headline)
                Text(device.type ?? "unknown")
                    .font(.subheadline)
            }
            
            Spacer()
        }
        .contextMenu {
            Button(action: {
                viewModel.deleteDevice(deviceId: device.id)
            }) {
                Text("Delete")
                Image(systemName: "trash")
            }
        }
    }
    
    @ObservedObject var viewModel: PlaceDevicesListViewModel
}
