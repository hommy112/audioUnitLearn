//
//  MusicEffectAudioUnit.h
//  MusicEffect
//
//  Created by hanyang on 2020/12/20.
//

#import <AudioToolbox/AudioToolbox.h>
#import "MusicEffectDSPKernelAdapter.h"

// Define parameter addresses.
extern const AudioUnitParameterID myParam1;

@interface MusicEffectAudioUnit : AUAudioUnit

@property (nonatomic, readonly) MusicEffectDSPKernelAdapter *kernelAdapter;
- (void)setupAudioBuses;
- (void)setupParameterTree;
- (void)setupParameterCallbacks;
@end
