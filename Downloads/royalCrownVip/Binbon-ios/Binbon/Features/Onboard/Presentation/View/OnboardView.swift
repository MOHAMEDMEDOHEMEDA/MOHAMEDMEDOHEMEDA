//
//  OnboardView.swift
//  Binbon
//
//  Created by Salah Khaled on 19/04/2026.
//

import SwiftUI

enum OnboardStepEnum: Hashable {
    case step1Singers
    case step2Famous
    case step3Binbon
}

struct OnboardView: View {
    
    let step: OnboardStepEnum
    
    @State private var showActions = true
    @StateObject private var viewModel = OnboardViewModel()
    @Environment(\.router) private var router

    @State private var showSelectionTooltip = true

    private let gridColumns = [
        GridItem(.flexible(), spacing: 14),
        GridItem(.flexible(), spacing: 14),
        GridItem(.flexible(), spacing: 14)
    ]

    private var screenTitle: String {
        switch step {
        case .step1Singers: "singers_actors".localized
        case .step2Famous:  "famous_people".localized
        case .step3Binbon:  "famous_on_binbon".localized
        }
    }

    var body: some View {
        gridSection
            .appBackground()
            .appNavigation(title: screenTitle)
            .errorAlert(error: $viewModel.error)
            .loadingOverlay($viewModel.isLoading)
            .overlay(alignment: .bottom) { bottomActions }
            .task {
                viewModel.step = step
                viewModel.fetchSuggestions()
            }
            .onAppear {
                viewModel.step = step
                viewModel.selectedUserIds.removeAll()
            }
    }

    private var filteredPeople: [OnboardSuggestionResponse] {
        viewModel.suggestions
    }
    
    private var bottomActions: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                Button {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        showActions.toggle()
                    }
                } label: {
                    HStack(spacing: 6) {
                        Text(showActions ? "hide_actions".localized : "show_actions".localized)
                        Image(systemName: "chevron.up")
                            .rotationEffect(.degrees(showActions ? 180 : 0))
                    }
                }
                .font(.subheadline)
                .shadow(radius: 6)
                .buttonStyle(.borderedProminent)
                .tint(AppColor.gradientTop)
                .foregroundStyle(.appText)
                .padding(.top, 10)
            }
            .padding(.horizontal, 16)
            
            if showActions {
                bottomActionPanel
                    .transition(.asymmetric(
                        insertion: .move(edge: .bottom).combined(with: .opacity),
                        removal: .move(edge: .bottom).combined(with: .opacity)
                    ))
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: showActions)
    }

    private var gridSection: some View {
        ScrollView(showsIndicators: false) {
            LazyVGrid(columns: gridColumns, spacing: 12) {
                ForEach(filteredPeople) { person in
                    followCell(for: person)
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 50)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private static let followCardCornerRadius: CGFloat = 20
    private static var followCardGold: Color { .appGold }
    private static let followCardOrange = Color(hex: "F0A431")

    private var followCardGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(hex: "EE8D5E"),
                Color(hex: "D1647D"),
                Color(hex: "9546A7")
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    private func followCell(for person: OnboardSuggestionResponse) -> some View {
        let isSelected = viewModel.selectedUserIds.contains(person.id ?? 0)
        return Button {
            toggleSelection(person.id ?? 0)
        } label: {
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: Self.followCardCornerRadius, style: .continuous)
                    .fill(followCardGradient)
                    .overlay(
                        RoundedRectangle(cornerRadius: Self.followCardCornerRadius, style: .continuous)
                            .stroke(Self.followCardGold, lineWidth: isSelected ? 4 : 0)
                    )
                VStack(alignment: .center, spacing: 0) {
                    Spacer(minLength: 20)
                    
                    HStack {
                        Spacer()
                        if let photoUrl = person.profilePhoto {
                            ImageView(photoUrl)
                                .frame(width: 80, height: 80)
                                .clipShape(Circle())
                                .overlay(
                                    Circle()
                                        .stroke(Color.appText, lineWidth: 2)
                                )
                                .padding(10)
                        } else {
                            Image("front-side-profile")
                                .resizable()
                                .interpolation(.high)
                                .scaledToFill()
                                .frame(width: 80, height: 80)
                                .clipShape(Circle())
                                .overlay(
                                    Circle()
                                        .stroke(Color.appText, lineWidth: 2)
                                )
                                .padding(10)
                        }
                        Spacer()
                    }
                    
                    VStack(alignment: .center, spacing: 4) {
                        HStack(alignment: .center, spacing: 4) {
                            ZStack {
                                Circle()
                                    .fill(person.gender?.lowercased() == "female" ? Color(hex: "E640BE") : Color(hex: "3C7DD9"))
                                    .frame(width: 20, height: 20)
                                
                                Image(person.gender?.lowercased() == "female" ? "Female_list" : "Male_list")
                                    .scaledToFit()
                                    .frame(width: 16, height: 16)
                            }
                            
                            Text(person.fullname ?? "")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(.appText)
                                .lineLimit(1)
                                .truncationMode(.tail)
                                .minimumScaleFactor(0.85)
                        }
                        
                        Text("@\(person.username ?? "")")
                            .font(.system(size: 11, weight: .regular))
                            .foregroundStyle(.appText.opacity(0.7))
                            .lineLimit(1)
                            .truncationMode(.tail)
                    }
                    .padding(.horizontal, 8)
                    .padding(.bottom, 12)
                }
                
                
                if isSelected {
                    ZStack {
                        Circle()
                            .fill(Self.followCardGold)
                            .frame(width: 24, height: 24)
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .heavy))
                            .foregroundStyle(.appText)
                    }
                    .padding(8)
                    .zIndex(2)
                }
            }
        }
        .buttonStyle(.plain)
    }

    private func toggleSelection(_ id: Int) {
        viewModel.toggleSelection(id)
        withAnimation(.easeOut(duration: 0.2)) {
            showSelectionTooltip = false
        }
    }
    
    private var bottomActionPanel: some View {
        VStack(spacing: 10) {
            designBottomButton(title: viewModel.isAllSelected ? "unselect_all".localized : "select_all".localized, isPrimary: false,
                               action: viewModel.toggleAll)

            designBottomButton(title: "follow_count".localizedFormat(viewModel.selectedUserIds.count), isPrimary: true,
                               action: viewModel.next)

            designBottomButton(title: "skip".localized, isPrimary: false,
                               action: viewModel.skip)
        }
        .padding(.horizontal, 16)
        .padding(.top, 10)
    }
    
    private func designBottomButton(title: String, isPrimary: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.appText)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: isPrimary
                                    ? [Color(hex: "CC2BD1"), Color(hex: "742C9F"), Color(hex: "5B2A92")]
                                    : [Color(hex: "E98764"), Color(hex: "B55C96"), Color(hex: "81419F")],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(Color.appText.opacity(0.22), lineWidth: 2)
                )
        }
        .shadow(radius: 6)
        .buttonStyle(.plain)
    }

}

private struct TooltipPointer: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.closeSubpath()
        return path
    }
}

#Preview {
    NavigationView {
        OnboardView(step: .step1Singers)
    }
    
}
