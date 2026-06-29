//
//  SharePostSheet.swift
//  Binbon
//

import SwiftUI
import UIKit

// MARK: - Share post sheet
struct SharePostSheet: View {
    let shareURL: URL
    var onSelect: ((ShareDestination) -> Void)? = nil
    var onSelectContact: ((ShareContact) -> Void)? = nil

    @StateObject private var viewModel: ShareViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var sheetHeight: CGFloat = 0

    init(
        shareURL: URL,
        onSelect: ((ShareDestination) -> Void)? = nil,
        onSelectContact: ((ShareContact) -> Void)? = nil
    ) {
        self.shareURL = shareURL
        self.onSelect = onSelect
        self.onSelectContact = onSelectContact
        _viewModel = StateObject(wrappedValue: ShareViewModel())
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            header
            VStack(alignment: .leading, spacing: 22) {
                contactsRow
                destinationsRow(ShareDestination.mediaApps)
                destinationsRow(ShareDestination.actions)
            }
        }
        .task { viewModel.load() }
        .padding(.bottom, 40)
        .frame(maxWidth: .infinity, alignment: .leading)
        .fixedSize(horizontal: false, vertical: true)
        .background {
            GeometryReader { proxy in
                Color.clear.preference(key: SheetHeightKey.self, value: proxy.size.height)
            }
        }
        .onPreferenceChange(SheetHeightKey.self) { sheetHeight = $0 }
        .presentationDetents(sheetHeight > 0 ? [.height(sheetHeight)] : [.medium])
    }
    
    private var header: some View {
        ZStack {
            Text("send_to".localized)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(AppColor.shareText)
            
            HStack {
                Button { dismiss() } label: {
                    icon("CommentClose", size: 24)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(Text("close".localized))
                
                Spacer()
                
                icon("share-search", size: 18)
                    .accessibilityHidden(true)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 20)
    }
    
    private func icon(_ name: String, size: CGFloat) -> some View {
        Image(name)
            .renderingMode(.template)
            .resizable()
            .scaledToFit()
            .frame(width: size, height: size)
            .foregroundStyle(AppColor.shareText)
    }
    
    private var contactsRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(alignment: .top, spacing: 10) {
                ForEach(viewModel.contacts) { contact in
                    Button {
                        onSelectContact?(contact)
                        dismiss()
                    } label: {
                        VStack(spacing: 4) {
                            ImageView(contact.avatarURL)
                                .frame(width: 50, height: 50)
                                .background(.purple)
                                .clipShape(Circle())
                            label(contact.name)
                        }
                        .frame(width: 64)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 20)
        }
        .fixedSize(horizontal: false, vertical: true)
    }
    
    private func destinationsRow(_ destinations: [ShareDestination]) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(alignment: .top, spacing: 10) {
                ForEach(destinations) { destination in
                    Button {
                        handle(destination)
                    } label: {
                        VStack(spacing: 4) {
                            badge(for: destination)
                            label(destination.title)
                        }
                        .frame(width: 64)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 20)
        }
        .fixedSize(horizontal: false, vertical: true)
    }
    
    @ViewBuilder
    private func badge(for destination: ShareDestination) -> some View {
        Image(destination.assetName)
            .resizable()
            .scaledToFit()
            .background(.purple)
            .clipShape(Circle())
            .frame(width: 50, height: 50)
    }
    
    private func label(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 14, weight: .medium))
            .foregroundStyle(AppColor.shareText)
            .multilineTextAlignment(.center)
            .lineLimit(2)
            .minimumScaleFactor(0.6)
            .frame(height: 34, alignment: .top)
    }
    
    private func handle(_ destination: ShareDestination) {
        switch destination {
        case .copyLink:
            UIPasteboard.general.string = shareURL.absoluteString
            dismiss()
            Toaster.shared.show(.success("square.on.square"), "copied_clipboard".localized)
        default:
            onSelect?(destination)
            dismiss()
        }
    }
}

// MARK: - Height measurement

/// Carries the measured content height up so the sheet detent can match it.
private struct SheetHeightKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

// MARK: - Presentation

/// Hosts the share sheet plus the confirm-before-open popup. Tapping an
/// external-app destination dismisses the sheet and raises the popup at the
/// presenter level so it can center over the whole screen (the sheet's own
/// bounds are too short). The caller's `onSelect` fires once for non-external
/// destinations, and only after the user taps "Open" for external apps.
private struct ShareSheetModifier: ViewModifier {
    @Binding var isPresented: Bool
    let shareURL: URL
    let onSelect: ((ShareDestination) -> Void)?
    let onSelectContact: ((ShareContact) -> Void)?

    @State private var pendingDestination: ShareDestination?

    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $isPresented) {
                SharePostSheet(
                    shareURL: shareURL,
                    onSelect: handleSelect,
                    onSelectContact: onSelectContact
                )
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(20)
                .presentationBackground(AppColor.shareSheetGradient)
            }
            .confirmPopup(
                isPresented: Binding(
                    get: { pendingDestination != nil },
                    set: { if !$0 { pendingDestination = nil } }
                ),
                title: AppStrings.confirmOpenApp.localizedFormat(pendingDestination?.title ?? ""),
                confirmTitle: AppStrings.open.localized,
                cancelTitle: AppStrings.cancel.localized,
                onConfirm: { pendingDestination.map { onSelect?($0) } }
            )
    }

    private func handleSelect(_ destination: ShareDestination) {
        if destination.opensExternalApp {
            pendingDestination = destination
        } else {
            onSelect?(destination)
        }
    }
}

extension View {

    func shareSheet(
        isPresented: Binding<Bool>,
        shareURL: URL,
        onSelect: ((ShareDestination) -> Void)? = nil,
        onSelectContact: ((ShareContact) -> Void)? = nil
    ) -> some View {
        modifier(ShareSheetModifier(
            isPresented: isPresented,
            shareURL: shareURL,
            onSelect: onSelect,
            onSelectContact: onSelectContact
        ))
    }
}

#Preview {
    Color.gray
        .ignoresSafeArea()
        .shareSheet(isPresented: .constant(true), shareURL: URL(string: "https://binbon.app/p/1")!)
}
