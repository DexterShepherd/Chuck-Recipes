fun void voice(float freq, dur length) {
  SinOsc s => Envelope e => dac;
  100::ms => e.duration;

  freq => s.freq;
  e.keyOn();
  length => now;
  e.keyOff();
  e.duration() => now;
}


fun int quantizeNote(int note, int map[]) {
  map.size() => int size;
  note / size => int offset;

  return map[note % size] + (offset * 12);
}

[0, 0, 2, 2, 4, 5, 5, 7, 7, 9, 9, 11] @=> int map[];


class Shifter {
  float buffer[16];

  fun void add(float n) {
    buffer << n;
  }

  fun float shift(int amount) {
    return buffer[buffer.size() - (1 + (amount % buffer.size()))];
  }
}

Shifter shifter;

while(1) {
  for ( int i; i < 3; i++ ) {
    if ( i == 0 ) {
      Std.mtof(quantizeNote(Math.random2(60, 84), map)) => float note;
      shifter.add(note);
      spork ~ voice(note, Math.random2(500, 2000)::ms);
    } else {
      spork ~ voice(shifter.shift(i), Math.random2(500, 2000)::ms);
    }
    500::ms => now;
  }
}
