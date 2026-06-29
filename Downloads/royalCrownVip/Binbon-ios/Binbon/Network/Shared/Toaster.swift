//
//  Toaster.swift
//  Binbon
//
//  Created by Salah Khaled on 19/03/2026.
//

import SwiftUI
import Combine


// MARK: - Modifier
extension View {
    func toaster() -> some View { modifier(ToastModifier()) }
}

fileprivate struct ToastModifier: ViewModifier {
    func body(content: Content) -> some View {
        content.window { if let scene = $0?.windowScene { ToastManager.shared.setup(scene: scene)} }
    }
}

// MARK: - Entry
enum ToastEntry: Equatable {
    
    case success(_ icon: String? = nil)
    case error(_ icon: String? = nil)
    case online
    case offline
    
    var icons: String {
        switch self {
        case .success(let icon): icon ?? "checkmark"
        case .error(let icon): icon ?? "xmark"
        case .online: "wifi"
        case .offline: "wifi.slash"
        }
    }
    
    var color: Color {
        switch self {
        case .success, .online: .green
        case .error, .offline: .red
        }
    }
    
}

// MARK: - Toaster
final class Toaster: ObservableObject {
    static let shared = Toaster()
    
    // MARK: - Properties
    private var currentTask: DispatchWorkItem?
    @Published fileprivate var message: String = ""
    @Published fileprivate var isShowing: Bool = false
    @Published fileprivate var type: ToastEntry = .success("checkmark.circle")
    
    // MARK: - Toast
//    func show(_ message: String, _ duration: TimeInterval = 3) {
//        show(.default, message, duration)
//    }
    
    func show(_ type: ToastEntry, _ message: String, _ duration: TimeInterval = 3) {
        if isShowing, type == self.type { return }

        currentTask?.cancel()
        self.isShowing = false
        self.type = type
        self.message = message
        
        withAnimation {
            self.isShowing = false
            self.isShowing = true
        }
        
        let task = DispatchWorkItem {
            withAnimation { self.isShowing = false }
        }
        
        currentTask = task
        DispatchQueue.main.asyncAfter(deadline: .now() + duration, execute: task)
    }
}

// MARK: - Toast View
struct ToastView: View {
    @ObservedObject var manager: Toaster = .shared
    
    var body: some View {
        if manager.isShowing {
            HStack(spacing: 14) {
                Image(systemName: manager.type.icons)
                    .foregroundStyle(.appText)
                    .font(.system(size: 18))
                    .frame(width: 20, height: 20, alignment: .center)
//                    .if(manager.type == .default) {
//                        $0.symbolEffect(.bounce.up.byLayer, options: .repeat(.periodic(delay: 1.0)))
//                    } else: {
//                        $0.contentTransition(.symbolEffect(.replace.magic(fallback: .downUp.byLayer), options: .nonRepeating))
//                    }
//                Text(manager.message)
//                    .font(.footnote.weight(.medium))
//                    .multilineTextAlignment(.center)
//                    .lineLimit(3)
            }
            .padding()
            .background(manager.type.color, in: RoundedRectangle(cornerRadius: 20))
            .transition(.move(edge: .top).combined(with: .opacity))
            .padding(.horizontal)
//            .localizer()
        }
    }
}

#Preview {
    let toaster: Toaster =  {
       let toaster = Toaster()
        toaster.isShowing = true
        toaster.message = "This is a message"
        toaster.type = .success("lock")
        return toaster
    }()
    
    ToastView(manager: toaster)
}


// MARK: - Window Helper
fileprivate final class ToastManager {
    static let shared = ToastManager()
    private var toastWindow: UIWindow?
    
    func setup(scene: UIWindowScene) {
        let window = UIWindow(windowScene: scene)
        let rootView = Color.clear.ignoresSafeArea().overlay(alignment: .top) { ToastView() }
        window.rootViewController = UIHostingController(rootView: rootView)
        window.rootViewController?.view.backgroundColor = .clear
        window.windowLevel = .alert + 1
        window.isUserInteractionEnabled = false
        window.makeKeyAndVisible()
        toastWindow = window
    }
}

fileprivate extension View {
    func window(_ callback: @escaping (UIWindow?) -> Void) -> some View {
        background(HostingWindowFinder(callback: callback))
    }
}

fileprivate struct HostingWindowFinder: UIViewRepresentable {
    var callback: (UIWindow?) -> Void
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        DispatchQueue.main.async { [weak view] in
            self.callback(view?.window)
        }
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
}
