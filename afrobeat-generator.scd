(
s.waitForBoot {

	// synthdefs
	// sample synthdef
	SynthDef.new(\simple, {
	arg freq = 440, rq = 0.2;
	var sig;
	sig = PinkNoise.ar(1!2);
	sig = BPF.ar(
		sig,
		freq.lag(0.5), //.lag makes sound smooth & not pop
		rq.lag(0.5),
		1/rq.sqrt.lag(0.5)
	);
	Out.ar(0, sig);}).add;

	//beats
	// setting up samples
	~kick = Buffer.read(s, "samples/kick.wav");
	~ohat = Buffer.read(s, "samples/ohat.wav");
	~chat = Buffer.read(s, "samples/chat.wav");
	~clap = Buffer.read(s, "samples/clap.wav");
	~snar = Buffer.read(s, "samples/snar.wav");
	~perc = Buffer.read(s, "samples/perc.wav");
	~rest = Buffer.read(s, "samples/rest.wav");

	// sample player src: https://truthindustri.es/supercollider/2019/01/04/supercollider-house-drums.html
	SynthDef(\samplePlayer,{ arg out = 0, bufnum, amp;
		Out.ar( out,
			PlayBuf.ar(2, bufnum, BufRateScale.kr(bufnum), doneAction: 2) * amp;
		)
	}).add;


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
		Pseq(output, 4);
		result = Pbind(\instrument, \samplePlayer, \bufnum, Pseq(output), \dur, 0.25);
	};

	//ginger reference 101 bpm.
	~a = ~generatePattern.([1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0], ~perc, 101);
	~b = ~generatePattern.([1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0], ~kick, 101);
	~c = ~generatePattern.([0,0,0,1,0,0,1,0,0,0,0,1,0,0,1,0], ~clap, 101);
	~d = ~generatePattern.([1,0,0,0,0,0,0,0,1,1,0,0,0,0,1,0], ~chat, 101);
	~wizk_beat_patterns = List[Ppar([~a,~b,~c, ~d], 4)];

	//ma lo reference 105 bpm
	~a = ~generatePattern.([1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0], ~perc, 105);
	~b = ~generatePattern.([1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0], ~kick, 105);
	~c = ~generatePattern.([1,0,0,1,0,0,1,0,0,0,1,0,1,0,0,0], ~clap, 105);
	~d = ~generatePattern.([1,0,0,0,0,0,1,0,1,0,0,0,1,0,1,0], ~chat, 105);
	~tiwa_beat_patterns = List[Ppar([~c, ~d], 4)];

	//rush reference 100 bpm
	~a = ~generatePattern.([1,0,1,0,0,1,0,0,1,0,1,0,0,1,0,0], ~snar, 100);
	~b = ~generatePattern.([1,0,0,0,0,0,1,0,0,0,0,0,0,0,1,0], ~kick, 100);
	~c = ~generatePattern.([0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0], ~ohat, 100);
	~d = ~generatePattern.([1,0,0,0,0,0,1,0,1,0,0,0,1,0,1,0], ~chat, 100);
	~arya_beat_patterns = List[Ppar([~a, ~b, ~c], 4)];

	//calm down reference 107 bpm
	~a = ~generatePattern.([1,0,1,0,0,1,0,0,1,0,1,0,0,1,0,0], ~chat, 107);
	~b = ~generatePattern.([1,0,0,0,0,0,1,0,0,0,0,0,0,0,1,0], ~kick, 107);
	~c = ~generatePattern.([0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0], ~ohat, 107);
	~d = ~generatePattern.([1,0,0,0,0,0,1,0,1,0,0,0,1,0,1,0], ~chat, 107);
	~arya_beat_patterns = List[Ppar([~a, ~b, ~c], 4)];

	~beat_patterns = List[~tiwa_beat_patterns, ~arya_beat_patterns, ~wizk_beat_patterns];
	~beat_to_play = ~beat_patterns[0].choose;







	// GUI for user interaction
	// close any windows that were open before to clean up screen space
	Window.closeAll;
	w = Window.new("Afrobeats Generator", Rect(
	Window.screenBounds.width/4,
	Window.screenBounds.height/2, 750, 300)).front;//.alwaysOnTop_(true);

	// creates TempoClock
	t = TempoClock;

	// creates slider for controlling tempo in beats per minute
	~bpm = Slider.new(w.view, Rect.new(20, 50, 150, 30))
	.background_(Color(0.8, 0.8, 0.8))
	.thumbSize_(20)
	.action_({
		arg obj;
		var cf;
		cf = obj.value.linlin(0,1,60,200); //.linexp(0, 1, 60, 200); //.postln;
		~number_box.value_(cf); //.linexp(0,1,60,200)
		// add function for grabbing bpm
		t.tempo = cf/60;
		//t.tempo.postln;
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
		//~artists = [menu.value, menu.item];
		//~artists.postln;

		// if item == "Tiwa Savage" then select from beat that is closest to bpm
		// postln statements are placeholders for functions that will choose which beat out of 2 from the given artists to play
		/*if (choice == 0, {"Tiwa Savage".postln;});
		if (choice == 1, {"Arya Starr".postln;});
		if (choice == 2, {"WizKid".postln;});*/
		~beat_to_play = ~beat_patterns[choice].choose;
		~artists[choice].postln;


	};);

	~artist_beat_label = StaticText(w, Rect(365, 80, 80, 20))
	.string_("Beat")
	.font_(Font("Monaco", 14))
	.align_(\center);

	c = Scale.major.degrees;
	c.postln;



	~artist_melody = PopUpMenu(w, Rect(500, 50, 150, 30))
	.items_(["Tiwa Savage", "Arya Starr", "WizKid"])
	.font_(Font("Monaco", 14))
	.action_({
		arg menu;
		var choice;
		// get from item
		choice = menu.value;
		// postln statements are placeholders for functions that will choose which melody (out of 2?) from the given artists to play
		if (choice == 0, {"Tiwa Savage".postln;


			~key = switch(~key_no,
				0, {~key = ~key + 60}, // C Major !
				1, {~key = ~key + 61}, // Db Major
				2, {~key = ~key + 70}, // Bb Major !
				3, {~key = ~key + 65}, // F Major
				4, {~key = ~key + 67}, // G Major
				5, {~key = ~key + 62}, // D Major
				6, {~key = ~key + 69}, // A Major
			);
			c = c + 72;
			~i = [c[0], c[2], c[4]];
			~iv = [c[3], c[5], c[0]];
			~v = [c[4], c[6], c[1]];
			// chord layer
			~bot = Pbind(\freq, Pseq([~i[0], ~iv[0], ~v[0]]).midicps );
			~mid = Pbind(\freq, Pseq([~i[1], ~iv[1], ~v[1]]).midicps );
			~top = Pbind(\freq, Pseq([~i[2], ~iv[2], ~v[2]]).midicps);

			Ppar([~bot, ~mid, ~top]).play;
		});

		if (choice == 1, {"Arya Starr".postln;});

		if (choice == 2, {"WizKid".postln;});


	};);

	~artist_melody_label = StaticText(w, Rect(530, 80, 80, 20))
	.string_("Melody")
	.font_(Font("Monaco", 14))
	.align_(\center);


	~instructions = StaticText(w, Rect(20, 75, 200, 300))
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
				x = ~beat_to_play.play;
				//x = Synth.new(\simple).register;
			},
			{x.stop;}
	); }

	);
})

(
SynthDef(\tiwa, {
})

c = Scale.major.degrees;
c.postln;
Pbind(\freq, c).play;

~i = [c[0], c[2], c[4]];
~iv = [c[3], c[5], c[0]];
~v = [c[4], c[6], c[1]];
)

().play
Pbind(\freq, Prand([300, 500, 231.2, 399.2], inf), \dur, 0.1).play;
