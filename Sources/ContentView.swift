import SwiftUI
import PhotosUI
import AppFactoryKit

// AI Interior Design — pick a room photo, preview it in a design style. The
// on-device engine grades the room's mood instantly; full generative redesign
// is wired behind RemoteInteriorService (Pro).
struct ContentView: View {
    @EnvironmentObject private var factory: AppFactory
    private let service: InteriorDesignService = OnDeviceInteriorService()

    @State private var pickerItem: PhotosPickerItem?
    @State private var inputImage: UIImage?
    @State private var outputImage: UIImage?
    @State private var style: DesignStyle = .all[0]
    @State private var isProcessing = false
    @State private var errorText: String?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    preview
                    styleGrid
                    actions
                    if let errorText { Text(errorText).font(.footnote).foregroundStyle(.red) }
                }
                .padding(20)
            }
            .navigationTitle("Interior Design")
        }
        .onChange(of: pickerItem) { _, item in
            guard let item else { return }
            Task { await load(item) }
        }
    }

    private var preview: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 18).fill(.quaternary)
            if let shown = outputImage ?? inputImage {
                Image(uiImage: shown).resizable().scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 18))
            } else {
                VStack(spacing: 10) {
                    Image(systemName: "sofa").font(.system(size: 54)).foregroundStyle(.purple)
                    Text("Pick a room photo").foregroundStyle(.secondary)
                }
            }
            if isProcessing { ProgressView().controlSize(.large) }
        }
        .frame(height: 320)
    }

    private var styleGrid: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 90), spacing: 12)], spacing: 12) {
            ForEach(DesignStyle.all) { s in
                Button { select(s) } label: {
                    VStack(spacing: 6) {
                        Image(systemName: s.icon).font(.title2)
                        Text(s.name).font(.caption2).lineLimit(1)
                    }
                    .frame(maxWidth: .infinity, minHeight: 64)
                    .background(RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(style == s ? Color.purple : .secondary.opacity(0.25), lineWidth: style == s ? 2 : 1))
                    .overlay(alignment: .topTrailing) {
                        if s.isPremium && !factory.subscriptions.isSubscribed {
                            Image(systemName: "lock.fill").font(.system(size: 10)).padding(5)
                        }
                    }
                }
                .buttonStyle(.plain)
                .tint(.purple)
            }
        }
    }

    private var actions: some View {
        VStack(spacing: 12) {
            PhotosPicker(selection: $pickerItem, matching: .images) {
                Label(inputImage == nil ? "Choose Room" : "Choose Another", systemImage: "photo")
                    .frame(maxWidth: .infinity, minHeight: 50)
            }
            .buttonStyle(.bordered)

            if outputImage != nil {
                Button {
                    factory.requirePremium(feature: "save_design") { save() }
                } label: {
                    Label("Save to Photos", systemImage: "square.and.arrow.down").frame(maxWidth: .infinity, minHeight: 50)
                }
                .buttonStyle(.bordered)
            }
        }
    }

    private func select(_ s: DesignStyle) {
        if s.isPremium && !factory.subscriptions.isSubscribed {
            factory.presentPaywall(placement: "style_\(s.id)")
            return
        }
        style = s
        if inputImage != nil { Task { await apply() } }
    }

    private func load(_ item: PhotosPickerItem) async {
        errorText = nil
        if let data = try? await item.loadTransferable(type: Data.self), let img = UIImage(data: data) {
            inputImage = img; outputImage = nil
            await apply()
        } else { errorText = "Couldn't load that photo." }
    }

    private func apply() async {
        guard let inputImage else { return }
        isProcessing = true; errorText = nil
        defer { isProcessing = false }
        do {
            outputImage = try await service.apply(style: style, to: inputImage)
        } catch { errorText = "Couldn't apply that style." }
    }

    private func save() {
        guard let outputImage else { return }
        UIImageWriteToSavedPhotosAlbum(outputImage, nil, nil, nil)
    }
}
