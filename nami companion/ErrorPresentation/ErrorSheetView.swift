// Copyright (c) nami.ai

import SwiftUI

struct ErrorSheetView: View {
    let error: NamiError
    let dismiss: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)
                .foregroundColor(.red)
            
            Text("An error occurred")
                .font(.title)
                .fontWeight(.bold)

            Text(error.localizedDescription)
                .multilineTextAlignment(.center)
                .padding()

            Button(action: dismiss) {
                Text("Dismiss")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
        }
        .padding()
        .frame(maxWidth: 400)
    }
}
