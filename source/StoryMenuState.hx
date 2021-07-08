package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.net.curl.CURLCode;
import flixel.group.FlxSpriteGroup;
#if desktop
import Discord.DiscordClient;
#end

using StringTools;

class StoryMenuState extends MusicBeatState
{
	var scoreText:FlxText;
	public static var cameos = [
		"New-Retro", // Kapi
		"57.5hz", // Demi
		"Free-Soul", // Merch
		"No-Arm-Shogun", // Flexy
		"Fragmented-Surreality", // Noke
		"Oxidation" // Anders
	];
	public static var cameoCharacters = [
		"kapi",
		"demetrios",
		"merchant",
		"flexy",
		"noke",
		"anders"
	];

	var encounterableCameos=[];
	public var baseCameoChance:Int = 10;
	public static var cameoAttempts:Int = 0;
	var weekData:Array<Dynamic> = [
		['Prelude'],
		['Bopeebo', 'Fresh', 'Dadbattle'],
		['Spookeez', 'South', "Salem"],
		['Pico', 'Philly-Nice', "Blammed"],
		['Satin-Panties', "High", "Milf"],
		['Cocoa', 'Eggnog', 'Monster', 'Winter-Horrorland'],
		['Senpai', 'Roses', 'Thorns'],
		['Mercenary','Odd-Job','Guardian']
	];
	var curDifficulty:Int = 1;

	public static var weekUnlocked:Array<Bool> = [true, true, true, true, true, true, true, true, true];

	var weekCharacters:Array<String> = [
		'gf',
		'dad',
		'spooky',
		'pico',
		'mom',
		'parents-christmas',
		'senpai',
		'omega'
	];

	var weekNames:Array<String> = [
		"Back to Basics",
		"In His Prime",
		"Town of Salem",
		"Trench Warfare",
		"Trainjacking",
		"Holiday Hoedown",
		"Nostalgia Trip",
		"Times & Tribulations"
	];

	var txtWeekTitle:FlxText;

	var curWeek:Int = 0;

	var txtTracklist:FlxText;

	var grpWeekText:FlxTypedGroup<OMenuItem>;
	var grpWeekCharacters:FlxTypedGroup<Character>;

	var grpLocks:FlxTypedGroup<FlxSprite>;
	var curCharacter:Character;

	var difficultySelectors:FlxGroup;
	var sprDifficulty:FlxSprite;
	var leftArrow:FlxSprite;
	var rightArrow:FlxSprite;

	override function create()
	{
		if(FlxG.save.data.omegaGoodEnding || FlxG.save.data.omegaBadEnding){ // beaten omega
			baseCameoChance=50;
		}

		if(FlxG.save.data.cameos!=null){
			var sex:Array<String> = FlxG.save.data.cameos;
			var cringe:Array<String>=[];
			if(!FlxG.save.data.cameos.contains("Oxidation")){
				for(c in cameos){
					if(!sex.contains(c)){
						cringe.push(c);
					}
				}
			}else{
				cringe=cameos;
			}
			encounterableCameos=cringe;
			encounterableCameos.remove("Oxidation");
			if(encounterableCameos.length==0 || FlxG.save.data.cameos.contains("Oxidation")){
				encounterableCameos.push("Oxidation");
			}
		}

		if(FlxG.save.data.cameos.contains("Oxidation") && encounterableCameos.length>1){
			baseCameoChance=5;
		}

		if (FlxG.sound.music != null)
		{
			if (!FlxG.sound.music.playing)
				FlxG.sound.playMusic(Paths.music('freakyMenu'));
		}

		#if desktop
		DiscordClient.changePresence("Story Mode", null);
		#end

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		if (FlxG.sound.music != null)
		{
			if (!FlxG.sound.music.playing)
				FlxG.sound.playMusic(Paths.music('freakyMenu'));
		}

		persistentUpdate = persistentDraw = true;

		scoreText = new FlxText(10, 10, 0, "SCORE: 49324858", 32);
		scoreText.setFormat("VCR OSD Mono", 36, FlxColor.WHITE, CENTER, SHADOW,FlxColor.BLACK);
		scoreText.shadowOffset.set(2,2);
		scoreText.screenCenter(XY);
		scoreText.y -= 200;

		txtWeekTitle = new FlxText(0, 0, 0, "", 32);
		txtWeekTitle.setFormat("VCR OSD Mono", 42, FlxColor.WHITE, CENTER, SHADOW,FlxColor.BLACK);
		txtWeekTitle.shadowOffset.set(2,2);
		txtWeekTitle.alpha = 1;
		txtWeekTitle.screenCenter(XY);
		txtWeekTitle.y -= 250;

		var ui_tex = Paths.getSparrowAtlas('campaign_menu_UI_assets');
		//var yellowBG:FlxSprite = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, 0xFF2446B5);
		var portal:FlxSprite = new FlxSprite(0,0).loadGraphic(Paths.image("spaceshit"));
		portal.antialiasing=true;
		portal.screenCenter(XY);

		var cameoShit:FlxSpriteGroup = new FlxSpriteGroup();

		var cameoCard:FlxSprite = new FlxSprite(0,0).loadGraphic(Paths.image("cameoshit/postit"));
		cameoCard.antialiasing=true;
		cameoCard.screenCenter(XY);
		add(cameoCard);


		var deme:FlxSprite = new FlxSprite(0,0).loadGraphic(Paths.image("cameoshit/dog"));
		deme.antialiasing=true;
		deme.screenCenter(XY);

		var femboy:FlxSprite = new FlxSprite(0,0).loadGraphic(Paths.image("cameoshit/femboy"));
		femboy.antialiasing=true;
		femboy.screenCenter(XY);

		var vase:FlxSprite = new FlxSprite(0,0).loadGraphic(Paths.image("cameoshit/intense_fingering"));
		vase.antialiasing=true;
		vase.screenCenter(XY);

		var kong:FlxSprite = new FlxSprite(0,0).loadGraphic(Paths.image("cameoshit/kong"));
		kong.antialiasing=true;
		kong.screenCenter(XY);

		var marcant:FlxSprite = new FlxSprite(0,0).loadGraphic(Paths.image("cameoshit/marcant"));
		marcant.antialiasing=true;
		marcant.screenCenter(XY);

		var noker:FlxSprite = new FlxSprite(0,0).loadGraphic(Paths.image("cameoshit/noker"));
		noker.antialiasing=true;
		noker.screenCenter(XY);

		var flecky:FlxSprite = new FlxSprite(0,0).loadGraphic(Paths.image("cameoshit/friend_ouo"));
		flecky.antialiasing=true;
		flecky.screenCenter(XY);

		var andrs:FlxSprite = new FlxSprite(0,0).loadGraphic(Paths.image("cameoshit/fat_bitch_andy_from_toy_story"));
		andrs.antialiasing=true;
		andrs.screenCenter(XY);

		grpWeekText = new FlxTypedGroup<OMenuItem>();

		grpWeekCharacters = new FlxTypedGroup<Character>();

		grpLocks = new FlxTypedGroup<FlxSprite>();
		add(grpLocks);

		trace("Line 70");

		for (i in 0...weekData.length)
		{
			var weekThing:OMenuItem = new OMenuItem(0, 0, "Week"+(i==7?"Omega":Std.string(i)) );
			weekThing.targetY = i;
			grpWeekText.add(weekThing);

			weekThing.daX = 150;
			weekThing.antialiasing = true;
		}

		for (char in 0...weekCharacters.length)
		{
			var character = weekCharacters[char];
			var weekCharacterThing:Character = new Character(0, 0, character);
			weekCharacterThing.alpha = 0;
			weekCharacterThing.screenCenter(XY);
			weekCharacterThing.y -= 25;
			weekCharacterThing.x += 300;
			weekCharacterThing.setGraphicSize(Std.int(weekCharacterThing.width*.5));
			switch(character){
				case 'senpai':
					weekCharacterThing.y += 275;
					weekCharacterThing.x += 250;
					weekCharacterThing.setGraphicSize(Std.int(weekCharacterThing.width*.6));
				case 'gf':
					weekCharacterThing.x += 105;
				case 'dad':
					weekCharacterThing.x += 100;
					weekCharacterThing.y -= 0;
					weekCharacterThing.flipX = true;
				case 'omega':
					weekCharacterThing.setGraphicSize(Std.int(weekCharacterThing.width*.35));
					weekCharacterThing.y -= 60;
					weekCharacterThing.x += 250;
					weekCharacterThing.flipX = true;
				case 'pico':
					weekCharacterThing.setGraphicSize(Std.int(weekCharacterThing.width*.4));
					weekCharacterThing.y += 50;
					weekCharacterThing.x += 175;
					weekCharacterThing.flipX = false;
				case 'spooky':
					weekCharacterThing.x += 100;
					weekCharacterThing.y += 50;
				case 'parents-christmas':
					weekCharacterThing.x += 100;
					weekCharacterThing.y -= 10;
					weekCharacterThing.flipX = true;
				case 'mom':
					weekCharacterThing.x += 125;
					weekCharacterThing.y -= 125;
					weekCharacterThing.flipX = true;

			}
			grpWeekCharacters.add(weekCharacterThing);
		}


		difficultySelectors = new FlxGroup();

		trace("Line 124");

		leftArrow = new FlxSprite(0,0);
		leftArrow.screenCenter(XY);
		leftArrow.x += 200;
		leftArrow.y += 150;
		leftArrow.frames = ui_tex;
		leftArrow.animation.addByPrefix('idle', "arrow left");
		leftArrow.animation.addByPrefix('press', "arrow push left");
		leftArrow.animation.play('idle');
		difficultySelectors.add(leftArrow);

		sprDifficulty = new FlxSprite(leftArrow.x + 130, leftArrow.y);
		sprDifficulty.frames = ui_tex;
		sprDifficulty.animation.addByPrefix('easy', 'EASY');
		sprDifficulty.animation.addByPrefix('normal', 'NORMAL');
		sprDifficulty.animation.addByPrefix('hard', 'HARD');
		sprDifficulty.animation.addByPrefix('glitch', 'GLITCH Alt');
		sprDifficulty.animation.play('easy');
		changeDifficulty();

		var difficultyBG = new FlxSprite().loadGraphic(Paths.image("DifficultyBar"));
		difficultyBG.x = leftArrow.x + 52;
		difficultyBG.y = leftArrow.y + 7;
		difficultyBG.setGraphicSize(Std.int(difficultyBG.width*1.05));


		difficultySelectors.add(sprDifficulty);

		rightArrow = new FlxSprite(sprDifficulty.x + sprDifficulty.width + 50, leftArrow.y);
		rightArrow.frames = ui_tex;
		rightArrow.animation.addByPrefix('idle', 'arrow right');
		rightArrow.animation.addByPrefix('press', "arrow push right", 24, false);
		rightArrow.animation.play('idle');
		difficultySelectors.add(rightArrow);

		trace("Line 150");

		//add(yellowBG);
		add(portal);
		cameoShit.add(cameoCard);
		cameoShit.add(andrs);
		cameoShit.add(noker);
		cameoShit.add(femboy);
		cameoShit.add(flecky);
		cameoShit.add(deme);
		cameoShit.add(kong);
		cameoShit.add(vase);
		cameoShit.add(marcant);


		var cumfart = ["Oxidation","Fragmented-Surreality","New-Retro","No-Arm-Shogun","57.5hz","Free-Soul","Dishonor","Hivemind"];
		var shit:Array<FlxSprite> = [andrs,noker,femboy,flecky,deme,marcant,kong,vase];
		for(idx in 0...cumfart.length){
			var song = cumfart[idx];
			if(FlxG.save.data.cameos.contains(song) || FlxG.save.data.unlockedOmegaSongs.contains(song.toLowerCase())) {
				shit[idx].visible=true;
			}else{
				shit[idx].visible=false;
			}
		}

		cameoShit.y += 175;
		cameoShit.x += 10;

		add(cameoShit);



		add(grpWeekText);
		add(grpWeekCharacters);
		add(difficultyBG);
		add(difficultySelectors);

		txtTracklist = new FlxText(0, 0, 0, "Tracks", 32);
		txtTracklist.alignment = CENTER;
		txtTracklist.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, CENTER,SHADOW,FlxColor.BLACK);
		txtTracklist.shadowOffset.set(2,2);
		txtTracklist.color = 0xFFe55777;
		txtTracklist.screenCenter(XY);
		txtTracklist.y -= 150;
		add(txtTracklist);


		// add(rankText);
		add(scoreText);
		add(txtWeekTitle);

		updateText();

		trace("Line 165");

		super.create();
		Conductor.changeBPM(102);
		Conductor.songPosition = FlxG.sound.music.time;
		changeWeek();
		AchievementState.doUnlock();
	}
	override function beatHit(){
		super.beatHit();

		for(item in grpWeekCharacters)
			item.dance();
	}

	override function update(elapsed:Float)
	{
		Conductor.songPosition += FlxG.elapsed * 1000;
		// scoreText.setFormat('VCR OSD Mono', 32);
		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, 0.5));

		scoreText.text = "WEEK SCORE:" + lerpScore;
		scoreText.screenCenter(X);
		txtWeekTitle.text = weekNames[curWeek].toUpperCase();
		txtWeekTitle.screenCenter(X);

		difficultySelectors.visible = weekUnlocked[curWeek];

		grpLocks.forEach(function(lock:FlxSprite)
		{
			lock.y = grpWeekText.members[lock.ID].y;
		});

		if (!movedBack)
		{
			if (!selectedWeek)
			{
				if (controls.UP_P)
				{
					changeWeek(-1);
				}

				if (controls.DOWN_P)
				{
					changeWeek(1);
				}

				if (controls.RIGHT)
					rightArrow.animation.play('press')
				else
					rightArrow.animation.play('idle');

				if (controls.LEFT)
					leftArrow.animation.play('press');
				else
					leftArrow.animation.play('idle');

				if (controls.RIGHT_P)
					changeDifficulty(1);
				if (controls.LEFT_P)
					changeDifficulty(-1);
			}

			if (controls.ACCEPT)
			{
				selectWeek();
			}
		}

		if (controls.BACK && !movedBack && !selectedWeek)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			movedBack = true;
			FlxG.switchState(new MainMenuState());
		}

		super.update(elapsed);
	}

	var movedBack:Bool = false;
	var selectedWeek:Bool = false;
	var stopspamming:Bool = false;

	function selectWeek()
	{
		if (weekUnlocked[curWeek])
		{
			if (stopspamming == false)
			{
				FlxG.sound.play(Paths.sound('confirmMenu'));

				grpWeekText.members[curWeek].startFlashing();
				stopspamming = true;
			}
			//if(curCharacter.curCharacter=='gf')
			//	curCharacter.playAnim("cheer",true);

			//if(curCharacter.curCharacter=='bf')
			//	curCharacter.playAnim("hey",true);
			PlayState.storyPlaylist = weekData[curWeek];
			trace(curWeek,weekData[curWeek]);
			var hasCameo=false;
			if(FlxG.random.bool(baseCameoChance+(cameoAttempts*10)) || cameoAttempts>5 && !FlxG.save.data.hasGottenACameo){
				FlxG.save.data.hasGottenACameo=true;
				cameoAttempts=0;
				var cameo = encounterableCameos[FlxG.random.int(0,encounterableCameos.length-1)];
				trace(cameo);
				if(FlxG.save.data.cameos==null){
					FlxG.save.data.cameos=[];
				}
				FlxG.save.data.cameos.push(cameo);
				PlayState.storyPlaylist.insert(0,cameo);
				hasCameo=true;
			}else if(FlxG.save.data.hasGottenACameo!=true){
				cameoAttempts++;
			};
			PlayState.isStoryMode = true;
			selectedWeek = true;


			var diffic = "";

			switch (curDifficulty)
			{
				case 0:
					diffic = '-easy';
				case 2:
					diffic = '-hard';
				case 3:
					diffic = '-glitch';
			}

			PlayState.storyDifficulty = curDifficulty;

			PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + diffic, PlayState.storyPlaylist[0].toLowerCase());
			if(curWeek==0 || curWeek==7){
				PlayState.storyWeek = -1;
			}else{
				PlayState.storyWeek = curWeek;
			}
			PlayState.blueballs=0;
			PlayState.campaignScore = 0;
			new FlxTimer().start(1, function(tmr:FlxTimer)
			{
				if(curWeek==7 && !hasCameo){
					if(FlxG.save.data.unlockedOmegaSongs.contains("guardian"))
						LoadingState.loadAndSwitchState(new CutsceneState(CoolUtil.coolTextFile(Paths.txt('mercenary/playedbefore')),new PlayState()));
					else
						LoadingState.loadAndSwitchState(new CutsceneState(CoolUtil.coolTextFile(Paths.txt('mercenary/pre')),new PlayState()));

				}else{
					LoadingState.loadAndSwitchState(new PlayState(), true);
				}
			});
		}
	}

	function changeDifficulty(change:Int = 0):Void
	{
		curDifficulty += change;

		var max = 2;
		if(FlxG.save.data.canGlitch) max=3;
		if (curDifficulty < 0)
			curDifficulty = max;
		if (curDifficulty > max)
			curDifficulty = 0;

		sprDifficulty.offset.x = 0;

		switch (curDifficulty)
		{
			case 0:
				sprDifficulty.animation.play('easy');
				sprDifficulty.offset.x = 20;
			case 1:
				sprDifficulty.animation.play('normal');
				sprDifficulty.offset.x = 70;
			case 2:
				sprDifficulty.animation.play('hard');
				sprDifficulty.offset.x = 20;
			case 3:
				sprDifficulty.animation.play('glitch');
				sprDifficulty.offset.x += 100;
				sprDifficulty.offset.y += 40;
		}

		sprDifficulty.alpha = 0;

		// USING THESE WEIRD VALUES SO THAT IT DOESNT FLOAT UP
		sprDifficulty.y = leftArrow.y - 15;
		intendedScore = Highscore.getWeekScore(curWeek, curDifficulty);

		#if !switch
		intendedScore = Highscore.getWeekScore(curWeek, curDifficulty);
		#end

		FlxTween.tween(sprDifficulty, {y: leftArrow.y + 15, alpha: 1}, 0.07);
	}

	var lerpScore:Int = 0;
	var intendedScore:Int = 0;

	function changeWeek(change:Int = 0):Void
	{
		curWeek += change;

		if (curWeek >= weekData.length)
			curWeek = 0;
		if (curWeek < 0)
			curWeek = weekData.length - 1;

		var bullShit:Int = 0;

		for (i in 0...grpWeekText.length)
		{
			var item = grpWeekText.members[i];
			item.targetY = bullShit - curWeek;
			item.targetX = bullShit - curWeek;
			if(bullShit>curWeek)
				item.targetX -= item.targetX*2;



			if (item.targetY == Std.int(0) && weekUnlocked[curWeek])
				item.alpha = 1;
			else
				item.alpha = 0.6;

			if(item.targetY==Std.int(0)){
				grpWeekCharacters.members[i].alpha = 1;
				curCharacter=grpWeekCharacters.members[i];
			}
			else
				grpWeekCharacters.members[i].alpha = 0;

			bullShit++;
		}

		if(curWeek>=6){
			grpWeekText.members[0].targetX = grpWeekText.members[7].targetX-1;
			grpWeekText.members[0].targetY = grpWeekText.members[7].targetY+1;
			grpWeekText.members[1].targetX = grpWeekText.members[7].targetX-2;
			grpWeekText.members[1].targetY = grpWeekText.members[7].targetY+2;



		}else if (curWeek<=2){
			grpWeekText.members[6].targetX = grpWeekText.members[0].targetX-2;
			grpWeekText.members[6].targetY = grpWeekText.members[0].targetY-2;
			grpWeekText.members[7].targetX = grpWeekText.members[0].targetX-1;
			grpWeekText.members[7].targetY = grpWeekText.members[0].targetY-1;

		}
		FlxG.sound.play(Paths.sound('scrollMenu'));

		updateText();
	}

	function updateText()
	{
		var stringThing:Array<String> = weekData[curWeek];
		txtTracklist.text = "Tracks\n";
		for (i in stringThing)
		{
			trace(i);
			txtTracklist.text += i + "\n";
		}

		txtTracklist.text = txtTracklist.text.toUpperCase();

		txtTracklist.screenCenter(X);

		#if !switch
		intendedScore = Highscore.getWeekScore(curWeek, curDifficulty);
		#end
	}
}
