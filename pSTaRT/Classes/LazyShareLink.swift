//
//  LazyShareLink.swift
//  pSTaRT
//
//  Created by Kurt Frey on 23.10.26.
//  Copyright © 2026 Kurt Frey. All rights reserved.
//


// Source - https://stackoverflow.com/a/78348687
// Posted by Deitsch, modified by community. See post 'Timeline' for change history
// Retrieved 2026-10-23, License - CC BY-SA 4.0
import SwiftUI

struct LazyShareLink<Label: View>: View {

    let label: Label
    let prepareData: @MainActor () async throws -> [Any]?
    let onError: (@MainActor (Error) -> Void)?

    @State private var isPreparing = false

    init(
        prepareData: @escaping @MainActor () async throws -> [Any]?,
        onError: (@MainActor (Error) -> Void)? = nil,
        @ViewBuilder label: () -> Label
    ) {
        self.label = label()
        self.prepareData = prepareData
        self.onError = onError
    }

    var body: some View {
        Button(action: openShare) {
            label
        }
        .disabled(isPreparing)
    }

    private func openShare() {
        isPreparing = true
        Task { @MainActor in
            defer { isPreparing = false }
            do {
                guard let data = try await prepareData() else {
                    return
                }
                present(data)
            } catch {
                onError?(error)
            }
        }
    }

    @MainActor
    private func present(_ data: [Any]) {
        let activityVC = UIActivityViewController(activityItems: data, applicationActivities: nil)

        if UIDevice.current.userInterfaceIdiom == .pad {
            // otherwise iPad crashes
            let thisViewVC = UIHostingController(rootView: self)
            activityVC.popoverPresentationController?.sourceView = thisViewVC.view
        }

        UIApplication.shared.connectedScenes
            .flatMap { ($0 as? UIWindowScene)?.windows ?? [] }
            .first { $0.isKeyWindow }?
            .rootViewController?
            .present(activityVC, animated: true, completion: nil)
    }
}

extension LazyShareLink where Label == Text {
    init(
        _ text: LocalizedStringKey,
        prepareData: @escaping @MainActor () async throws -> [Any]?,
        onError: (@MainActor (Error) -> Void)? = nil
    ) {
        self.init(prepareData: prepareData, onError: onError) {
            Text(text)
        }
    }
}

extension LazyShareLink where Label == Image {
    init(
        _ image: Image,
        prepareData: @escaping @MainActor () async throws -> [Any]?,
        onError: (@MainActor (Error) -> Void)? = nil
    ) {
        self.init(prepareData: prepareData, onError: onError) {
            image
        }
    }
}
