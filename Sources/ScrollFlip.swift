import AppKit

enum ScrollFlip {
    /// Fare tekerleği olayını Windows yönüne çevirir.
    /// Trackpad olayları sürekli olduğu için dokunulmaz. macOS yönü çevirmemişse
    /// (Doğal kaydırma kapalıysa) tekerlek zaten Windows yönündedir, olay olduğu gibi kalır.
    static func reverseIfNeeded(_ event: CGEvent) {
        guard event.getIntegerValueField(.scrollWheelEventIsContinuous) == 0,
              NSEvent(cgEvent: event)?.isDirectionInvertedFromDevice == true
        else { return }
        negateDeltas(of: event)
    }

    /// Uygulamalar satır, nokta veya kesirli değerden herhangi birini okuyabilir; hepsi birlikte çevrilir.
    /// Shift ile tekerlek yatay eksenden geldiği için iki eksen de çevrilir.
    static func negateDeltas(of event: CGEvent) {
        let axis1 = event.getIntegerValueField(.scrollWheelEventDeltaAxis1)
        let axis2 = event.getIntegerValueField(.scrollWheelEventDeltaAxis2)
        let point1 = event.getIntegerValueField(.scrollWheelEventPointDeltaAxis1)
        let point2 = event.getIntegerValueField(.scrollWheelEventPointDeltaAxis2)
        let fixed1 = event.getDoubleValueField(.scrollWheelEventFixedPtDeltaAxis1)
        let fixed2 = event.getDoubleValueField(.scrollWheelEventFixedPtDeltaAxis2)

        event.setIntegerValueField(.scrollWheelEventDeltaAxis1, value: -axis1)
        event.setIntegerValueField(.scrollWheelEventDeltaAxis2, value: -axis2)
        event.setIntegerValueField(.scrollWheelEventPointDeltaAxis1, value: -point1)
        event.setIntegerValueField(.scrollWheelEventPointDeltaAxis2, value: -point2)
        event.setDoubleValueField(.scrollWheelEventFixedPtDeltaAxis1, value: -fixed1)
        event.setDoubleValueField(.scrollWheelEventFixedPtDeltaAxis2, value: -fixed2)
    }
}
