#  AVAudioNode 
一个用于音频处理的抽象!!!类

### AVAUDIONODE_HAVE_AUAUDIOUNIT
```
public var AVAUDIONODE_HAVE_AUAUDIOUNIT: Int32 { get }
```
不知道是干什么的从字面上看好像是检测 au 是否可用

### AVAudioNodeTapBlock
```
/**    @typedef AVAudioNodeTapBlock
    @abstract A block that receives copies of the output of an AVAudioNode.
    @param buffer
        a buffer of audio captured from the output of an AVAudioNode
    @param when
        the time at which the buffer was captured
    @discussion
        CAUTION: This callback may be invoked on a thread other than the main thread.
*/
public typealias AVAudioNodeTapBlock = (AVAudioPCMBuffer, AVAudioTime) -> Void
```
一个用于处理AVAudioNode输出的音频的副本block
buffer 顾名思义音频(脉冲)文件的缓冲区,看不出是否需要手动 flush
when 音频输出的时间

```
/** @method reset
    @abstract Clear a unit's previous processing state.
*/
open func reset()
```
清除 au 的之前的处理状态

```
/** @method inputFormatForBus:
    @abstract Obtain an input bus's format.
*/
open func inputFormat(forBus bus: AVAudioNodeBus) -> AVAudioFormat
```
从音频输入获得当前音频的格式 
bus : 不详 //todo

```
/** @method outputFormatForBus:
    @abstract Obtain an output bus's format.
*/
open func outputFormat(forBus bus: AVAudioNodeBus) -> AVAudioFormat
```
从音频输出获得当前音频的格式 

```
/**    @method nameForInputBus:
    @abstract Return the name of an input bus.
*/
open func name(forInputBus bus: AVAudioNodeBus) -> String?
```
当前 au_bus 的名称

```

/** @method installTapOnBus:bufferSize:format:block:
    @abstract Create a "tap" to record/monitor/observe the output of the node.
    @param bus
        the node output bus to which to attach the tap
    @param bufferSize
        the requested size of the incoming buffers in sample frames. Supported range is [100, 400] ms.
    @param format
        If non-nil, attempts to apply this as the format of the specified output bus. This should
        only be done when attaching to an output bus which is not connected to another node; an
        error will result otherwise.
        The tap and connection formats (if non-nil) on the specified bus should be identical. 
        Otherwise, the latter operation will override any previously set format.
    @param tapBlock
        a block to be called with audio buffers
    
    @discussion
        Only one tap may be installed on any bus. Taps may be safely installed and removed while
        the engine is running.
 
        Note that if you have a tap installed on AVAudioOutputNode, there could be a mismatch
        between the tap buffer format and AVAudioOutputNode's output format, depending on the
        underlying physical device. Hence, instead of tapping the AVAudioOutputNode, it is
        advised to tap the node connected to it.

        E.g. to capture audio from input node:
<pre>
AVAudioEngine *engine = [[AVAudioEngine alloc] init];
AVAudioInputNode *input = [engine inputNode];
AVAudioFormat *format = [input outputFormatForBus: 0];
[input installTapOnBus: 0 bufferSize: 8192 format: format block: ^(AVAudioPCMBuffer *buf, AVAudioTime *when) {
// ‘buf' contains audio captured from input node at time 'when'
}];
....
// start engine
</pre>
*/
open func installTap(onBus bus: AVAudioNodeBus, bufferSize: AVAudioFrameCount, format: AVAudioFormat?, block tapBlock: @escaping AVAudioNodeTapBlock)

```


创建一个“tap”来记录/监控/观察节点的输出。
bus : 连接tap的节点输出总线
bufferSize : 采样帧中输入缓冲区的需要的大小,支持的范围是[100,400]ms.
format : 如果非nil,尝试将此格式作为指定输出总线的格式.只有当连接到一个没有连接到另一个节点的输出总线时,才应该这样做;否则将导致错误.指定总线上的tap和连接格式(如果非nil)应该是相同的.否则,后一种操作将覆盖以前设置的任何格式.
tapBlock : tapBlock当音频被缓冲后调用的闭包

每一个 bus 上只允许存在一个 tap, tap 在音频引擎运行时也可以安全的添加或删除

注意 当你通在AVAudioOutputNode 绑定 tap 时可能会由于 buffer 的格式和AVAudioOutputNode 的输出格式的不同而导致失败,这取决于底层的物理接口,因此建议不要直接在AVAudioOutputNode上绑定 tap 而应该在与之相连的 node 上绑定 tap,比如 inputnode 如下
```AVAudioEngine *engine = [[AVAudioEngine alloc] init];
AVAudioInputNode *input = [engine inputNode];
AVAudioFormat *format = [input outputFormatForBus: 0];
[input installTapOnBus: 0 bufferSize: 8192 format: format block: ^(AVAudioPCMBuffer *buf, AVAudioTime *when) {
// ‘buf' contains audio captured from input node at time 'when'
}];
// start engine
```
```
open func removeTap(onBus bus: AVAudioNodeBus)
```
顾名思义

```

/**    @property engine
    @abstract The engine to which the node is attached (or nil).
*/
open var engine: AVAudioEngine? { get }
```
为某一个节点绑定的音频引擎

```
/** @property numberOfInputs
    @abstract The node's number of input busses.
*/
open var numberOfInputs: Int { get }
```
某个 node 的输入 bus 数量

```
/** @property numberOfOutputs
    @abstract The node's number of output busses.
*/
open var numberOfOutputs: Int { get }
```
当前 node 的输出的 bus 数量

```
/** @property lastRenderTime
    @abstract Obtain the time for which the node most recently rendered.
    @discussion
        Will return nil if the engine is not running or if the node is not connected to an input or
        output node.
*/
open var lastRenderTime: AVAudioTime? { get }
```
某个节点的最近渲染时间
若当前节点并没有在运行或者并没有连接到任何输入或者输出节点则返回 nil

```
/** @property AUAudioUnit
    @abstract An AUAudioUnit wrapping or underlying the implementation's AudioUnit.
    @discussion
        This provides an AUAudioUnit which either wraps or underlies the implementation's
        AudioUnit, depending on how that audio unit is packaged. Applications can interact with this
        AUAudioUnit to control custom properties, select presets, change parameters, etc.

        No operations that may conflict with state maintained by the engine should be performed 
        directly on the audio unit. These include changing initialization state, stream formats, 
        channel layouts or connections to other audio units.
*/
@available(iOS 11.0, *)
open var auAudioUnit: AUAudioUnit { get }
```
这提供了一个AUAudioUnit，它是包装或作为实现的AudioUnit的基础，这取决于音频单元如何打包。应用程序可以与这个AUAudioUnit交互，以控制自定义属性、选择预设值、更改参数等。
任何可能与引擎维护的状态相冲突的操作都不应该直接在音频设备上执行。这些包括改变初始化状态、流格式、通道布局或与其他音频单元的连接。

```
/**    @property latency
    @abstract The processing latency of the node, in seconds.
    @discussion
        This property reflects the delay between when an impulse in the audio stream arrives at the
        input vs. output of the node. This should reflect the delay due to signal processing 
        (e.g. filters, FFT's, etc.), not delay or reverberation which is being applied as an effect. 
        A value of zero indicates either no latency or an unknown latency.
*/
@available(iOS 11.0, *)
open var latency: TimeInterval { get }
```
此属性反映音频流中的脉冲到达节点的输入与输出之间的延迟。这应该反映由于信号处理(例如滤波器、FFT等)造成的延迟，而不是作为效果应用的延迟或混响。值为0表示没有延迟或未知延迟。


```
/**    @property outputPresentationLatency
    @abstract The maximum render pipeline latency downstream of the node, in seconds.
    @discussion
        This describes the maximum time it will take for the audio at the output of a node to be
        presented. 
        For instance, the output presentation latency of the output node in the engine is:
            - zero in manual rendering mode
            - the presentation latency of the device itself when rendering to an audio device
              (see `AVAudioIONode(presentationLatency)`)
        The output presentation latency of a node connected directly to the output node is the
        output node's presentation latency plus the output node's processing latency (see `latency`).
 
        For a node which is exclusively in the input node chain (i.e. not connected to engine's 
        output node), this property reflects the latency for the output of this node to be 
        presented at the output of the terminating node in the input chain.

        A value of zero indicates either an unknown or no latency.
 
        Note that this latency value can change as the engine is reconfigured (started/stopped, 
        connections made/altered downstream of this node etc.). So it is recommended not to cache
        this value and fetch it whenever it's needed.
*/
@available(iOS 11.0, *)
open var outputPresentationLatency: TimeInterval { get }
```
这描述了在节点的输出处显示音频所需要的最大时间。
例如，引擎中输出节点的输出呈现延迟为:
1. 手动渲染模式为零
2. 当渲染到音频设备时设备本身的呈现延迟(参见“AVAudioIONode(presentationLatency)”)
直接连接到输出节点的输出表示延迟是输出节点的表示延迟加上输出节点的处理延迟(见“latency”)。

对于只在输入节点链中的节点(即没有连接到引擎的输出节点)，该属性反映了该节点的输出在输入链中终止节点的输出中呈现的延迟。

值为0表示未知或无延迟。

请注意，这个延迟值可能会随着引擎的重新配置而改变(启动/停止、在该节点下游建立/更改连接等)。因此，建议不要缓存这个值并在需要的时候获取它。

# AUAudioUnit

```
/**    @typedef    AUAudioUnitStatus
    @brief        A result code returned from an audio unit's render function.
*/
public typealias AUAudioUnitStatus = OSStatus
```
au 处理的返回值

```
/**    @typedef    AUEventSampleTime
    @brief        Expresses time as a sample count.
    @discussion
        Sample times are normally positive, but hosts can propagate HAL sample times through audio
        units, and HAL sample times can be small negative numbers.
*/
public typealias AUEventSampleTime = Int64
```
AUEventSampleTime : 取样时间戳几乎一直是正的 HAL 的取样可能是小的负数


```
/*!    @var        AUEventSampleTimeImmediate
    @brief        A special value of AUEventSampleTime indicating "immediately."
    @discussion
        Callers of AUScheduleParameterBlock and AUScheduleMIDIEventBlock can pass
        AUEventSampleTimeImmediate to indicate that the event should be rendered as soon as
        possible, in the next cycle. A caller may also add a small (less than 4096) sample frame
        offset to this constant. The base AUAudioUnit implementation translates this constant to a
        true AUEventSampleTime; subclasses will not see it.
*/

public var AUEventSampleTimeImmediate: AUEventSampleTime { get }
```
//todo 不太懂
AUScheduleParameterBlock和AUScheduleMIDIEventBlock的调用者可以通过AUEventSampleTimeImmediate来指示应该在下一个周期中尽快呈现事件。调用者也可以添加一个小的(小于4096)样本帧偏移到这个常量。基础AUAudioUnit实现将此常量转换为真正的AUEventSampleTime;子类不会看到它。


```
/**    @typedef    AUAudioFrameCount
    @brief        A number of audio sample frames.
    @discussion
        This is `uint32_t` for impedence-matching with the pervasive use of `UInt32` in AudioToolbox
        and C AudioUnit API's, as well as `AVAudioFrameCount`.
*/
public typealias AUAudioFrameCount = UInt32
```
音频的帧数


```
/**    @typedef    AUAudioChannelCount
    @brief        A number of audio channels.
    @discussion
        This is `uint32_t` for impedence-matching with the pervasive use of `UInt32` in AudioToolbox
        and C AudioUnit API's, as well as `AVAudioChannelCount`.
*/
public typealias AUAudioChannelCount = UInt32
```
音频通道数


```
/**    @enum        AUAudioUnitBusType
    @brief        Describes whether a bus array is for input or output.
*/
public enum AUAudioUnitBusType : Int {

    
    case input = 1

    case output = 2
}
```
描述通道数组是输入的还是输出的


```
/**    @typedef    AURenderPullInputBlock
    @brief        Block to supply audio input to AURenderBlock.
    @param actionFlags
        Pointer to action flags.
    @param timestamp
        The HAL time at which the input data will be rendered. If there is a sample rate conversion
        or time compression/expansion downstream, the sample time will not be valid.
    @param frameCount
        The number of sample frames of input requested.
    @param inputBusNumber
        The index of the input bus being pulled.
    @param inputData
        The input audio data.

        The caller must supply valid buffers in inputData's mBuffers' mData and mDataByteSize.
        mDataByteSize must be consistent with frameCount. This block may provide input in those
        specified buffers, or it may replace the mData pointers with pointers to memory which it
        owns and guarantees will remain valid until the next render cycle.
    @return
        An AUAudioUnitStatus result code. If an error is returned, the input data should be assumed 
        to be invalid.
*/
public typealias AURenderPullInputBlock = (UnsafeMutablePointer<AudioUnitRenderActionFlags>, UnsafePointer<AudioTimeStamp>, AUAudioFrameCount, Int, UnsafeMutablePointer<AudioBufferList>) -> AUAudioUnitStatus
```
actionFlags : AudioUnitRenderActionFlags 定义在以下代码表示当前 renderengine 的行为类型


```
/**
    @enum            AudioUnitRenderActionFlags
    @discussion        These flags can be set in a callback from an audio unit during an audio unit 
                    render operation from either the RenderNotify Proc or the render input 
                    callback.

    @constant        kAudioUnitRenderAction_PreRender
                    Called on a render notification Proc - which is called either before or after 
                    the render operation of the audio unit. If this flag is set, the proc is being 
                    called before the render operation is performed.
                    
    @constant        kAudioUnitRenderAction_PostRender
                    Called on a render notification Proc - which is called either before or after 
                    the render operation of the audio unit. If this flag is set, the proc is being 
                    called after the render operation is completed.

    @constant        kAudioUnitRenderAction_OutputIsSilence
                    The originator of a buffer, in a render input callback, or in an audio unit's
                    render operation, may use this flag to indicate that the buffer contains
                    only silence.

                    The receiver of the buffer can then use the flag as a hint as to whether the
                    buffer needs to be processed or not.

                    Note that because the flag is only a hint, when setting the silence flag,
                    the originator of a buffer must also ensure that it contains silence (zeroes).
                    
    @constant        kAudioOfflineUnitRenderAction_Preflight
                    This is used with offline audio units (of type 'auol'). It is used when an 
                    offline unit is being preflighted, which is performed prior to the actual 
                    offline rendering actions are performed. It is used for those cases where the 
                    offline process needs it (for example, with an offline unit that normalises an 
                    audio file, it needs to see all of the audio data first before it can perform 
                    its normalization)
                    
    @constant        kAudioOfflineUnitRenderAction_Render
                    Once an offline unit has been successfully preflighted, it is then put into 
                    its render mode. So this flag is set to indicate to the audio unit that it is 
                    now in that state and that it should perform its processing on the input data.
                    
    @constant        kAudioOfflineUnitRenderAction_Complete
                    This flag is set when an offline unit has completed either its preflight or 
                    performed render operations
                    
    @constant        kAudioUnitRenderAction_PostRenderError
                    If this flag is set on the post-render call an error was returned by the 
                    AUs render operation. In this case, the error can be retrieved through the 
                    lastRenderError property and the audio data in ioData handed to the post-render 
                    notification will be invalid.
    @constant        kAudioUnitRenderAction_DoNotCheckRenderArgs
                    If this flag is set, then checks that are done on the arguments provided to render 
                    are not performed. This can be useful to use to save computation time in
                    situations where you are sure you are providing the correct arguments
                    and structures to the various render calls
*/
public struct AudioUnitRenderActionFlags : OptionSet {

    public init(rawValue: UInt32)

    
    public static var unitRenderAction_PreRender: AudioUnitRenderActionFlags { get }

    public static var unitRenderAction_PostRender: AudioUnitRenderActionFlags { get }

    public static var unitRenderAction_OutputIsSilence: AudioUnitRenderActionFlags { get }

    public static var offlineUnitRenderAction_Preflight: AudioUnitRenderActionFlags { get }

    public static var offlineUnitRenderAction_Render: AudioUnitRenderActionFlags { get }

    public static var offlineUnitRenderAction_Complete: AudioUnitRenderActionFlags { get }

    public static var unitRenderAction_PostRenderError: AudioUnitRenderActionFlags { get }

    public static var unitRenderAction_DoNotCheckRenderArgs: AudioUnitRenderActionFlags { get }
}
```
timestamp : AudioTimeStamp 时间戳
AUAudioFrameCount : 需要渲染的帧数
outputBusNumber : 输出的通道标识向哪个输出
outputData : AudioBufferList 输出的渲染数据
AUAudioUnitStatus : 返回是否渲染成功



```
/**    @typedef    AURenderBlock
    @brief        Block to render the audio unit.
    @discussion
        All realtime operations are implemented using blocks to avoid ObjC method dispatching and
        the possibility of blocking.
    @param actionFlags
        Pointer to action flags.
    @param timestamp
        The HAL time at which the output data will be rendered. If there is a sample rate conversion
        or time compression/expansion downstream, the sample time will not have a defined
        correlation with the AudioDevice sample time.
    @param frameCount
        The number of sample frames to render.
    @param outputBusNumber
        The index of the output bus to render.
    @param outputData
        The output bus's render buffers and flags.

        The buffer pointers (outputData->mBuffers[x].mData) may be null on entry, in which case the
        block will render into memory it owns and modify the mData pointers to point to that memory.
        The block is responsible for preserving the validity of that memory until it is next called
        to render, or deallocateRenderResources is called.

        If, on entry, the mData pointers are non-null, the block will render into those buffers.
    @param pullInputBlock
        A block which the AU will call in order to pull for input data. May be nil for instrument
        and generator audio units (which do not have input busses).
    @return
        An `AUAudioUnitStatus` result code. If an error is returned, the output data should be assumed
        to be invalid.
*/
public typealias AURenderBlock = (UnsafeMutablePointer<AudioUnitRenderActionFlags>, UnsafePointer<AudioTimeStamp>, AUAudioFrameCount, Int, UnsafeMutablePointer<AudioBufferList>, AURenderPullInputBlock?) -> AUAudioUnitStatus
```
所有的实时操作都是用块来实现的，以避免ObjC方法调度和阻塞。
actionFlags : AudioUnitRenderActionFlags  标识操作的性质
timestamp: AudioTimeStamp 时间戳 //todo
输出数据将被呈现的HAL时间。如果有下游进行了采样率转换或时间压缩/扩展，采样时间将和AudioDevice采样时间不具有定义的相关性。
frameCount :AUAudioFrameCount 有多少帧需要渲染
outputBusNumber :Int 向哪一条输出去输出
outputData : AudioBufferList 输出通道的缓冲和标识. buffer pointers的结构如下 (outputData->mBuffers[x].mData) buffer 指针指向的容器的空间内可能是 null ,在这种情况下 block 将会向他自己的内存空间渲染数据,并且将 mData 的指针指向该空间.
这个 block将会一直保持这块数据的有效性,直到下一次调用 render 或者 deallocateRenderResources.若在 block 入口处 mData 不为空, block 将会向缓冲区渲染

pullInputBlock : 一个块，AU将调用它来拉取输入数据, 对于instrumentaudio units 和generator audio units(没有输入总线)可能是nil.

返回 :  AUAudioUnitStatus



```
public typealias AURenderObserver = (AudioUnitRenderActionFlags, UnsafePointer<AudioTimeStamp>, AUAudioFrameCount, Int) -> Void
```
当 AU 开始渲染时将会回调该闭包
这个块在每个渲染周期之前和之后由基类的AURenderBlock调用。观察者可以通过使用PreRender和postrender标志,来监控渲染周期。
这个闭包的参数与AURenderBlock相同。



```
/**    @typedef    AUScheduleParameterBlock
    @brief        Block to schedule parameter changes.
    @discussion
        Not all parameters are rampable; check the parameter's flags.
    @param eventSampleTime
        The sample time (timestamp->mSampleTime) at which the parameter is to begin changing. When
        scheduling parameters during the render cycle (e.g. via a render observer) this time can be
        AUEventSampleTimeImmediate plus an optional buffer offset, in which case the event is
        scheduled at that position in the current render cycle.
    @param rampDurationSampleFrames
        The number of sample frames over which the parameter's value is to ramp, or 0 if the 
        parameter change should take effect immediately.
    @param parameterAddress
        The parameter's address.
    @param value
        The parameter's new value if the ramp duration is 0; otherwise, the value at the end
        of the scheduled ramp.
*/
public typealias AUScheduleParameterBlock = (AUEventSampleTime, AUAudioFrameCount, AUParameterAddress, AUValue) -> Void
```
这个闭包用来处理参数的变化并不是所有的参数都是可变的;检查参数的标志。
eventSampleTime: 参数开始改变的采样时间(timestamp->mSampleTime).当在渲染周期中改变参数时(例如,通过渲染观察者),这个时间可以是AUEventSampleTimeImmediate加上一个可选的缓冲区偏移量.在这种情况下,事件被安排在当前渲染周期的那个位置.
 rampDurationSampleFrames : 
参数值改变生效还需要的的样本帧数，如果参数改变立即生效，则为0.
parameterAddress : 参数的地址。
@param价值
如果改变持续时间为0,则参数的新值;否则,为旧值.


```
/**    @typedef    AUScheduleMIDIEventBlock
    @brief        Block to schedule MIDI events.
    @param eventSampleTime
        The sample time (timestamp->mSampleTime) at which the MIDI event is to occur. When
        scheduling events during the render cycle (e.g. via a render observer) this time can be
        AUEventSampleTimeImmediate plus an optional buffer offset, in which case the event is
        scheduled at that position in the current render cycle.
    @param cable
        The virtual cable number.
    @param length
        The number of bytes of MIDI data in the provided event(s).
    @param midiBytes
        One or more valid MIDI 1.0 events, except sysex which must always be sent as the only event
        in the chunk. Also, running status is not allowed.
*/
public typealias AUScheduleMIDIEventBlock = (AUEventSampleTime, UInt8, Int, UnsafePointer<UInt8>) -> Void
```
AU 处理 midi 事件时的 block
eventSampleTime : 当在渲染周期中midi处理事件将要发生时的时间戳(timestamp->mSampleTime),这个时间可以是AUEventSampleTimeImmediate加上一个可选的缓冲区偏移量.在这种情况下,事件被安排在当前渲染周期的那个位置.
cable : 虚拟的线缆号
length : 在提供的事件中MIDI数据的字节数。
midiBytes : 一个或多个有效的MIDI1.0事件,sysex事件除外,它必须总是作为chunk中的唯一事件发送.此外,运行状态是不允许的.



```
/**    @typedef    AUMIDIOutputEventBlock
    @brief        Block to provide MIDI output events to the host.
    @param eventSampleTime
        The timestamp associated with the MIDI data in this chunk.
    @param cable
        The virtual cable number associated with this MIDI data.
    @param length
        The number of bytes of MIDI data in the provided event(s).
    @param midiBytes
        One or more valid MIDI 1.0 events, except sysex which must always be sent as the only event
        in the chunk.
*/
public typealias AUMIDIOutputEventBlock = (AUEventSampleTime, UInt8, Int, UnsafePointer<UInt8>) -> OSStatus
```
eventSampleTime : 该块数据对应的时间戳
cable : medi 的虚拟线缆
length : 提供给该事件的比特数
midiBytes : 一个或多个有效的MIDI 1.0事件，sysex事件除外，它必须总是作为chunk中的唯一事件发送。

```


/**    @typedef    AUHostMusicalContextBlock
    @brief        Block by which hosts provide musical tempo, time signature, and beat position.
    @param    currentTempo
        The current tempo in beats per minute.
    @param    timeSignatureNumerator
        The numerator of the current time signature.
    @param    timeSignatureDenominator
        The denominator of the current time signature.
    @param    currentBeatPosition
        The precise beat position of the beginning of the current buffer being rendered.
    @param    sampleOffsetToNextBeat
        The number of samples between the beginning of the buffer being rendered and the next beat
        (can be 0).
    @param    currentMeasureDownbeatPosition
        The beat position corresponding to the beginning of the current measure.
    @return
        YES for success.
    @discussion
        If the host app provides this block to an AUAudioUnit (as its musicalContextBlock), then
        the block may be called at the beginning of each render cycle to obtain information about
        the current render cycle's musical context.
        
        Any of the provided parameters may be null to indicate that the audio unit is not interested
        in that particular piece of information.
*/
public typealias AUHostMusicalContextBlock = (UnsafeMutablePointer<Double>?, UnsafeMutablePointer<Double>?, UnsafeMutablePointer<Int>?, UnsafeMutablePointer<Double>?, UnsafeMutablePointer<Int>?, UnsafeMutablePointer<Double>?) -> Bool
```
有父进程提供的音乐的节奏,速度,节拍,以及节拍位置的处理函数
currentTempo : AUEventSampleTime 每分钟的节拍数
timeSignatureNumerator : 当前签名的时间分子
timeSignatureDenominator : 当前签名的时间分母
currentBeatPosition : 当前buffer内第一个节拍位置的精确地相对时间
sampleOffsetToNextBeat : 当前下一个节拍相对缓冲区开始采样数
sampleOffsetToNextBeat : 当前节拍的位置
返回成功或者失败
如果主应用程序将这个闭包提供给AUAudioUnit(作为它的musicalContextBlock)，那么这个闭包可能会在每个渲染周期的开始被调用，以获得关于当前渲染周期的音乐上下文的信息。提供的任何参数都可以为空，表示音频单元对特定的信息不感兴趣。


```
/**    @typedef    AUMIDICIProfileChangedBlock
    @brief        Block by which hosts are informed of an audio unit having enabled or disabled a
                MIDI-CI profile.
    @param cable
        The virtual MIDI cable on which the event occured.
    @param channel
        The MIDI channel on which the profile was enabled or disabled.
    @param profile
        The MIDI-CI profile.
    @param enabled
        YES if the profile was enabled, NO if the profile was disabled.
*/
public typealias AUMIDICIProfileChangedBlock = (UInt8, MIDIChannelNumber, MIDICIProfile, Bool) -> Void
```
audiounit 已经停用某个 midici 配置文件的回调
cable : 时间产生的虚拟的 midi 线缆
channel : 产生配置变化的 midi 声道
profile : midici 的配置文件(新? 旧?) todo
enabled : 当前配置文件是否已经生效


```
/**    @enum        AUHostTransportStateFlags
    @brief        Flags describing the host's transport state.
    @constant    AUHostTransportStateChanged
        True if, since the callback was last called, there was a change to the state of, or
        discontinuities in, the host's transport. Can indicate such state changes as
        start/stop, or seeking to another position in the timeline.
    @constant    AUHostTransportStateMoving
        True if the transport is moving.
    @constant    AUHostTransportStateRecording
        True if the host is recording, or prepared to record. Can be true with or without the
        transport moving.
    @constant    AUHostTransportStateCycling
        True if the host is cycling or looping.
*/
public struct AUHostTransportStateFlags : OptionSet {

    public init(rawValue: UInt)

    
    public static var changed: AUHostTransportStateFlags { get }

    public static var moving: AUHostTransportStateFlags { get }

    public static var recording: AUHostTransportStateFlags { get }

    public static var cycling: AUHostTransportStateFlags { get }
}
```
描述主进程的传输状态
AUHostTransportStateChanged : 如果自上次调用回调以来，主机传输的状态或中断发生了更改，则为True。可以指示这样的状态更改，如开始/停止，或寻求时间线上的另一个位置。
AUHostTransportStateMoving : 如果正在传输则为真
AUHostTransportStateRecording : 如果主程序正在录制则为真,无论当前是有信息交换
AUHostTransportStateCycling : 主机正在渲染周期中(???//todo)


```
/**    @typedef    AUHostTransportStateBlock
    @brief        Block by which hosts provide information about their transport state.
    @param    transportStateFlags
        The current state of the transport.
    @param    currentSamplePosition
        The current position in the host's timeline, in samples at the audio unit's output sample
        rate.
    @param    cycleStartBeatPosition
        If cycling, the starting beat position of the cycle.
    @param    cycleEndBeatPosition
        If cycling, the ending beat position of the cycle.
    @discussion
        If the host app provides this block to an AUAudioUnit (as its transportStateBlock), then
        the block may be called at the beginning of each render cycle to obtain information about
        the current transport state.
        
        Any of the provided parameters may be null to indicate that the audio unit is not interested
        in that particular piece of information.
*/
public typealias AUHostTransportStateBlock = (UnsafeMutablePointer<AUHostTransportStateFlags>?, UnsafeMutablePointer<Double>?, UnsafeMutablePointer<Double>?, UnsafeMutablePointer<Double>?) -> Bool
```
主程序提供的关于数据传输数据状态的回调
transportStateFlags : 当前数据的传输状态
currentSamplePosition : 在主机时间轴上的位置, 使用当前 au 输出的采样率
cycleStartBeatPosition : 若当前正在渲染周期内 返回循环入点的节拍的时间戳
cycleEndBeatPosition : 渲染周期内,出点节拍的时间戳
如果宿主应用程序将这个块提供给AUAudioUnit(作为它的transportStateBlock)，那么在每个渲染周期的开始，块可能会被调用，以获得关于当前传输状态的信息。
提供的任何参数都可以为空，表示音频单元对特定的信息不感兴趣。
 
 
 
 # AUAudioUnit
```
/**    @class        AUAudioUnit
    @brief        An audio unit instance.
    @discussion
        AUAudioUnit is a host interface to an audio unit. Hosts can instantiate either version 2 or
        version 3 units with this class, and to some extent control whether an audio unit is
        instantiated in-process or in a separate extension process.
        
        Implementors of version 3 audio units can and should subclass AUAudioUnit. To port an
        existing version 2 audio unit easily, AUAudioUnitV2Bridge can be subclassed.
        
        These are the ways in which audio unit components can be registered:
        
        - (v2) Packaged into a component bundle containing an `AudioComponents` Info.plist entry,
        referring to an `AudioComponentFactoryFunction`. See AudioComponent.h.
        
        - (v2) AudioComponentRegister(). Associates a component description with an
        AudioComponentFactoryFunction. See AudioComponent.h.
        
        - (v3) Packaged into an app extension containing an AudioComponents Info.plist entry.
        The principal class must conform to the AUAudioUnitFactory protocol, which will typically
        instantiate an AUAudioUnit subclass.

        - (v3) `+[AUAudioUnit registerSubclass:asComponentDescription:name:version:]`. Associates
        a component description with an AUAudioUnit subclass.
        
        A host need not be aware of the concrete subclass of AUAudioUnit that is being instantiated.
        `initWithComponentDescription:options:error:` ensures that the proper subclass is used.
        
        When using AUAudioUnit with a v2 audio unit, or the C AudioComponent and AudioUnit API's
        with a v3 audio unit, all major pieces of functionality are bridged between the
        two API's. This header describes, for each v3 method or property, the v2 equivalent.
```
AUAudioUnit是一个主程序连接音频处理单元的接口.主机可以用这个类实例化v2或v3 的AudioUnit,并且在一定程度上控制AudioUnit,无论其是在进程中实例化还是在单独的扩展进程中实例化.

v3AUAudioUnit的实现者可以也应该使用AUAudioUnit的子类。为了方便地移植现有的v2AUAudioUnit，AUAudioUnitV2Bridge可以被子类化。

这些是音频单元组件可以注册的方式:
- (v2)将组件库打包到一个包含`AudioComponents`  键值对的Info.plist的 bundle 中
AudioComponents 的 value 应该为 AudioComponentFactoryFunction 详情见AudioComponent.h.
- (v2)AudioComponentRegister(),将组件描述与一个AudioComponentFactoryFunction关联起来,详情见AudioComponent.h.

- (v3) 被一个Info.plist包含AudioComponents键值对的 app extention 程序打包,主类即 bundle 的入口必须遵循AUAudioUnitFactory协议,并且一般来说该类必须是AUAudioUnit的子类(每个可加载的Cocoa包都包含一个主类。NSBundle类提供的代码加载机制使用bundle的主体类作为入口点。加载bundle的应用程序可以要求NSBundle查找主体类，并使用返回的class对象创建该类的实例。

NSBundle通过两种方式之一找到主类。首先，它在bundle的信息属性列表中查找NSPrincipalClass键。如果键存在，它将使用由键的值命名的类作为包的主类。如果键不存在或键指定的类不存在，则NSBundle将使用加载的第一个类作为主类。如果bundle是用Xcode构建的，那么在项目中查看的类的顺序决定了它们的加载顺序。)
- (v3)' +[AUAudioUnit registerSubclass:asComponentDescription:name:version:]”.方法将组件描述和
AUAudioUnit的子类连接起来。
主机不需要知道AUAudioUnit的具体子类正在被实例化。
' initWithComponentDescription:options:error: '确保使用了正确的子类。

当使用AUAudioUnit和v2音频单元，或者C语言版的 AudioComponent和AudioUnit API和v3音频单元时，所有主要功能都桥接了这两类API。这个头文件描述了每个v3和v2方法及属性都是等价的。

```
/**    @method        initWithComponentDescription:options:error:
    @brief        Designated initializer.
    @param componentDescription
        A single AUAudioUnit subclass may implement multiple audio units, for example, an effect
        that can also function as a generator, or a cluster of related effects. The component
        description specifies the component which was instantiated.
    @param options
        Options for loading the unit in-process or out-of-process.
    @param outError
        Returned in the event of failure.
*/
public init(componentDescription: AudioComponentDescription, options: AudioComponentInstantiationOptions = []) throws
```
初始构造器
componentDescription : 一个单独的AUAudioUnit子类可以实现多个音频单元，例如，一个effect
这也可以作为一个generator，或一系列相关的effect。组件
description指定被实例化的组件。
options : 标识是否将扩展作为主程序的一个静态库或者进程或者一个外部程序 ,ios 选外部程序
outError : 返回创建失败的理由

```
/**    @method        initWithComponentDescription:error:
    @brief        Convenience initializer (omits options).
*/
public convenience init(componentDescription: AudioComponentDescription) throws
```
便利构造器

```
/**    @method    instantiateWithComponentDescription:options:completionHandler:
    @brief    Asynchronously create an AUAudioUnit instance.
    @param componentDescription
        The AudioComponentDescription of the audio unit to instantiate.
    @param options
        See the discussion of AudioComponentInstantiationOptions in AudioToolbox/AudioComponent.h.
    @param completionHandler
        Called in a thread/dispatch queue context internal to the implementation. The client should
        retain the supplied AUAudioUnit.
    @discussion
        Certain types of AUAudioUnits must be instantiated asynchronously -- see 
        the discussion of kAudioComponentFlag_RequiresAsyncInstantiation in
        AudioToolbox/AudioComponent.h.

        Note: Do not block the main thread while waiting for the completion handler to be called;
        this can deadlock.
*/
open class func instantiate(with componentDescription: AudioComponentDescription, options: AudioComponentInstantiationOptions = [], completionHandler: @escaping (AUAudioUnit?, Error?) -> Void)
```
异步的创建一个AUAudioUnit实例无法被重载
componentDescription : 实例的描述具体如下
如下 {
var componentType: OSType
A unique 4-byte code identifying the interface for the component.
var componentSubType: OSType
A 4-byte code that you can use to indicate the purpose of a component. For example, you could use lpas or lowp as a mnemonic indication that an audio unit is a low-pass filter.
var componentManufacturer: OSType
The unique vendor identifier, registered with Apple, for the audio component.
var componentFlags: UInt32
Set this value to zero.
var componentFlagsMask: UInt32
Set this value to zero.’
}

options :  {
static var loadInProcess: AudioComponentInstantiationOptions
static var loadOutOfProcess: AudioComponentInstantiationOptions
}

```
/**    @property    componentDescription
    @brief        The AudioComponentDescription with which the audio unit was created.
*/
open var componentDescription: AudioComponentDescription { get }
```
组件的描述


```
/**    @property    component
    @brief        The AudioComponent which was found based on componentDescription when the
                audio unit was created.
*/
open var component: AudioComponent { get }
```
组件

```
/**    @property    componentName
    @brief        The unit's component's name.
    @discussion
        By convention, an audio unit's component name is its manufacturer's name, plus ": ",
        plus the audio unit's name. The audioUnitName and manufacturerName properties are derived
        from the component name.
*/
open var componentName: String? { get }
```
组件名

```
/**    @property    audioUnitName
    @brief        The audio unit's name.
*/
open var audioUnitName: String? { get }
```
au 名


```
/**    @property    manufacturerName
    @brief        The manufacturer's name.
*/
open var manufacturerName: String? { get }
```
制造商一般为 apple

```
/**    @property    audioUnitShortName
    @brief        A short name for the audio unit.
    @discussion
        Audio unit host applications can display this name in situations where the audioUnitName 
        might be too long. The recommended length is up to 16 characters. Host applications may 
        truncate it.
*/
@available(iOS 11.0, *)
open var audioUnitShortName: String? { get }
```
audioUnit 的短名最长为 16 ,程序可能会展示该程序名若AU 的全名过长,即便如此也有可能被截断

```
/**    @property    componentVersion
    @brief        The unit's component's version.
*/
open var componentVersion: UInt32 { get }
```
组件版本号

```
/**    @method        allocateRenderResourcesAndReturnError:
    @brief        Allocate resources required to render.
    @discussion
        Hosts must call this before beginning to render. Subclassers should call the superclass
        implementation.
        
        Bridged to the v2 API AudioUnitInitialize().
*/
open func allocateRenderResources() throws
```
分配需要处理的资源
主程序在开始渲染前必须调用该函数,子类必须调用其父类的实现
桥接了 v2 的AudioUnitInitialize().


```
/**    @method        deallocateRenderResources
    @brief        Deallocate resources allocated by allocateRenderResourcesAndReturnError:
    @discussion
        Hosts should call this after finishing rendering. Subclassers should call the superclass
        implementation.
        
        Bridged to the v2 API AudioUnitUninitialize().
*/
open func deallocateRenderResources()
```
在结束渲染之后调用该方法
子类必须调用父类的该方法

```
/**    @property    renderResourcesAllocated
    @brief        returns YES if the unit has render resources allocated.
*/
open var renderResourcesAllocated: Bool { get }
```
资源是否被分配

```
/**    @method        reset
    @brief        Reset transitory rendering state to its initial state.
    @discussion
        Hosts should call this at the point of a discontinuity in the input stream being provided to
        an audio unit, for example, when seeking forward or backward within a track. In response,
        implementations should clear delay lines, filters, etc. Subclassers should call the
        superclass implementation.
        
        Bridged to the v2 API AudioUnitReset(), in the global scope.
*/
open func reset()
```
迅速将渲染状态调整到初始状态
主机应该在提供给音频单元的输入流中的不连续点调用此函数，例如，当在一个音轨内向前或向后搜索时。作为回应，实现应该清除延迟线、过滤器等。子类应该调用超类实现。


```
/**    @property    inputBusses
    @brief        An audio unit's audio input connection points.
    @discussion
        Subclassers must override this property's getter. The implementation should return the same
        object every time it is asked for it, since clients can install KVO observers on it.
*/
open var inputBusses: AUAudioUnitBusArray { get }
```
au 的输入链接点
子类必须实现此 getter方法并且在 返回是应返回同一对象,从而客户端可以通过 kvo 对其进行监听
bus 的定义如下 {
func setFormat(AVAudioFormat)
Sets the bus’s audio format.
var format: AVAudioFormat
The audio format and channel layout of audio being transferred on the bus.
var isEnabled: Bool
Determines whether the bus is active.
var name: String?
A name for the bus.
var index: Int
The index of this bus in its containing array.
var busType: AUAudioUnitBusType
The bus type.
var ownerAudioUnit: AUAudioUnit
The audio unit that owns the bus.
var supportedChannelLayoutTags: [NSNumber]?
An array of audio channel layout tags.
var contextPresentationLatency: TimeInterval
Information about latency in the audio unit’s processing context.
var shouldAllocateBuffer: Bool

These methods and properties are only of interest to audio unit subclasses.
init(format: AVAudioFormat)
Initializes a bus object with a specific format.
var supportedChannelCounts: [NSNumber]?
An array of numbers indicating the supported number of channels for this bus.
var maximumChannelCount: AUAudioChannelCount
The maximum number of channels supported for this bus.
}


```
open var outputBusses: AUAudioUnitBusArray { get }
```
同上类似

```
/**    @property    renderBlock
    @brief        Block which hosts use to ask the unit to render.
    @discussion
        Before invoking an audio unit's rendering functionality, a host should fetch this block and cache the result. The block can then be called from a realtime context without the possibility of blocking and causing an overload at the Core Audio HAL level.
        
        This block will call a subclass' internalRenderBlock, providing all realtime events scheduled for the current render time interval, bracketed by calls to any render observers.

        Subclassers should override internalRenderBlock, not this property.
        
        Bridged to the v2 API AudioUnitRender().
*/
open var renderBlock: AURenderBlock { get }
```
在调用音频单元的渲染功能之前，主机应该获取这个块并缓存结果。块然后可以从实时上下文调用，而不会阻塞和导致 core audio HAL(硬件抽象层)级别过载。

这个块将调用一个子类的internalRenderBlock，提供在当前渲染时间间隔内调度的所有实时事件，包含在对任何渲染观察者的调用中。
子类应该重写internalRenderBlock，而不是这个属性。

桥接到v2 API AudioUnitRender()。

```
/**    @property    scheduleParameterBlock
    @brief        Block which hosts use to schedule parameters.
    @discussion
        As with renderBlock, a host should fetch and cache this block before beginning to render, if it intends to schedule parameters.
                
        The block is safe to call from any thread context, including realtime audio render threads.
        
        Subclassers should not override this; it is implemented in the base class and will schedule the events to be provided to the internalRenderBlock.
        
        Bridged to the v2 API AudioUnitScheduleParameters().
*/
open var scheduleParameterBlock: AUScheduleParameterBlock { get }
```
提供给主程序负责参数处理
从任何线程上下文调用块都是安全的，包括实时音频渲染线程。

```
/**    @method        tokenByAddingRenderObserver:
    @brief        Add a block to be called on each render cycle.
    @discussion
        The supplied block is called at the beginning and ending of each render cycle. It should
        not make any blocking calls.
        
        This method is implemented in the base class AUAudioUnit, and should not be overridden.
        
        Bridged to the v2 API AudioUnitAddRenderNotify().
    @param observer
        The block to call.
    @return
        A token to be used when removing the observer.
*/
open func token(byAddingRenderObserver observer: @escaping AURenderObserver) -> Int
``` 
添加一个在每次渲染周期开始时调用的 block
它不应该进行任何阻塞调用。
这个方法是在AUAudioUnit基类中实现的，不允许被重写。
桥接到v2 API AudioUnitAddRenderNotify()。


```
/**    @method        removeRenderObserver:
    @brief        Remove an observer block added via tokenByAddingRenderObserver:
    @param token
        The token previously returned by tokenByAddingRenderObserver:

        Bridged to the v2 API AudioUnitRemoveRenderNotify().
*/
open func removeRenderObserver(_ token: Int)
```
移除由 tokenByAddingRenderObserver: 方法添加的观察者
tocken 是tokenByAddingRenderObserver提供的

```
/**    @property    maximumFramesToRender
    @brief        The maximum number of frames which the audio unit can render at once.
    @discussion
        This must be set by the host before render resources are allocated. It cannot be changed
        while render resources are allocated.
        
        Bridged to the v2 property kAudioUnitProperty_MaximumFramesPerSlice.
*/
open var maximumFramesToRender: AUAudioFrameCount
```
au 每次刻意渲染的帧数
这必须在分配呈现资源之前由主程序设置。在分配渲染资源后不能更改它。
桥接到v2属性kaudiounitproperty_maximumframespersice。

```
/**    @property    parameterTree
    @brief        An audio unit's parameters, organized in a hierarchy.
    @return
        A parameter tree object, or nil if the unit has no parameters.
    @discussion
        Audio unit hosts can fetch this property to discover a unit's parameters. KVO notifications
        are issued on this member to notify the host of changes to the set of available parameters.
        
        AUAudioUnit has an additional pseudo-property, "allParameterValues", on which KVO
        notifications are issued in response to certain events where potentially all parameter
        values are invalidated. This includes changes to currentPreset, fullState, and
        fullStateForDocument.
 
        Hosts should not attempt to set this property.

        Subclassers should implement the parameterTree getter to expose parameters to hosts. They
        should cache as much as possible and send KVO notifications on "parameterTree" when altering
        the structure of the tree or the static information (ranges, etc) of parameters.
        
        This is similar to the v2 properties kAudioUnitProperty_ParameterList and
        kAudioUnitProperty_ParameterInfo.
 
        Note that it is not safe to modify this property in a real-time context.
*/
open var parameterTree: AUParameterTree?
```
一个树状组织的 au参数结构
音频单元主机可以获取这个属性来发现AU的参数。在这个成员上发出KVO通知，以通知主机对可用参数集的更改。
AUAudioUnit有一个额外的伪属性，“allParameterValues”，在这个伪属性上，KVO通知会在某些事件上发出，在这些事件中，所有的参数值都可能失效。这包括对currentPreset、fullState和fullStateForDocument的变更。
主 程序不应尝试设置此属性。
子类应该实现参数树getter将参数公开给宿主。当改变树的结构或参数的静态信息(范围等)时，应尽可能地缓存，并在“参数树”上发送KVO通知。
这类似于kAudioUnitProperty_ParameterList和kAudioUnitProperty_ParameterInfo的v2属性。
注意，`在实时上下文中修改此属性是不安全的!!!!!!!`

```
/**    @method        parametersForOverviewWithCount:
    @brief        Returns the audio unit's `count` most important parameters.
    @discussion
        This property allows a host to query an audio unit for some small number of parameters which
        are its "most important", to be displayed in a compact generic view.

        An audio unit subclass should return an array of NSNumbers representing the addresses
        of the `count` most important parameters.

        The base class returns an empty array regardless of count.
        
        Partially bridged to kAudioUnitProperty_ParametersForOverview (v2 hosts can use that
        property to access this v3 method of an audio unit).
*/
open func parametersForOverview(withCount count: Int) -> [NSNumber]
```
返回一些最重要的参数 count 是返回参数的数量
父类每次都返回一个空数组
子类需要自己实现该方法如果必要的话

```
open var allParameterValues: Bool { get } /// special pseudo-property for KVO
```
为 kvo 准备的伪属性???//todo

```
/**    @property    musicDeviceOrEffect
    @brief        Specifies whether an audio unit responds to MIDI events.
    @discussion
        This is implemented in the base class and returns YES if the component type is music
        device or music effect.
*/
open var isMusicDeviceOrEffect: Bool { get }
```
指出 au 是否可以执行 midi 相关的方法

```
/**    @property    virtualMIDICableCount
    @brief        The number of virtual MIDI cables implemented by a music device or effect.
    @discussion
        A music device or MIDI effect can support up to 256 virtual MIDI cables of input; this
        property expresses the number of cables supported by the audio unit.
*/
open var virtualMIDICableCount: Int { get }
```
返回通过音乐设备或者特效实现的虚拟的 midi 接口数量



