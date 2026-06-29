//
//  ScreenHeaderBar.swift
//  Binbon
//
//  Created by Ramez Hamdy on 09/06/2026.
//

import SwiftUI

/// The brand gradient top band used by the host-flow screens: a centered title
/// over `AppColor.buttonGradient` (coral→purple in Colored, charcoal in
/// Light/Dark), with a leading back chevron (auto-mirrors for RTL) and optional
/// trailing content. Hides the system navigation bar; pair with
/// `.toolbar(.hidden, for: .navigationBar)` on the screen.
struct ScreenHeaderBar<Trailing: View>: View {

    let title: String
    var showsBack: Bool = true
    @ViewBuilder var trailing: () -> Trailing

    @Environment(\.router) private var router

    init(_ title: String,
         showsBack: Bool = true,
         @ViewBuilder trailing: @escaping () -> Trailing = { EmptyView() }) {
        self.title = title
        self.showsBack = showsBack
        self.trailing = trailing
    }

    var body: some View {
        ZStack {
            Text(title)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(.appText)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .padding(.horizontal, 56)

            HStack {
                if showsBack && router.canBack() {
                    Button { router.back() } label: {
                        Image(systemName: "chevron.backward")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(.appText)
                            .frame(width: 32, height: 32)
                            .contentShape(Rectangle())
                    }
                }
                Spacer()
                trailing()
            }
        }
        .padding(.horizontal, 16)
        .frame(height: 52)
        .frame(maxWidth: .infinity)
        .background {
            Rectangle()
                .fill(AppColor.appBarFill)
                .ignoresSafeArea(edges: .top)
                .shadow(color: AppColor.authListRowShadowColor, radius: 4, y: 4)
        }
    }
}

#Preview {
    VStack(spacing: 0) {
        ScreenHeaderBar("Information Form")
        Spacer()
    }
    .appBackground()
}
