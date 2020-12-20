//
//  AudioUnitManager.swift
//  AU_Learn
//
//  Created by hanyang on 2020/12/20.
//

import UIKit
import AVKit
import CoreAudioKit
import AVFoundation

enum AudioUnitType: Int {
    case effect
    case instrument
}

enum InstantiationType: Int {
    case inProcess
    case outOfProcess
}

enum PresetType: Int {
    case factory
    case user
}

enum UserPresetsChangeType: Int {
    case save
    case delete
    case external
    case undefined
}



struct UserPresetsChange {
    let type: UserPresetsChangeType
    let userPresets: [Preset]
}


extension Notification.Name {
    static let userPresetsChanged = Notification.Name("userPresetsChanged")
}

// A simple wrapper type to prevent exposing the Core Audio AUAudioUnitPreset in the UI layer.
public struct Preset {
    init(name: String) {
        let preset = AUAudioUnitPreset()
        preset.name = name
        preset.number = -1
        self.init(preset: preset)
    }
    fileprivate init(preset: AUAudioUnitPreset) {
        audioUnitPreset = preset
    }
    fileprivate let audioUnitPreset: AUAudioUnitPreset
    public var number: Int { return audioUnitPreset.number }
    public var name: String { return audioUnitPreset.name }
}


public struct Component {

    private let audioUnitType: AudioUnitType
    fileprivate let avAudioUnitComponent: AVAudioUnitComponent?

    fileprivate init(_ component: AVAudioUnitComponent?, type: AudioUnitType) {
        audioUnitType = type
        avAudioUnitComponent = component
    }

    public var name: String {
        guard let component = avAudioUnitComponent else {
            return audioUnitType == .effect ? "(No Effect)" : "(No Instrument)"
        }
        return "\(component.name) (\(component.manufacturerName))"
    }

    public var hasCustomView: Bool {
        #if os(macOS)
        return avAudioUnitComponent?.hasCustomView ?? false
        #else
        return false
        #endif
    }
}


class AudioUnitManager {
    // Filter out these AUs. They don't make sense for this demo.
    var filterClosure: (AVAudioUnitComponent) -> Bool = {
        
        let blacklist = ["AUNewPitch", "AURoundTripAAC", "AUNetSend"]
        var allowed = !blacklist.contains($0.name)
        #if os(macOS)
        if allowed && $0.typeName == AVAudioUnitTypeEffect {
            allowed = $0.hasCustomView
        }
        #endif
        return allowed
    }
}
