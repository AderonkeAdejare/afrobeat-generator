(
s.waitForBoot {
	//beats
	// setting up samples
	b = [\kick, \ohat, \chat, \clap, \snar, \perc, \rest].collect{|val| Buffer.read(s,(val++".wav").resolveRelative) };
	~kick = b[0]; // Buffer.read(s, ("samples/kick.wav").resolveRelative);
	~ohat = b[1]; //Buffer.read(s, "samples/ohat.wav");
	~chat = b[2]; //Buffer.read(s, "samples/chat.wav");
	~clap = b[3]; //Buffer.read(s, "samples/clap.wav");
	~snar = b[4]; //Buffer.read(s, "samples/snar.wav");
	~perc = b[5]; //Buffer.read(s, "samples/perc.wav");
	~rest = b[6]; //Buffer.read(s, "samples/rest.wav");


	// sample player src: https://truthindustri.es/supercollider/2019/01/04/supercollider-house-drums.html
	SynthDef(\samplePlayer,{ arg out = 0, bufnum, amp;
		Out.ar( out,
			PlayBuf.ar(2, bufnum, BufRateScale.kr(bufnum), doneAction: 2) * amp;
		)
	}).add;

	~artist_B = 0;
	~artist_M = 0;


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

	//ma lo reference 105 bpm
	~a = ~generatePattern.([1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0], ~perc, 105);
	~b = ~generatePattern.([1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0], ~kick, 105);
	~c = ~generatePattern.([1,0,0,1,0,0,1,0,0,0,1,0,1,0,0,0], ~clap, 105);
	~d = ~generatePattern.([1,0,0,0,0,0,1,0,1,0,0,0,1,0,1,0], ~chat, 105);
	~tiwa_beat_patterns = List[Ppar([~c, ~d], inf)];

	//rush reference 100 bpm
	~a = ~generatePattern.([1,0,1,0,0,1,0,0,1,0,1,0,0,1,0,0], ~snar, 100);
	~b = ~generatePattern.([1,0,0,0,0,0,1,0,0,0,0,0,0,0,1,0], ~kick, 100);
	~c = ~generatePattern.([0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0], ~ohat, 100);
	~d = ~generatePattern.([1,0,0,0,0,0,1,0,1,0,0,0,1,0,1,0], ~chat, 100);
	~arya_beat_patterns = List[Ppar([~a, ~b, ~c], inf)];

	//rush down reference 100 bpm
	~a = ~generatePattern.([1,0,1,0,0,1,0,0,1,0,1,0,0,1,0,0], ~chat, 107);
	~b = ~generatePattern.([1,0,0,0,0,0,1,0,0,0,0,0,0,0,1,0], ~kick, 107);
	~c = ~generatePattern.([0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0], ~ohat, 107);
	~d = ~generatePattern.([1,0,0,0,0,0,1,0,1,0,0,0,1,0,1,0], ~chat, 107);
	~arya_beat_patterns = List[Ppar([~a, ~b, ~c], inf)];

	~beat_patterns = List[~tiwa_beat_patterns, ~arya_beat_patterns, ~wizk_beat_patterns];
	~beat_to_play = ~beat_patterns[0].choose;


	// GUI for user interaction
	// close any windows that were open before to clean up screen space
	Window.closeAll;
	// creates new window
	w = Window.new("Afrobeats Generator", Rect(
	Window.screenBounds.width/4,
	Window.screenBounds.height/2, 750, 300)).front;

	// creates TempoClock
	t = TempoClock;

	// creates slider for controlling tempo in beats per minute
	~bpm = Slider.new(w.view, Rect.new(20, 50, 150, 30))
	.background_(Color(0.8, 0.8, 0.8))
	.thumbSize_(20)
	.value_(0)
	.action_({
		arg obj;
		var cf;
		cf = obj.value.linlin(0,1,60,200);
		~number_box.value_(cf);
		// add function for grabbing bpm
		t.tempo = cf/60;
	});
	t.tempo;

	// number box that displays beats per minute
	~number_box = NumberBox(w, Rect(200, 50, 80, 30))
	.value_(60)
	.clipLo_(60)
	.clipHi_(200)
	.font_(Font("Monaco", 18))
	.decimals_(0)
	.action_({
		arg obj;
		~bpm.valueAction_(obj.value.linlin(0,1,60,200))
	})
	.align_(\center);

	~tempo_label = StaticText(w, Rect(200, 80, 80, 20))
	.string_("Tempo")
	.font_(Font("Monaco", 14))
	.align_(\center);

	// artists is an array of eligible artists
	~artists = ["Tiwa Savage", "Arya Starr", "WizKid"];

	~artist_beat = PopUpMenu(w, Rect(325, 50, 150, 30))
	.items_(~artists)
	.font_(Font("Monaco", 14))
	.action_({
		arg menu;
		var choice;
		// get from item
		choice = menu.value;
		~artist_B = choice;

	};);

	~select_beat = {
		~beat_to_play = ~beat_patterns[~artist_B].choose;
		~artists[~artist_B].postln;
	};

	~chords;


	~select_melody = {
		~artist_switch = switch(~artist_M,
			// C, Bb, and G as default keys in different octaves for each artist
			0, {~notes = [72, 70, 79].choose;},
			1, {~notes = [60, 58, 67].choose;},
			2, {~notes = [48, 46, 55].choose;}
		);
			~chords = ~generateChord.(~notes);
		~notes.postln;
	};

	~artist_beat_label = StaticText(w, Rect(365, 80, 80, 20))
	.string_("Beat")
	.font_(Font("Monaco", 14))
	.align_(\center);

	// define scales for melody & lyric generation
	c = Scale.major.degrees;
	~key_distribution = [
		[Scale.major.degrees, Scale.minor.degrees, Scale.minor.degrees],
		[Scale.major.degrees, Scale.minor.degrees, Scale.major.degrees,Scale.dorian.degrees,Scale.minor.degrees],
		[Scale.major.degrees, Scale.major.degrees,Scale.minor.degrees,Scale.dorian.degrees, Scale.dorian.degrees]
	];

	~generateChord = {
		arg octave;
		c = ~key_distribution[~artist_M].choose;
		c = c + octave;
		~i = [c[0], c[2], c[4]];
		~iv = [c[3], c[5], c[0]];
		~v = [c[4], c[6], c[1]];
		// chord layer
		x = [1,2,2,4,4,4,4].choose;
		//x.postln;
		~bot = Pbind(\freq, Pseq([~i[0], ~iv[0], ~v[0], ~i[0]], inf).midicps, \dur, x);
		~mid = Pbind(\freq, Pseq([~i[1], ~iv[1], ~v[1], ~i[1]], inf).midicps, \dur, x );
		~top = Pbind(\freq, Pseq([~i[2], ~iv[2], ~v[2], ~i[2]], inf).midicps, \dur, x);

		Ppar([~bot, ~mid, ~top]);
	};

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
		~ret = Ppar([Pseq([~generatePattern.([0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0], ~rest)], 8)]);

		Pseq([~ret, Pbind(\freq, Pseq(n, inf).midicps, \dur, 0.5)], 4);
	};



	~artist_melody = PopUpMenu(w, Rect(500, 50, 150, 30))
	.items_(~artists)
	.font_(Font("Monaco", 14))
	.action_({
		arg menu;
		var choice;
		// get from item
		choice = menu.value;
		menu.item.postln;
		~artist_M = choice;


	};);

	~artist_melody_label = StaticText(w, Rect(530, 80, 80, 20))
	.string_("Melody")
	.font_(Font("Monaco", 14))
	.align_(\center);


	~instructions = StaticText(w, Rect(20, 75, 300, 300))
	.string_("Instructions: Use the slider to set the tempo. Pick a beat and a melody from the artist(s) you want to make a song in the style of. Hit Play!")
	.font_(Font("Monaco", 14))
	.align_(\center);

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
})
