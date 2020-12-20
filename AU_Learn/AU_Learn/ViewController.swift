//
//  ViewController.swift
//  AU_Learn
//
//  Created by hanyang on 2020/12/19.
//

import UIKit
import AVKit
import CoreAudioKit
import AVFoundation

//enum AudioUnitType: Int {
//    case effect
//    case instrument
//}
//
//enum InstantiationType: Int {
//    case inProcess
//    case outOfProcess
//}
//
//enum PresetType: Int {
//    case factory
//    case user
//}
//
//enum UserPresetsChangeType: Int {
//    case save
//    case delete
//    case external
//    case undefined
//}
//
//
//
//struct UserPresetsChange {
//    let type: UserPresetsChangeType
//    let userPresets: [Preset]
//}


//extension Notification.Name {
//    static let userPresetsChanged = Notification.Name("userPresetsChanged")
//}
//
//// A simple wrapper type to prevent exposing the Core Audio AUAudioUnitPreset in the UI layer.
//public struct Preset {
//    init(name: String) {
//        let preset = AUAudioUnitPreset()
//        preset.name = name
//        preset.number = -1
//        self.init(preset: preset)
//    }
//    fileprivate init(preset: AUAudioUnitPreset) {
//        audioUnitPreset = preset
//    }
//    fileprivate let audioUnitPreset: AUAudioUnitPreset
//    public var number: Int { return audioUnitPreset.number }
//    public var name: String { return audioUnitPreset.name }
//}
//
//
//public struct Component {
//
//    private let audioUnitType: AudioUnitType
//    fileprivate let avAudioUnitComponent: AVAudioUnitComponent?
//
//    fileprivate init(_ component: AVAudioUnitComponent?, type: AudioUnitType) {
//        audioUnitType = type
//        avAudioUnitComponent = component
//    }
//
//    public var name: String {
//        guard let component = avAudioUnitComponent else {
//            return audioUnitType == .effect ? "(No Effect)" : "(No Instrument)"
//        }
//        return "\(component.name) (\(component.manufacturerName))"
//    }
//
//    public var hasCustomView: Bool {
//        #if os(macOS)
//        return avAudioUnitComponent?.hasCustomView ?? false
//        #else
//        return false
//        #endif
//    }
//}






class ViewController: UIViewController {
    
    var audioUnit: AUAudioUnit?
    private var currentViewConfigurationIndex = 1

    /// View configurations supported by the host app
    private var viewConfigurations: [AUAudioUnitViewConfiguration] = {
        let compact = AUAudioUnitViewConfiguration(width: 400, height: 100, hostHasController: false)
        let expanded = AUAudioUnitViewConfiguration(width: 800, height: 500, hostHasController: false)
        return [compact, expanded]
    }()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let manager = AVAudioUnitComponentManager.shared()
        
        // Retrieve audio unit components by description.
        let description = AudioComponentDescription(componentType: kAudioUnitType_Effect,
                                                    componentSubType: 0,
                                                    componentManufacturer: 0,
                                                    componentFlags: 0,
                                                    componentFlagsMask: 0)
        let componentsByDesc = manager.components(matching: description)
        
        
        // Retrieve audio unit components by predicate.
        let predicate = NSPredicate(format: "typeName CONTAINS 'Effect'")
        let componentsByPredicate = manager.components(matching: predicate)
        
        // Retrieve audio unit components by test.
        let componentsByTest = manager.components { component, _ in
            return component.typeName == AVAudioUnitTypeEffect
        }
        
        let description1 = componentsByTest[0].audioComponentDescription
        
        // Instantiate using AVFoundation's AVAudioUnit class method.
        
        //        AVAudioUnit.instantiate(with: description, options: []) { avAudioUnit, error in
        //            guard error == nil else {
        //
        //                let audioUnit = avAudioUnit!.audioUnit
        //                self.audioUnit = AUAudioUnit(audioUnit)
        //                var maxFrames = UInt32(4096)
        //
        //                // Set the maximum frames to render.
        //                AudioUnitSetProperty(audioUnit,
        //                                     kAudioUnitProperty_MaximumFramesPerSlice,
        //                                     kAudioUnitScope_Global,
        //                                     0,
        //                                     &maxFrames,
        //                                     UInt32(MemoryLayout<UInt32>.size))
        //                DispatchQueue.main.async {
        //                    /* Show error message to user. */
        //
        //                }
        //                return
        //            }
        let options = AudioComponentInstantiationOptions.loadOutOfProcess
        AVAudioUnit.instantiate(with: description, options: options) { avAudioUnit, error in
            guard error == nil else {
                DispatchQueue.main.async {
                    //                    completion(.failure(error!))
                }
                return
            }
            self.audioUnit = avAudioUnit?.auAudioUnit
            //            self.playEngine.connect(avAudioUnit: avAudioUnit) {
            ////                DispatchQueue.main.async {
            ////                    completion(.success(true))
            ////                }
            //            }
        }
        
        
        
        
        
        // Audio unit successfully instantiated.
        // Connect it to AVAudioEngine to use.
        
        
        
        
    }
    
    
    func loadAudioUnitViewController(completion: @escaping (ViewController?) -> Void) {
        
        
        
        
        if let audioUnit = audioUnit {
            
            audioUnit.requestViewController { viewController in
                DispatchQueue.main.async {
                }
            }
        } else {
            completion(nil)
        }
    }
    
    
}

