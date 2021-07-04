package;

#if desktop
import Discord.DiscordClient;
import sys.thread.Thread;
#end
import Options;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup;
import flixel.input.gamepad.FlxGamepad;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.system.ui.FlxSoundTray;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import io.newgrounds.NG;
import lime.app.Application;
import flixel.FlxCamera;
import openfl.Assets;
import sys.FileSystem;

using StringTools;

class TitleState extends MusicBeatState
{
	static var initialized:Bool = false;
	static var playedCutscene:Bool=false;
	var blackScreen:FlxSprite;
	var credGroup:FlxGroup;
	var credTextShit:Alphabet;
	var textGroup:FlxGroup;
	var ngSpr:FlxSprite;

	var curWacky:Array<String> = [];

	var wackyImage:FlxSprite;

	function setSave(){
		if(FlxG.save.data.finishedSongs==null)
			FlxG.save.data.finishedSongs=[];

		if(FlxG.save.data.perfectedSongs==null)
			FlxG.save.data.perfectedSongs=[];

		if(FlxG.save.data.flashySongs==null)
			FlxG.save.data.flashySongs=[];

		if(FlxG.save.data.unlockedOmegaSongs==null)
			FlxG.save.data.unlockedOmegaSongs=[];

		if(FlxG.save.data.unlocked==null)
			FlxG.save.data.unlocked=[];

		if(FlxG.save.data.cameos==null)
			FlxG.save.data.cameos=[];

		if(FlxG.save.data.unlockedSkins==null)
			FlxG.save.data.unlockedSkins=[];

		if(FlxG.save.data.equipped==null)
			FlxG.save.data.equipped=[];

		if(FlxG.save.data.selectedSkin==null)
			FlxG.save.data.selectedSkin='bf';


		SkinState.selectedSkin=FlxG.save.data.selectedSkin;
	}
	override public function create():Void
	{
		super.create();
		new FlxTimer().start(1, function(tmr:FlxTimer) {
			FlxG.mouse.visible = false;
			setSave();
			if(initialized){
				#if FREEPLAY
				FlxG.switchState(new FreeplayState());
				#elseif CHARTING
				FlxG.switchState(new ChartingState());
				#else
				startIntro();
				#end
			}else{

				#if polymod
				polymod.Polymod.init({modRoot: "mods", dirs: ['introMod']});
				#end
				OptionUtils.bindSave();
				OptionUtils.loadOptions(OptionUtils.options);


				PlayerSettings.init();
				FlxG.bitmap.add(Paths.getPreloadPath('images/MainMenuShit.png'));
				FlxG.bitmap.add(Paths.getPreloadPath('images/FNF_main_menu_assets.png'));
				FlxG.bitmap.add(Paths.getPreloadPath('images/spaceshit.png'));
				/*for(file in FileSystem.readDirectory(FileSystem.absolutePath("assets/shared/images/characters"))){
					if(file.endsWith('.png'))
						FlxG.bitmap.add(Paths.image("characters/" + file.replace(".png",""),"shared"));
				}*/
				// TODO: MAKE THIS IN A LOADING SCREEN!!!

				// DEBUG BULLSHIT
				if (!initialized)
				{
					var diamond:FlxGraphic = FlxGraphic.fromClass(GraphicTransTileDiamond);
					diamond.persist = true;
					diamond.destroyOnNoUse = false;

					FlxTransitionableState.defaultTransIn = new TransitionData(FADE, FlxColor.BLACK, 1, new FlxPoint(0, -1), {asset: diamond, width: 32, height: 32},
						new FlxRect(-200, -200, FlxG.width * 1.4, FlxG.height * 1.4));
					FlxTransitionableState.defaultTransOut = new TransitionData(FADE, FlxColor.BLACK, 0.7, new FlxPoint(0, 1),
						{asset: diamond, width: 32, height: 32}, new FlxRect(-200, -200, FlxG.width * 1.4, FlxG.height * 1.4));

					transIn = FlxTransitionableState.defaultTransIn;
					transOut = FlxTransitionableState.defaultTransOut;

					initialized = true;
				}

				/*NGio.noLogin(APIStuff.API);

				#if ng
				var ng:NGio = new NGio(APIStuff.API, APIStuff.EncKey);
				trace('NEWGROUNDS LOL');
				#end*/

				FlxG.save.bind('funkin', 'ninjamuffin99');
				setSave();
				Highscore.load();

				AchievementState.checkUnlocks();

				if (FlxG.save.data.weekUnlocked != null)
				{
					// FIX LATER!!!
					// WEEK UNLOCK PROGRESSION!!
					// StoryMenuState.weekUnlocked = FlxG.save.data.weekUnlocked;

					if (StoryMenuState.weekUnlocked.length < 4)
						StoryMenuState.weekUnlocked.insert(0, true);

					// QUICK PATCH OOPS!
					if (!StoryMenuState.weekUnlocked[0])
						StoryMenuState.weekUnlocked[0] = true;
				}

				#if FREEPLAY
				FlxG.switchState(new FreeplayState());
				#elseif CHARTING
				FlxG.switchState(new ChartingState());
				#else
				startIntro();
				#end

				#if desktop
				DiscordClient.initialize();

				Application.current.onExit.add (function (exitCode) {
					DiscordClient.shutdown();
				 });
				#end
			}
		});
	}

		var logoBl:FlxSprite;
		var danceLeft:Bool = false;
		var titleText:FlxSprite;

		function startIntro()
		{
			if(FlxG.save.data.seenOmegaIntro!=true && !playedCutscene){
				playedCutscene=true;
				FlxG.save.data.seenOmegaIntro=true;
				FlxTransitionableState.skipNextTransIn = true;
				FlxG.switchState(new CutsceneState(CoolUtil.coolTextFile(Paths.txt('introCutscene')),new TitleState(),true));
				return;
			}
			curWacky = FlxG.random.getObject(getIntroTextShit());

			FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);
			FlxG.sound.music.fadeIn(4, 0, 0.7);

			Conductor.changeBPM(102);
			persistentUpdate = true;

			var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
			// bg.antialiasing = true;
			// bg.setGraphicSize(Std.int(bg.width * 0.6));
			// bg.updateHitbox();
			add(bg);

			logoBl = new FlxSprite(-125, -75);
			logoBl.frames = Paths.getSparrowAtlas('logoBumpin');
			logoBl.antialiasing = true;
			logoBl.animation.addByPrefix('bump', 'logo bumpin', 24);
			logoBl.setGraphicSize(Std.int(logoBl.width*.8));
			logoBl.animation.play('bump');
			logoBl.centerOffsets();
			logoBl.updateHitbox();
			// logoBl.screenCenter();
			// logoBl.color = FlxColor.BLACK;
			var portal:FlxSprite = new FlxSprite(0,-80).loadGraphic(Paths.image("spaceshit"));
			portal.antialiasing=true;
			add(portal);
			var noGravityFuckYou:FlxSprite = new FlxSprite(FlxG.width * 0.4, FlxG.height * 0.07);
			noGravityFuckYou.frames = Paths.getSparrowAtlas("MainMenuShit");
			noGravityFuckYou.animation.addByPrefix("idle","TitleCard_loop",16);
			noGravityFuckYou.setGraphicSize(Std.int(noGravityFuckYou.width*.5));
			noGravityFuckYou.antialiasing=true;
			noGravityFuckYou.animation.play("idle");
			noGravityFuckYou.updateHitbox();
			add(noGravityFuckYou);

			add(logoBl);

			titleText = new FlxSprite(100, FlxG.height * 0.8);
			titleText.frames = Paths.getSparrowAtlas('titleEnter');
			titleText.animation.addByPrefix('idle', "Press Enter to Begin", 24);
			titleText.animation.addByPrefix('press', "ENTER PRESSED", 24);
			titleText.antialiasing = true;
			titleText.animation.play('idle');
			titleText.updateHitbox();
			// titleText.screenCenter(X);
			add(titleText);

			var logo:FlxSprite = new FlxSprite().loadGraphic(Paths.image('logo'));
			logo.screenCenter();
			logo.antialiasing = true;
			// add(logo);

			// FlxTween.tween(logoBl, {y: logoBl.y + 50}, 0.6, {ease: FlxEase.quadInOut, type: PINGPONG});
			// FlxTween.tween(logo, {y: logoBl.y + 50}, 0.6, {ease: FlxEase.quadInOut, type: PINGPONG, startDelay: 0.1});

			credGroup = new FlxGroup();
			add(credGroup);
			textGroup = new FlxGroup();

			blackScreen = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
			credGroup.add(blackScreen);

			credTextShit = new Alphabet(0, 0, "ninjamuffin99\nPhantomArcade\nkawaisprite\nevilsk8er", true);
			credTextShit.screenCenter();

			// credTextShit.alignment = CENTER;

			credTextShit.visible = false;

			ngSpr = new FlxSprite(0, FlxG.height * 0.52).loadGraphic(Paths.image('newgrounds_logo'));
			add(ngSpr);
			ngSpr.visible = false;
			ngSpr.setGraphicSize(Std.int(ngSpr.width * 0.8));
			ngSpr.updateHitbox();
			ngSpr.screenCenter(X);
			ngSpr.antialiasing = true;

			FlxTween.tween(credTextShit, {y: credTextShit.y + 20}, 2.9, {ease: FlxEase.quadInOut, type: PINGPONG});
			createCoolText(['The']);
			// credGroup.add(credTextShit);
	}

	function getIntroTextShit():Array<Array<String>>
	{
		var fullText:String = Assets.getText(Paths.txt('introText'));

		var firstArray:Array<String> = fullText.split('\n');
		var swagGoodArray:Array<Array<String>> = [];

		for (i in firstArray)
		{
			swagGoodArray.push(i.split('--'));
		}

		return swagGoodArray;
	}

	var transitioning:Bool = false;
	var timer:Float=0;
	override function update(elapsed:Float)
	{
		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;
		// FlxG.watch.addQuick('amp', FlxG.sound.music.amplitude);

		if (FlxG.keys.justPressed.F)
		{
			FlxG.fullscreen = !FlxG.fullscreen;
		}

		var pressedEnter:Bool = FlxG.keys.justPressed.ENTER;

		#if mobile
		for (touch in FlxG.touches.list)
		{
			if (touch.justPressed)
			{
				pressedEnter = true;
			}
		}
		#end

		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

		if (gamepad != null)
		{
			if (gamepad.justPressed.START)
				pressedEnter = true;

			#if switch
			if (gamepad.justPressed.B)
				pressedEnter = true;
			#end
		}

		if (pressedEnter && !transitioning && skippedIntro)
		{
			#if !switch
			//NGio.unlockMedal(60960);

			// If it's Friday according to da clock
			if (Date.now().getDay() == 5)
				//NGio.unlockMedal(61034);
			#end

			titleText.animation.play('press',true);

			FlxG.camera.flash(FlxColor.WHITE, 1);
			FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);

			transitioning = true;
			// FlxG.sound.music.stop();

			new FlxTimer().start(2, function(tmr:FlxTimer)
			{
				FlxG.switchState(new MainMenuState());
			});
			// FlxG.sound.play(Paths.music('titleShoot'), 0.7);
		}

		if (pressedEnter && !skippedIntro)
		{
			skipIntro();
		}

		super.update(elapsed);
	}

	function createCoolText(textArray:Array<String>)
	{
		for (i in 0...textArray.length)
		{
			var money:Alphabet = new Alphabet(0, 0, textArray[i], true, false);
			money.screenCenter(X);
			money.y += (i * 60) + 200;
			credGroup.add(money);
			textGroup.add(money);
		}
	}

	function addMoreText(text:String)
	{
		var coolText:Alphabet = new Alphabet(0, 0, text, true, false);
		coolText.screenCenter(X);
		coolText.y += (textGroup.length * 60) + 200;
		credGroup.add(coolText);
		textGroup.add(coolText);
	}

	function deleteCoolText()
	{
		while (textGroup.members.length > 0)
		{
			credGroup.remove(textGroup.members[0], true);
			textGroup.remove(textGroup.members[0], true);
		}
	}

	override function beatHit()
	{
		super.beatHit();
		if(logoBl!=null)
			logoBl.animation.play('bump');

		FlxG.log.add(curBeat);

		switch (curBeat)
		{
			case 1:

			case 3:
				addMoreText('omega');
			case 4:

			case 5:
				addMoreText('team');

			case 7:
				addMoreText('present');
			case 8:
				deleteCoolText();
			case 9:

				createCoolText([curWacky[0]]);

			case 11:
				addMoreText(curWacky[1]);

			case 12:
				deleteCoolText();
				addMoreText('Times');


			case 13:
				addMoreText('and');

			// credTextShit.visible = true;
			case 14:
				addMoreText('Tribulations');

			// credTextShit.text += '\nNight';
			case 15:
				addMoreText('VS Omega');

				 // credTextShit.text += '\nFunkin';

			case 16:
				skipIntro();

		}
	}

	var skippedIntro:Bool = false;

	function skipIntro():Void
	{
		if (!skippedIntro)
		{
			remove(ngSpr);

			FlxG.camera.flash(FlxColor.WHITE, 4);
			remove(credGroup);
			skippedIntro = true;
		}
	}
}
