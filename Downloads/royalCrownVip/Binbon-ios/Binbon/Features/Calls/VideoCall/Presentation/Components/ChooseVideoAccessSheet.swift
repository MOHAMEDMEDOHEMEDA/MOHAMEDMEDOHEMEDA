//
//  ChooseVideoAccessSheet.swift
//  Binbon
//
//  Created by Mohamed Magdy on 24/06/2026.
//

import SwiftUI

struct ChooseVideoAccessSheet: View {

    let participants: [VideoCallParticipant]

    @State private var searchText = ""
    @State private var allowedIDs: Set<String>

    init(participants: [VideoCallParticipant]) {
        self.participants = participants
        _allowedIDs = State(initialValue: Set(participants.map(\.id)))
    }

    private var filtered: [VideoCallParticipant] {
        guard !searchText.isEmpty else { return participants }
        return participants.filter {
            $0.name.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            searchBar
                .padding(.top, 12)
                .padding(.horizontal, 19)
                .padding(.bottom, 4)

            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: 8) {
                    ForEach(filtered) { participant in
                        row(participant)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
            }
        }
        .presentationDetents([.fraction(0.66)])
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(27)
        .presentationBackground(AppColor.backgroundGradient)
    }

    // MARK: - Search bar (identical to AddParticipantDrawer)

    private var searchBar: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 12))
                .foregroundStyle(.white.opacity(0.65))

            TextField("choose_video_access_search".localized, text: $searchText)
                .font(.system(size: 12))
                .foregroundStyle(.white)
                .tint(.white)
        }
        .padding(.horizontal, 12)
        .frame(height: 30)
        .background(Capsule(style: .continuous).fill(.white.opacity(0.15)))
    }

    // MARK: - Participant row (CallContactItem layout, toggle in place of +)

    private func row(_ participant: VideoCallParticipant) -> some View {
        let isOn = Binding<Bool>(
            get: { allowedIDs.contains(participant.id) },
            set: { if $0 { allowedIDs.insert(participant.id) } else { allowedIDs.remove(participant.id) } }
        )
        return HStack(spacing: 14) {
            participantAvatar(participant)

            Text(participant.name)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.25), radius: 2, y: 2)
                .lineLimit(1)

            Spacer(minLength: 0)

            Toggle("", isOn: isOn)
                .labelsHidden()
                .tint(AppColor.voiceCallRemoteBorder)
        }
        .padding(.horizontal, 14)
        .frame(height: 56)
        .background {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(.white.opacity(0.10))
                .overlay {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(AppColor.gold.opacity(0.55), lineWidth: 1)
                }
        }
    }

    private func participantAvatar(_ participant: VideoCallParticipant) -> some View {
        Group {
            if let str = participant.avatarURL, let url = URL(string: str) {
                AsyncImage(url: url) { phase in
                    if case .success(let img) = phase { img.resizable().scaledToFill() }
                    else { Circle().fill(.white.opacity(0.25)) }
                }
            } else if !participant.imageAsset.isEmpty {
                Image(participant.imageAsset)
                    .resizable()
                    .scaledToFill()
            } else {
                Circle().fill(.white.opacity(0.25))
            }
        }
        .frame(width: 45, height: 45)
        .clipShape(Circle())
        .overlay(Circle().stroke(AppColor.gold, lineWidth: 1.5))
    }
}

// MARK: - Preview

#Preview {
    Color.black.ignoresSafeArea()
        .sheet(isPresented: .constant(true)) {
            ChooseVideoAccessSheet(participants: [
                VideoCallParticipant(id: "1", name: "أحمد محمد",  imageAsset: "", avatarURL: nil, accent: .remote),
                VideoCallParticipant(id: "2", name: "سعيد أحمد",  imageAsset: "", avatarURL: nil, accent: .remote),
                VideoCallParticipant(id: "3", name: "نرمين",       imageAsset: "", avatarURL: nil, accent: .remote),
                VideoCallParticipant(id: "4", name: "عبدالرحمن",  imageAsset: "", avatarURL: nil, accent: .remote),
            ])
        }
}
