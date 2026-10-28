//
//  ExportList.swift
//  pSTaRT
//
//  Created by Kurt Frey on 23.10.26.
//  Copyright © 2026 Kurt Frey. All rights reserved.
//

import SwiftUI

struct ExportList: View {
    @FileFetchRequest(
        directory: .documentsDirectory,
        pathExtensions: ["csv"],
        watchesFileContents: false,
        sortDescriptors: [KeyPathComparator(\.modificationDate, order: .reverse)],
        animation: .default
    ) private var files
    
    @Binding public var isShowing: Bool
    
    @State private var isExporting: Bool = false
    @State public var isShowingDeleteAll: Bool = false
    @State public var errorMessage: Error?
    
    @AppStorage(AppSettings.Key.shareImmediately) var shareImmediately: Bool = AppSettings.Default.shareImmediately
    
    var body: some View {
                List {
                    ForEach(files) { file in
                        HStack {
                            VStack {
                                Text("PERSON_LIST_FILE")
                                Text(file.creationDate!, style: .date)
                                    .font(.caption)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            ShareLink(item: file.url) {
                                Image(systemName: "square.and.arrow.up")
                            }
                        }
                        .swipeActions(edge: .leading) {
                            ShareLink(item: file.url)
                        }
                        .contextMenu(menuItems: {
                            ShareLink(item: file.url)
                            Button("DELETE", systemImage: "trash", role: .destructive) {
                                do {
                                    try deleteFile(with: file.url)
                                } catch {
                                    errorMessage = error
                                }
                            }
                        })
                    }
                    .onDelete(perform: deleteFile)
                }
                .overlay {
                        if files.isEmpty { ContentUnavailableView("NO_EXPORTED_FILES", systemImage: "doc") }
                    }
        .navigationTitle("CSV_FILES")
        .toolbar {
            ToolbarItem(placement: .topBarLeading, content: {
                Button(action: {
                    isShowing.toggle()
                }) {
                    Image(systemName: "xmark")
                }
            })
            ToolbarItem(placement: .topBarTrailing, content: {
                if shareImmediately {
                    LazyShareLink(Image(systemName: "document.badge.plus")) {
                        [try await CSVManager.provideCSV()]
                    } onError: { error in
                        print(error)
                    }
                } else {
                    Button(action: {
                        isExporting = true
                        Task {
                            defer { isExporting = false }
                            do {
                                try await CSVManager.provideCSV()
                            } catch {
                                errorMessage = error
                            }
                        }
                        
                    }) {
                        if isExporting {
                            ProgressView()
                        } else {
                            Image(systemName: "document.badge.plus")
                        }
                    }
                    .disabled(isExporting)
                    
                }
            })
            ToolbarItem(placement: .topBarTrailing, content: {
                Button(role: .destructive, action: {
                    isShowingDeleteAll.toggle()
                }) {
                    Image(systemName: "trash")
                }
                .disabled(files.isEmpty)
                .alert("exportList.deleteAll", isPresented: $isShowingDeleteAll) {
                    Button("CANCEL", role: .cancel) { }
                    Button("CONFIRM", role: .destructive) {
                        do {
                            try deleteFiles()
                        } catch {
                            errorMessage = error
                        }
                    }
                }
            })
        }
        .alert(error: $errorMessage, actions: {
            Button("OK") {
                return
            }
        })
    }
    
    private func deleteFile(at offsets: IndexSet) {
        for index in offsets {
            do {
                try deleteFile(with: files[index].url)
            } catch {
                errorMessage = error
            }
        }
    }
    
    private func deleteFiles() throws {
        for file in files {
            try CSVManager.deleteCSV(file.url)
        }
        throw pSTaRTErrors.dbDeleteError
    }
    
    private func deleteFile(with url: URL) throws {
        try CSVManager.deleteCSV(url)
    }
}

#Preview {
    NavigationStack {
        ExportList(isShowing: .constant(true))
    }
}
