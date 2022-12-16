//final project code

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
	result = Pbind(\instrument, \samplePlayer, \bufnum, Pseq(output), \dur, 24/bpm);
};

//ginger reference 101 bpm.
~a = ~generatePattern.([1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0], ~perc, 101);
~b = ~generatePattern.([1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0], ~kick, 101);
~c = ~generatePattern.([0,0,0,1,0,0,1,0,0,0,0,1,0,0,1,0], ~clap, 101);
~d = ~generatePattern.([1,0,0,0,0,0,0,0,1,1,0,0,0,0,1,0], ~chat, 101);
~wizk_beat_pattern1 = Ppar([~a,~b,~c, ~d], 4);

//ma lo reference 105 bpm
~a = ~generatePattern.([1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0], ~perc, 105);
~b = ~generatePattern.([1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0], ~kick, 105);
~c = ~generatePattern.([1,0,0,1,0,0,1,0,0,0,1,0,1,0,0,0], ~clap, 105);
~d = ~generatePattern.([1,0,0,0,0,0,1,0,1,0,0,0,1,0,1,0], ~chat, 105);
~tiwa_beat_pattern1 = Ppar([~c, ~d], 4);

//rush reference 100 bpm
~a = ~generatePattern.([1,0,1,0,0,1,0,0,1,0,1,0,0,1,0,0], ~snar, 100);
~b = ~generatePattern.([1,0,0,0,0,0,1,0,0,0,0,0,0,0,1,0], ~kick, 100);
~c = ~generatePattern.([0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0], ~ohat, 100);
~d = ~generatePattern.([1,0,0,0,0,0,1,0,1,0,0,0,1,0,1,0], ~chat, 100);
~arya_beat_pattern1 = Ppar([~a, ~b, ~c], 4);
~arya_beat_pattern1.play;

//calm down reference 107 bpm
~a = ~generatePattern.([1,0,1,0,0,1,0,0,1,0,1,0,0,1,0,0], ~chat, 107);
~b = ~generatePattern.([1,0,0,0,0,0,1,0,0,0,0,0,0,0,1,0], ~kick, 107);
~c = ~generatePattern.([0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0], ~ohat, 107);
~d = ~generatePattern.([1,0,0,0,0,0,1,0,1,0,0,0,1,0,1,0], ~chat, 107);
~arya_beat_pattern1 = Ppar([~a, ~b], 4);
~arya_beat_pattern1.play;

~scale = Scale.major;

~a = ~generatePattern.(
	[
		1,0,0,0,0,0,1,0,0,0,0,0,1,0,1,0,1,0,1,0,0,0,0,0,1,0,0,0,0,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,
		1,0,0,0,0,0,1,0,0,0,0,0,1,0,1,0,1,0,1,0,1,0,1,0,1,1,1,0,0,0,1,1,0,1,0,1,0,0,1,0,1,0,1,0,1,1,1,0,
		1,0,0,0,0,0,1,0,0,0,0,0,1,0,0,0,0,0,1,0,0,0,0,0,1,0,0,0,0,0,1,0,0,0,0,0,1,0,0,0,0,0,1,0,0,0,0,0,
		1,0,0,0,0,0,1,0,0,0,0,0,1,0,0,0,0,0,1,0,0,0,0,0,1,0,0,0,0,0,1,0,0,0,0,0,1,0,0,0,0,0,1,0,0,0,0,0
	],~kick, 107);
~a.play;

~scale.degrees;

66.midiToCps;

~arya_beat_pattern1.play;
~wizk_beat_pattern1.play;
~tiwa_beat_pattern1.play;

~pattern_generator = {
	arg key, pattern;
	var output;
	output = Array.new(pattern.size);
	pattern.do({
		arg item;
		//item.postln;
		if ( item == 0,                // Boolean expression (chooses one at random)
			{ output.add(\rest)},    // true function
    { output.add(key)}   // false function
)
	});
	Pseq(output, 4);
};


~kp1 = ~pattern_generator.(~kick,[1,0,0,0,0,0,1,0,0,0,1,0,0,1,0,0]);

~kpattern = Pbind(\instrument, \samplePlayer, \bufnum, ~kp1, \dur, 0.25);

~new_kick = ~generateKick.(240, \tiwa).play;