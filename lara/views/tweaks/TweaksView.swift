//
//  TweaksView.swift
//  lara
//
//  Created by lunginspector on 5/3/26.
//  Redesigned UI — card-based layout using PartyUI components
//
import SwiftUI

struct TweaksView: View {
    @ObservedObject var mgr: laramgr

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // Status banner when nothing is ready
                    if !mgr.sbxready && !mgr.vfsready && !mgr.rcready {
                        CompactAlert(
                            title: "Tweaks unavailable",
                            icon: "lock.fill",
                            text: "Run the exploit and initialize the system on the main tab before using tweaks.",
                            color: .orange
                        )
                    }

                    // SpringBoard section
                    TweakSection(
                        title: "SpringBoard",
                        icon: "house"
                    ) {
                        TweakRow(
                            title: "DarkBoard",
                            subtitle: "Custom icon themes for your home screen",
                            icon: "photo.on.rectangle.angled",
                            color: .purple,
                            destination: AnyView(DarkBoardView()),
                            disabled: false
                        )
                        TweakRow(
                            title: "Liquid Glass",
                            subtitle: "Toggle and configure iOS 26 Liquid Glass effects",
                            icon: "drop.circle",
                            color: .cyan,
                            destination: AnyView(LGView()),
                            disabled: false
                        )
                        TweakRow(
                            title: "RemoteCall Customizer",
                            subtitle: "Status bar, dock, grid, performance HUD and more",
                            icon: "syringe",
                            color: .indigo,
                            destination: AnyView(RemoteView(mgr: mgr)),
                            disabled: !mgr.rcready
                        )
                    }

                    // User Interface section
                    TweakSection(
                        title: "User Interface",
                        icon: "eye"
                    ) {
                        TweakRow(
                            title: "dirtyZero",
                            subtitle: "Zero out system files to break UI elements",
                            icon: "0.circle",
                            color: .red,
                            destination: AnyView(ZeroView(mgr: mgr)),
                            disabled: !mgr.vfsready
                        )
                        TweakRow(
                            title: "Card Overwrite",
                            subtitle: "Replace the Apple Pay / Wallet card background",
                            icon: "creditcard",
                            color: .green,
                            destination: AnyView(CardView()),
                            disabled: false
                        )
                        TweakRow(
                            title: "Font Overwrite",
                            subtitle: "Replace the system font with a custom one",
                            icon: "textformat",
                            color: .orange,
                            destination: AnyView(FontPicker(mgr: mgr)),
                            disabled: !mgr.vfsready
                        )
                        TweakRow(
                            title: "Passcode Theme",
                            subtitle: "Customize the passcode entry screen artwork",
                            icon: "lock.rectangle",
                            color: .blue,
                            destination: AnyView(PasscodeView(mgr: mgr)),
                            disabled: !mgr.sbxready
                        )
                        TweakRow(
                            title: "SystemColor Patcher",
                            subtitle: "Patch system accent and UI colors",
                            icon: "paintpalette",
                            color: .pink,
                            destination: AnyView(SystemColor(mgr: mgr)),
                            disabled: !mgr.sbxready || !mgr.vfsready
                        )
                    }

                    // System section
                    TweakSection(
                        title: "System",
                        icon: "gear"
                    ) {
                        TweakRow(
                            title: "3 App Bypass",
                            subtitle: "Bypass the 3-app sideload limit",
                            icon: "square.stack.3d.up",
                            color: .teal,
                            destination: AnyView(AppsView(mgr: mgr)),
                            disabled: !mgr.sbxready
                        )
                        TweakRow(
                            title: "Unblacklist",
                            subtitle: "Remove apps from the MobileIdentity blacklist",
                            icon: "checkmark.shield",
                            color: .green,
                            destination: AnyView(WhitelistView()),
                            disabled: !mgr.sbxready
                        )
                        TweakRow(
                            title: "VarClean",
                            subtitle: "Clean up junk from /var to free space",
                            icon: "trash.circle",
                            color: .red,
                            destination: AnyView(VarCleanView()),
                            disabled: !mgr.sbxready
                        )
                        TweakRow(
                            title: "JIT Enabler",
                            subtitle: "Enable JIT for apps with get-task-allow",
                            icon: "bolt.circle",
                            color: .yellow,
                            destination: AnyView(JitView()),
                            disabled: !mgr.sbxready
                        )
                        TweakRow(
                            title: "Custom Overwrite",
                            subtitle: "Overwrite any system file with a custom one",
                            icon: "doc.badge.arrow.up",
                            color: .gray,
                            destination: AnyView(CustomView(mgr: mgr)),
                            disabled: !mgr.vfsready
                        )
                    }

                    // Extra Tools
                    TweakSection(
                        title: "Extras",
                        icon: "wrench.and.screwdriver"
                    ) {
                        TweakRow(
                            title: "Extra Tools",
                            subtitle: "ASLR, process info, sandbox tokens, Pocket Poster helper",
                            icon: "hammer",
                            color: .brown,
                            destination: AnyView(ToolsView()),
                            disabled: false
                        )
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 32)
            }
            .navigationTitle("Tweaks")
        }
    }
}

// MARK: - TweakSection

private struct TweakSection<Content: View>: View {
    var title: String
    var icon: String
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ThemedHeaderLabel(text: title, icon: icon)
            VStack(spacing: 0) {
                content
            }
            .background(Color(.secondarySystemBackground), in: .rect(cornerRadius: cornerRad.platter))
        }
    }
}

// MARK: - TweakRow

private struct TweakRow: View {
    var title: String
    var subtitle: String
    var icon: String
    var color: Color
    var destination: AnyView
    var disabled: Bool

    var body: some View {
        NavigationLink(destination: destination) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: cornerRad.sPlatter)
                        .fill(color.opacity(disabled ? 0.25 : 0.18))
                        .frame(width: 42, height: 42)
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(disabled ? .secondary : color)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .fontWeight(.medium)
                        .foregroundStyle(disabled ? .secondary : .primary)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
                Spacer()
                if disabled {
                    Image(systemName: "lock.fill")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
        }
        .disabled(disabled)
        .overlay(alignment: .bottom) {
            Divider()
                .padding(.leading, 70)
        }
    }
}
