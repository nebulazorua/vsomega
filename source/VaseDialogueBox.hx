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

using StringTools;

class VaseDialogueBox extends FlxSpriteGroup
{
	var box:FlxSprite;
	var curCharacter:String = '';
	var dialogueList:Array<String> = [];
	var swagDialogue:FlxTypeText;
	var dropText:FlxText;

	public var finishThing:Void->Void;
	public var leftCallback:Void->Void;
	public var rightCallback:Void->Void;
  public var finishedTyping:Bool = false;
  public var wantedText:String='';

	public var leftDecision:FlxSprite;
	public var rightDecision:FlxSprite;

	public var leftDecisionTxt:FlxText;
	public var rightDecisionTxt:FlxText;

	public var inDecision=false;
  var speed = 0.04;

	var nametag:FlxSprite;

	var handSelect:FlxSprite;
	var bgFade:FlxSprite;

	var dialogueList = [];

	public function new(dialogue:Array<String>)
	{
		super();

		dialogueList=dialogue;
		box = new FlxSprite(-20, 45);
		var hasDialog=true;
		box.frames = Paths.getSparrowAtlas("speech_bubble_talking");
		box.animation.addByPrefix('normalOpen', 'Speech Bubble Normal Open', 24, false);
		box.animation.addByPrefix('normal','speech bubble normal', 24);

		box.animation.play('normalOpen');
		box.flipX=true;
		portraitLeft.frames = Paths.getSparrowAtlas('ports/dad_portrait');
		var shit = portraitLeft.frames.frames[0].name;
		var name = shit.substr(0,shit.length-4);
		portraitLeft.animation.addByPrefix('enter', name, 24, true);
		portraitLeft.animation.addByIndices('idle', name, [0],'',24,false);

		portraitLeft.updateHitbox();
		portraitLeft.scrollFactor.set();
		add(portraitLeft);
		portraitLeft.visible = false;

		box.updateHitbox();
		box.screenCenter(XY);
		box.y += 200;
		portraitLeft.x += 50;
		portraitLeft.y += 150;

		add(box);

		swagDialogue = new FlxTypeText(100, 500, Std.int((FlxG.width - 100)*.9), "", 32);
		swagDialogue.setFormat(Paths.font("vcr.ttf"), 32,FlxColor.WHITE,LEFT,SHADOW,0xFFD89494);
		swagDialogue.color = 0xFFFFFFFF;
    swagDialogue.completeCallback = function(){
      finishedTyping=true;
    }
		add(swagDialogue);

		var cum = dialogueList[0];

	}

	public function setDropTextColor(?color:FlxColor){
		swagDialogue.borderColor=color;
	}

  public function setText(text:String,?delay=.04){
    finishedTyping=false;
    speed=delay;
    wantedText=text;
    swagDialogue.resetText(text);
    swagDialogue.start(delay,true);
  }

  public function skipDialogue(){
    swagDialogue.skip();
    finishedTyping=true;
  }

	public function setTypeSound(?sound=null){
		swagDialogue.sounds=[FlxG.sound.load(Paths.sound(sound))];
	}

	var dialogueOpened:Bool = true;
	var dialogueStarted:Bool = true;

	override function update(elapsed:Float)
	{
    if(FlxG.keys.pressed.SHIFT){
      swagDialogue.delay = speed/2;
    }else{
      swagDialogue.delay = speed;
    }

    if(swagDialogue.text.length==wantedText.length && !finishedTyping){
      finishedTyping=true;
    }

		if(FlxG.keys.justPressed.ENTER){
			if(finishedTyping){
				if(dialogueList.length==0){
					if(finishThing==null)
						finishThing();
					else
						destroy();

				}else{
					dialogueList.shift();
					setText(dialogueList[0])
				}
			}else{
				skipDialogue();
			}
		}

		super.update(elapsed);
	}

}
