// Copyright (c) nami.ai

import NamiPairingFramework
import SwiftUI

struct SessionCodeView: View {
    @ObservedObject var viewModel: SessionCodeViewModel
    @State private var showErrorPopover = false  // State to control popover visibility
    
    init(viewModel: SessionCodeViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        if viewModel.state.buttonTapped {
            ProgressView()
        } else {
            List{
                Section {
                    Text("Please enter the session code acquired from the partner's application")
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    TextField("Session Code", text: $viewModel.state.sessionCode)
                        .textFieldStyle(.roundedBorder)
                        .disableAutocorrection(true)
                        .textInputAutocapitalization(.never)

                    Text("Client ID")
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    TextField("Client ID", text: $viewModel.state.clientId)
                        .textFieldStyle(.roundedBorder)
                        .disableAutocorrection(true)
                        .textInputAutocapitalization(.never)

                    Text("Base URL")
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    TextField("Base URL", text: $viewModel.state.baseUrl)
                        .textFieldStyle(.roundedBorder)
                        .disableAutocorrection(true)
                        .textInputAutocapitalization(.never)

                    Text("Country code")
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    TextField("Country code", text: $viewModel.state.countryCode)
                        .textFieldStyle(.roundedBorder)
                        .disableAutocorrection(true)
                        .textInputAutocapitalization(.never)
                    
                    Text("Language")
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    TextField("Language", text: $viewModel.state.language)
                        .textFieldStyle(.roundedBorder)
                        .disableAutocorrection(true)
                        .textInputAutocapitalization(.never)

//                    Picker("Appearance", selection: $viewModel.state.appearance) {
//                        Text("\(NamiSdkConfig.Appearance.system)").tag(NamiSdkConfig.Appearance.system)
//                        Text("\(NamiSdkConfig.Appearance.light)").tag(NamiSdkConfig.Appearance.light)
//                        Text("\(NamiSdkConfig.Appearance.dark)").tag(NamiSdkConfig.Appearance.dark)
//                    }
//                    Picker("Measurement system", selection: $viewModel.state.measurementSystem) {
//                        Text("\(NamiSdkConfig.MeasurementSystem.metric)").tag(NamiSdkConfig.MeasurementSystem.metric)
//                        Text("\(NamiSdkConfig.MeasurementSystem.imperial)").tag(NamiSdkConfig.MeasurementSystem.imperial)
//                    }
                }
                Button("Confirm") {
                    viewModel.confirmTapped(onError: { showErrorPopover = true })
                }
                .disabled(viewModel.state.disableButton)
                .popover(isPresented: $showErrorPopover) {
                    if let error = viewModel.state.error {
                        VStack {
                            Text("Error Occurred")
                                .font(.headline)
                                .foregroundColor(.red)
                                .padding(.bottom, 5)
                            
                            Text(error.localizedDescription)
                                .font(.body)
                                .multilineTextAlignment(.center)
                                .padding()
                            
                            Button("Dismiss") {
                                showErrorPopover = false
                                viewModel.clearError()
                            }
                            .buttonStyle(.borderedProminent)
                            .padding(.top, 5)
                        }
                        .padding()
                    }
                }
            }
        }
    }
    
}
