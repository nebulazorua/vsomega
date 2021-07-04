package;

import Controls.Control;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.FlxCamera;
class AchievementSubState extends MusicBeatSubstate
{
  public function new(name:String,rarity:String)
  {
    super();
    var camera = new FlxCamera();
    camera.bgColor.alpha = 0;
    FlxG.cameras.add(camera);
    var notifSound = new FlxSound().loadEmbedded(Paths.sound('achievements/${rarity}'), false, true);
    notifSound.volume = .5;
    notifSound.play(true,0);

    FlxG.sound.list.add(notifSound);

    var notif = new FlxSprite(-200,50).loadGraphic(Paths.image('achievements/${rarity}notif/${name}'));
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
            FlxG.cameras.remove(camera);
            remove(notif);
            close();
          }
        });
      }
    });

    add(notif);

    cameras = [camera];
  }
}
