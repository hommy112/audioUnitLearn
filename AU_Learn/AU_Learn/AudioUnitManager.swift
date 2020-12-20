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


// Standard Audio Unit Types
//@available(iOS 9.0, *)
//音频单元类型是一种输出类型。
//public let AVAudioUnitTypeOutput: String
//@available(iOS 9.0, *)
//音频单元类型是一种音乐设备类型。
//public let AVAudioUnitTypeMusicDevice: String
//@available(iOS 9.0, *)
//音频单元类型是一种音乐效果类型。
//public let AVAudioUnitTypeMusicEffect: String
//@available(iOS 9.0, *)
//音频单元类型是一种格式转换器类型。
//public let AVAudioUnitTypeFormatConverter: String
//@available(iOS 9.0, *)
//音频单元类型是音效类型。
//public let AVAudioUnitTypeEffect: String
//@available(iOS 9.0, *)
//音频单元类型是混音器类型。
//public let AVAudioUnitTypeMixer: String
//@available(iOS 9.0, *)
//音频单元类型是(平移?)类型。
//public let AVAudioUnitTypePanner: String
//@available(iOS 9.0, *)
//音频单元类型是生成器类型。
//public let AVAudioUnitTypeGenerator: String
//@available(iOS 9.0, *)
//音频单元类型是脱机效果类型。
//public let AVAudioUnitTypeOfflineEffect: String
//@available(iOS 9.0, *)
//medi 处理器类型
//public let AVAudioUnitTypeMIDIProcessor: String
//
//// Standard Audio Unit Manufacturers
//@available(iOS 9.0, *)
//public let AVAudioUnitManufacturerNameApple: String


/// 集成的是那个类型的 AU
enum AudioUnitType: Int {
    case effect
    case instrument
}

//AudioComponentInstantiationOptions
//大多数组件实例都被加载到调用过程中。
//
//然而，版本3音频单元可以加载到单独的扩展服务流程中，这是这些组件的默认行为。为了能够加载一个进程内的音频单元，开发人员需要将音频单元打包在一个bundle中，与应用程序扩展分开，因为扩展的主二进制文件不能动态加载到另一个进程中。
//
//macOS主机可以使用kAudioComponentInstantiation_LoadInProcess请求进程内加载这些音频单元。
//
//kAudioComponentFlag_IsV3AudioUnit指定一个音频单元是否使用API版本3实现。
//
//这些选项只是对实现的请求。它可能会失败并退回到默认值。
//尝试将组件加载到一个单独的扩展进程中。
//尝试将组件加载到当前进程中。仅在macOS上可用。
// An enum used to prevent exposing the Core Audio AudioComponentInstantiationOptions to the UI layer. 可能自认为比较底层不是很想跨过服务层进入应用层
enum InstantiationType: Int {
//    将音频进程加载到主进程运行
    case inProcess
//    将音频组件加载到子进程运行
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
//防止跨层的封装但其实还是有暴露 但是方便自己做监听扩展
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








//提供有关音频单元的详细信息，如类型、子类型、制造商、位置等。用户
//标签可以添加到AVAudioUnitComponent中，稍后可以查询它以显示。
public struct Component {

    private let audioUnitType: AudioUnitType
    fileprivate let avAudioUnitComponent: AVAudioUnitComponent?

    fileprivate init(_ component: AVAudioUnitComponent?, type: AudioUnitType) {
        audioUnitType = type
        avAudioUnitComponent = component
    }

    public var name: String {
        guard let component = avAudioUnitComponent else {
            // TODO: 需要仔细找两种类型的差别
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
    
    
    var observer: NSKeyValueObservation?
    
    var userPresetChangeType: UserPresetsChangeType = .undefined
    
    private var audioUnit: AUAudioUnit? {
        didSet {
            // A new audio unit was selected. Reset our internal state.
            observer = nil
            userPresetChangeType = .undefined

            // If the selected audio unit doesn't support user presets, return.
            guard audioUnit?.supportsUserPresets ?? false else { return }
            
            // Start observing the selected audio unit's "userPresets" property.
            observer = audioUnit?.observe(\.userPresets) { _, _ in
                DispatchQueue.main.async {
                    var changeType = self.userPresetChangeType
                    // If the change wasn't triggered by a user save or delete, it changed
                    // due to an external add or remove from the presets folder.
                    if ![.save, .delete].contains(changeType) {
                        changeType = .external
                    }
                    
                    // Post a notification to any registered listeners.
                    let change = UserPresetsChange(type: changeType, userPresets: self.userPresets)
                    NotificationCenter.default.post(name: .userPresetsChanged, object: change)
                    
                    // Reset property to its default value
                    self.userPresetChangeType = .undefined
                }
            }
        }
    }
//    搞一个处理 unit 组件的队列
    private let componentsAccessQueue = DispatchQueue(label: "com.example.apple-samplecode.ComponentsAccessQueue")
    
    
    private var _components = [Component]()

    /// The loaded AVAudioUnitComponent objects.
    private var components: [Component] {
        // This property can be accessed by multiple threads. Synchronize reads/writes.
        //存取器在一个队列里串行执行保证了存取器的原子性
        get {
            var array = [Component]()
            componentsAccessQueue.sync {
                array = _components
            }
            return array
        }
        set {
            componentsAccessQueue.sync {
                _components = newValue
            }
        }
    }

    /// The playback engine used to play audio.
    private let playEngine = SimplePlayEngine()

    private var options = AudioComponentInstantiationOptions.loadOutOfProcess
    
    
    
    
    @available(iOS, unavailable)
    var instantiationType = InstantiationType.outOfProcess {
        didSet {
            options = instantiationType == .inProcess ? .loadInProcess : .loadOutOfProcess
        }
    }

    // MARK: Preset Management

    /// Gets the audio unit's factory presets.
    public var factoryPresets: [Preset] {
        //出厂预设
        guard let presets = audioUnit?.factoryPresets else { return [] }
        return presets.map { Preset(preset: $0) }
    }
    
    /// Get or set the audio unit's current preset.
    public var currentPreset: Preset? {
        get {
            guard let preset = audioUnit?.currentPreset else { return nil }
            return Preset(preset: preset)
        }
        set {
            audioUnit?.currentPreset = newValue?.audioUnitPreset
        }
    }
    
    // MARK: User Presets
    
    /// Gets the audio unit's user presets.
    public var userPresets: [Preset] {
        guard let presets = audioUnit?.userPresets else { return [] }
        return presets.map { Preset(preset: $0) }.reversed()
    }
    
    public func savePreset(_ preset: Preset) throws {
        userPresetChangeType = .save
        try audioUnit?.saveUserPreset(preset.audioUnitPreset)
    }
    
    public func deletePreset(_ preset: Preset) throws {
        userPresetChangeType = .delete
        try audioUnit?.deleteUserPreset(preset.audioUnitPreset)
    }
    
    var supportsUserPresets: Bool {
        return audioUnit?.supportsUserPresets ?? false
    }

    // MARK: View Configuration

    var preferredWidth: CGFloat {
        return viewConfigurations[currentViewConfigurationIndex].width
    }

    private var currentViewConfigurationIndex = 1

    /// View configurations supported by the host app
//    主机可能支持在不同配置中嵌入音频单元的视图。这些配置可能在为音频单元的视图保留的大小和附加的控制表面上有所不同。
//    主机可以提出几种视图配置，音频单元应该报告它所支持的视图配置。
    private var viewConfigurations: [AUAudioUnitViewConfiguration] = {
//        @param        width
//            The width associated with this view configuration.
//        @param        height
//            The height associated with this view configuration.
//        @param        hostHasController
//            This property controls whether the host shows its own control surface in this view
//            configuration.
        let compact = AUAudioUnitViewConfiguration(width: 400, height: 100, hostHasController: false)
        let expanded = AUAudioUnitViewConfiguration(width: 800, height: 500, hostHasController: false)
        return [compact, expanded]
    }()

    /// Determines if the selected AU provides more than one user interface.
    var providesAlterativeViews: Bool {
        guard let audioUnit = audioUnit else { return false }
        let supportedConfigurations = audioUnit.supportedViewConfigurations(viewConfigurations)
        return supportedConfigurations.count > 1
    }

    /// Determines if the selected AU provides provides user interface.
    //    在框架中实现，且不应被实现者重写。框架检测是否有任何子类实现了requestViewControllerWithCompletionHandler:或被一个扩展点标识为' com.apple.AudioUnit-UI '的AU扩展实现。请参见<CoreAudioKit/AUViewController.h> ' requestViewControllerWithCompletionHandler: '
    var providesUserInterface: Bool {
        return audioUnit?.providesUserInterface ?? false
    }

    /// Toggles the current view mode (compact or expanded)
    func toggleViewMode() {
        guard let audioUnit = audioUnit else { return }
        currentViewConfigurationIndex = currentViewConfigurationIndex == 0 ? 1 : 0
        audioUnit.select(viewConfigurations[currentViewConfigurationIndex])
    }
    
    
    func loadAudioUnits(ofType type: AudioUnitType, completion: @escaping ([Component]) -> Void) {

        // Reset the engine to remove any configured audio units.
        playEngine.reset()

        // Locating components is a blocking operation. Perform this work on a separate queue.
        DispatchQueue.global(qos: .default).async {

            let componentType = type == .effect ? kAudioUnitType_Effect : kAudioUnitType_MusicDevice

             // Make a component description matching any Audio Unit of the selected component type.
            let description = AudioComponentDescription(componentType: componentType,
                                                        componentSubType: 0,
                                                        componentManufacturer: 0,
                                                        componentFlags: 0,
                                                        componentFlagsMask: 0)

            let components = AVAudioUnitComponentManager.shared().components(matching: description)

            // Filter out components that don't make sense for this demo.
            // Map AVAudioUnitComponent to array of Component (view model) objects.
            var wrapped = components.filter(self.filterClosure).map { Component($0, type: type) }

            // Insert a "No Effect" element into array if effect
            if type == .effect {
                wrapped.insert(Component(nil, type: type), at: 0)
            }
            self.components = wrapped
            // Notify the caller of the loaded components.
            DispatchQueue.main.async {
                completion(wrapped)
            }
        }
    }
    
    func selectComponent(at index: Int, completion: @escaping (Result<Bool, Error>) -> Void) {

        // nil out existing component
        audioUnit = nil

        // Get the wrapped AVAudioUnitComponent
        guard let component = components[index].avAudioUnitComponent else {
            // Reset the engine to remove any configured audio units.
            playEngine.reset()
            // Return success, but indicate an audio unit was not selected.
            // This occurrs when the user selects the (No Effect) row.
            completion(.success(false))
            return
        }

        // Get the component description
        let description = component.audioComponentDescription

        // Instantiate the audio unit and connect it the the play engine.
        AVAudioUnit.instantiate(with: description, options: options) { avAudioUnit, error in
            guard error == nil else {
                DispatchQueue.main.async {
                    completion(.failure(error!))
                }
                return
            }
            self.audioUnit = avAudioUnit?.auAudioUnit
//            self.playEngine.connect(avAudioUnit: avAudioUnit) {
//                DispatchQueue.main.async {
//                    completion(.success(true))
//                }
//            }
        }
    }

    func loadAudioUnitViewController(completion: @escaping (UIViewController?) -> Void) {
        if let audioUnit = audioUnit {
            audioUnit.requestViewController { viewController in
                DispatchQueue.main.async {
                    completion(viewController!)
                }
            }
        } else {
            completion(nil)
        }
    }

    // MARK: Audio Transport

//    @discardableResult
//    func togglePlayback() -> Bool {
//        return playEngine.togglePlay()
//    }
//
//    func stopPlayback() {
//        playEngine.stopPlaying()
//    }

}
