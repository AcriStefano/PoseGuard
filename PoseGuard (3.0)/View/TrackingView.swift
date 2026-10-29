import SwiftUI
import CoreMotion
import AVFoundation

struct TrackingView: View {
    @Binding var hasCompletedOnboarding: Bool

    @StateObject private var postureMonitor = PostureMonitorModel()
    @State private var motionManager = CMHeadphoneMotionManager()
    /// Non-nil while tracking; also measures the session's time in a correct posture.
    @State private var postureTimer: CorrectPostureTimer?
    @State private var showTips = false
    @State private var showReport = false
    @State private var showAirPodsAlert = false

    @Environment(SessionStore.self) private var sessionStore
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var isTracking: Bool { postureTimer != nil }

    /// Gray while idle, green or red while tracking, as in the original design.
    private var stateColor: Color {
        guard isTracking else { return .gray }
        return postureMonitor.isPostureCorrect ? PostureCategory.buona.color : PostureCategory.cattiva.color
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black
                    .ignoresSafeArea()

                ZStack {
                    // Idle: one slow gray ripple invites a tap. Tracking: three ripples in the posture color.
                    if !reduceMotion {
                        PulseRings(color: stateColor, count: isTracking ? 3 : 1)
                            .id(isTracking)
                    }

                    TrackButton(isTracking: isTracking, tint: stateColor, action: toggleTracking)
                }
                .overlay(alignment: .top) {
                    Group {
                        if isTracking {
                            Text(postureMonitor.postureMessage)
                        } else if reduceMotion {
                            // Without the motion cues, spell out what the button does.
                            Text("Tap to Track")
                        }
                    }
                    .font(.title2.weight(.medium))
                    .foregroundStyle(stateColor)
                    .multilineTextAlignment(.center)
                    .containerRelativeFrame(.horizontal) { width, _ in width - 32 }
                    .fixedSize(horizontal: false, vertical: true)
                    // Sit above the button without moving it off center.
                    .alignmentGuide(.top) { $0[.bottom] + 56 }
                }
                // Centered on the physical screen, ignoring the toolbar.
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()
            }
            .overlay(alignment: .bottom) {
                if let postureTimer {
                    LiveStatsCard(startDate: postureTimer.start, pitch: postureMonitor.pitch, roll: postureMonitor.roll)
                        .padding()
                        .transition(reduceMotion ? .opacity : .move(edge: .bottom).combined(with: .opacity))
                }
            }
            .animation(Theme.spring, value: isTracking)
            .animation(.smooth, value: postureMonitor.isPostureCorrect)
            // Named for VoiceOver and the app switcher, but not drawn in the bar.
            .navigationTitle("PoseGuard")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(removing: .title)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("How it works", systemImage: "info.circle", action: showOnboarding)
                }

                ToolbarItemGroup(placement: .primaryAction) {
                    Button("Tips", systemImage: "lightbulb") { showTips = true }
                    Button("My Report", systemImage: "chart.bar.xaxis") { showReport = true }
                }
            }
            .sheet(isPresented: $showTips) {
                MyTipsView()
            }
            .sheet(isPresented: $showReport) {
                MyReportView()
            }
            .alert("AirPods not connected", isPresented: $showAirPodsAlert) {
            } message: {
                Text("Put on AirPods with motion sensors, then try again.")
            }
            .sensoryFeedback(.impact, trigger: isTracking)
            .sensoryFeedback(trigger: postureMonitor.isPostureCorrect) { _, isCorrect in
                isTracking && !isCorrect ? .warning : nil
            }
            .onChange(of: postureMonitor.isPostureCorrect) { _, isCorrect in
                guard isTracking else { return }
                postureTimer?.update(isCorrect: isCorrect, at: .now)
                // VoiceOver users can't see the color change, so speak it.
                AccessibilityNotification.Announcement(postureMonitor.postureMessage).post()
            }
        }
    }

    private func showOnboarding() {
        hasCompletedOnboarding = false
    }

    private func toggleTracking() {
        if isTracking {
            stopTracking()
        } else {
            startTracking()
        }
    }

    private func startTracking() {
        areAirPodsConnected { isAirPods in
            if isAirPods && motionManager.isDeviceMotionAvailable {
                postureTimer = CorrectPostureTimer(start: .now, isCorrect: postureMonitor.isPostureCorrect)
                postureMonitor.startMonitoring()
            } else {
                showAirPodsAlert = true
            }
        }
    }

    private func stopTracking() {
        if let session = postureTimer?.session(endingAt: .now) {
            sessionStore.add(session)
        }
        postureTimer = nil
        postureMonitor.stopMonitoring()
    }

    func areAirPodsConnected(completion: @escaping (Bool) -> Void) {
        let motionManager = CMHeadphoneMotionManager()

            // Verifica se il dispositivo supporta HeadphoneMotion
        guard motionManager.isDeviceMotionAvailable else {
            print("Il giroscopio non è disponibile.")
            completion(false)
            return
        }

        let session = AVAudioSession.sharedInstance()
        let outputs = session.currentRoute.outputs

            // Verifica se ci sono cuffie Bluetooth collegate
        let areHeadphonesConnected = outputs.contains { output in
            output.portType == .bluetoothA2DP || output.portType == .bluetoothHFP
        }

        if !areHeadphonesConnected {
            print("Nessuna cuffia Bluetooth collegata.")
            completion(false)
            return
        }

            // Impostiamo un timeout per verificare se riceviamo dati dal giroscopio
        var receivedMotionData = false
        var timeoutTimer: Timer?

            // Inizia a monitorare i dati del giroscopio
        motionManager.startDeviceMotionUpdates(to: OperationQueue.main) { (data, error) in
            if error != nil {
                    // In caso di errore, non sono AirPods con giroscopio
                timeoutTimer?.invalidate()
                motionManager.stopDeviceMotionUpdates()
                if !receivedMotionData {
                    print("Errore dal giroscopio - non sono AirPods.")
                    receivedMotionData = true
                    completion(false)
                }
                return
            }

            if data != nil && !receivedMotionData {
                    // Abbiamo ricevuto dati dal giroscopio, sono AirPods
                timeoutTimer?.invalidate()
                print("Giroscopio attivo e dati disponibili - sono AirPods.")
                receivedMotionData = true
                completion(true)
                    // Non fermiamo gli aggiornamenti in caso serva continuare a usare i dati
            }
        }

            // Impostiamo un timeout (ad esempio 1 secondo)
        timeoutTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { _ in
            if !receivedMotionData {
                print("Timeout: nessun dato dal giroscopio - non sono AirPods.")
                motionManager.stopDeviceMotionUpdates()
                completion(false)
            }
        }
    }
}

#Preview {
    TrackingView(hasCompletedOnboarding: .constant(true))
        .environment(SessionStore())
}
