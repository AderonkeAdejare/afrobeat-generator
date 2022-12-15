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
		t.tempo.postln;
	});

	~bpm.value.postln;
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
		if (choice == 0, {"Tiwa Savage".postln;});
		if (choice == 1, {"Arya Starr".postln;});
		if (choice == 2, {"WizKid".postln;});


	};);

	~artist_beat_label = StaticText(w, Rect(365, 80, 80, 20))
	.string_("Beat")
	.font_(Font("Monaco", 14))
	.align_(\center);

	~artist_melody = PopUpMenu(w, Rect(500, 50, 150, 30))
	.items_(["Tiwa Savage", "Arya Starr", "WizKid"])
	.font_(Font("Monaco", 14))
	.action_({
		arg menu;
		var choice;
		// get from item
		choice = menu.value;
		// postln statements are placeholders for functions that will choose which melody (out of 2?) from the given artists to play
		if (choice == 0, {"Tiwa Savage".postln;});
		if (choice == 1, {"Arya Starr".postln;});
		if (choice == 2, {"WizKid".postln;});


	};);

	~artist_melody_label = StaticText(w, Rect(530, 80, 80, 20))
	.string_("Melody")
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
				x = Synth.new(\simple).register;
			},
			{x.free}
	); }

	);
})