public class Scale {
    
//minor scales
[0, 2, 3, 5, 7, 8, 10] @=> int min[]; //minor mode
[0, 2, 3, 5, 7, 8, 11] @=> int har[]; //harmonic minor
[0, 2, 3, 5, 7, 9, 11] @=> int asc[]; //ascending melodic minor
[0, 1, 3, 5, 7, 8, 10] @=> int nea[]; //make 2nd degree neapolitain

[0, 2, 4, 5, 7, 9, 11] @=> int maj[]; //major scale
[0, 2, 4, 5, 7, 8, 10] @=> int mixo[]; //church mixolydian
[0, 2, 3, 5, 7, 9, 10] @=> int dor[]; //church dorian
[0, 2, 4, 6, 7, 9, 11] @=> int lyd[]; //church lydian
    
[0, 2, 4, 7, 9] @=> int pent[]; //major pentatonic
[0, 1, 4, 5, 7, 8, 10] @=> int jewish[]; //phrygian dominant, jewish scale
[0, 2, 3, 6, 7, 8, 11] @=> int gypsy[]; //hungarian or gypsy
[0, 1, 4, 5, 7, 8, 11] @=> int arabic[]; //arabic scale
[0, 2, 4, 6, 8, 10] @=> int whole_tone[]; //the whole tone scale
[0, 2, 3, 5, 6, 8, 9, 11] @=> int dim[]; //diminished scale

//new pseudo indian lydian mode
[0, 2, 4, 6, 7, 9, 10] @=> int ind[];


fun int scale(int note, int sc[]) {
    sc.cap() => int n; //number of degrees in scale
    note / n => int octave; //octave being requested, number of wraps
    note % n => note; //wrap the note within first octave
    
    if ( note < 0 ) { //cover the negative border case
        note + 12 => note;
        octave - 1 => octave;
    }
    
    //each octave contributes 12 semitones, plus the scale
    return octave*12 + sc[note];
}
}
