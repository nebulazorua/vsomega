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
import flixel.system.FlxSound;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.math.FlxMath;

typedef Code = {
  var code:String;
  var reward:String;
}

class CodeState extends MusicBeatState
{
  public static var codes:Array<Code> = [
    {code: "iamafool",reward:"skin:babyvase"},
    {code: "getout",reward:"skin:bfside"},
    {code: "naikaze",reward:"skin:naikaze"},
    {code: "mikeeey",reward:"skin:mikeeey"},
    {code: "tgr",reward:"skin:tgr"},
    {code: "erderithefox",reward:"skin:erderi"},
    //{code: "acai28",reward:"skin:acai28"},
  ];

  var inputText:FlxInputText;
  var void1:FlxSprite;
  var void2:FlxSprite;
  var wrong:FlxText;
  var wrongTimer:Float = 10000;
  var notifSound:FlxSound;
  override function create(){
    notifSound = new FlxSound();

    var title = new FlxText(0, 250, 0, "Type the code into the box and press enter to input\nthe code", 32);
    title.setFormat("VCR OSD Mono", 36, FlxColor.WHITE, CENTER, SHADOW,FlxColor.BLACK);
    title.shadowOffset.set(2,2);
    title.screenCenter(X);

    wrong = new FlxText(0, 0, 0, "That is not a valid code!", 32);
    wrong.setFormat("VCR OSD Mono", 36, FlxColor.RED, CENTER, SHADOW,FlxColor.BLACK);
    wrong.shadowOffset.set(2,2);
    wrong.screenCenter(XY);
    wrong.y += 100;
    wrong.visible=false;

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

    add(wrong);
    add(title);
    inputText = new FlxInputText(0,125,FlxG.width,"Code",16,FlxColor.WHITE,FlxColor.BLACK,true);
    @:privateAccess
    inputText.backgroundSprite.setGraphicSize(Std.int(inputText.backgroundSprite.width),Std.int(inputText.backgroundSprite.height*3));
    @:privateAccess
    inputText.backgroundSprite.alpha = 0.5;
    inputText.screenCenter(XY);
    inputText.callback = function(text,action){
      if(action=='enter'){
        var exists=false;
        for(codeData in codes){
          if(text==codeData.code){
            if(codeData.reward.startsWith("skin:")){
              var skin = codeData.reward.substring(5,codeData.reward.length);
              var sound = 'GeneralUnlock';
              switch(skin){
                case 'bfside':
                  sound = 'BrightsideUnlock';
                case 'babyvase':
                  sound = 'VaseUnlock';
                case 'acai28':
                  sound = 'AcaiUnlock';
              }

              if(FlxG.save.data.unlockedSkins.contains(skin)){
                sound='alreadyHave';
              }
              notifSound.loadEmbedded(Paths.sound('${sound}'), false, true);
              notifSound.volume = 1;
              notifSound.play(true,0);


              if(!FlxG.save.data.unlockedSkins.contains(skin)){
                var notif = new FlxSprite(-200,50).loadGraphic(Paths.image('codenotifs/${codeData.code}'));
                notif.setGraphicSize(Std.int(notif.width*.5));
                notif.updateHitbox();
                notif.scrollFactor.set(0,0);
                FlxTween.tween(notif,{x: 0}, 0.4, {
                  ease: FlxEase.quartInOut,
                  onComplete:function(twn:FlxTween){
                    FlxTween.tween(notif,{x: -400}, 0.4, {
                      startDelay:2.5,
                      ease: FlxEase.quartInOut,
                      onComplete:function(twn:FlxTween){
                        remove(notif);
                      }
                    });
                  }
                });

                add(notif);
                FlxG.save.data.unlockedSkins.push(skin);
              }

            }
            exists=true;
            break;
          }
        }
        if(!exists){
          var notifSound = new FlxSound().loadEmbedded(Paths.sound('wrongCode'), false, true);
          notifSound.volume = .7;
          notifSound.play(true,0);
          wrong.visible=true;
          wrongTimer=0;
        }
      }
    }
    add(inputText);
    FlxG.mouse.visible=true;

    super.create();
  }
  var timer:Float = 0;
  override function update(elapsed:Float){
    timer += elapsed;
    wrongTimer+= elapsed;
    FlxG.sound.music.volume = FlxMath.lerp(FlxG.sound.music.volume,.5,.1);

    if(wrongTimer>2){
      wrong.visible=false;
    }else{
      wrong.visible=true;
    }

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
      FlxG.mouse.visible=false;
    }

    if(FlxG.keys.justPressed.ESCAPE && inputText.hasFocus){
      inputText.hasFocus=false;
    }

    super.update(elapsed);
  }
}
