//
//  ShareDestination.swift
//  Binbon
//

import Foundation

// MARK: - Destinations
enum ShareDestination: String, CaseIterable, Identifiable {
    case copyLink, republish, facebook,
         instagram, tiktok, x, whatsapp,
         telegram, messenger, snapchat,
         threads, report, notInterested,
         save, addMyStory, promotion


    var id: String { rawValue }

    /// Third-party apps the post can be opened in.
    static var mediaApps: [ShareDestination] { allCases.filter { !$0.isAction } }
    /// In-app actions rather than external apps.
    static var actions: [ShareDestination] { allCases.filter(\.isAction) }

    private var isAction: Bool {
        switch self {
        case .report, .notInterested, .save,
                .addMyStory, .promotion:
            return true
        default:
            return false
        }
    }

    /// Third-party apps that leave Binbon when opened, so they prompt a
    /// "Want to 'Bin Bon' open '…'" confirmation first.
    var opensExternalApp: Bool {
        switch self {
        case .facebook, .instagram, .tiktok, .x, .whatsapp,
                .telegram, .messenger, .snapchat, .threads:
            return true
        default:
            return false
        }
    }

    var title: String {
        switch self {
        case .copyLink:  return "copy_link".localized
        case .republish: return "republish".localized
        case .facebook:  return "facebook".localized
        case .instagram: return "instagram".localized
        case .tiktok:    return "tiktok".localized
        case .x:         return "x".localized
        case .whatsapp:  return "whatsapp".localized
        case .telegram:  return "telegram".localized
        case .messenger: return "messenger".localized
        case .snapchat:  return "snapchat".localized
        case .threads:   return "threads".localized
        case .report:    return "Report"
        case .notInterested: return "Not Interested".localized
        case .save:          return "Save".localized
        case .addMyStory:    return "Add My Story".localized
        case .promotion:     return "Promotion".localized

        }
    }

    var assetName: String {
        return "share-\(rawValue)"
    }
}
