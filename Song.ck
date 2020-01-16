float tps;
setBpm(115);

fun void setBpm(float bpm) {
  60.0/bpm/4.0  => tps;
}

class Tick extends Event {
  int playhead;
}


Tick tick;

fun void masterClock() {
  0 => int playhead;

  while(1) {
    playhead => tick.playhead; 
    tick.broadcast();
    1 +=> playhead;
    tps::second => now;
  }
}

class Pattern {
  Event trigger;
  int pattern[];
  Tick @ tick;
  0 => int start;
  0 => int end;

  fun void play() {
    while(1) {
      tick => now;
      if ( tick.playhead >= start && tick.playhead < end) {
        if ( pattern[tick.playhead % pattern.size()] ) {
          trigger.broadcast();
        }
      }
    }
  }

  spork ~ play();

  fun static Pattern create(Event trig, int p[], Tick t, int st, int en) {
    Pattern temp;
    trig @=> temp.trigger;
    p @=> temp.pattern;
    t @=> temp.tick;
    st @=> temp.start;
    en @=> temp.end;
    return temp;
  }
}

class FloatEvent extends Event {
  float data;
}

class Sound {
  SndBuf s => dac;

  Event trigger;

  fun void init(string file) {
    file => s.read;
    s.samples() => s.pos;
  }

  fun void poll() {
    while(1) {
      trigger => now;
      0 => s.pos;
    }
  }

  spork ~ poll();

  fun Pattern add(int p[], int start, int loops) {
    Pattern.create(trigger, p, tick, start, start + p.size() * loops) @=> Pattern temp;
    return temp;
  }

  fun static Sound create(string file) {
    Sound temp;
    temp.init(file);
    return temp;
  }

}


Sound.create("./samples/kick/song-kick.wav") @=> Sound kick;
Sound.create("./samples/hat/song-hat.wav") @=> Sound hat;
Sound.create("./samples/clap/song-909.wav") @=> Sound clap;

kick.add([1, 0, 0, 0], 0, 16);
kick.add([0, 0, 1, 0], 32, 1);
clap.add([0, 0, 0, 0, 1, 0, 0, 0], 0, 8);
hat.add([0, 0, 1, 0], 0, 16);


spork ~ masterClock();

while(1) {
  1::second => now;
}
