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
import flixel.group.FlxSpriteGroup;

class CreditInfo extends FlxSpriteGroup {
  var iconSpr:FlxSprite;
  var nameTxt:FlxText;
  var roleTxt:FlxText;
  var subTxt:FlxText;
  var dscTxt:FlxText;
  var timer:Float=0;
  public function new(x:Float,y:Float,icon:String,name:String,role:String,subtitle:String,desc:String){
    super(x,y);

    iconSpr = new FlxSprite(0,0).loadGraphic(Paths.image('crediticons/${icon.toLowerCase()}'));
    iconSpr.setGraphicSize(300,300);
    iconSpr.updateHitbox();
    iconSpr.antialiasing=true;
    iconSpr.centerOffsets();
    iconSpr.offset.x -= 32;

    nameTxt = new FlxText(0, 0, 500, name, 32);
		nameTxt.setFormat("VCR OSD Mono", 36, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
    nameTxt.y = iconSpr.y - 75;

    roleTxt = new FlxText(0, 0, 500, role, 24);
    roleTxt.setFormat("VCR OSD Mono", 24, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
    roleTxt.y = nameTxt.y + 35;

    subTxt = new FlxText(0, 0, 500, subtitle, 24);
    subTxt.setFormat("VCR OSD Mono", 24, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
    subTxt.y = iconSpr.getGraphicMidpoint().y + iconSpr.height/2 + 75;

    dscTxt = new FlxText(0, 0, 500, desc, 24);
    dscTxt.setFormat("VCR OSD Mono", 24, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
    dscTxt.y = subTxt.y + 50;

    add(iconSpr);
    add(nameTxt);
    add(roleTxt);
    add(subTxt);
    add(dscTxt);
  }

  override function update(elapsed:Float){
    timer+=elapsed/2;
    subTxt.x = iconSpr.getGraphicMidpoint().x - iconSpr.width/2 ;
    roleTxt.x = iconSpr.getGraphicMidpoint().x - iconSpr.width/2 ;
    nameTxt.x = iconSpr.getGraphicMidpoint().x - iconSpr.width/2 ;
    dscTxt.x = iconSpr.getGraphicMidpoint().x - iconSpr.width/2 ;

    iconSpr.angle = 10*Math.cos(timer);
    super.update(elapsed);
  }
}

class CreditsState extends MusicBeatState {
  var items:FlxTypedGroup<OMenuItem>;
  var creditInfo:FlxTypedGroup<CreditInfo>;
  var curSelected:Int = 0;
  var movedBack:Bool = false;

  override function create()
  {
    controls.setKeyboardScheme(Solo,true);
    #if desktop
    // Updating Discord Rich Presence
    DiscordClient.changePresence("In the Menus", null);
    #end
    if (!FlxG.sound.music.playing)
    {
      FlxG.sound.playMusic(Paths.music('freakyMenu'));
    }

    persistentUpdate = persistentDraw = true;

    var portal:FlxSprite = new FlxSprite(0,-80).loadGraphic(Paths.image("spaceshit"));
    portal.scrollFactor.x = 0.02;
    portal.scrollFactor.y = 0.18;
    portal.antialiasing=true;
    portal.setGraphicSize(Std.int(portal.width*1.05));
    add(portal);

    items = new FlxTypedGroup<OMenuItem>();
    add(items);

    creditInfo = new FlxTypedGroup<CreditInfo>();
    add(creditInfo);

    var creditData = CoolUtil.coolTextFile(Paths.txt('credits'));

		for (i in 0...creditData.length)
    {
      var data = creditData[i].split("-");
      var icon = data.splice(0,1)[0];
      var name = data.splice(0,1)[0];
      var role = data.splice(0,1)[0];
      var subtitle = data.splice(0,1)[0];
      var desc = data.join("-");

      var asd:OMenuItem = new OMenuItem(0, 0, icon, "CreditMenu_UI");
			asd.targetY = i;
			items.add(asd);
      if(icon=='Naikaze'){
        asd.offset.y += asd.height;
      }

			asd.daX = 80;
			asd.antialiasing = true;

      var stuff = new CreditInfo(650,0,icon,name,role,subtitle,desc);
      stuff.visible=false;
      stuff.screenCenter(Y);
      stuff.y += 25;
      creditInfo.add(stuff);
    }

    scroll();

    super.create();
  }

  function scroll(change:Int = 0):Void
	{
		curSelected += change;

		if (curSelected >= items.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = items.length - 1;

		for (i in 0...items.length)
		{
			var item = items.members[i];
			item.targetY = i - curSelected;
			item.targetX = i - curSelected;
			if(i>curSelected)
				item.targetX -= item.targetX*2;



			if (item.targetY == Std.int(0)){
				item.alpha = 1;
        creditInfo.members[i].visible=true;
			}else{
				item.alpha = 0.6;
        creditInfo.members[i].visible=false;
      }

		}

		FlxG.sound.play(Paths.sound('scrollMenu'));

	}

  override function update(elapsed:Float){
    if (controls.BACK && !movedBack)
    {
      FlxG.sound.play(Paths.sound('cancelMenu'));
      movedBack = true;
      FlxG.switchState(new MainMenuState());
    }

    if (controls.UP_P)
    {
      scroll(-1);
    }

    if (controls.DOWN_P)
    {
      scroll(1);
    }
    super.update(elapsed);
  }
}
