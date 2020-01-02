Gain master => dac;

fun int quantizeNote(float freq, int map[]) {
  Math.floor(Std.ftom(freq))$int => int note;
  map.size() => int size;
  note / size => int offset;

  return map[note % size] + (offset * 12);
}

[0, 0, 2, 2, 4, 5, 5, 7, 7, 9, 9, 11] @=> int map[];

fun void gliss(Osc osc, Envelope env, float target) {
  env.target(target);

  while(1) {
    env.value() => osc.freq;
    1::samp => now; 
    if ( env.value() == target ) {
      return;
    }
  }
}



fun void test(int offset) {
  TriOsc s => Envelope e => master;
  Envelope glisser => blackhole;

  600::ms => glisser.duration;

  2000::ms => e.duration;

  e.keyOn();
  while(1) {
    spork ~ gliss(s, glisser, Std.mtof(quantizeNote(Math.random2f(200, 1000), map) + offset));
    2000::ms => now;
  }
}


spork ~ test(0);
spork ~ test(12);
spork ~ test(-12);


while(1) {
  1::second => now;
}
