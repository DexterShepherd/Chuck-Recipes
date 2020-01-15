MidiIn MidiInput;
MidiMsg MidiMessage;

if ( !MidiInput.open("Arturia KeyStep 32") ) {
  me.exit();
}

Gain master => NRev rev => dac;


fun void voice(int note) {
  SinOsc s => Envelope e => master;
  0.5 => s.gain;
  Std.mtof(note) => s.freq;
  100::ms => e.duration;

  e.keyOn();

  1::second => now;

  e.keyOff();

  e.duration() => now;
}


while(true) {
  MidiInput => now;
  while(MidiInput.recv(MidiMessage)) {
    if ( MidiMessage.data1 == 144 ) {
      spork ~ voice(MidiMessage.data2);
    }
    <<<MidiMessage.data1, MidiMessage.data2, MidiMessage.data3 >>>;
  }
}

