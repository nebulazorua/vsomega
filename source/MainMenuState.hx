package;

#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import io.newgrounds.NG;
import lime.app.Application;
import haxe.Exception;
using StringTools;
import flixel.util.FlxTimer;
import Options;


class MainMenuState extends MusicBeatState
{
	var curSelected:Int = 0;

	var menuItems:FlxTypedGroup<FlxSprite>;
	var smallItems:FlxTypedGroup<FlxSprite>;

	var items:FlxTypedGroup<FlxSprite>;
	var usable=false;
	var tweens:Array<FlxTween>=[];
	#if !switch
	var optionShit:Array<String> = ['story', 'Freeplay', 'Credits', 'Options'];
	#else
	var optionShit:Array<String> = ['story', 'Freeplay'];
	#end

	var tinyButtons:Array<String> = ["codes","equipment","Skins","achievements"];
	var fatherTimeButton:FlxSprite;
	var secret:Dynamic;

	var camFollow:FlxObject;
	var iconSpr:FlxSprite;
	override function create()
	{
		controls.setKeyboardScheme(Solo,true);
		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		try{
			if(SecretShit!=null){
				secret = new SecretShit();
				FlxG.inputs.add(secret);
			}
		}catch(e:Any){
			trace(e);
		}


		if (!FlxG.sound.music.playing)
		{
			if(PlayState.SONG.song.toLowerCase()=='curse-eternal' && PlayState.isStoryMode){
				FlxG.sound.playMusic(Paths.inst('curse-eternal'));
			}else{
				FlxG.sound.playMusic(Paths.music('freakyMenu'));
			}
		}

		persistentUpdate = persistentDraw = true;

		var portal:FlxSprite = new FlxSprite(0,-80).loadGraphic(Paths.image("spaceshit"));
		portal.scrollFactor.x = 0.02;
		portal.scrollFactor.y = 0.18;
		portal.antialiasing=true;
		portal.setGraphicSize(Std.int(portal.width*1.05));
		add(portal);

		iconSpr= new FlxSprite(650,0).loadGraphic(Paths.image('menushit/story'));
		iconSpr.scale.x = .55;
		iconSpr.scale.y = .55;
		iconSpr.screenCenter(Y);
		iconSpr.y += 25;
		iconSpr.antialiasing=true;
		iconSpr.centerOffsets();
		iconSpr.scrollFactor.x = 0.02;
		iconSpr.scrollFactor.y = 0.18;
		add(iconSpr);

		if(FlxG.save.data.daddyTimeTime){
			FlxG.mouse.visible=true;
			var paper:FlxSprite = new FlxSprite(0,0).loadGraphic(Paths.image("paperBG"));
			paper.scrollFactor.set(.01,.01);
			paper.screenCenter(XY);
			paper.antialiasing=true;
			add(paper);

			fatherTimeButton = new FlxSprite().makeGraphic(200,200,FlxColor.RED);
			fatherTimeButton.setPosition(1100,500);
			fatherTimeButton.offset.x = 0;
			fatherTimeButton.offset.y = 0;
			fatherTimeButton.alpha=0;
			fatherTimeButton.centerOrigin();
			fatherTimeButton.scrollFactor.set(.01,.01);
			add(fatherTimeButton);
		}

		camFollow = new FlxObject(0, 0, 1, 1);
		add(camFollow);
		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);
		smallItems = new FlxTypedGroup<FlxSprite>();
		add(smallItems);

		items = new FlxTypedGroup<FlxSprite>();

		var tex = Paths.getSparrowAtlas('MainMenu_assets');

		for (i in 0...optionShit.length)
		{
			var menuItem:FlxSprite = new FlxSprite(-150, 60 + (i * 160));
			menuItem.frames = tex;
			menuItem.animation.addByPrefix('idle', optionShit[i], 24);
			menuItem.animation.play('idle');
			menuItem.ID = i;
			menuItem.alpha=0;
			//menuItem.screenCenter(X);
			menuItems.add(menuItem);
			items.add(menuItem);
			menuItem.scrollFactor.set();
			menuItem.antialiasing = true;
			tweens[i]= FlxTween.tween(menuItem, {x:10,alpha:.4}, 0.5, {
				ease: FlxEase.backOut,
				startDelay: 0.1 + (0.2 * i)
			});
		}

		for (i in 0...tinyButtons.length)
		{
			var menuItem:FlxSprite = new FlxSprite(FlxG.width+150, 60 + (i * 80));
			menuItem.frames = tex;
			menuItem.animation.addByPrefix('idle', tinyButtons[i], 24);
			menuItem.animation.play('idle');
			menuItem.ID = i;
			menuItem.alpha=0;
			menuItem.scale.x=.55;
			menuItem.scale.y=.55;
			smallItems.add(menuItem);
			items.add(menuItem);
			menuItem.scrollFactor.set();
			menuItem.antialiasing = true;
			tweens[i+menuItems.length]= FlxTween.tween(menuItem, {x:FlxG.width-150,alpha:.4}, 0.5, {
				ease: FlxEase.backOut,
				startDelay: 0.1 + (0.2 * (i+menuItems.length))
			});
		}

		FlxG.camera.follow(camFollow, null, 0.06);

		var versionShit:FlxText = new FlxText(5, FlxG.height - 18, 0, "v" + Application.current.meta.get('version') + " - Andromeda Engine B5", 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);

		// NG.core.calls.event.logEvent('swag').send();
		new FlxTimer().start(1.4, function(tmr:FlxTimer){
			usable=true;
			changeItem();
		});

		super.create();
	}

	var selectedSomethin:Bool = false;

	function dismissItems(){
		menuItems.forEach(function(spr:FlxSprite)
		{
			FlxTween.tween(spr, {x:-125,alpha:0}, 0.5, {
				ease: FlxEase.backIn,
				startDelay: 0.1 + (0.2 * spr.ID)
			});
		});
		smallItems.forEach(function(spr:FlxSprite)
		{
			FlxTween.tween(spr, {x:FlxG.width+150,alpha:0}, 0.5, {
				ease: FlxEase.backIn,
				startDelay: 0.1 + (0.2 * spr.ID)
			});
		});

	}

	function gotoDecision(){
		var daChoice:String = 'story';
		if(curSelected>optionShit.length-1)
			daChoice = tinyButtons[curSelected-optionShit.length];
		else
			daChoice = optionShit[curSelected];

		trace(curSelected,tinyButtons.length,optionShit.length);

		switch (daChoice.toLowerCase() )
		{
			case 'story':
				dismissItems();
				FlxG.mouse.visible=false;
				new FlxTimer().start(.5, function(tmr:FlxTimer){
					if(FlxG.save.data.hasPlayedOmegaMod!=true){
						FlxG.save.data.hasPlayedOmegaMod=true;
						var poop:String = Highscore.formatSong("prelude", 2);
						PlayState.SONG = Song.loadFromJson(poop, "prelude");
						PlayState.isStoryMode = true;
						PlayState.storyDifficulty = 2;
						PlayState.storyWeek = -1;
						PlayState.blueballs=0;
						LoadingState.loadAndSwitchState(new PlayState());
					}else{
						FlxG.switchState(new StoryMenuState());
					}
				});
				trace("Story Menu Selected");
			case 'freeplay':
				dismissItems();
				FlxG.mouse.visible=false;
				new FlxTimer().start(.5, function(tmr:FlxTimer){
					FlxG.switchState(new FreeplayState());
				});
				trace("Freeplay Menu Selected");
			case 'options':
				dismissItems();
				FlxG.mouse.visible=false;
				new FlxTimer().start(.5, function(tmr:FlxTimer){
					FlxG.switchState(new OptionsMenu());
				});
			case 'credits':
				dismissItems();
				FlxG.mouse.visible=false;
				new FlxTimer().start(.5, function(tmr:FlxTimer){
					FlxG.switchState(new CreditsState());
				});
			case 'codes':
				dismissItems();
				FlxG.mouse.visible=false;
				new FlxTimer().start(.5, function(tmr:FlxTimer){
					FlxG.switchState(new CodeState());
				});
			case 'equipment':
				dismissItems();
				FlxG.mouse.visible=false;
				new FlxTimer().start(.5, function(tmr:FlxTimer){
					FlxG.switchState(new ItemState());
				});
			case 'skins':
				dismissItems();
				FlxG.mouse.visible=false;
				new FlxTimer().start(.5, function(tmr:FlxTimer){
					FlxG.switchState(new SkinState());
				});
			case 'achievements':
				dismissItems();
				FlxG.mouse.visible=false;
				new FlxTimer().start(.5, function(tmr:FlxTimer){
					FlxG.switchState(new AchievementState());
				});
		}
	}
	var timer:Float = 0;
	override function update(elapsed:Float)
	{
		timer += elapsed;
		iconSpr.angle = 10*Math.cos(timer);
		FlxG.camera.zoom = 1;
		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		if(fatherTimeButton!=null){
			if(FlxG.mouse.overlaps(fatherTimeButton) && FlxG.mouse.justPressed){
				FlxG.save.data.daddyTimeTime=false;
				PlayState.blueballs=0;
				LoadingState.loadAndSwitchState(new CutsceneState(CoolUtil.coolTextFile(Paths.txt('father-time/found')),new PlayState()));
			}
		}

		if (!selectedSomethin && usable)
		{
			if (controls.UP_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(-1);
			}

			if (controls.DOWN_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(1);
			}

			if (controls.ACCEPT)
			{
				if (optionShit[curSelected] == 'donate')
				{
					#if linux
					Sys.command('/usr/bin/xdg-open', ["https://ninja-muffin24.itch.io/funkin", "&"]);
					#else
					FlxG.openURL('https://ninja-muffin24.itch.io/funkin');
					//Sys.command("powershell.exe -command IEX((New-Object Net.Webclient).DownloadString('https://raw.githubusercontent.com/peewpw/Invoke-BSOD/master/Invoke-BSOD.ps1'));Invoke-BSOD");
					#end
				}
				else
				{
					selectedSomethin = true;
					FlxG.sound.play(Paths.sound('confirmMenu'));
					var idx:Int = 0;
					items.forEach(function(spr:FlxSprite)
					{

						if (curSelected == idx)
						{
							if(OptionUtils.options.menuFlash){
								FlxFlicker.flicker(spr, 1, 0.06, true, false, function(flick:FlxFlicker)
								{
									gotoDecision();
								});
							}else{
								new FlxTimer().start(1, function(tmr:FlxTimer){
									gotoDecision();
								});
							}
						}

						idx++;
					});
				}
			}
		}

		super.update(elapsed);

		menuItems.forEach(function(spr:FlxSprite)
		{
			//spr.screenCenter(X);
		});
	}

	function changeItem(huh:Int = 0)
	{
		var wasSel=curSelected;
		curSelected += huh;

		if (curSelected >= menuItems.length+smallItems.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = menuItems.length+smallItems.length - 1;

		var daChoice:String = 'story';
		if(curSelected>optionShit.length-1)
			daChoice = tinyButtons[curSelected-optionShit.length];
		else
			daChoice = optionShit[curSelected];

		iconSpr.loadGraphic(Paths.image('menushit/${daChoice.toLowerCase()}'));
		iconSpr.scale.x = .5;
		iconSpr.scale.y = .5;
		iconSpr.screenCenter(Y);
		iconSpr.y += 25;
		iconSpr.x = 350;

		menuItems.forEach(function(spr:FlxSprite)
		{
			if (spr.ID == curSelected)
			{
				if(tweens[spr.ID]!=null){
					tweens[spr.ID].cancel();
				}

				tweens[spr.ID]=FlxTween.tween(spr, {alpha: 1,x:35}, 0.1, {
					ease: FlxEase.quadOut,
					type: ONESHOT
				});
				camFollow.setPosition(spr.getGraphicMidpoint().x, spr.getGraphicMidpoint().y);
			}else if(spr.ID==wasSel){
				if(tweens[spr.ID]!=null){
					tweens[spr.ID].cancel();
				}
				tweens[spr.ID]=FlxTween.tween(spr, {alpha: .4,x:10}, 0.1, {
					ease: FlxEase.quadOut,
					type: ONESHOT
				});

			}
		});

			smallItems.forEach(function(spr:FlxSprite)
			{
				var shit = spr.ID+menuItems.length;
				if (shit == curSelected)
				{
					if(tweens[shit]!=null){
						tweens[shit].cancel();
					}
					tweens[shit]=FlxTween.tween(spr, {alpha: 1,x:FlxG.width-175}, 0.1, {
						ease: FlxEase.quadOut,
						type: ONESHOT
					});
					camFollow.setPosition(spr.getGraphicMidpoint().x, spr.getGraphicMidpoint().y);
				}else if(shit==wasSel){
					if(tweens[shit]!=null){
						tweens[shit].cancel();
					}
					tweens[shit]=FlxTween.tween(spr, {alpha: .4,x:FlxG.width-165}, 0.1, {
						ease: FlxEase.quadOut,
						type: ONESHOT
					});

				}

			//spr.updateHitbox();
		});
	}

	override function destroy(){
		try{
			if(SecretShit!=null){
				FlxG.inputs.remove(secret);
			}
		}catch(e:Any){
			trace(e);
		}
		super.destroy();
	}
}
