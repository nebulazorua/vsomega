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


class UnlockingItemState extends MusicBeatState {
  public static var unlocking:Array<String>=[];
  public var itemSheets:Array<FlxSprite>=[];
  var current:FlxSprite;
  var canGotoNext=true;
  override function create(){
    var portal:FlxSprite = new FlxSprite(0,-80).loadGraphic(Paths.image("spaceshit"));
    portal.antialiasing=true;
    add(portal);
    for(item in unlocking){
      var shit = new FlxSprite(0,0);
      shit.frames = Paths.getSparrowAtlas('items/${item}');
      shit.animation.addByPrefix("equip","equip",24,false);
      var reversedindices = [];
      var max = shit.animation.getByName("equip").frames.copy();
      max.reverse();
      for(i in max){
        reversedindices.push(i-2);
      }
      shit.animation.addByIndices("begone","equip",reversedindices,"",32,false);
      shit.antialiasing=true;
      shit.setGraphicSize(Std.int(shit.width*1.75));
      shit.updateHitbox();
      shit.screenCenter(XY);
      shit.x -= 400;
      shit.animation.finishCallback = function(n){
        if(n=='equip')
          canGotoNext=true;
        else if(n=='begone')
          remove(shit);
      }
      itemSheets.push(shit);
      shit.visible=false;
      add(shit);
    }

    gotoNextItem();
    unlocking=[];

    super.create();
  }

  public function gotoNextItem(){
    if(canGotoNext){
      canGotoNext=false;
      if(current!=null){
        current.animation.play("begone",true);
      }
      current=itemSheets[0];
      current.animation.play("equip",true);
      current.visible=true;
      itemSheets.shift();
    }
  }

  override function update(elapsed:Float){
    if(canGotoNext && FlxG.keys.justPressed.ENTER && itemSheets.length!=0){
      gotoNextItem();
    }else if(itemSheets.length==0 && canGotoNext && FlxG.keys.justPressed.ENTER){
      FlxG.switchState(new MainMenuState());
    }
    super.update(elapsed);
  }
}
