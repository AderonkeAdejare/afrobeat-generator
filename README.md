# afrobeat-generator
## Created by Aderonke Adejare & Enoch Omale

Instructions: Use the slider to set the tempo. Pick a beat and a melody from the artist(s) you want to make a song in the style of. Hit Play!

# Afrobeats Generator

Inspired by our Nigerian culture, we created a program that generates songs based on Afrobeats artists. Afrobeats is a genre that is growing in popularity across the world. Originating from Nigeria as an evolution of 1970s and ‘80s Afrobeat (without the s) music, Afrobeats focuses combining traditional Nigerian drum beats with modern hip-hop beats.

Our Program, written in SuperCollider, is an easy-to-use generator of Afrobeats instrumentals in a small selection of styles inspired by songs from three of the most popular Afrobeats artists today: WizKid, Arya Starr, and Tiwa Savage. To use it, simply select the names of the artists whose sound you would like to mimic, a tempo, and then hit play to hear a unique piece of African music. Hitting “Stop” stops the music and hitting “Save” saves it in a file (in the default SuperCollider location) for later listening.


## GUI

The GUI has a slider users can slide to change the song's tempo.  There are two dropdown menus where. You can select a beat similar to the artist in the first and a melody similar to the artist in the second.  The default tempo is 60 bpm and the tempo ranges up to 200 bpm.  The default artist is Tiwa Savage for the beat and melody, but you can mix and match the styles of each artist.  When you hit the play button, it will play the music and start recording.  Hitting the stop button will stop the music and save the recording to your device.

[https://lh4.googleusercontent.com/VWd96fkNRN-lS_HtMeDAQHu9OmG1p2HKN1T9Z5c5-vFRZw13Grm2FqLazcMVqKJ7n0dCmJV52_2Pdg72PnLf0mnR_MDlhvAKM92ayfLC5fCWP--piJkQ8PNz6UmshKWy1y9252l6sVB2-ohZVhB5pkcxCrPh485satuLqb1APqr2q1fYs-OsK_pv1cPfjQ](https://lh4.googleusercontent.com/VWd96fkNRN-lS_HtMeDAQHu9OmG1p2HKN1T9Z5c5-vFRZw13Grm2FqLazcMVqKJ7n0dCmJV52_2Pdg72PnLf0mnR_MDlhvAKM92ayfLC5fCWP--piJkQ8PNz6UmshKWy1y9252l6sVB2-ohZVhB5pkcxCrPh485satuLqb1APqr2q1fYs-OsK_pv1cPfjQ)

![Screen Shot 2022-12-17 at 12.37.37 AM.png](https://s3-us-west-2.amazonaws.com/secure.notion-static.com/9ec7a5cd-6476-4c15-9118-858a70549bdd/Screen_Shot_2022-12-17_at_12.37.37_AM.png)

## Chord

I determined each artist will have a certain MIDI range that is similar to their vocal range: Tiwa Savage’s is 70 to 96, Arya Starr’s is 58 to 84, and WizKid’s is 46 to 60.  That range would be used to create the chord layer and the lyric layer of the song.  C, Bb, and G in each artist’s range were chosen as the keys that would be randomly chosen to create the chord layer.  I went with the basic pop song chord progression of I, IV, V, I.

```c
~generateChord = {
		arg octave;
		c = ~key_distribution[~artist_M];
		c = c + octave;
		~i = [c[0], c[2], c[4]];
		~iv = [c[3], c[5], c[0]];
		~v = [c[4], c[6], c[1]];
		// chord layer
		x = [1,2,4].wchoose([1, 2, 4]);
		//x.postln;
		~bot = Pbind(\freq, Pseq([~i[0], ~iv[0], ~v[0], ~i[0]], inf).midicps, \dur, x);
		~mid = Pbind(\freq, Pseq([~i[1], ~iv[1], ~v[1], ~i[1]], inf).midicps, \dur, x );
		~top = Pbind(\freq, Pseq([~i[2], ~iv[2], ~v[2], ~i[2]], inf).midicps, \dur, x);

		Ppar([~bot, ~mid, ~top]);
	};
```

We also chose the type of scale used in the song based on the artist.  For Tiwa Savage, there is a higher chance of using a minor scale than a major scale.  For Arya Starr, there’s an equal chance of choosing a major or minor scale and a chance of choosing a Dorian scale.  For Wizkid, there’s an equal chance of choosing a major or Dorian scale and a lesser chance of choosing a minor scale.

```c
~key_distribution = [
		[Scale.major.degrees, Scale.minor.degrees].wchoose([1, 2]),
		[Scale.major.degrees, Scale.minor.degrees, Scale.dorian.degrees].wchoose([2, 2, 1]),
		[Scale.major.degrees, Scale.minor.degrees,Scale.dorian.degrees].wchoose([2, 1, 2])
	];
```

## Lyrics (Pitches)

I used a Mealy Machine to generate the layer of music that could be the pitches to lyrics in the song.  The machine had three states: 0, 1, 2.  If it was in state 0, it had a 50/50 chance of staying in 0 or going to state 1.  If it was in state 1, it had a 45% chance of going to state 0 or 2 and a 10% chance of staying in state 1.  If it was in state 2, there was a  45% chance of going to state 0 or 1 and a 10% chance of staying in state 2.  When in state 0, the machine could choose between the first, fourth, and fifth notes of the scale for the next note.  When in state 1, the machine could choose between the second, fifth, and sixth notes of the scale for the next note. When in state 2, the machine could choose between the third, sixth, and seventh notes of the scale for the next note.  We had the machine go through this 128 times before it stopped.  We then added the randomly chosen scale’s MIDI note number to the array of lyric notes to get the notes that would be played in the song.

```c
// Mealy Machine to generate notes that on that could be pitches of lyrics
	n = [];
	~genNState = {
		arg current;
		switch(current,
			0, {
				// choose note to play in this state
				n = n.add([c[0], c[3], c[4]].choose);
				// choose next state
				~states.wchoose([0.5, 0.5, 0.0]);
			},
			1, {
				n = n.add([c[1], c[4], c[5]].choose);
				~states.wchoose([0.45, 0.1, 0.45]);
			},
			2, {
				n = n.add([c[2], c[5], c[6]].choose);
				~states.wchoose([0.45, 0.45, 0.1]);
			}
		);

	};
	~generateLyrics = {
		arg octave;
		n = [];
		~states = [0, 1, 2];
		// start state is 0
		~c_state = ~states[0];
		//("Current:" + ~c_state).postln;

		~n_state = ~genNState.(~c_state); // printing out n
		//("Next:" + ~n_state).postln;
		128.do{
			~c_state = ~n_state;
			~n_state = ~genNState.(~c_state);
		};
		("Note Scale Degrees:" + n).postln;
		// n = n + octave;
		("Notes:" + n).postln;
		//Pbind(\freq, Pseq(n, inf).midicps, \dur, 0.5).play;
	};
```

Enoch: I worked on the percussion of the music generated. The beat selection system works by selecting a Ppar (manually composed) that is associated with the selected artist. These are inspired by their respective discographies. I created a pseudo step sequence in-code, which just has on (1) and off (0) beats. We could then just place the drum beats of each layer and provide the sample buffer variable to be used. These layers get passed to the ~generatePattern function which picks the durations of each note and adds the appropriate rest notes and spits out Pbinds to be layered in a Ppar which eventually gets added to the final Ppar. The generate_pattern function is also used for timing the “Lyric” layer/main melody, by adding a number of rests to the start of the generated note sequence.

the generate pattern function + example beat:

```c
b = [\kick, \ohat, \chat, \clap, \snar, \perc, \rest].collect{|val| Buffer.read(s,(val++".wav").resolveRelative) };
	~kick = b[0]; 
	~ohat = b[1];
	~chat = b[2]; 
	~clap = b[3];
	~snar = b[4]; 
	~perc = b[5];
	~rest = b[6];

	// sample player src: https://truthindustri.es/supercollider/2019/01/04/supercollider-house-drums.html
	SynthDef(\samplePlayer,{ arg out = 0, bufnum, amp;
		Out.ar( out,
			PlayBuf.ar(2, bufnum, BufRateScale.kr(bufnum), doneAction: 2) * amp;
		)
	}).add;

	~artist_B = 0;
	~artist_M = 0;

	//
	~generatePattern = {
		arg pattern, sound, bpm;
		var output;
		var result;
		output = Array.new(pattern.size);
		pattern.do({
			arg item;
			//item.postln;
			if ( item == 0,                // Boolean expression (chooses one at random)
				{ output.add(\rest)},    // true function
				{ output.add(sound)}   // false function
			)
		});
		Pseq(output, inf);
		result = Pbind(\instrument, \samplePlayer, \bufnum, Pseq(output), \dur, 0.25);
	};

	//ginger reference 101 bpm.
	~a = ~generatePattern.([1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0], ~perc, 101);
	~b = ~generatePattern.([1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0], ~kick, 101);
	~c = ~generatePattern.([0,0,0,1,0,0,1,0,0,0,0,1,0,0,1,0], ~clap, 101);
	~d = ~generatePattern.([1,0,0,0,0,0,0,0,1,1,0,0,0,0,1,0], ~chat, 101);
	~wizk_beat_patterns = List[Ppar([~a,~b,~c, ~d], inf)];
```

I  also worked on the main logic/state structure within our program (which variables were passed to Aderonke’s UI etc, controlling when sequences/patterns got generated and the functions bringing the layers together. The song is split up into three layers: the chords (Aderonke), the melody (Aderonke) and the beats/percussion (Enoch). These layers after generation (or random selection in the case of the beats) get put into Ppars to be played immediately. They get generated right as you hit play to ensure that each run results in a different song.

play action:

```c

~play = Button(w, Rect(600, 200, 60, 40))
	.states_([
		["Play", Color.black, Color.white],
		["Stop", Color.black, Color.white]
	])
	.font_(Font("Monaco", 14))
	.action_({
		// when play is hit, then music will be played
		arg obj;
		if (
			obj.value == 1,
			{   "playing".postln;
				~select_beat.();
				~select_melody.();
				~mel = ~generateLyrics.(~notes);
				r = Recorder.new(s);
				r.record;
				x = Ppar([~beat_to_play, ~chords, ~mel]).play;
			},
			{
				x.stop;
				r.stopRecording;
			}

	); }

	);

```

# Demo Video & Song

(audio not captured with video, but head to the our GitHub link above to download and test yourself)

below is clip of the UI being interacted with and some output musical pieces.
