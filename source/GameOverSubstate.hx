package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSubState;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.math.FlxMath;
using StringTools;
import openfl.filters.ShaderFilter;
import Shaders;

class GameOverSubstate extends MusicBeatSubstate
{
	var bf:Boyfriend;
	var camFollow:FlxObject;

	var stageSuffix:String = "";
	var chromaticAbberation:ChromaticAbberationEffect;
	public function new(x:Float, y:Float, ?bfVer:String='bf', ?glitchNoteDeath:Bool=false)
	{
		PlayState.currentPState.modchart.clearCamEffects();
		if(glitchNoteDeath){
			chromaticAbberation = new ChromaticAbberationEffect();
			FlxG.camera.setFilters([new ShaderFilter(chromaticAbberation.shader)]);
		}
		var daStage = PlayState.curStage;
		var daBf:String = '';
		switch (daStage)
		{
			case 'school':
				stageSuffix = '-pixel';
				daBf = 'bf-pixel-dead';
			case 'schoolEvil':
				stageSuffix = '-pixel';
				daBf = 'bf-pixel-dead';
			default:
				daBf = bfVer;
		}

		if(daBf=='bf' || daBf.startsWith("sword") || daBf.startsWith("arrow") || daBf.startsWith("twat") || daBf=='depressed'  ){
			switch(PlayState.SONG.song.toLowerCase()){
				case 'last-stand' | 'dishonor':
					daBf = 'bf-FUCKING-DIES';
					stageSuffix='-omega';
			}
		}else{
			switch(daBf){
				case 'naikaze' | 'tgr' | 'erderi' | 'mikeeey':
					switch(PlayState.SONG.song.toLowerCase()){
						case 'last-stand' | 'dishonor':
							daBf = '${daBf}-FUCKING-DIES';
							stageSuffix='-omega';
					}

			}
		}

		super();

		Conductor.songPosition = 0;

		bf = new Boyfriend(x, y, daBf);
		add(bf);

		camFollow = new FlxObject(bf.getGraphicMidpoint().x, bf.getGraphicMidpoint().y, 1, 1);
		add(camFollow);

		switch(daBf){
			case 'babyvase':
				FlxG.sound.play(Paths.sound('vaseDeath'));
			case 'bfside':
				FlxG.sound.play(Paths.sound('brightsideDeath'));
			default:
				if(PlayState.SONG.song.toLowerCase()=='prelude'){
					FlxG.sound.play(Paths.sound('NotHowYouDoIt'));
				}
				FlxG.sound.play(Paths.sound('fnf_loss_sfx' + stageSuffix));
		}


		Conductor.changeBPM(100);

		// FlxG.camera.followLerp = 1;
		// FlxG.camera.focusOn(FlxPoint.get(FlxG.width / 2, FlxG.height / 2));
		FlxG.camera.scroll.set();
		FlxG.camera.target = null;

		bf.playAnim('firstDeath');
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if(chromaticAbberation!=null){
			chromaticAbberation.strength = FlxMath.lerp(chromaticAbberation.strength,1,.06);
			chromaticAbberation.update();
		}
		if (controls.ACCEPT && (bf.curCharacter!='bf-FUCKING-DIES' || FlxG.save.data.seenLastStandOmegaGameOver))
		{
			endBullshit();
		}

		if (controls.BACK)
		{
			FlxG.sound.music.stop();

			var state:MusicBeatState = new FreeplayState();
			if(UnlockingItemState.unlocking.length>0){
				state = new UnlockingItemState();
			}else if(PlayState.isStoryMode){
				state = new StoryMenuState();
			}

			FlxG.switchState(state);
		}

		if (bf.animation.curAnim.name == 'firstDeath' && bf.animation.curAnim.curFrame == 12)
		{
			FlxG.camera.follow(camFollow, LOCKON, 0.01);
		}

		if (bf.animation.curAnim.name == 'firstDeath' && bf.animation.curAnim.finished)
		{
			FlxG.sound.playMusic(Paths.music('gameOver' + stageSuffix));
		}

		if (FlxG.sound.music.playing)
		{
			Conductor.songPosition = FlxG.sound.music.time;
		}
	}

	override function beatHit()
	{
		super.beatHit();

		FlxG.log.add('beat');
	}

	var isEnding:Bool = false;

	function endBullshit():Void
	{
		if (!isEnding)
		{
			isEnding = true;
			bf.playAnim('deathConfirm', true);
			FlxG.sound.music.stop();
			FlxG.sound.play(Paths.music('gameOverEnd' + stageSuffix));
			new FlxTimer().start(0.7, function(tmr:FlxTimer)
			{
				FlxG.camera.fade(FlxColor.BLACK, 2, false, function()
				{
					LoadingState.loadAndSwitchState(new PlayState());
				});
			});
		}
	}
}
