//
//  Constants.h
//  AudioLab
//
//  Created by Jing Su on 9/29/19.
//  Copyright © 2019 Jing Su. All rights reserved.
//

#ifndef Constants_h
#define Constants_h

// Global
#define BUFFER_SIZE 8192
#define AUDIO_DATA_SIZE BUFFER_SIZE
#define FFT_DATA_SIZE BUFFER_SIZE/2

// Module A
#define WINDOW_LENGTH BUFFER_SIZE/200
#define MINIMUM_FREQUENCY 50
#define DISPLAY_ACCURACY 3 // (±3Hz) accuracy

// Module B
#define MIN_OUTPUT_FREQ 15000 // 15kHz
#define MAX_OUTPUT_FREQ 20000 // 20kHz
#define RECOGNIZE_RANGE 2
#define RECOGNIZE_SENSITIVITY 1
#define RECOGNIZE_CYCLES 3

#endif /* Constants_h */
