//
//  AppColor.swift
//  Binbon
//
//  Created by Salah Khaled on 19/04/2026.
//

import SwiftUI

// MARK: - Hex initializer

extension Color {

    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let red, green, blue, alpha: UInt64
        switch hex.count {
        case 6:
            (red, green, blue, alpha) = (int >> 16, (int >> 8) & 0xFF, int & 0xFF, 255)
        case 8:
            (red, green, blue, alpha) = (int >> 24, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        default:
            assertionFailure("Malformed hex string: \(hex)")
            (red, green, blue, alpha) = (0, 0, 0, 255)
        }
        self.init(
            .sRGB,
            red: Double(red) / 255,
            green: Double(green) / 255,
            blue: Double(blue) / 255,
            opacity: Double(alpha) / 255
        )
    }
}

// MARK: - Adaptive primitives & theming entry point

extension Color {

    static var appGold: Color { AppColor.gold }

    /// Resolves a color against the active `ThemeManager` mode. `.system`
    /// follows the device's light/dark appearance live.
    static func themed(colored: Color, light: Color, dark: Color) -> Color {
        Color(uiColor: UIColor { trait in
            switch ThemeManager.shared.mode {
            case .colored: return UIColor(colored)
            case .light:   return UIColor(light)
            case .dark:    return UIColor(dark)
            case .system:  return UIColor(trait.userInterfaceStyle == .dark ? dark : light)
            }
        })
    }

    /// Primary ink — near-black on light, white on dark.
    static let appText = Color(uiColor: UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor.white
            : UIColor(red: 0.047, green: 0.047, blue: 0.047, alpha: 1)
    })

    static let appBlack = Color(uiColor: UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor(red: 0.2, green: 0.2, blue: 0.22, alpha: 1)
            : UIColor.black
    })

    static let appGray = Color(uiColor: UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
            : UIColor(red: 0.612, green: 0.612, blue: 0.612, alpha: 1)
    })

    static let appSurface = Color(uiColor: UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor.white
            : UIColor(white: 0.90, alpha: 1)
    })
}

// MARK: - Asset catalog colors

extension Color {
    static let appWhite    = Color("WhiteAsset")
    static let appYellow   = Color("YellowAsset")
    static let appOrange   = Color("OrangeAsset")
    static let appPurple   = Color("PurpleAsset")
    static let appPalePink = Color("PalePink")
    static let appRosePink = Color("RosePink")
}

// MARK: - Semantic color tokens

enum AppColor {

    // MARK: Theme plumbing
    private static var palette: ThemePalette { ThemeManager.shared.palette }
    private static let coloredPalette = ThemePalette.colored
    private static let lightPalette   = ThemePalette.light
    private static let darkPalette    = ThemePalette.dark

    private static var isColored: Bool { ThemeManager.shared.mode == .colored }

    /// On the Colored theme use the vivid `brand` style; on Light/Dark/System
    /// fall back to a neutral one. Collapses the repeated mode ternary.
    private static func coloredOrNeutral<Brand: ShapeStyle, Neutral: ShapeStyle>(
        _ brand: @autoclosure () -> Brand,
        _ neutral: @autoclosure () -> Neutral
    ) -> AnyShapeStyle {
        isColored ? AnyShapeStyle(brand()) : AnyShapeStyle(neutral())
    }

    /// The recurring neutral surface shared by chips, tiles and rows:
    /// `#D8D8D8` on Light, `#4B4B4B` on Dark. `colored` varies per use.
    private static func neutralSurface(colored: Color) -> Color {
        .themed(colored: colored, light: neutralLight, dark: neutralDark)
    }

    /// A single flat color expressed as a `LinearGradient` (so brand and
    /// neutral themes can share one gradient-typed token).
    private static func flatGradient(_ color: Color) -> LinearGradient {
        LinearGradient(colors: [color, color], startPoint: .top, endPoint: .bottom)
    }

    // MARK: Reused raw values
    private static let coral        = Color(hex: "E14554")
    private static let orange       = Color(hex: "EB7048")
    private static let charcoal     = Color(hex: "2B2B2B")
    private static let neutralLight = Color(hex: "D8D8D8")
    private static let neutralDark  = Color(hex: "4B4B4B")

    // MARK: - Brand background & gradients
    static var gold: Color {
        .themed(colored: Color(hex: "FBBC05"),
                light:   Color(red: 0.09, green: 0.09, blue: 0.11),
                dark:    .white)
    }

    /// Fill for an unselected tab (Home top pills + Live sub-tabs). Fixed,
    /// independent of the active theme.
    static let unselectedTabFill = Color(hex: "7C0930")

    /// Unselected tab pill gradient for the Home screen tab bar (Figma 1660:54654).
    static let tabUnselectedGradient = LinearGradient(
        colors: [Color(hex: "813478"), Color(hex: "802C6C")],
        startPoint: .top,
        endPoint: .bottom
    )
    
    static let tabBorderGradient = LinearGradient(
        colors: [Color(hex: "FBBC05"), Color(hex: "EB7048")],
        startPoint: .top,
        endPoint: .bottom
    )

    /// Selected tab pill gradient for the Home screen tab bar (Figma 1660:54654).
    static let tabSelectedGradient = LinearGradient(
        colors: [Color(hex: "80408A"), Color(hex: "EB7048")],
        startPoint: .top,
        endPoint: .bottom
    )
    static var gradientTop: Color {
        .themed(colored: coloredPalette.gradientTop,
                light:   lightPalette.gradientTop,
                dark:    darkPalette.gradientTop)
    }
    static var gradientBottom: Color {
        .themed(colored: coloredPalette.gradientBottom,
                light:   lightPalette.gradientBottom,
                dark:    darkPalette.gradientBottom)
    }
    static var backgroundGradientTop: Color {
        .themed(colored: coloredPalette.backgroundGradientTop,
                light:   lightPalette.backgroundGradientTop,
                dark:    darkPalette.backgroundGradientTop)
    }
    static var backgroundGradientBottom: Color {
        .themed(colored: coloredPalette.backgroundGradientBottom,
                light:   lightPalette.backgroundGradientBottom,
                dark:    darkPalette.backgroundGradientBottom)
    }
    static var gradientStart: Color {
        .themed(colored: coloredPalette.gradientStart,
                light:   lightPalette.gradientStart,
                dark:    darkPalette.gradientStart)
    }
    static var gradientEnd: Color {
        .themed(colored: coloredPalette.gradientEnd,
                light:   lightPalette.gradientEnd,
                dark:    darkPalette.gradientEnd)
    }
    static var backgroundGradient: LinearGradient {
        LinearGradient(colors: [gradientTop, gradientBottom], startPoint: .top, endPoint: .bottom)
    }
    static var backgroundGradientApp: LinearGradient {
        LinearGradient(
            colors: [backgroundGradientTop, backgroundGradientBottom],
            startPoint: .top,
            endPoint: .bottom
        )
    }
    /// Friends-report flow screens: theme top → coral `#EB7048` at the bottom.
    static var orangeBottomGradient: LinearGradient {
        LinearGradient(colors: [gradientTop, orange], startPoint: .top, endPoint: .bottom)
    }
    /// Verification upsell page + floating assistive button: purple `#83489C`
    /// at the top fading to orange `#EB7048` at the bottom. Fixed across themes.
    static var verificationGradient: LinearGradient {
        LinearGradient(colors: [Color(hex: "83489C"), orange], startPoint: .top, endPoint: .bottom)
    }
    static var buttonGradient: LinearGradient { palette.buttonGradient }
    /// Report sheet body: the tab/pill brand gradient (`buttonGradient`) reversed
    /// vertically — purple `#83489C` at the top fading to coral `#EB7048` below.
    static var reportSheetGradient: LinearGradient {
        LinearGradient(colors: [Color(hex: "83489C"), Color(hex: "EB7048")], startPoint: .top, endPoint: .bottom)
    }
    /// Messages long-press menu (dialog card + action pills): purple `#944D8B`
    /// at the top fading to coral `#D2665A`. Fixed across themes.
    static var messageMenuGradient: LinearGradient {
        LinearGradient(colors: [Color(hex: "944D8B"), Color(hex: "D2665A")], startPoint: .top, endPoint: .bottom)
    }
    static var goldAccentGradient: LinearGradient { palette.goldAccentGradient }
    static var datePickerPanelGradient: LinearGradient { palette.datePickerPanelGradient }
    static var pageIndicatorGradient: LinearGradient { ThemePalette.brandBarGradient }
    static var authListFirstRowGradient: LinearGradient { backgroundGradient }
    static var liveSubTabGradient: LinearGradient {
        isColored
            ? LinearGradient(
                colors: [Color(hex: "83489C"), Color(hex: "7C0930")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            : flatGradient(
                Color.themed(
                    colored: .clear,
                    light: Color(hex: "E5E5E5"),
                    dark: charcoal
                )
            )
    }
    static var promoGradient: LinearGradient { LinearGradient(colors: [Color(hex: "D025A5"), Color(hex: "2718CD")], startPoint: .topLeading, endPoint: .bottomTrailing) }

    static var chromeButtonGradient: LinearGradient {
        if isColored { return coloredPalette.buttonGradient }
        let surface = Color.themed(colored: Color(hex: "E5E5E5"),
                                   light:   Color(hex: "E5E5E5"),
                                   dark:    charcoal)
        return LinearGradient(colors: [surface, surface], startPoint: .top, endPoint: .bottom)
    }
    
    static var messagesTabGradient: LinearGradient {
        isColored
            ? LinearGradient(
                colors: [Color(hex: "8E4C92"), Color(hex: "DA6954")],
                startPoint: .top,
                endPoint: .bottom
            )
            : flatGradient(
                Color.themed(
                    colored: .clear,
                    light: Color(hex: "E5E5E5"),
                    dark: charcoal
                )
            )
    }
    
    static var messageBolderColor = Color(hex: "F5C523")

    // MARK: - Surfaces
    static var cardBackground: Color {
        .themed(colored: coloredPalette.cardBackground,
                light:   lightPalette.cardBackground,
                dark:    darkPalette.cardBackground)
    }
    static var sectionSurface: Color {
        .themed(colored: coloredPalette.sectionSurface,
                light:   lightPalette.sectionSurface,
                dark:    darkPalette.sectionSurface)
    }
    static var buttonBackground: Color { palette.buttonBackground }
    static var toggleOnColor: Color { palette.toggleOnColor }
    static var tabBarFill: AnyShapeStyle { palette.tabBarFill }
    static var authListRowShadowColor: Color { palette.authListRowShadowColor }

    /// Neutral app-bar / panel fill: brand gradient on Colored, white on
    /// Light, black on Dark.
    static var appBarFill: AnyShapeStyle {
        coloredOrNeutral(buttonGradient, Color.themed(colored: .white, light: .white, dark: .black))
    }
    static var panelSurface: AnyShapeStyle { appBarFill }

    static var groupedPageBackground: Color {
        .themed(colored: gradientTop, light: Color(hex: "F2F2F7"), dark: .black)
    }
    static var neutralButtonFill: AnyShapeStyle {
        coloredOrNeutral(buttonGradient,
                         Color.themed(colored: .white, light: Color(hex: "E5E5EA"), dark: charcoal))
    }
    static var profileHeaderFill: AnyShapeStyle {
        AnyShapeStyle(Color.themed(colored: coloredPalette.profileHeaderColor,
                                   light:   lightPalette.profileHeaderColor,
                                   dark:    darkPalette.profileHeaderColor))
    }

    /// Semi-transparent black panel behind grouped content. Fixed `#00000080`.
    static let sectionPanel = Color(hex: "00000080")

    // MARK: - Foreground / ink tokens
    /// Primary text/icon on dark gradient surfaces.
    static let textPrimary = Color.white
    /// Muted/secondary text on dark surfaces.
    static let textSecondary = Color.white.opacity(0.7)
    static let captionMuted = Color.appGray
    /// Text/icon drawn on a gold/accent fill.
    static let textOnAccent = Color.black.opacity(0.85)
    /// Hairline strokes/borders on dark surfaces.
    static let hairline = Color.white.opacity(0.35)
    /// Dimmed backdrop behind modal sheets/overlays.
    static let scrim = Color.black.opacity(0.45)

    static var secondaryTextColor: Color {
        .themed(colored: textSecondary, light: .black.opacity(0.6), dark: textSecondary)
    }

    /// Ink that's dark on light surfaces, white on the dark surface.
    static var promoteText: Color {
        .themed(colored: .black, light: .black, dark: .white)
    }
    
    static var primaryTextColor: Color {
        .themed(colored: .white, light: .black, dark: .white)
    }

    /// Required-field mark `*` — fixed brand orange in every theme.
    static let requiredMark = Color(hex: "EB7048")

    // MARK: - Coin / gold recharge package tile
    /// Raised package tile on the recharge store: white on Colored, light gray
    /// (#D8D8D8) on Light, `#4B4B4B` on Dark — matches Figma.
    static var coinTileBackground: Color { neutralSurface(colored: .white) }
    /// Primary amount text on a coin tile — dark on the light/white tile (Colored,
    /// Light), white on the dark tile (Dark).
    static var coinTileTitle: Color { promoteText }
    /// Secondary price text on a coin tile.
    static var coinTilePrice: Color { promoteText }
    /// Highlighted coin tile when its package is selected — the send-sheet pink.
    static let coinTileSelected = Color(hex: "F49AA1")

    // MARK: - Photo tiles
    /// Photo upload tile background: dark gray on Light, light gray on Dark.
    static var photoTileFill: Color {
        .themed(colored: Color.appText.opacity(0.18), light: neutralDark, dark: Color(hex: "D1D1D6"))
    }
    /// Camera glyph on a photo tile — contrasts the tile in each theme.
    static var photoTileIcon: Color {
        .themed(colored: Color.appText.opacity(0.6), light: .black, dark: neutralDark)
    }

    // MARK: - Auth / following rows
    static var authListFollowingRowGradient: AnyShapeStyle {
        coloredOrNeutral(palette.authListFollowingRowGradient, neutralSurface(colored: .clear))
    }
    static var followingRowGradient: AnyShapeStyle {
        coloredOrNeutral(palette.authListFollowingRowGradient,
                         Color.themed(colored: .clear, light: coral, dark: coral))
    }
    static var accentRed: Color { neutralSurface(colored: coral) }

    // MARK: - Context / action menu (e.g. friend row Block/Report/Mute popover)
    /// Flat dark surface for the floating action menu, dark across every theme to
    /// match the design's popover. (Block tint reuses `destructive`.)
    static var contextMenuSurface: Color { charcoal }

    // MARK: - Profile media tiles
    /// Dark + maroon tint laid over profile thumbnails so the gold border, play
    /// badge, and views label stay legible (matches the Figma overlay).
    static var mediaTileOverlay: LinearGradient {
        LinearGradient(
            colors: [Color.black.opacity(0.18), Color(hex: "7C0930").opacity(0.32)],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    // MARK: - Goal objective chips (Promote → Choose your goal)
    static let goalChipSelected = Color(hex: "E14554")
    static var goalChipUnselected: Color { neutralSurface(colored: Color(hex: "EFEFEF")) }

    // MARK: - Promotion pack rows (Promote → Choose a promotion pack)
    /// Pack row fill: frosted white on Colored, clear on Light, `#2B2B2B` on Dark.
    static var packRowFill: Color {
        .themed(colored: Color.white.opacity(0.12), light: .clear, dark: charcoal)
    }
    /// Recommended pack row fill: red-tinted in every theme.
    static var packRecommendedFill: Color {
        .themed(colored: coral.opacity(0.18),
                light:   Color(hex: "F8DEDF"),
                dark:    Color(hex: "3A2627"))
    }
    /// Ink color sitting on the coral "Recommended" pill — matches the Figma
    /// onbody surface so the badge reads cleanly across themes.
    static var packRecommendedBadgeText: Color {
        .themed(colored: .white, light: Color(hex: "E5E5E5"), dark: .white)
    }
    static let packTierAccents: [Color] = [Color(hex: "34C759"), Color(hex: "EB7048"), Color(hex: "E14554")]

    // MARK: - Promote review-terms warning banner
    static var promoteReviewBannerFill: Color {
        .themed(colored: .white.opacity(0.7),
                light:   .white.opacity(0.7),
                dark:    .white.opacity(0.12))
    }

    // MARK: - Promote pay action
    static var promotePayFill: Color {
        .themed(colored: Color(hex: "E5E5E5"),
                light:   .white,
                dark:    charcoal)
    }

    // MARK: - Promote customize panel gradients
    static var promoteEstimateBannerFill: AnyShapeStyle {
        switch ThemeManager.shared.mode {
        case .colored:
            return AnyShapeStyle(LinearGradient(
                colors: [coral, Color(hex: "83489C")],
                startPoint: .top, endPoint: .bottom
            ))
        case .light:
            return AnyShapeStyle(neutralLight)
        case .dark:
            return AnyShapeStyle(charcoal)
        case .system:
            return AnyShapeStyle(Color.themed(colored: coral, light: neutralLight, dark: charcoal))
        }
    }
 
    static var promoteBudgetHintFill: AnyShapeStyle {
        switch ThemeManager.shared.mode {
        case .colored:
            return AnyShapeStyle(LinearGradient(
                colors: [coral, Color(hex: "83489C")],
                startPoint: .leading, endPoint: .trailing
            ))
        case .light:
            return AnyShapeStyle(neutralLight)
        case .dark:
            return AnyShapeStyle(charcoal)
        case .system:
            return AnyShapeStyle(Color.themed(colored: coral, light: neutralLight, dark: charcoal))
        }
    }

    // MARK: - Promote surfaces (shared by cards, bottom bar, App Store sheet)
    static var promoteCardFill: AnyShapeStyle {
        switch ThemeManager.shared.mode {
        case .colored:
            return AnyShapeStyle(LinearGradient(
                colors: [Color(hex: "FFABB3"), Color(hex: "B671A6")],
                startPoint: .leading, endPoint: .trailing
            ))
        case .dark:
            return AnyShapeStyle(Color(hex: "262626"))
        case .light:
            return AnyShapeStyle(Color(hex: "E5E5E5"))
        case .system:
            return AnyShapeStyle(Color.themed(
                colored: Color(hex: "FFABB3"),
                light:   Color(hex: "E5E5E5"),
                dark:    Color(hex: "262626")
            ))
        }
    }
    static var promoteBottomBarFill: AnyShapeStyle { promoteCardFill }
    static var promoteSheetFill: AnyShapeStyle { promoteCardFill }
    static var promoteSheetInnerFill: Color {
        .themed(colored: .clear, light: Color(hex: "D8D8D8"), dark: Color(hex: "3A3A3A"))
    }
    static var promoteSheetCloseFill: Color {
        .themed(colored: .clear, light: Color(hex: "404040"), dark: Color(hex: "404040"))
    }
    static let promoteSheetScrim = Color.black.opacity(0.4)
    static var promoteSheetDivider: Color {
        .themed(colored: .white.opacity(0.5), light: .black.opacity(0.15), dark: .white.opacity(0.2))
    }
    
    // MARK: - Chat
    static let chatMyBubble = Color(hex: "8D3536")
    static let chatOtherBubble = Color(hex: "7523B9")
    static let chatHartIcon: Color = Color(hex: "AE0000")
    static let chatReactPlus = Color(hex: "DB6869")
    static let chatDeleteMenu = Color(hex: "D20000")
    static let chatReplySender = Color(hex: "EAAEAE")
    static let forwordSelection = Color(hex: "0BE812")
    static let forwordSelectionHeader = Color(hex: "CCCCCC")
    static let deleteChat = Color(hex: "D01616")

    static var chatCopyToastGradient: LinearGradient {
        LinearGradient(
            colors: [Color(hex: "AA65AF"), Color(hex: "A43723")],
            startPoint: .trailing,
            endPoint: .leading
        )
    }
    
    static var chatHeaderGradient: LinearGradient {
        LinearGradient(
            colors: [Color(hex: "954E8A"), Color(hex: "D66754")],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    // MARK: - Customize button & panel (Promote → packs)
    static var customizeButtonFill: AnyShapeStyle {
        coloredOrNeutral(palette.authListFollowingRowGradient, Color.clear)
    }
    static let sliderMinTrack = Color(hex: "E14554")
    // MARK: - Audience chips (Custom audience)
    static let audienceChipSelectedFill = Color(hex: "E14554")
    static let audienceChipFill = Color.clear
    static var audienceChipStroke: Color {
        .themed(colored: .white, light: .gray, dark: .white)
    }

    // MARK: - Comment sheet
    static let commentSheetSurface = Color.white
    static var commentSheetGradient: LinearGradient {
        LinearGradient(colors: [.appPalePink, .white, .appPalePink], startPoint: .leading, endPoint: .trailing)
    }
    static let commentText = Color.black
    static let commentMeta = Color.black.opacity(0.5)
    static let commentLiked = Color(hex: "F50000")
    static let commentSeparator = Color(hex: "0C0C0C").opacity(0.05)

    // MARK: - Share sheet
    static let shareText = Color.black
    static var shareSheetGradient: LinearGradient {
        LinearGradient(colors: [Color(hex: "FFAAB3"), .appPurple], startPoint: .top, endPoint: .bottom)
    }

    /// Account switcher sheet — muted lavender at the top warming to a dusty rose
    /// at the bottom, matching the design.
    static var accountSwitcherGradient: LinearGradient {
        LinearGradient(colors: [Color(hex: "AE93BC"), Color(hex: "C46C6B")], startPoint: .top, endPoint: .bottom)
    }

    /// Live sub-tab "Union" border — gold on the Colored theme, faint ink elsewhere.
    static var liveUnionBorder: Color {
        isColored ? gold : Color.appText.opacity(0.15)
    }

    // MARK: - Post options menu / delete dialog
    /// Post "⋯" dropdown — muted red at the top fading to purple.
    static var postMenuGradient: LinearGradient {
        LinearGradient(colors: [Color(hex: "B14C5E"), Color(hex: "6F5097")], startPoint: .top, endPoint: .bottom)
    }
    /// Hairline divider between the dropdown rows.
    static let postMenuDivider = Color.white.opacity(0.18)
    /// Dark card behind the destructive confirm dialog.
    static let dialogBackground = Color(hex: "241A30")
    static let dialogBorder = Color.white.opacity(0.15)
    /// Vivid destructive action (Delete).
    static let destructiveRed = Color(hex: "FF3B5C")
    static var shareCopyLinkGradient: LinearGradient {
        LinearGradient(colors: [Color(hex: "EB7048"), .appPurple], startPoint: .top, endPoint: .bottom)
    }

    // MARK: - Content support widget
    /// Expanded panel background — horizontal pink → mauve.
    static var contentSupportPanel: LinearGradient {
        LinearGradient(colors: [Color(hex: "FFABB3"), Color(hex: "B671A6")], startPoint: .leading, endPoint: .trailing)
    }
    /// Support / Promotion action buttons — vertical orange → purple.
    static var contentSupportButton: LinearGradient {
        LinearGradient(colors: [Color(hex: "EB7048"), Color(hex: "83489C")], startPoint: .top, endPoint: .bottom)
    }

    // MARK: - Confirm popup
    static var confirmPopupGradient: LinearGradient { shareSheetGradient }
    static let confirmPopupDivider = Color(hex: "0C0C0C").opacity(0.05)
    static let confirmPopupScrim = Color.black.opacity(0.6)

    // MARK: - Video details screen
    /// Brand info panel behind the title / author / action pills. Vivid
    /// magenta on Colored; a flat neutral surface on Light/Dark.
    static var videoInfoPanel: LinearGradient {
        isColored
            ? LinearGradient(colors: [Color(hex: "700A5C"), Color(hex: "C22687")],
                             startPoint: .topLeading, endPoint: .bottomTrailing)
            : flatGradient(.themed(colored: .white, light: .white, dark: .black))
    }

    /// Primary ink on the video panels — white over the dark Colored/Dark
    /// surfaces, near-black over the Light surface.
    static var videoInk: Color { .themed(colored: .white, light: .black, dark: .white) }
    /// Muted variant of `videoInk` for metadata (views, age, timestamps).
    static var videoInkMuted: Color {
        .themed(colored: .white.opacity(0.72), light: .black.opacity(0.55), dark: .white.opacity(0.72))
    }
    /// Frosted chip fill for the like / comment / share / report pills.
    static var videoActionChip: Color {
        .themed(colored: .white.opacity(0.18), light: .black.opacity(0.06), dark: .white.opacity(0.12))
    }
    /// Selected (pressed) state for an action chip.
    static var videoActionChipSelected: Color {
        .themed(colored: .white.opacity(0.32), light: .black.opacity(0.12), dark: .white.opacity(0.22))
    }
    /// Subscribe capsule fill (brand tan); subscribed state reuses the chip.
    static let videoSubscribeFill = Color(hex: "C9A06A")

    /// Settings-sheet surface gradient: brand pink on Colored, flat neutral
    /// on Light/Dark. Paired with `videoMenuText` for legible rows.
    static var videoMenuGradient: LinearGradient {
        isColored
            ? LinearGradient(colors: [Color(hex: "FCDBE0"), Color(hex: "C73F80")],
                             startPoint: .top, endPoint: .bottom)
            : flatGradient(.themed(colored: .white, light: .white, dark: charcoal))
    }
    /// Row ink on the settings sheet — dark on the pink/light surface, white on Dark.
    static var videoMenuText: Color { promoteText }
    /// Hairline divider between settings-sheet rows.
    static var videoMenuDivider: Color {
        .themed(colored: .black.opacity(0.12), light: .black.opacity(0.10), dark: .white.opacity(0.12))
    }
    /// Destructive actions (report / block) — brand coral, legible on every sheet surface.
    static let destructive = Color(hex: "E14554")

    // MARK: - Live countries picker
    /// Light card surface for the country tiles and continent pills that
    /// float on the dark broadcasts-list gradient. Fixed in every theme,
    /// same idiom as `commentSheetSurface` / `shareSheetSurface`.
    static var liveCountryCardText: Color {
        .themed(colored: Color(hex: "E66D4B"), light: Color(hex: "D8D8D8"), dark: Color(hex: "262626"))
    }

    /// Border for the live category tiles — gold only on the Colored theme,
    /// clear on Light/Dark so the tile reads as a flat neutral surface.
    static var liveCategoryTileBorder: Color {
        .themed(colored: Color(hex: "FBBC05"), light: .clear, dark: .clear)
    }

    // MARK: - Stories
    /// Deep magenta panel that sits behind the active story tab and the
    /// content area below the tab strip. Matches Figma exactly.
    static var storyPanelFill: Color {
        .themed(colored: Color(hex: "7C0930"), light: .clear, dark: .clear)
    }

    /// 7-stop magenta → yellow ring around story avatars. Matches Figma exactly
    /// (Borders → Linear Gradient on the friends-strip avatar) and stays vivid
    /// across every theme so the ring keeps the Instagram-story-like feel.
    static var storyRingGradient: LinearGradient {
        LinearGradient(
            colors: [
                .themed(colored: Color(hex: "E901C5"), light: Color(hex: "D8D8D8"), dark: .clear),
                .themed(colored: Color(hex: "C41170"), light: Color(hex: "D8D8D8"), dark: .clear),
                .themed(colored: Color(hex: "F20932"), light: Color(hex: "D8D8D8"), dark: .clear),
                .themed(colored: Color(hex: "F96B05"), light: Color(hex: "D8D8D8"), dark: .clear),
                .themed(colored: Color(hex: "FBAB01"), light: Color(hex: "D8D8D8"), dark: .clear),
                .themed(colored: Color(hex: "F9D201"), light: Color(hex: "D8D8D8"), dark: .clear),
                .themed(colored: Color(hex: "FEC902"), light: Color(hex: "D8D8D8"), dark: .clear)
            ],
            startPoint: .center,
            endPoint: .bottomLeading
        )
    }

    /// Solid muted purple — idle fill for the delete-story menu pills.
    static let storyMenuPillFill = Color(hex: "964E8C")

    /// Vivid magenta → deep purple — pressed state of the destructive
    /// menu option ("delete story").
    static let storyMenuDeleteGradient = LinearGradient(
        colors: [Color(hex: "D83DD3"), Color(hex: "611B77")],
        startPoint: .top,
        endPoint: .bottom
    )

    /// Subtler purple gradient — pressed state of the non-destructive menu
    /// option ("cancel").
    static let storyMenuCancelGradient = LinearGradient(
        colors: [Color(hex: "B66BAB"), Color(hex: "7A4072")],
        startPoint: .top,
        endPoint: .bottom
    )

    // MARK: - Story viewer
    /// Muted ink for the timestamp in the viewer's author row.
    static let storyViewerMeta = Color(hex: "D1D1D1")

    // MARK: - Voice call
    /// Top chrome capsule on the in-call screen — charcoal fade in Colored.
    static var voiceCallTopBarGradient: LinearGradient {
        isColored
            ? LinearGradient(
                colors: [Color(hex: "4A4A4A").opacity(0.94), Color(hex: "242424").opacity(0.96)],
                startPoint: .top,
                endPoint: .bottom
            )
            : LinearGradient(
                colors: [Color(hex: "3A3A3C").opacity(0.94), Color(hex: "1C1C1E").opacity(0.96)],
                startPoint: .top,
                endPoint: .bottom
            )
    }

    /// Bottom control rail — purple → coral in Colored, neutral charcoal off it.
    static var voiceCallControlsBarGradient: LinearGradient {
        isColored
            ? LinearGradient(
                colors: [Color(hex: "83489C"), Color(hex: "E97840")],
                startPoint: .leading,
                endPoint: .trailing
            )
            : LinearGradient(
                colors: [Color(hex: "3A3A3C"), Color(hex: "2B2B2B")],
                startPoint: .leading,
                endPoint: .trailing
            )
    }

    /// Semi-transparent capsule behind the call control rows (Figma).
    static var voiceCallControlsBarCapsuleGradient: LinearGradient {
        isColored
            ? LinearGradient(
                colors: [
                    Color(hex: "83489C").opacity(0.52),
                    Color(hex: "E97840").opacity(0.52)
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
            : LinearGradient(
                colors: [
                    Color(hex: "3A3A3C").opacity(0.58),
                    Color(hex: "2B2B2B").opacity(0.58)
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
    }

    /// Frosted circle behind each utility control on the call rail.
    static var voiceCallControlButtonFill: Color {
        isColored
            ? Color.black.opacity(0.24)
            : Color.black.opacity(0.30)
    }
    static var voiceCallControlButtonFillGredient: LinearGradient {
        isColored
            ? LinearGradient(
                colors: [Color(hex: "954E8A"), Color(hex: "D66754")],
                startPoint: .top,
                endPoint: .bottom
            )
            : LinearGradient(
                colors: [Color.black.opacity(0.30), Color.black.opacity(0.30)],
                startPoint: .top,
                endPoint: .bottom
            )
    }

    /// Add-person sheet — magenta → coral per the in-call Figma.
    static var voiceCallAddPersonSheetGradient: LinearGradient {
        isColored
            ? LinearGradient(
                colors: [Color(hex: "9B3073"), Color(hex: "E9705A")],
                startPoint: .top,
                endPoint: .bottom
            )
            : LinearGradient(
                colors: [Color(hex: "3A3A3C"), Color(hex: "2B2B2B")],
                startPoint: .top,
                endPoint: .bottom
            )
    }

    /// Highlight stroke on a focused add-person row.
    static let voiceCallAddPersonSelectionStroke = Color(hex: "3498DB")

    /// Hairline on the in-call ⋯ options popover (Figma `#964E8C` @ 0.5pt).
    static let voiceCallOptionsMenuBorder = Color(hex: "964E8C")

    static let voiceCallRemoteBorder = Color(hex: "08FF00")
    static let voiceCallLocalBorder  = Color(hex: "1FE6F6")
    static let voiceCallVideoScrim = LinearGradient(
        colors: [Color.black.opacity(0.80), Color.black.opacity(0.0)],
        startPoint: .top,
        endPoint: .center
    )

    /// Background gradient for the "Add Participant" sliding drawer — fixed purple→coral
    /// regardless of theme because the call screen is always visually dark.
    static let voiceCallDrawerGradient = LinearGradient(
        colors: [Color(hex: "964E8C"), Color(hex: "E26B4E")],
        startPoint: .top,
        endPoint: .bottom
    )

    // MARK: - Creator settings (Virtual Currencies & Gifts)
    /// Warm card gradient (purple → orange, top → bottom) for the wealth /
    /// spending / gift tiles. Flattens to a neutral surface off Colored.
    static var creatorCardGradient: LinearGradient {
        isColored
            ? LinearGradient(colors: [Color(hex: "964E8C"), Color(hex: "E26B4E")],
                             startPoint: .top, endPoint: .bottom)
            : flatGradient(.themed(colored: .clear, light: Color(hex: "E5E5EA"), dark: charcoal))
    }
}

// MARK: - ShapeStyle conveniences

extension ShapeStyle where Self == Color {
    static var appWhite: Color    { Color.appWhite }
    static var appYellow: Color   { Color.appYellow }
    static var appOrange: Color   { Color.appOrange }
    static var appPurple: Color   { Color.appPurple }
    static var appPalePink: Color { Color.appPalePink }
    static var appRosePink: Color { Color.appRosePink }
    static var appText: Color     { Color.appText }
    static var appBlack: Color    { Color.appBlack }
    static var appGray: Color     { Color.appGray }
    static var appSurface: Color  { Color.appSurface }
    static var promoteText: Color { AppColor.promoteText }
}
