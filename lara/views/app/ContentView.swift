//
//  ContentView.swift
//  lara
//
//  Created by ruter on 23.03.26.
//  Redesigned UI — card-based layout using PartyUI components
//
import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @EnvironmentObject private var mgr: laramgr
    @ObservedObject private var logger = globallogger
    @AppStorage("selectedMethod") private var selectedmethod: method = .hybrid
    @AppStorage("logsdisplaymode") private var selectedlogsdisplaymode: logsdisplaymode = .toolbar
    @AppStorage("loggerNoBS") private var loggernobs: Bool = true

    @State private var showSettings: Bool = false

    init() {
        globallogger.capture()
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    if !mgr.hasOffsets {
                        AlertBanner
                    }
                    StatusRow
                    ExploitSection
                    ActionsCard
                    DebugCard
                    InlineLogsCard
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 32)
            }
            .navigationTitle("lara")
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    if selectedlogsdisplaymode == .toolbar {
                        Button(action: { mgr.showLogs.toggle() }) {
                            Image(systemName: "terminal")
                        }
                    }
                    Button(action: { showSettings.toggle() }) {
                        Image(systemName: "gear")
                    }
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
        }
    }

    // MARK: - Alert Banner

    private var AlertBanner: some View {
        VStack(alignment: .leading, spacing: 8) {
            CompactAlert(
                title: "No offsets found",
                icon: "exclamationmark.triangle.fill",
                text: "Kernelcache offsets are missing. Download them in Settings to use lara.",
                color: .orange
            )
            Button(action: { showSettings.toggle() }) {
                ButtonLabel(text: "Open Settings", icon: "gear")
            }
            .buttonStyle(TranslucentButtonStyle(color: .orange))
        }
    }

    // MARK: - Status Row

    private var StatusRow: some View {
        HStack(spacing: 10) {
            CVStatusCard(
                label: "Exploit",
                icon: exploitIcon,
                color: exploitColor,
                progress: mgr.dsrunning ? mgr.dsprogress : nil
            )
            CVStatusCard(
                label: "VFS",
                icon: vfsIcon,
                color: vfsColor,
                progress: nil
            )
            CVStatusCard(
                label: "Sandbox",
                icon: sbxIcon,
                color: sbxColor,
                progress: nil
            )
            #if !DISABLE_REMOTECALL
            CVStatusCard(
                label: "RC",
                icon: rcIcon,
                color: rcColor,
                progress: nil
            )
            #endif
        }
    }

    // MARK: - Status icon/color helpers

    private var exploitIcon: String {
        if mgr.dsready { return "checkmark.circle.fill" }
        if mgr.dsrunning { return "showMeProgressPlease" }
        if mgr.dsattempted && mgr.dsfailed { return "xmark.circle.fill" }
        return "bolt.circle"
    }
    private var exploitColor: Color {
        if mgr.dsready { return .green }
        if mgr.dsattempted && mgr.dsfailed { return .red }
        return .secondary
    }
    private var vfsIcon: String {
        if mgr.vfsready { return "checkmark.circle.fill" }
        if mgr.vfsrunning { return "showMeProgressPlease" }
        if mgr.vfsattempted && mgr.vfsfailed { return "xmark.circle.fill" }
        return "externaldrive.badge.questionmark"
    }
    private var vfsColor: Color {
        if mgr.vfsready { return .green }
        if mgr.vfsattempted && mgr.vfsfailed { return .red }
        return .secondary
    }
    private var sbxIcon: String {
        if mgr.sbxready { return "checkmark.circle.fill" }
        if mgr.sbxrunning { return "showMeProgressPlease" }
        if mgr.sbxattempted && mgr.sbxfailed { return "xmark.circle.fill" }
        return "lock.circle"
    }
    private var sbxColor: Color {
        if mgr.sbxready { return .green }
        if mgr.sbxattempted && mgr.sbxfailed { return .red }
        return .secondary
    }
    private var rcIcon: String {
        if mgr.rcready { return "checkmark.circle.fill" }
        if mgr.rcrunning { return "showMeProgressPlease" }
        if mgr.rcfailed { return "xmark.circle.fill" }
        return "syringe"
    }
    private var rcColor: Color {
        if mgr.rcready { return .green }
        if mgr.rcfailed { return .red }
        return .secondary
    }

    // MARK: - Exploit Section

    private var ExploitSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            ThemedHeaderLabel(text: "Kernel Read Write", icon: "externaldrive")

            // Run Exploit button
            Button(action: {
                offsets_init()
                mgr.run()
            }) {
                HStack(spacing: 12) {
                    TerminalHeader(
                        text: mgr.dsrunning
                            ? "Running exploit…"
                            : (mgr.dsready ? "Exploit active" : "Run Exploit"),
                        icon: mgr.dsrunning
                            ? "showMeProgressPlease"
                            : (mgr.dsready ? "checkmark.circle.fill" : "bolt"),
                        color: mgr.dsready ? .green : .accentColor,
                        context: mgr.dsrunning
                            ? "\(Int(mgr.dsprogress * 100))% complete"
                            : (mgr.dsready
                                ? "DarkSword kernel exploit is running"
                                : "Tap to run the DarkSword kernel exploit")
                    )
                    Spacer()
                }
            }
            .buttonStyle(TranslucentButtonStyle(color: mgr.dsready ? .green : .accentColor))
            .disabled(!mgr.hasOffsets || mgr.dsready || mgr.dsrunning || isdebugged())

            // Hybrid: Initialize System
            if selectedmethod == .hybrid {
                Button(action: {
                    mgr.vfsinit()
                    mgr.sbxescape()
                }) {
                    HStack(spacing: 12) {
                        TerminalHeader(
                            text: (mgr.vfsrunning || mgr.sbxrunning)
                                ? "Initializing…"
                                : ((mgr.vfsready && mgr.sbxready) ? "System ready" : "Initialize System"),
                            icon: (mgr.vfsrunning || mgr.sbxrunning)
                                ? "showMeProgressPlease"
                                : ((mgr.vfsready && mgr.sbxready) ? "checkmark.circle.fill" : "gearshape.2"),
                            color: (mgr.vfsready && mgr.sbxready) ? .green : .accentColor,
                            context: (mgr.vfsrunning || mgr.sbxrunning)
                                ? "Setting up VFS and sandbox escape…"
                                : ((mgr.vfsready && mgr.sbxready)
                                    ? "VFS and sandbox escape are ready"
                                    : "Initialize VFS and escape sandbox")
                        )
                        Spacer()
                    }
                }
                .buttonStyle(TranslucentButtonStyle(color: (mgr.vfsready && mgr.sbxready) ? .green : .accentColor))
                .disabled(!mgr.dsready || mgr.vfsrunning || mgr.sbxrunning || (mgr.vfsready && mgr.sbxready))
            }

            // VFS only
            if selectedmethod == .vfs {
                Button(action: { mgr.vfsinit() }) {
                    HStack(spacing: 12) {
                        TerminalHeader(
                            text: mgr.vfsrunning
                                ? "Initializing VFS…"
                                : (mgr.vfsready ? "VFS ready" : "Initialize VFS"),
                            icon: mgr.vfsrunning
                                ? "showMeProgressPlease"
                                : (mgr.vfsready ? "checkmark.circle.fill" : "externaldrive"),
                            color: mgr.vfsready ? .green : .accentColor,
                            context: mgr.vfsrunning
                                ? "Setting up virtual file system…"
                                : (mgr.vfsready
                                    ? "Virtual file system is active"
                                    : "Initialize the virtual file system")
                        )
                        Spacer()
                    }
                }
                .buttonStyle(TranslucentButtonStyle(color: mgr.vfsready ? .green : .accentColor))
                .disabled(!mgr.dsready || mgr.vfsready || mgr.vfsrunning || isdebugged())
            }

            // SBX only
            if selectedmethod == .sbx {
                Button(action: { mgr.sbxescape() }) {
                    HStack(spacing: 12) {
                        TerminalHeader(
                            text: mgr.sbxrunning
                                ? "Escaping sandbox…"
                                : (mgr.sbxready ? "Sandbox escaped" : "Escape Sandbox"),
                            icon: mgr.sbxrunning
                                ? "showMeProgressPlease"
                                : (mgr.sbxready ? "checkmark.circle.fill" : "lock.open"),
                            color: mgr.sbxready ? .green : .accentColor,
                            context: mgr.sbxrunning
                                ? "Escaping the sandbox…"
                                : (mgr.sbxready
                                    ? "Sandbox escape is active"
                                    : "Escape the application sandbox")
                        )
                        Spacer()
                    }
                }
                .buttonStyle(TranslucentButtonStyle(color: mgr.sbxready ? .green : .accentColor))
                .disabled(!mgr.dsready || mgr.sbxready || mgr.sbxrunning || isdebugged())
            }

            if isdebugged() {
                InfoBadge(
                    text: "Exploit unavailable while a debugger is attached",
                    icon: "ant",
                    color: .orange
                )
            }

            // RemoteCall
            #if !DISABLE_REMOTECALL
            RCButtons
            #endif
        }
    }

    // MARK: - RemoteCall Buttons

    #if !DISABLE_REMOTECALL
    private var RCButtons: some View {
        VStack(alignment: .leading, spacing: 10) {
            ThemedHeaderLabel(text: "RemoteCall", icon: "syringe")

            Button(action: {
                mgr.rcinit(process: "SpringBoard", migbypass: false) { success in
                    if success {
                        mgr.logmsg("rc init succeeded!")
                        let pid = mgr.rccall(name: "getpid")
                        mgr.logmsg("remote getpid() returned: \(pid)")
                    } else {
                        mgr.logmsg("rc init failed")
                        mgr.rcfailed = true
                    }
                }
            }) {
                HStack(spacing: 12) {
                    TerminalHeader(
                        text: mgr.rcrunning
                            ? "Initializing RC…"
                            : (mgr.rcready ? "RemoteCall ready" : "Initialize RemoteCall"),
                        icon: mgr.rcrunning
                            ? "showMeProgressPlease"
                            : (mgr.rcready ? "checkmark.circle.fill" : "syringe"),
                        color: mgr.rcready ? .green : .accentColor,
                        context: mgr.rcrunning
                            ? "Attaching to SpringBoard…"
                            : (mgr.rcready
                                ? "RemoteCall is active"
                                : "Attach RemoteCall to SpringBoard")
                    )
                    Spacer()
                }
            }
            .buttonStyle(TranslucentButtonStyle(color: mgr.rcready ? .green : .accentColor))
            .disabled(!mgr.dsready || isdebugged() || mgr.rcrunning || mgr.rcready)

            if mgr.rcready {
                Button(action: { mgr.rcdestroy() }) {
                    ButtonLabel(text: "Destroy RemoteCall", icon: "xmark.circle")
                }
                .buttonStyle(TranslucentButtonStyle(color: .red))
            }

            if let error = mgr.rcLastError ?? mgr.sbProc?.lastError {
                InfoBadge(text: "Error: \(error)", icon: "exclamationmark.triangle.fill", color: .red)
            }

            if RemoteCall.isLiveContainerRuntime() && !RemoteCall.isLiveProcessRuntime() {
                InfoBadge(
                    text: "RemoteCall needs a PAC-enabled LiveContainer launch context.",
                    icon: "info.circle",
                    color: .orange
                )
            }

            InfoBadge(
                text: "RemoteCall is relatively unstable and may not work properly.",
                icon: "exclamationmark.triangle",
                color: .secondary
            )
        }
    }
    #endif

    // MARK: - Actions Card

    private var ActionsCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            ThemedHeaderLabel(text: "Actions", icon: "wrench.and.screwdriver")

            HStack(spacing: 10) {
                Button(action: { mgr.respring() }) {
                    ButtonLabel(text: "Respring", icon: "arrow.clockwise.circle")
                }
                .buttonStyle(TranslucentButtonStyle())

                Button(action: { mgr.panic() }) {
                    ButtonLabel(text: "Panic!", icon: "exclamationmark.triangle")
                }
                .buttonStyle(TranslucentButtonStyle(color: .red))
            }

            if isdebugged() {
                Button(action: { exit(0) }) {
                    ButtonLabel(text: "Detach Debugger", icon: "ant")
                }
                .buttonStyle(TranslucentButtonStyle(color: .orange))
            }
        }
    }

    // MARK: - Debug Card

    private var DebugCard: some View {
        Group {
            if weonadebugbuild_pjbweouttahereexclamationmark && mgr.dsready {
                VStack(alignment: .leading, spacing: 10) {
                    ThemedHeaderLabel(text: "Debug Info", icon: "ant")

                    VStack(spacing: 8) {
                        HStack {
                            Text("kernel_base")
                                .foregroundStyle(.secondary)
                                .font(.subheadline)
                            Spacer()
                            Text(String(format: "0x%llx", mgr.kernbase))
                                .font(.system(.subheadline, design: .monospaced))
                                .textSelection(.enabled)
                        }
                        Divider()
                        HStack {
                            Text("kernel_slide")
                                .foregroundStyle(.secondary)
                                .font(.subheadline)
                            Spacer()
                            Text(String(format: "0x%llx", mgr.kernslide))
                                .font(.system(.subheadline, design: .monospaced))
                                .textSelection(.enabled)
                        }
                    }
                    .modifier(SectionPlatter())
                }
            }
        }
    }

    // MARK: - Inline Logs Card

    @ViewBuilder
    private var InlineLogsCard: some View {
        if selectedlogsdisplaymode == .content {
            VStack(alignment: .leading, spacing: 10) {
                ThemedHeaderLabel(text: "Logs", icon: "terminal")

                ScrollView {
                    if loggernobs {
                        let combined = logger.logs.joined(separator: "\n")
                        Text(combined)
                            .font(.system(size: 12, design: .monospaced))
                            .lineSpacing(1)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .textSelection(.enabled)
                            .onTapGesture {
                                UIPasteboard.general.string = combined
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            }
                    } else {
                        ForEach(Array(logger.logs.enumerated()), id: \.offset) { _, log in
                            Text(log)
                                .font(.system(size: 12, design: .monospaced))
                                .lineSpacing(1)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .textSelection(.enabled)
                                .onTapGesture {
                                    UIPasteboard.general.string = log
                                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                }
                        }
                    }
                }
                .modifier(TerminalPlatter())

                HStack(spacing: 10) {
                    Button(action: {
                        UIPasteboard.general.string = logger.logs.joined(separator: "\n\n")
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    }) {
                        ButtonLabel(text: "Copy All", icon: "doc.on.doc")
                    }
                    .buttonStyle(TranslucentButtonStyle())

                    Button(action: { logger.clear() }) {
                        ButtonLabel(text: "Clear", icon: "trash")
                    }
                    .buttonStyle(TranslucentButtonStyle(color: .red))
                }
            }
        }
    }
}

// MARK: - CVStatusCard (local to ContentView)

private struct CVStatusCard: View {
    var label: String
    var icon: String
    var color: Color
    var progress: Double?

    var body: some View {
        VStack(spacing: 6) {
            if icon == "showMeProgressPlease" {
                ProgressView()
                    .frame(width: 22, height: 22)
                    .tint(MatrixColors.matrixGreen)
            } else {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(color == .secondary ? MatrixColors.matrixGreen.opacity(0.5) : color)
                    .frame(width: 22, height: 22)
            }
            if let p = progress {
                Text("\(Int(p * 100))%")
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundStyle(MatrixColors.matrixGreen)
            } else {
                Text(label.uppercased())
                    .font(.system(size: 8, design: .monospaced))
                    .fontWeight(.bold)
                    .foregroundStyle(color == .secondary ? MatrixColors.matrixGreen.opacity(0.5) : color)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(MatrixColors.matrixBlack)
        .overlay(
            RoundedRectangle(cornerRadius: cornerRad.sPlatter)
                .stroke(color == .secondary ? MatrixColors.matrixGreen.opacity(0.2) : color.opacity(0.5), lineWidth: 1)
        )
    }
}

#Preview {
    ContentView()
        .environmentObject(laramgr())
}
