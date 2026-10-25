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
    @AppStorage(AppSettings.Key.shareImmediately) var shareImmediately: Bool = true
    var body: some View {
        Group {
            if files.isEmpty {
                Text ("NO_EXPORTED_FILES")
            }
            List{
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
                            deleteFile(with: file.url)
                        }
                    })
                }
                .onDelete(perform: deleteFile)
            }
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
                        Task {
                            do {
                                try await CSVManager.provideCSV()
                            } catch {
                                print("error")
                            }
                        }
                        
                    }) {
                        Image(systemName: "document.badge.plus")
                    }
                }
            })
            ToolbarItem(placement: .topBarTrailing, content: {
                Button(role: .destructive, action: {
                    deleteFiles()
                }) {
                    Image(systemName: "trash")
                }
            })
        }
    }
    
    private func deleteFile(at offsets: IndexSet) {
        for index in offsets {
            deleteFile(with: files[index].url)
        }
    }
    
    private func deleteFiles() {
        for file in files {
            do {
                try CSVManager.deleteCSV(file.url)
            } catch {
                print(error)
            }
        }
    }
    
    private func deleteFile(with url: URL) {
        do {
            try CSVManager.deleteCSV(url)
        } catch {
            print(error)
        }
    }
}

#Preview {
    NavigationView {
        ExportList(isShowing: .constant(true))
    }
}
