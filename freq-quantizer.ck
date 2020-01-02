Gain master => dac;

/* Expects an input midi note ( int ) and a 12 note mapping array */
fun int quantizeNote(float freq, int map[]) {

  Math.floor(Std.ftom(freq))$int => int note;
  map.size() => int size;
  note / size => int offset;

  return map[note % size] + (offset * 12);
}

[0, 0, 2, 2, 4, 5, 5, 7, 7, 9, 9, 11] @=> int map[];

fun void test() {
  SinOsc s => Envelope e => master;

  Math.random2(500, 2000)::ms => e.duration;

  while(1) {
    Math.random2(500, 1000)::ms => now;
    Std.mtof(quantizeNote(Math.random2f(200, 1000), map)) => s.freq;
    e.keyOn();
    Math.random2(500, 1000)::ms => now;
    e.keyOff();
  }
}


for ( int i; i < 2; i++ ) {
  spork ~ test();
}


while(1) {
  1::second => now;
}
