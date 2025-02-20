// Copyright (c) nami.ai

import Foundation

struct NamiError: Identifiable {
    let id = UUID()
    let error: Error
    let localizedDescription: String

    init(_ error: Error) {
        self.error = error
        self.localizedDescription = error.localizedDescription
    }
}
