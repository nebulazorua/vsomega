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

	public function new()
	{
		super();

		box = new FlxSprite(0, 0);
		var hasDialog=true;
		box.loadGraphic(Paths.image('transDialogueBox'));

		box.updateHitbox();
		add(box);

		box.screenCenter(XY);

		swagDialogue = new FlxTypeText(100, 500, Std.int((FlxG.width - 100)*.9), "", 32);
		swagDialogue.setFormat(Paths.font("vcr.ttf"), 32,FlxColor.WHITE,LEFT,SHADOW,0xFFD89494);
		swagDialogue.color = 0xFFFFFFFF;
    swagDialogue.completeCallback = function(){
      finishedTyping=true;
    }
		add(swagDialogue);

		leftDecision = new FlxSprite(100, 0).makeGraphic(300,75,FlxColor.BLACK);
		leftDecision.screenCenter(Y);
		leftDecision.y += 25;
		leftDecision.alpha = .5;
		leftDecision.visible=false;

		add(leftDecision);

		rightDecision = new FlxSprite(FlxG.width-400, 0).makeGraphic(300,75,FlxColor.BLACK);
		rightDecision.screenCenter(Y);
		rightDecision.y += 25;
		rightDecision.alpha = .5;
		rightDecision.visible=false;

		add(rightDecision);

		leftDecisionTxt = new FlxText(leftDecision.x,leftDecision.y+leftDecision.height/2,leftDecision.width*.9,"NAH YEAH M8");
		leftDecisionTxt.setFormat(Paths.font("vcr.ttf"), 32,FlxColor.WHITE,CENTER,SHADOW,0xFFD89494);
		leftDecisionTxt.color = 0xFFFFFFFF;
		add(leftDecisionTxt);

		rightDecisionTxt = new FlxText(rightDecision.x,rightDecision.y+rightDecision.height/2,rightDecision.width*.9,"YEAH NAH M8");
		rightDecisionTxt.setFormat(Paths.font("vcr.ttf"), 32,FlxColor.WHITE,CENTER,SHADOW,0xFFD89494);
		rightDecisionTxt.color = 0xFFFFFFFF;
		add(rightDecisionTxt);
	}

	public function setDropTextColor(?color:FlxColor){
		swagDialogue.borderColor=color;
	}

	public function unsetDecision(){
		FlxG.mouse.visible=false;
		inDecision=false;
		leftDecision.visible=false;
		rightDecision.visible=false;

		leftDecisionTxt.visible=false;
		rightDecisionTxt.visible=false;
	}

	public function setDecision(left:String,right:String){
		inDecision=true;
		FlxG.mouse.visible=true;
		leftDecisionTxt.text = left;
		rightDecisionTxt.text = right;
		if(left.replace(" ","")=='')
			leftDecision.visible=false;
		else
			leftDecision.visible=true;

		if(right.replace(" ","")=='')
			rightDecision.visible=false;
		else
			rightDecision.visible=true;

		rightDecisionTxt.visible=rightDecision.visible;
		leftDecisionTxt.visible=leftDecision.visible;

		if(!leftDecision.visible && !rightDecision.visible)unsetDecision();
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

		rightDecisionTxt.visible = rightDecision.visible;
		leftDecisionTxt.visible = leftDecision.visible;

		rightDecisionTxt.x = rightDecision.x;
		rightDecisionTxt.y = rightDecision.y+(rightDecision.height/4);

		leftDecisionTxt.x = leftDecision.x;
		leftDecisionTxt.y = leftDecision.y+(leftDecision.height/4);

		if(FlxG.mouse.justPressed && inDecision){
			if(FlxG.mouse.overlaps(leftDecision)){
				leftCallback();
			}else if(FlxG.mouse.overlaps(rightDecision)){
				rightCallback();
			}
		}
		super.update(elapsed);
	}

}
