package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.text.FlxTypeText;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxSpriteGroup;
import flixel.input.FlxKeyManager;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

using StringTools;

class DialogueBox extends FlxSpriteGroup
{
	var box:FlxSprite;

	var curCharacter:String = '';

	var dialogue:Alphabet;
	var dialogueList:Array<String> = [];

	// SECOND DIALOGUE FOR THE PIXEL SHIT INSTEAD???
	var swagDialogue:FlxTypeText;
	var wantedText:String = '';
	var dropText:FlxText;
	var finishedTyping:Bool=false;

	public var finishThing:Void->Void;

	var portraitLeft:FlxSprite;
	var portraitRight:FlxSprite;

	var handSelect:FlxSprite;
	var bgFade:FlxSprite;

	public function new(talkingRight:Bool = true, ?dialogueList:Array<String>)
	{
		super();

		switch (PlayState.SONG.song.toLowerCase())
		{
			case 'senpai':
				FlxG.sound.playMusic(Paths.music('Lunchbox'), 0);
				FlxG.sound.music.fadeIn(1, 0, 0.8);
			case 'thorns':
				FlxG.sound.playMusic(Paths.music('LunchboxScary'), 0);
				FlxG.sound.music.fadeIn(1, 0, 0.8);
		}

		bgFade = new FlxSprite(-200, -200).makeGraphic(Std.int(FlxG.width * 3), Std.int(FlxG.height * 3), 0xFFB3DFd8);
		bgFade.scrollFactor.set();
		bgFade.alpha = 0;
		add(bgFade);

		if(PlayState.curStage.startsWith("school")){
			new FlxTimer().start(0.83, function(tmr:FlxTimer)
			{
				bgFade.alpha += (1 / 5) * 0.7;
				if (bgFade.alpha > 0.7)
					bgFade.alpha = 0.7;
			}, 5);
		}else{
			FlxTween.tween(bgFade, {alpha:0.7}, 1, {
				startDelay:.83,
				ease:FlxEase.quadInOut
			});
		}


		box = new FlxSprite(-20, 45);
		var hasDialog = false;
		switch (PlayState.SONG.song.toLowerCase())
		{
			case 'senpai':
				hasDialog = true;
				box.frames = Paths.getSparrowAtlas('weeb/pixelUI/dialogueBox-pixel');
				box.animation.addByPrefix('normalOpen', 'Text Box Appear', 24, false);
				box.animation.addByIndices('normal', 'Text Box Appear', [4], "", 24);
			case 'roses':
				hasDialog = true;
				FlxG.sound.play(Paths.sound('ANGRY_TEXT_BOX'));

				box.frames = Paths.getSparrowAtlas('weeb/pixelUI/dialogueBox-senpaiMad');
				box.animation.addByPrefix('normalOpen', 'SENPAI ANGRY IMPACT SPEECH', 24, false);
				box.animation.addByIndices('normal', 'SENPAI ANGRY IMPACT SPEECH', [4], "", 24);

			case 'thorns':
				hasDialog = true;
				box.frames = Paths.getSparrowAtlas('weeb/pixelUI/dialogueBox-evil');
				box.animation.addByPrefix('normalOpen', 'Spirit Textbox spawn', 24, false);
				box.animation.addByIndices('normal', 'Spirit Textbox spawn', [11], "", 24);

			default:
				hasDialog=true;
				box.frames = Paths.getSparrowAtlas("speech_bubble_talking");
				box.animation.addByPrefix('normalOpen', 'Speech Bubble Normal Open', 24, false);
				box.animation.addByPrefix('normal','speech bubble normal', 24);
		}

		box.animation.play('normalOpen');
		if(PlayState.SONG.song.toLowerCase()=='thorns' || PlayState.SONG.song.toLowerCase()=='roses' || PlayState.SONG.song.toLowerCase()=='senpai')
			box.setGraphicSize(Std.int(box.width * PlayState.daPixelZoom * 0.9));

		box.updateHitbox();
		this.dialogueList = dialogueList;

		if (!hasDialog)
			return;

		portraitLeft = new FlxSprite(0, 40);

		if(PlayState.SONG.song.toLowerCase()=='thorns' || PlayState.SONG.song.toLowerCase()=='roses' || PlayState.SONG.song.toLowerCase()=='senpai' || PlayState.SONG.song.toLowerCase()=='2v200')
		{
			portraitLeft.frames = Paths.getSparrowAtlas('weeb/senpaiPortrait');
			portraitLeft.animation.addByPrefix('enter', 'Senpai Portrait Enter', 24, false);
			portraitLeft.setGraphicSize(Std.int(portraitLeft.width * PlayState.daPixelZoom * 0.9));
		}else{
			portraitLeft.frames = Paths.getSparrowAtlas('ports/dad_portrait');
			portraitLeft.antialiasing=true;
			portraitLeft.animation.addByPrefix('enter', portraitLeft.frames.frames[0].name, 24, false);
		}
		portraitLeft.updateHitbox();
		portraitLeft.scrollFactor.set();
		add(portraitLeft);
		portraitLeft.visible = false;

		portraitRight = new FlxSprite(Std.int(FlxG.width/2), 40);
		if(PlayState.SONG.song.toLowerCase()=='thorns' || PlayState.SONG.song.toLowerCase()=='roses' || PlayState.SONG.song.toLowerCase()=='senpai')
		{
			portraitRight.x = 0;
			portraitRight.frames = Paths.getSparrowAtlas('weeb/bfPortrait');
			portraitRight.animation.addByPrefix('enter', 'Boyfriend portrait enter', 24, true);
			portraitRight.setGraphicSize(Std.int(portraitRight.width * PlayState.daPixelZoom * 0.9));
		}else{
			portraitRight.antialiasing=true;
			portraitRight.frames = Paths.getSparrowAtlas('ports/${SkinState.selectedSkin}_portrait');
			var shit = portraitRight.frames.frames[0].name;
			var name = shit.substr(0,shit.length-4);
			portraitRight.animation.addByPrefix('enter', name, 24, true);
			portraitRight.animation.addByIndices('idle', name, [0],'',24,false);
		}

		portraitRight.updateHitbox();
		portraitRight.scrollFactor.set();
		add(portraitRight);
		portraitRight.visible = false;

		add(box);
		if(PlayState.SONG.song.toLowerCase()=='thorns' || PlayState.SONG.song.toLowerCase()=='roses' || PlayState.SONG.song.toLowerCase()=='senpai')
		{
			portraitLeft.screenCenter(X);
			box.screenCenter(X);
			handSelect = new FlxSprite(FlxG.width * 0.9, FlxG.height * 0.9).loadGraphic(Paths.image('weeb/pixelUI/hand_textbox'));
			add(handSelect);
		}else{
			box.screenCenter(XY);
			box.y += 200;
			portraitRight.y += 180;
			portraitRight.x += 125;
			portraitLeft.x += 50;
			portraitLeft.y += 150;
		}

		if(PlayState.SONG.song.toLowerCase()=='thorns'){
			var face:FlxSprite = new FlxSprite(320, 170).loadGraphic(Paths.image('weeb/spiritFaceForward'));
			face.setGraphicSize(Std.int(face.width * 6));
			add(face);
		}


		if (!talkingRight)
		{
			//box.flipX = true;
		}

		dropText = new FlxText(242, 502, Std.int(FlxG.width * 0.6), "", 32);
		if(PlayState.SONG.song.toLowerCase()=='thorns' || PlayState.SONG.song.toLowerCase()=='roses' || PlayState.SONG.song.toLowerCase()=='senpai'){
			dropText.font = 'Pixel Arial 11 Bold';
		}else{
			dropText.setFormat(Paths.font("vcr.ttf"), 32);
		}
		dropText.color = 0xFFD89494;
		add(dropText);

		swagDialogue = new FlxTypeText(240, 500, Std.int(FlxG.width * 0.6), "", 32);
		if(PlayState.SONG.song.toLowerCase()=='thorns' || PlayState.SONG.song.toLowerCase()=='roses' || PlayState.SONG.song.toLowerCase()=='senpai'){
			swagDialogue.font = 'Pixel Arial 11 Bold';
		}else{
			swagDialogue.setFormat(Paths.font("vcr.ttf"), 32);
		}
		swagDialogue.color = 0xFF3F2021;
		swagDialogue.sounds = [FlxG.sound.load(Paths.sound('pixelText'), 0.6)];
		add(swagDialogue);

		dialogue = new Alphabet(0, 80, "", false, true);
		// dialogue.x = 90;
		// add(dialogue);
	}

	public function skipDialogue(){
		swagDialogue.skip();
		finishedTyping=true;
	}

	var dialogueOpened:Bool = false;
	var dialogueStarted:Bool = false;

	override function update(elapsed:Float)
	{
		// HARD CODING CUZ IM STUPDI
		if (PlayState.SONG.song.toLowerCase() == 'roses')
			portraitLeft.visible = false;
		if (PlayState.SONG.song.toLowerCase() == 'thorns')
		{
			portraitLeft.color = FlxColor.BLACK;
			swagDialogue.color = FlxColor.WHITE;
			dropText.color = FlxColor.BLACK;
		}

		dropText.text = swagDialogue.text;

		if (box.animation.curAnim != null)
		{
			if (box.animation.curAnim.name == 'normalOpen' && box.animation.curAnim.finished)
			{
				box.animation.play('normal');
				dialogueOpened = true;
			}
		}

		if (dialogueOpened && !dialogueStarted)
		{
			startDialogue();
			dialogueStarted = true;
		}

		if (FlxG.keys.justPressed.ENTER  && dialogueStarted == true)
		{
			remove(dialogue);

			FlxG.sound.play(Paths.sound('clickText'), 0.8);

			if (dialogueList[1] == null && dialogueList[0] != null && finishedTyping)
			{
				if (!isEnding)
				{
					isEnding = true;

					if (PlayState.SONG.song.toLowerCase() == 'senpai' || PlayState.SONG.song.toLowerCase() == 'thorns')
						FlxG.sound.music.fadeOut(2.2, 0);

					new FlxTimer().start(0.2, function(tmr:FlxTimer)
					{
						box.alpha -= 1 / 5;
						bgFade.alpha -= 1 / 5 * 0.7;
						portraitLeft.visible = false;
						portraitRight.visible = false;
						swagDialogue.alpha -= 1 / 5;
						dropText.alpha = swagDialogue.alpha;
					}, 5);

					new FlxTimer().start(1.2, function(tmr:FlxTimer)
					{
						finishThing();
						kill();
					});
				}
			}
			else if(finishedTyping)
			{
				dialogueList.remove(dialogueList[0]);
				startDialogue();
			}else{
				skipDialogue();
			}
		}

		if(swagDialogue.text.length==wantedText.length){
			finishedTyping=true;
			if (portraitLeft.visible && portraitLeft.animation.curAnim.name!='idle' && portraitLeft.animation.getByName("idle")!=null )
				portraitLeft.animation.play("idle",true);

			if (portraitRight.visible && portraitRight.animation.curAnim.name!='idle' && portraitRight.animation.getByName("idle")!=null )
				portraitRight.animation.play("idle",true);
		}else{
			if (portraitLeft.visible && portraitLeft.animation.curAnim.name!='enter' && portraitLeft.animation.getByName("enter")!=null )
				portraitLeft.animation.play("enter",true);

			if (portraitRight.visible && portraitRight.animation.curAnim.name!='enter' && portraitRight.animation.getByName("enter")!=null )
				portraitRight.animation.play("enter",true);
		}

		super.update(elapsed);
	}

	var isEnding:Bool = false;

	var curLeft = '';
	var curRight = '';
	function startDialogue():Void
	{
		cleanDialog();
		finishedTyping=false;
		// var theDialog:Alphabet = new Alphabet(0, 70, dialogueList[0], false, true);
		// dialogue = theDialog;
		// add(theDialog);

		// swagDialogue.text = ;
		wantedText=dialogueList[0];
		swagDialogue.resetText(dialogueList[0]);
		swagDialogue.start(0.04, true);

		switch (curCharacter)
		{
		case 'dad':
			portraitRight.visible = false;
			if(!PlayState.curStage.startsWith("school")){
				if(curLeft!=curCharacter){
					curLeft=curCharacter;
					var x = portraitLeft.x;
					var y = portraitLeft.y;
					portraitLeft.frames = Paths.getSparrowAtlas('ports/${curLeft}_portrait');
					var shit = portraitLeft.frames.frames[0].name;
					var name = shit.substr(0,shit.length-4);
					portraitLeft.animation.addByPrefix('enter', name, 24, true);
					portraitLeft.animation.addByIndices('idle', name, [0],'',24,false);
					portraitLeft.updateHitbox();
					portraitLeft.scrollFactor.set();
					portraitLeft.visible=false;

					portraitLeft.x=x;
					portraitLeft.y=y;
				}
				if (!portraitLeft.visible)
				{
					swagDialogue.sounds = [FlxG.sound.load(Paths.sound('soundbytes/${curLeft}'), 0.6)];
					portraitLeft.visible = true;
					portraitLeft.animation.play('enter');
				}
			}

			if (!portraitLeft.visible)
			{
				portraitLeft.visible = true;
				portraitLeft.animation.play('enter');
			}
		case 'bf':
			box.flipX = false;
			portraitLeft.visible = false;
			if(curRight != 'bf' && PlayState.SONG.song.toLowerCase()!='thorns' && PlayState.SONG.song.toLowerCase()!='roses' && PlayState.SONG.song.toLowerCase()!='senpai'){
				curRight='bf';
				var x = portraitRight.x;
				var y = portraitRight.y;
				portraitRight.frames = Paths.getSparrowAtlas('ports/${SkinState.selectedSkin}_portrait');
				var shit = portraitRight.frames.frames[0].name;
				var name = shit.substr(0,shit.length-4);
				portraitRight.animation.addByPrefix('enter', name, 24, true);
				portraitRight.animation.addByIndices('idle', name, [0],'',24,false);
				portraitRight.updateHitbox();
				portraitRight.scrollFactor.set();
				portraitRight.visible=false;

				portraitRight.x=x;
				portraitRight.y=y;
			}
			swagDialogue.font = Paths.font("vcr.ttf");
			dropText.font = Paths.font("vcr.ttf");
			if (!portraitRight.visible)
			{
				swagDialogue.sounds = [FlxG.sound.load(Paths.sound('soundbytes/${curRight}'), 0.6)];
				portraitRight.visible = true;
				portraitRight.animation.play('enter');
			}
		default:
			box.flipX = true;
			portraitRight.visible = false;
			if(curLeft!=curCharacter){
				curLeft=curCharacter;
				var x = portraitLeft.x;
				var y = portraitLeft.y;
				portraitLeft.frames = Paths.getSparrowAtlas('ports/${curLeft}_portrait');
				var shit = portraitLeft.frames.frames[0].name;
				var name = shit.substr(0,shit.length-4);
				portraitLeft.animation.addByPrefix('enter', name, 24, true);
				portraitLeft.animation.addByIndices('idle', name, [0],'',24,false);
				portraitLeft.updateHitbox();
				portraitLeft.scrollFactor.set();
				portraitLeft.visible=false;

				portraitLeft.x=x;
				portraitLeft.y=y;
			}
			swagDialogue.font = Paths.font("vcr.ttf");
			dropText.font = Paths.font("vcr.ttf");
			if (!portraitLeft.visible)
			{
				swagDialogue.sounds = [FlxG.sound.load(Paths.sound('soundbytes/${curLeft}'), 0.6)];
				portraitLeft.visible = true;
				portraitLeft.animation.play('enter');
			}
		}
	}

	function cleanDialog():Void
	{
		var splitName:Array<String> = dialogueList[0].split(":");
		curCharacter = splitName[1].toLowerCase();
		dialogueList[0] = dialogueList[0].substr(splitName[1].length + 2).trim();
	}
}
