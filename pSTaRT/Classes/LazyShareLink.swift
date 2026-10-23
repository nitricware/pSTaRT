//
//  LazyShareLink.swift
//  pSTaRT
//
//  Created by Kurt Frey on 23.10.26.
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
            // The label stays in the layout (just hidden) so the button keeps
            // its size and doesn't jump while the spinner is shown.
            ZStack {
                label
                    .opacity(isPreparing ? 0 : 1)
                if isPreparing {
                    ProgressView()
                }
            }
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
        guard var presenter = UIApplication.shared.connectedScenes
            .flatMap({ ($0 as? UIWindowScene)?.windows ?? [] })
            .first(where: { $0.isKeyWindow })?
            .rootViewController else {
            return
        }

        // The link may live inside a sheet, so present from the topmost
        // controller instead of the root, which is already presenting.
        while let presented = presenter.presentedViewController, !presented.isBeingDismissed {
            presenter = presented
        }

        let activityVC = UIActivityViewController(activityItems: data, applicationActivities: nil)

        // iPad presents the share sheet as a popover, which needs an on-screen anchor.
        if let popover = activityVC.popoverPresentationController {
            popover.sourceView = presenter.view
            popover.sourceRect = CGRect(x: presenter.view.bounds.midX, y: presenter.view.bounds.midY, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }

        presenter.present(activityVC, animated: true, completion: nil)
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
