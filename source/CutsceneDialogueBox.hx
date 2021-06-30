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

class CutsceneDialogueBox extends FlxSpriteGroup
{
	var box:FlxSprite;
	var curCharacter:String = '';
	var dialogueList:Array<String> = [];
	var swagDialogue:FlxTypeText;
	var dropText:FlxText;

	public var finishThing:Void->Void;
  public var finishedTyping:Bool = false;
  public var wantedText:String='';
  var speed = 0.04;

	var nametag:FlxSprite;

	var handSelect:FlxSprite;
	var bgFade:FlxSprite;

	public function new()
	{
		super();

		box = new FlxSprite(0, 0);
		var hasDialog=true;
		box.loadGraphic(Paths.image('transDialogueBox'));

		box.updateHitbox();
		add(box);

		box.screenCenter(XY);


		swagDialogue = new FlxTypeText(100, 500, Std.int((FlxG.width - 100)*.8), "", 32);
		swagDialogue.setFormat(Paths.font("vcr.ttf"), 32,FlxColor.WHITE,LEFT,SHADOW,0xFFD89494);
		swagDialogue.color = 0xFFFFFFFF;
    swagDialogue.completeCallback = function(){
      finishedTyping=true;
    }
		add(swagDialogue);
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
		super.update(elapsed);
	}

}
