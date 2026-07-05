import SwiftUI
import SwiftData
import QuartzCore
import OSLog
import UniformTypeIdentifiers

struct DiagnosticsView: View {
    @Query private var preferences: [AppPreferences]
    @Environment(\.modelContext) private var modelContext

    @State private var fps: Double = 0
    @State private var memoryUsage: UInt64 = 0
    @State private var cpuUsage: Double = 0
    @State private var logEntries: [String] = []
    @State private var selectedLogCategory: String = "All"
    @State private var swiftDataStoreSize: String = "—"
    @State private var documentsSize: String = "—"
    @State private var cachesSize: String = "—"
    @State private var showingClearCacheAlert = false
    @State private var showingResetAlert = false
    @State private var timer: Timer?

    private let logCategories = ["All", "App", "Download", "Torrent", "Security", "Crawler"]

    var body: some View {
        List {
            performanceSection
            networkSection
            logsSection
            storageSection
            actionsSection
        }
        .navigationTitle("Diagnostics")
        .onAppear {
            startMonitoring()
            refreshStorageSizes()
        }
        .onDisappear {
            stopMonitoring()
        }
        .alert("Clear Cache?", isPresented: $showingClearCacheAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Clear", role: .destructive) { clearCache() }
        } message: {
            Text("This will remove all cached data. Downloads and settings will not be affected.")
        }
        .alert("Reset All Settings?", isPresented: $showingResetAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Reset", role: .destructive) { resetAllSettings() }
        } message: {
            Text("This will reset all app settings to defaults. Your downloads and files will not be affected.")
        }
    }

    // MARK: - Performance

    private var performanceSection: some View {
        Section("Performance") {
            HStack {
                Label("FPS", systemImage: "gauge.medium")
                Spacer()
                Text("\(fps, specifier: "%.1f")")
                    .foregroundStyle(fpsColor)
                    .monospacedDigit()
            }

            HStack {
                Label("Memory", systemImage: "memorychip")
                Spacer()
                Text(memoryString)
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
            }

            HStack {
                Label("CPU", systemImage: "cpu")
                Spacer()
                Text("\(cpuUsage, specifier: "%.1f")%")
                    .foregroundStyle(cpuColor)
                    .monospacedDigit()
            }
        }
    }

    // MARK: - Network

    private var networkSection: some View {
        Section("Network") {
            HStack {
                Label("Active Connections", systemImage: "point.3.connected.trianglepath.dotted")
                Spacer()
                Text("0")
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
            }

            HStack {
                Label("Data Transferred Today", systemImage: "arrow.up.arrow.down")
                Spacer()
                Text("—")
                    .foregroundStyle(.secondary)
            }
        }
    }

    // MARK: - Logs

    private var logsSection: some View {
        Section {
            Picker("Category", selection: $selectedLogCategory) {
                ForEach(logCategories, id: \.self) { category in
                    Text(category).tag(category)
                }
            }

            if logEntries.isEmpty {
                Text("No log entries")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 8)
            } else {
                ForEach(logEntries.prefix(50), id: \.self) { entry in
                    Text(entry)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .lineLimit(3)
                }
            }
        } header: {
            Text("Logs")
        }
    }

    // MARK: - Storage

    private var storageSection: some View {
        Section("Storage") {
            HStack {
                Label("SwiftData Store", systemImage: "externaldrive")
                Spacer()
                Text(swiftDataStoreSize)
                    .foregroundStyle(.secondary)
            }

            HStack {
                Label("Documents", systemImage: "folder")
                Spacer()
                Text(documentsSize)
                    .foregroundStyle(.secondary)
            }

            HStack {
                Label("Caches", systemImage: "archivebox")
                Spacer()
                Text(cachesSize)
                    .foregroundStyle(.secondary)
            }
        }
    }

    // MARK: - Actions

    private var actionsSection: some View {
        Section {
            Button {
                exportLogs()
            } label: {
                Label("Export Logs", systemImage: "square.and.arrow.up")
            }

            Button(role: .destructive) {
                showingClearCacheAlert = true
            } label: {
                Label("Clear Cache", systemImage: "trash")
            }

            Button(role: .destructive) {
                showingResetAlert = true
            } label: {
                Label("Reset All Settings", systemImage: "gear.badge.xmark")
            }
        } header: {
            Text("Actions")
        }
    }

    // MARK: - Monitoring

    private func startMonitoring() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            Task { @MainActor in
                fps = FPSCounter.shared.fps
                memoryUsage = memoryUsed()
                cpuUsage = cpuUsagePercent()
                refreshLogs()
            }
        }
        FPSCounter.shared.start()
    }

    private func stopMonitoring() {
        timer?.invalidate()
        timer = nil
        FPSCounter.shared.stop()
    }

    private func refreshLogs() {
        logEntries = fetchRecentLogs(category: selectedLogCategory)
    }

    private func fetchRecentLogs(category: String) -> [String] {
        let store = try? OSLogStore(scope: .currentProcessIdentifier)
        guard let store else { return [] }

        let position = store.position(date: Date().addingTimeInterval(-300))
        let entries = try? store.getEntries(at: position)

        return (entries?.compactMap { entry in
            guard let log = entry as? OSLogEntryLog else { return nil }
            if category != "All" && log.category != category { return nil }
            let df = DateFormatter()
            df.dateFormat = "HH:mm:ss"
            return "[\(df.string(from: log.date))] [\(log.category)] \(log.composedMessage)"
        } ?? []).suffix(50).reversed()
    }

    private func refreshStorageSizes() {
        swiftDataStoreSize = "—"
        documentsSize = sizeString(for: documentsDirectory())
        cachesSize = sizeString(for: cachesDirectory())
    }

    private func clearCache() {
        let caches = cachesDirectory()
        try? FileManager.default.removeItem(at: caches)
        try? FileManager.default.createDirectory(at: caches, withIntermediateDirectories: true)
        cachesSize = "0 KB"
    }

    private func resetAllSettings() {
        for pref in preferences {
            modelContext.delete(pref)
        }
        try? modelContext.save()
    }

    private func exportLogs() {
        let logText = logEntries.joined(separator: "\n")
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("dirxplore_logs.txt")
        try? logText.write(to: url, atomically: true, encoding: .utf8)

        let av = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let root = scene.windows.first?.rootViewController {
            root.present(av, animated: true)
        }
    }

    // MARK: - Metrics

    private var fpsColor: Color {
        fps >= 55 ? .green : fps >= 30 ? .orange : .red
    }

    private var cpuColor: Color {
        cpuUsage < 50 ? .green : cpuUsage < 80 ? .orange : .red
    }

    private var memoryString: String {
        ByteCountFormatter.string(fromByteCount: Int64(memoryUsage), countStyle: .memory)
    }

    private func memoryUsed() -> UInt64 {
        var info = task_vm_info_data_t()
        var count = mach_msg_type_number_t(MemoryLayout<task_vm_info>.size) / 4
        let result = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_, task_flavor_t(TASK_VM_INFO), $0, &count)
            }
        }
        return result == KERN_SUCCESS ? info.phys_footprint : 0
    }

    private func cpuUsagePercent() -> Double {
        var threadsList: thread_act_array_t?
        var threadsCount = mach_msg_type_number_t(0)
        let result = task_threads(mach_task_self_, &threadsList, &threadsCount)
        guard result == KERN_SUCCESS, let threads = threadsList else { return 0 }

        var totalUsage: Double = 0
        for i in 0..<threadsCount {
            var threadInfo = thread_basic_info()
            var count = mach_msg_type_number_t(MemoryLayout<thread_basic_info>.size) / 4
            let infoResult = withUnsafeMutablePointer(to: &threadInfo) {
                $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                    thread_info(threads[Int(i)], thread_flavor_t(THREAD_BASIC_INFO), $0, &count)
                }
            }
            if infoResult == KERN_SUCCESS {
                let info = threadInfo as thread_basic_info
                if info.flags & TH_FLAGS_IDLE == 0 {
                    totalUsage += Double(info.cpu_usage) / Double(TH_USAGE_SCALE) * 100
                }
            }
        }
        vm_deallocate(mach_task_self_, vm_address_t(UInt64(bitPattern: threads)), vm_size_t(threadsCount) * vm_size_t(MemoryLayout<thread_t>.size))
        return totalUsage
    }

    private func documentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }

    private func cachesDirectory() -> URL {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }

    private func sizeString(for url: URL) -> String {
        guard let enumerator = FileManager.default.enumerator(at: url, includingPropertiesForKeys: [.fileSizeKey]) else {
            return "—"
        }
        var total: Int64 = 0
        for case let fileURL as URL in enumerator {
            guard let attrs = try? fileURL.resourceValues(forKeys: [.fileSizeKey]),
                  let size = attrs.fileSize else { continue }
            total += Int64(size)
        }
        return ByteCountFormatter.string(fromByteCount: total, countStyle: .file)
    }
}

// MARK: - FPS Counter

final class FPSCounter: NSObject {
    static let shared = FPSCounter()

    private var displayLink: CADisplayLink?
    private var lastTimestamp: CFTimeInterval = 0
    private var frameCount: Int = 0
    private(set) var fps: Double = 60

    func start() {
        stop()
        displayLink = CADisplayLink(target: self, selector: #selector(tick))
        displayLink?.add(to: .main, forMode: .common)
    }

    func stop() {
        displayLink?.invalidate()
        displayLink = nil
        lastTimestamp = 0
        frameCount = 0
    }

    @objc private func tick(_ link: CADisplayLink) {
        if lastTimestamp == 0 {
            lastTimestamp = link.timestamp
            return
        }
        frameCount += 1
        let elapsed = link.timestamp - lastTimestamp
        if elapsed >= 1.0 {
            fps = Double(frameCount) / elapsed
            frameCount = 0
            lastTimestamp = link.timestamp
        }
    }
}
