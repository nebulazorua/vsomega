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
  public var finishedTyping:Bool = false;
  public var wantedText:String='';

  var speed = 0.04;

	var nametag:FlxSprite;

	var handSelect:FlxSprite;
	var bgFade:FlxSprite;
	var portraitLeft:FlxSprite;
	public function new(dialogue:Array<String>)
	{
		super();

		dialogueList=dialogue;
		var hasDialog=true;

		dropText = new FlxText(52, 522, Std.int(FlxG.width * 0.9), "", 32);
		dropText.setFormat(Paths.font("vcr.ttf"), 32);
		dropText.color = 0xFFD89494;
		add(dropText);

		swagDialogue = new FlxTypeText(50, 520, Std.int(FlxG.width * 0.9), "", 32);
		swagDialogue.setFormat(Paths.font("vcr.ttf"), 32);
		swagDialogue.color = 0xFFFFFFFF;
		add(swagDialogue);


		var cum = dialogueList[0];
		dialogueList.shift();
		swagDialogue.sounds=[FlxG.sound.load(Paths.sound("Vase"))];
		setText(cum);
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
					if(finishThing!=null)
						finishThing();
					else
						destroy();
				}else{
					setText(dialogueList[0]);
					dialogueList.shift();
				}
			}else{
				skipDialogue();
			}
		}

		super.update(elapsed);
	}

}
