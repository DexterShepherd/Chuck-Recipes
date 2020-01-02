80 => float bpm; 

60.0/bpm/4.0  => float tick;

0.2 => float swing;

Shakers s => dac;
0 => int up;

while(1) {
  s.noteOn(1);

  float swungTick;
  if ( up % 2 == 0 ) {
    tick - (tick * swing) => swungTick;
  } else {
    tick + (tick * swing) => swungTick;
  }

  swungTick::second => now;

  up++;
}
