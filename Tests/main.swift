// Yön mantığını sisteme hiçbir olay göndermeden, elle kurulan olaylarla sınar.
import AppKit
import ApplicationServices

var failures = 0

func check(_ name: String, _ passed: Bool) {
    print("\(passed ? "GEÇTİ" : "KALDI")  \(name)")
    if !passed { failures += 1 }
}

struct Deltas: Equatable {
    var axis1, axis2, point1, point2: Int64
    var fixed1, fixed2: Double

    var negated: Deltas {
        Deltas(axis1: -axis1, axis2: -axis2, point1: -point1, point2: -point2, fixed1: -fixed1, fixed2: -fixed2)
    }
}

func read(_ event: CGEvent) -> Deltas {
    Deltas(
        axis1: event.getIntegerValueField(.scrollWheelEventDeltaAxis1),
        axis2: event.getIntegerValueField(.scrollWheelEventDeltaAxis2),
        point1: event.getIntegerValueField(.scrollWheelEventPointDeltaAxis1),
        point2: event.getIntegerValueField(.scrollWheelEventPointDeltaAxis2),
        fixed1: event.getDoubleValueField(.scrollWheelEventFixedPtDeltaAxis1),
        fixed2: event.getDoubleValueField(.scrollWheelEventFixedPtDeltaAxis2))
}

func makeEvent(continuous: Bool, invertedByMacOS: Bool = false) -> CGEvent {
    let event = CGEvent(scrollWheelEvent2Source: nil, units: .line, wheelCount: 2, wheel1: 3, wheel2: -2, wheel3: 0)!
    event.setIntegerValueField(.scrollWheelEventIsContinuous, value: continuous ? 1 : 0)
    event.setIntegerValueField(.scrollWheelEventDeltaAxis1, value: 3)
    event.setIntegerValueField(.scrollWheelEventDeltaAxis2, value: -2)
    event.setIntegerValueField(.scrollWheelEventPointDeltaAxis1, value: 30)
    event.setIntegerValueField(.scrollWheelEventPointDeltaAxis2, value: -20)
    event.setDoubleValueField(.scrollWheelEventFixedPtDeltaAxis1, value: 2.5)
    event.setDoubleValueField(.scrollWheelEventFixedPtDeltaAxis2, value: -1.5)
    if invertedByMacOS, let field = CGEventField(rawValue: 137) {
        // macOS'un "yön çevrildi" işareti yalnızca bu testte elle kurulur; uygulama bu alana dokunmaz.
        event.setIntegerValueField(field, value: 1)
    }
    return event
}

let baseline = read(makeEvent(continuous: false))
check("Test olayı beklenen değerleri taşıyor",
      baseline == Deltas(axis1: 3, axis2: -2, point1: 30, point2: -20, fixed1: 2.5, fixed2: -1.5))

let negated = makeEvent(continuous: false)
ScrollFlip.negateDeltas(of: negated)
check("Altı alanın hepsi ters çevriliyor", read(negated) == baseline.negated)
ScrollFlip.negateDeltas(of: negated)
check("İki kez çevirince ilk değerlere dönüyor", read(negated) == baseline)

let trackpad = makeEvent(continuous: true, invertedByMacOS: true)
ScrollFlip.reverseIfNeeded(trackpad)
check("Trackpad olayına dokunulmuyor", read(trackpad) == baseline)

let naturalOff = makeEvent(continuous: false)
check("Test olayında yön işareti kapalı", NSEvent(cgEvent: naturalOff)?.isDirectionInvertedFromDevice == false)
ScrollFlip.reverseIfNeeded(naturalOff)
check("Doğal kaydırma kapalıyken tekerlek olayına dokunulmuyor", read(naturalOff) == baseline)

let naturalOn = makeEvent(continuous: false, invertedByMacOS: true)
if NSEvent(cgEvent: naturalOn)?.isDirectionInvertedFromDevice == true {
    ScrollFlip.reverseIfNeeded(naturalOn)
    check("Doğal kaydırma açıkken tekerlek olayı çevriliyor", read(naturalOn) == baseline.negated)
} else {
    print("ATLANDI  Yön işareti elle kurulamadı; bu yol gerçek tekerlekle ölçülmeli")
}

for symbol in ["computermouse", "computermouse.fill", "exclamationmark.triangle"] {
    check("Menü simgesi var: \(symbol)", NSImage(systemSymbolName: symbol, accessibilityDescription: nil) != nil)
}

let start = ProcessInfo.processInfo.systemUptime
for _ in 0..<100 { _ = AXIsProcessTrusted() }
let perCall = (ProcessInfo.processInfo.systemUptime - start) * 10
print(String(format: "BİLGİ  İzin kontrolü çağrı başına %.3f ms", perCall))

print(failures == 0 ? "Tüm testler geçti." : "\(failures) test kaldı.")
exit(failures == 0 ? 0 : 1)
