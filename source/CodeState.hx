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
import flixel.addons.ui.FlxInputText;

class CodeState extends MusicBeatState
{
  public static var codes = [];

  var inputText:FlxInputText;
  var void1:FlxSprite;
  var void2:FlxSprite;

  override function create(){
    void1 = new FlxSprite(-600, -500).loadGraphic(Paths.image('BGvoid'));
    void1.antialiasing = true;
    void1.setGraphicSize(Std.int(void1.width*2));
    void1.updateHitbox();
    void1.x = -600;
    void1.scrollFactor.set(0, 0);
    void1.active = false;
    add(void1);

    void2 = new FlxSprite(-600, -500).loadGraphic(Paths.image('BGvoid'));
    void2.antialiasing = true;
    void2.setGraphicSize(Std.int(void2.width*2));
    void2.updateHitbox();
    void2.scrollFactor.set(0, 0);
    void2.active = false;
    void2.x = -(void1.width)-600;
    add(void2);

    inputText = new FlxInputText(0,125,FlxG.width,"CUM",16,FlxColor.WHITE,FlxColor.BLACK,true);
    @:privateAccess
    inputText.backgroundSprite.setGraphicSize(Std.int(inputText.backgroundSprite.width),Std.int(inputText.backgroundSprite.height*3));
    @:privateAccess
    inputText.backgroundSprite.alpha = 0.5;
    inputText.screenCenter(XY);
    inputText.callback = function(text,action){
      if(action=='enter'){

      }
    }
    add(inputText);
    FlxG.mouse.visible=true;

    super.create();
  }
  var timer:Float = 0;
  override function update(elapsed:Float){
    timer += elapsed;

    var nextXBG = void1.x+(elapsed*64);
    var nextXBG2 = void2.x+(elapsed*64);

    void1.x = nextXBG;
    void2.x = nextXBG2;

    if(nextXBG>=3000){
      void1.x = void2.x-void2.width;
    }

    if(nextXBG2>=3000){
      void2.x = void1.x-void1.width;
    }

    if (controls.BACK && !inputText.hasFocus)
    {
      FlxG.sound.play(Paths.sound('cancelMenu'));
      FlxG.switchState(new MainMenuState());
    }

    super.update(elapsed);
  }
}
