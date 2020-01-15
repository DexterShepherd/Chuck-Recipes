MidiIn MidiInput;
MidiMsg MidiMessage;

if ( !MidiInput.open("Arturia KeyStep 32") ) {
  me.exit();
}


SinOsc osc[127];
Envelope env[127];
Gain master  => dac;

SinOsc lfo => blackhole;

3 => lfo.freq;
0.8 => lfo.gain;

for ( int i; i < osc.size(); i++ ) {
  osc[i] => env[i] => master;
  Std.mtof(i) => osc[i].freq;
}


spork ~ lfoTick();

0.0 => float lfoDepth;

while(true) {
  MidiInput => now;
  while(MidiInput.recv(MidiMessage)) {
    if ( MidiMessage.data1 == 144 ) {

      Std.scalef(MidiMessage.data3, 30, 127, 3000, 10)::ms => dur envTime;

      envTime => env[MidiMessage.data2].duration;
      env[MidiMessage.data2].keyOn();

    }
    if ( MidiMessage.data1 == 128 ) {
      env[MidiMessage.data2].keyOff();
    }

    if ( MidiMessage.data1 == 208 ) {
      MidiMessage.data2 / 127.0 => lfoDepth;
    }
      <<<MidiMessage.data1, MidiMessage.data2, MidiMessage.data3 >>>;
  }
}

fun void lfoTick() {
  while(1) {
    for ( int i; i < osc.size(); i++ ) {
      Std.mtof(i) - Std.mtof(i - 1) => float semi;
      Std.mtof(i) + (lfo.last() * semi * lfoDepth) => osc[i].freq;
    }
    1::ms => now;
  }
}
