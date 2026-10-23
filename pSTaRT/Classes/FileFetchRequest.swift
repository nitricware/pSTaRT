//
//  FileFetchRequest.swift
//
//  A SwiftUI counterpart to @FetchRequest / FetchedResults – for files.
//  Watches a directory (DispatchSource/kqueue) and updates the view whenever
//  files are added, removed, renamed or modified.
//
//  Requirements: iOS 17 / macOS 14 (Observation), Swift 5.9+ (Swift 6 clean).
//
//  Usage:
//
//      struct DocumentsView: View {
//          @FileFetchRequest(
//              directory: .documentsDirectory,
//              pathExtensions: ["txt", "md"],
//              sortDescriptors: [KeyPathComparator(\.modificationDate, order: .reverse)]
//          )
//          private var files
//
//          var body: some View {
//              List(files) { file in
//                  Text(file.name)
//              }
//              .refreshable { $files.refresh() }
//          }
//      }
//

import Foundation
import Observation
import SwiftUI

// MARK: - Model

public struct FileItem: Identifiable, Hashable, Sendable {
    public var id: URL { url }
    public let url: URL
    public let isDirectory: Bool
    public let fileSize: Int?
    public let creationDate: Date?
    public let modificationDate: Date?

    public var name: String { url.lastPathComponent }
    public var pathExtension: String { url.pathExtension }
}

/// Analogous to `FetchedResults`: a random-access collection of the current files.
public struct FileFetchedResults: RandomAccessCollection, Equatable, Sendable {
    public let items: [FileItem]

    public var startIndex: Int { items.startIndex }
    public var endIndex: Int { items.endIndex }
    public subscript(position: Int) -> FileItem { items[position] }
}

// MARK: - Property Wrapper

@propertyWrapper
public struct FileFetchRequest: DynamicProperty {
    @State private var watcher = DirectoryWatcher()

    private let configuration: DirectoryWatcher.Configuration
    private let sortDescriptors: [KeyPathComparator<FileItem>]
    private let filter: (@Sendable (FileItem) -> Bool)?
    private let transaction: Transaction

    /// - Parameters:
    ///   - directory: The directory to watch (not recursive).
    ///   - pathExtensions: Only include files with these extensions (case-insensitive). `nil` = all.
    ///   - includesHidden: Include hidden files (".foo").
    ///   - includesDirectories: Include subdirectories in the results.
    ///   - watchesFileContents: Also report content changes of individual files
    ///     (opens one file descriptor per file). Otherwise only add/remove/rename is reported.
    ///   - sortDescriptors: Sort order, e.g. `KeyPathComparator(\.name)`.
    ///   - animation: The animation used when the results change. The initial load is never animated.
    ///   - filter: Additional filter. Note: closures can't be compared, so a changed
    ///     filter only takes effect on the next scan (or after `refresh()`).
    public init(
        directory: URL,
        pathExtensions: Set<String>? = nil,
        includesHidden: Bool = false,
        includesDirectories: Bool = false,
        watchesFileContents: Bool = true,
        sortDescriptors: [KeyPathComparator<FileItem>] = [KeyPathComparator(\.name)],
        animation: Animation? = nil,
        filter: (@Sendable (FileItem) -> Bool)? = nil
    ) {
        self.init(
            directory: directory,
            pathExtensions: pathExtensions,
            includesHidden: includesHidden,
            includesDirectories: includesDirectories,
            watchesFileContents: watchesFileContents,
            sortDescriptors: sortDescriptors,
            transaction: Transaction(animation: animation),
            filter: filter
        )
    }

    /// Same as above, but with a full `Transaction` applied when the results change.
    public init(
        directory: URL,
        pathExtensions: Set<String>? = nil,
        includesHidden: Bool = false,
        includesDirectories: Bool = false,
        watchesFileContents: Bool = true,
        sortDescriptors: [KeyPathComparator<FileItem>] = [KeyPathComparator(\.name)],
        transaction: Transaction,
        filter: (@Sendable (FileItem) -> Bool)? = nil
    ) {
        self.configuration = .init(
            directory: directory.standardizedFileURL,
            pathExtensions: pathExtensions.map { Set($0.map { $0.lowercased() }) },
            includesHidden: includesHidden,
            includesDirectories: includesDirectories,
            watchesFileContents: watchesFileContents
        )
        self.sortDescriptors = sortDescriptors
        self.filter = filter
        self.transaction = transaction
    }

    @MainActor public var wrappedValue: FileFetchedResults { watcher.results }

    /// Access to the watcher: `$files.error`, `$files.isLoading`, `$files.refresh()`.
    @MainActor public var projectedValue: DirectoryWatcher { watcher }

    // SwiftUI always calls update() on the main thread.
    public nonisolated func update() {
        let (watcher, configuration, sortDescriptors, filter) =
            (watcher, configuration, sortDescriptors, filter)
        // `Transaction` isn't Sendable, but we never actually leave the main thread.
        nonisolated(unsafe) let transaction = transaction
        MainActor.assumeIsolated {
            watcher.apply(
                configuration,
                sortDescriptors: sortDescriptors,
                filter: filter,
                transaction: transaction
            )
        }
    }
}

// MARK: - Watcher

@MainActor
@Observable
public final class DirectoryWatcher {
    public struct Configuration: Equatable, Sendable {
        var directory: URL
        var pathExtensions: Set<String>?
        var includesHidden: Bool
        var includesDirectories: Bool
        var watchesFileContents: Bool
    }

    public private(set) var results = FileFetchedResults(items: [])
    public private(set) var error: (any Error)?
    public private(set) var isLoading = false

    @ObservationIgnored private var configuration: Configuration?
    @ObservationIgnored private var sortDescriptors: [KeyPathComparator<FileItem>] = []
    @ObservationIgnored private var filter: (@Sendable (FileItem) -> Bool)?
    @ObservationIgnored private var transaction = Transaction()
    @ObservationIgnored private var hasLoaded = false
    @ObservationIgnored private let sources = SourceBag()
    @ObservationIgnored private var pendingScan: Task<Void, Never>?

    /// Events within this window are coalesced into a single scan.
    private static let debounce: Duration = .milliseconds(100)

    public nonisolated init() {}

    /// Forces an immediate rescan.
    public func refresh() {
        scheduleScan(after: .zero)
    }

    func apply(
        _ configuration: Configuration,
        sortDescriptors: [KeyPathComparator<FileItem>],
        filter: (@Sendable (FileItem) -> Bool)?,
        transaction: Transaction
    ) {
        self.filter = filter
        self.transaction = transaction
        if configuration != self.configuration {
            self.configuration = configuration
            self.sortDescriptors = sortDescriptors
            startWatching()
        } else if sortDescriptors != self.sortDescriptors {
            self.sortDescriptors = sortDescriptors
            // Don't sort synchronously: we're in the middle of a view update.
            scheduleScan(after: .zero)
        }
    }

    // MARK: Watching

    private func startWatching() {
        sources.cancelAll()
        guard let configuration else { return }

        sources.directory = makeSource(
            for: configuration.directory,
            mask: [.write, .delete, .rename, .revoke]
        ) { [weak self] event in
            guard let self else { return }
            if !event.isDisjoint(with: [.delete, .rename, .revoke]) {
                // The directory itself was moved/deleted → re-attach.
                self.startWatching()
            } else {
                self.scheduleScan(after: Self.debounce)
            }
        }

        if sources.directory == nil {
            error = CocoaError(.fileNoSuchFile, userInfo: [NSURLErrorKey: configuration.directory])
            results = FileFetchedResults(items: [])
            return
        }
        scheduleScan(after: .zero)
    }

    private func updateFileSources(for items: [FileItem]) {
        guard configuration?.watchesFileContents == true else {
            sources.cancelFiles()
            return
        }
        let wanted = Set(items.lazy.filter { !$0.isDirectory }.map(\.url))

        for (url, source) in sources.files where !wanted.contains(url) {
            source.cancel()
            sources.files[url] = nil
        }
        for url in wanted where sources.files[url] == nil {
            sources.files[url] = makeSource(
                for: url,
                mask: [.write, .extend, .attrib, .delete, .rename]
            ) { [weak self] _ in
                self?.scheduleScan(after: Self.debounce)
            }
        }
    }

    private func makeSource(
        for url: URL,
        mask: DispatchSource.FileSystemEvent,
        handler: @escaping @MainActor @Sendable (DispatchSource.FileSystemEvent) -> Void
    ) -> DispatchSourceFileSystemObject? {
        let fd = open(url.path(percentEncoded: false), O_EVTONLY)
        guard fd >= 0 else { return nil }

        let source = DispatchSource.makeFileSystemObjectSource(
            fileDescriptor: fd, eventMask: mask, queue: .main
        )
        source.setEventHandler { [weak source] in
            guard let event = source?.data else { return }
            MainActor.assumeIsolated { handler(event) }
        }
        source.setCancelHandler { close(fd) }
        source.resume()
        return source
    }

    // MARK: Scanning

    private func scheduleScan(after delay: Duration) {
        pendingScan?.cancel()
        pendingScan = Task { [weak self] in
            if delay > .zero {
                try? await Task.sleep(for: delay)
            }
            guard !Task.isCancelled else { return }
            await self?.performScan()
        }
    }

    private func performScan() async {
        guard let configuration else { return }
        let sortDescriptors = sortDescriptors
        let filter = filter

        isLoading = true
        let outcome = await Task.detached(priority: .utility) {
            Result {
                var items = try Self.scan(configuration)
                if let filter { items = items.filter(filter) }
                items.sort(using: sortDescriptors)
                return items
            }
        }.value
        isLoading = false

        // Configuration changed in the meantime → discard the result.
        guard configuration == self.configuration, !Task.isCancelled else { return }

        switch outcome {
        case .success(let items):
            if error != nil { error = nil }
            let newResults = FileFetchedResults(items: items)
            if newResults != results {
                if hasLoaded {
                    withTransaction(transaction) { results = newResults }
                } else {
                    results = newResults
                }
            }
            hasLoaded = true
            updateFileSources(for: items)
        case .failure(let scanError):
            error = scanError
        }
    }

    private nonisolated static func scan(_ configuration: Configuration) throws -> [FileItem] {
        let keys: [URLResourceKey] = [
            .isDirectoryKey, .fileSizeKey, .creationDateKey, .contentModificationDateKey,
        ]
        let urls = try FileManager.default.contentsOfDirectory(
            at: configuration.directory,
            includingPropertiesForKeys: keys,
            options: configuration.includesHidden ? [] : [.skipsHiddenFiles]
        )
        let keySet = Set(keys)

        return urls.compactMap { url in
            let values = try? url.resourceValues(forKeys: keySet)
            let isDirectory = values?.isDirectory ?? false

            if isDirectory, !configuration.includesDirectories { return nil }
            if !isDirectory,
               let extensions = configuration.pathExtensions,
               !extensions.contains(url.pathExtension.lowercased()) {
                return nil
            }
            return FileItem(
                url: url.standardizedFileURL,
                isDirectory: isDirectory,
                fileSize: values?.fileSize,
                creationDate: values?.creationDate,
                modificationDate: values?.contentModificationDate
            )
        }
    }
}

// MARK: - Source storage

/// Holds the dispatch sources and cancels them in deinit
/// (the main-actor watcher's own deinit is nonisolated).
/// Only mutated from the main actor.
private final class SourceBag: @unchecked Sendable {
    var directory: DispatchSourceFileSystemObject?
    var files: [URL: DispatchSourceFileSystemObject] = [:]

    func cancelFiles() {
        files.values.forEach { $0.cancel() }
        files.removeAll()
    }

    func cancelAll() {
        directory?.cancel()
        directory = nil
        cancelFiles()
    }

    deinit { cancelAll() }
}
