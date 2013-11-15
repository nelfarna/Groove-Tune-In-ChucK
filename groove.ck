Scale sc; // for scaling melody

950::ms => dur T; // change to speed up or slow down tune

sc.maj @=> int scType[]; // scale used for tune, in this case: major
48 => int midiNote; // MIDI note corresponding to Middle C, starting note for our scale

// Melody sequences
[2, 2, 4, 4, 1, 1, 5, 6, 7, 8] @=> int melody[];  // main melody
//[8, 5, 8, 5, 2, 5, 6, 5, 6, 9] @=> int melody[];  // alternative main melody
[2, 4, 2, 4, 1, 4, 1, 5] @=> int base[]; // base melody
[2, 6, 9, 9, 3, 6, 9, 6] @=> int bg[]; // for background sounds

[ T, 3*T / 4, T / 4] @=> dur durations[];

// Return random time from durations array
fun void random_time() {
    durations[ Math.random2( 0, 2 ) ] => now;
}

// Snare and kick beat
fun void kick_snare_beat()
{
    SndBuf kick => dac;
    SndBuf snare => dac;

    me.dir() + "/audio/kick_01.wav" => kick.read;
    me.dir() + "/audio/snare_01.wav" => snare.read;
    
    // set playhead position to end to prevent sound on start up
    kick.samples() => kick.pos;
    snare.samples() => snare.pos;
    
    0 => int counter;

    while (true)
    {
        
        0 => kick.pos;
        Math.random2f( .8, 1.0 ) => kick.rate;
        0.5 => kick.gain;
        T / 2 => now; // advance time     

        for(0 => int i; i < 2; i++) {
           0 => snare.pos;
           Math.random2f( .7, 1.0 ) => snare.rate;
           0.2 => snare.gain;
           T / 4 => now; // advance time
        }
        
    }
}

// Random cowbell
fun void cowbell_beat() {
    SndBuf cb => JCRev rs => dac;
    0.4 => rs.gain;
    
    me.dir() + "/audio/cowbell_01.wav" => cb.read;
    cb.samples() => cb.pos;  
    
    while(true) {
        Math.random2f( .1, .2 ) => cb.gain;
        0 => cb.pos;
        Math.random2f( .6, 1.8 ) => cb.rate;  
        
        random_time();
    } 
}

// Random hihat
fun void hihat_beat()
{
    SndBuf hihat => JCRev r => dac;

    me.dir() + "/audio/hihat_01.wav" => hihat.read;
  
    // set playhead to end so no sound is made
    hihat.samples() => hihat.pos;

    0.8 => r.gain;
    0.2 => r.mix;
   
    0 => int counter;
   
    while (true)
    {
               
        if(counter % 4 == 0) {
            
            0 => hihat.pos;
            Math.random2f( .9, 1.0 ) => hihat.rate;
            0.1 => hihat.gain;
            
            T / 2 => now; // advance time
        }
        
        counter++;
    }
    
}

// Background beats
fun void modal_beat1( ) {
    
    ModalBar inst => JCRev r => dac;
    
    while(true) {
        
        // set freq
        melody[ Math.random2( 0, melody.cap() - 1 ) ] => int note;
        
        60 + Math.random2( 0, 2 )*12 + note => Std.mtof => inst.freq;
        .8 => inst.noteOn;
        
        4 * T => now;  // advance time for 4 times the main duration
    }
}

// More background beats
fun void modal_beat2( ) {
    
    ModalBar inst => JCRev r => Echo a => dac;
    
    .4 => r.gain;
    60::ms => a.max;
    20::ms => a.delay;
    .10 => a.mix;
    
    0 => int counter;
    .9 => inst.gain;
    
    while ( true ) { 
        
        bg[ counter % bg.cap() ] => int note;
        
        Std.mtof( ( midiNote - 12 ) + sc.scale( note, sc.maj ) ) => inst.freq;
        1.0 => inst.noteOn;
         
        T / 2 => now; // play for half of T duration
        counter++;
    }
}

// Add a little randomized base
fun void base_tune( ) {
    Rhodey inst => JCRev r => dac;
    
    .4 => r.gain;
    .2 => r.mix;
    1.3 => inst.gain;
    
    0 => int counter;
    
    while( true ) {
        base[ counter%base.cap() ] => int note;
        Std.mtof( (midiNote - 12) + sc.scale(note, scType)) => inst.freq;
        
        Math.random2f(0.6, 0.8) => inst.noteOn;
        random_time();
        
        counter++;
    }
}


// Main Tune
fun void main_tune( ) 
{
    // Rhodey is a unit generator from the Synthesis Toolkit
    Rhodey inst => JCRev r => Echo a => Echo b => Echo c => dac;
    
    0.8 => r.gain; // amplitude of reverb
    0.2 => r.mix; // reverb mix amount
    T => a.max => b.max => c.max; 
    3*T / 4 => a.delay => b.delay => c.delay;
    .50 => a.mix => b.mix => c.mix;
    
    1.8 => inst.gain;
    
    0 => int n; // a counter for looping through array in infinite loop
    
    
    while ( true ) { 
        
        // get melody note from array --- cap() is length of array
        melody[ n % melody.cap() ] => int note;
        
        // set the scale of note by passing it through the scale function
        // convert the note to a midi note (middle C)
        // finally, convert the result to a frequency and chuck it to the unit generator's frequency
        Std.mtof( midiNote + sc.scale( note, scType ) ) => inst.freq;
        
        // turn on note, randomize its rate
        Math.random2f(0.4, 0.7) => inst.noteOn;
        
        // randomize note playing duration
        if( Math.randomf() > 0.5 ) {
            durations[ Math.random2(0, 2) ] => now;
        } else {
            // repeating note
            2 * Math.random2(1, 2) => int rep;
            
            for( 0 => int i; i < rep; i++ ) {
                Math.random2f(.5, .7) => inst.noteOn;
                T / 4 => now;
            }  
        }

        n++;
        
    }
}


// spork shreds --- can also play separately (simply comment out shreds to remove from tune)

spork ~ modal_beat1( );
spork ~ modal_beat2( );
spork ~ hihat_beat( );
spork ~ kick_snare_beat( );
spork ~ cowbell_beat( );

spork ~ base_tune( );
spork ~ main_tune( );

// advance time to get shreds above going 
// --- as long as this shred keeps advancing time, the other embedded shreds will do so too
while ( true ) 
{
    1::second => now;
}
