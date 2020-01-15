class Voice {
  8 => int numGrains;
  SndBuf grain[numGrains];
  Envelope env[numGrains];
  Pan2 pan[numGrains];
  int grainPositions[numGrains];

  Pan2 master;

  Envelope masterEnv => blackhole;

  0.5 => master.gain;

  1000::ms => masterEnv.duration;

  2000 => int readSpeed;

  60 => int root;

  spork ~ gainTick();


  for ( int i; i < numGrains; i++ ) {
    grain[i] => env[i] => pan[i] => master;
    Math.random2f(-1, 1) => pan[i].pan;
    1 => grain[i].loop;
    0.5 => grain[i].gain;
    5::ms => env[i].duration;
    if ( maybe ) {
      "./samples/grain/shak.wav" => grain[i].read;
    } else  {
      "./samples/grain/steel.wav" => grain[i].read;
    }
    Math.random2(0, grain[i].samples()) => grainPositions[i];
  }

  for ( int i; i < numGrains; i++ ) {
    spork ~ tick(i);
  }

  fun void tick(int grainIndex) {
    while(1) {
      env[grainIndex].keyOn();
      Math.random2(40, 100)::ms => now;
      env[grainIndex].keyOff();
      Math.random2(40, 100)::ms => now;
      readSpeed +=> grainPositions[grainIndex];
      if ( grainPositions[grainIndex] > grain[grainIndex].samples() ) {
        0 => grainPositions[grainIndex];
      }
      grainPositions[grainIndex] => grain[grainIndex].pos;
    }
  }

  fun void keyOn() {
    masterEnv.keyOn();
  }

  fun void keyOff() {
    masterEnv.keyOff();
  }

  fun void freq(int midiNote) {
    for( int i; i < numGrains; i++ ) {
      if ( Math.randomf() > 0.8 ) {
        rateForNote(midiNote) / 2.0 => grain[i].rate;
      } else if ( Math.randomf() > 0.8 ) {
        rateForNote(midiNote) * 2.0 => grain[i].rate;
      } else {
        rateForNote(midiNote) => grain[i].rate;
      }

      Math.random2f(-0.01, 0.01) + grain[i].rate() => grain[i].rate;
    }
  }

  fun float rateForNote(float n) {
    n - root => float diff;
    diff / 12 => float semi;
    return ( Math.pow(2, semi) );
  }

  fun void gainTick() {
    while(1) {
      masterEnv.value() => master.gain;
      1::ms => now;
    }

  }
}

0 => int nextVoice;
8 => int numVoices;
Voice voice[numVoices];

int notes[numVoices];

for( int i; i < numVoices; i++ ) {
  voice[i].master => dac;
}

MidiIn MidiInput;
MidiMsg MidiMessage;

if ( !MidiInput.open("Arturia KeyStep 32") ) {
  me.exit();
}


while(true) {
  MidiInput => now;
  while(MidiInput.recv(MidiMessage)) {
    if ( MidiMessage.data1 == 144 ) {
      voice[nextVoice].keyOn();
      MidiMessage.data2 => voice[nextVoice].freq;
      MidiMessage.data2 => notes[nextVoice];
      1 +=> nextVoice;
      if ( nextVoice >= numVoices ) {
        0 => nextVoice;
      }
    }

    if ( MidiMessage.data1 == 128 ) {
      for ( int i; i < numVoices; i++ ) {
        if ( notes[i] == MidiMessage.data2 ) {
          voice[i].keyOff();
        }
      }
    }
  }
}

