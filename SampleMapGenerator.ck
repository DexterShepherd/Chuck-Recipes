/* 
Ripping off Tidal Cycles some more.

Requires --caution-to-the-wind flag to 
run sys command. If that isn't possible just generate the map
ahead of time and remove the Std.sys line.

This will only work with sample folders one level deep. /SAMPLE_DIR/sound_name/sample_1.wav etc. 

I'm not sure if this is a smart thing to be doing. Use at your own risk.
*/


"./samples" @=> string SAMPLE_DIR;

"recurse() {
 for i in \"$1\"/*;do
    if [ -d \"$i\" ];then
        echo \"!$i\"
        recurse \"$i\"
    elif [ -f \"$i\" ]; then
        echo \"*$i\"
    fi
 done
}

recurse " + SAMPLE_DIR + "> map.txt"  @=> string mapper;

string map[0];
me.dir() + "/map.txt" => string mapPath;

class Sampler extends Chubgraph {
  fun static void generateMap() {

    Std.system(mapper);

    FileIO fio;

    fio.open(mapPath, FileIO.READ);

    if ( !fio.good() ) {
      <<<"Can't open file">>>;
      return; 
    }

    "" @=> string dir;
    0 => int index;
    while(fio.more()) {
      fio.readLine() @=> string line;
      if ( line.length() ) {
        if ( line.substring(0, 1) == "!" ) {
          line.erase(0, 1);
          line @=> dir;
          dir.erase(0, SAMPLE_DIR.length() + 1);
          0 => index;
        } else if (line.substring(0, 1) == "*") {
          line.erase(0, 1);
          if ( index == 0 ) {
            line @=> map[dir];
          }
          line @=> map[dir + ":" + index];
          index++;
        }
      }
    }
  }

  SndBuf buffer => outlet;

  fun void load(string sound) {
    buffer.read(map[sound]);
  }
}


Sampler.generateMap();

Sampler s => dac;
s.load("kick:2");
0.5::second => now;
s.load("hat");
0.5::second => now;
s.load("hat:1");
0.5::second => now;
s.load("clap:3");
0.5::second => now;
