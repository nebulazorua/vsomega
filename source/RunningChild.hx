package;

import flixel.FlxSprite;
import flixel.FlxG;
import flixel.math.FlxMath;

typedef MikaRunAnimMarker =
{
		var start:Float;
		var end:Float;
}

class RunningChild extends FlxSprite {
  public function new(){
    super();
    scrollFactor.set(.9,.9);
    x = 400;
    frames = Paths.getSparrowAtlas('dumbchild','shared');
    animation.addByPrefix("run","run child0",24,false);
    animation.addByPrefix("bounce","bounce child",24);
    visible=false;

    animation.play("bounce");

  }
  override function update(elapsed){
    var marker = PlayState.mikaShit[0];
    if(marker!=null){
      if(Conductor.songPosition>=marker.start-275 && Conductor.songPosition<=marker.end+200){
        if(Conductor.songPosition>=marker.start && Conductor.songPosition<marker.end+200){
          visible=false;
          @:privateAccess
          if(PlayState.instance.dad.animation.curAnim.name!='grabChild'){
            @:privateAccess
            PlayState.instance.dad.playAnim("grabChild",true);
          }
        }else{
          visible=true;
          animation.play("run");
          offset.y = 0;
          var startA = marker.start-Conductor.songPosition;
          var endA = 275;
          var endPoint = -325;
          x = FlxMath.lerp(400,endPoint,startA/endA);
        }
      }else if(Conductor.songPosition>=marker.start && Conductor.songPosition<=marker.end+700){
        animation.play("bounce");
        offset.y=100;
        visible=true; // JUST UNTIL THEY BOUNCE
        var startA = (Conductor.songPosition-marker.end)-200;
        var endA = 500;

        var endPoint = -500;
        x = FlxMath.lerp(275,endPoint,startA/endA);
        @:privateAccess
        if(PlayState.instance.dad.animation.curAnim.name=='grabChild'){
          @:privateAccess
          PlayState.instance.dad.playAnim("idle",true);
        }
        // BOUNCE OFF SCREEN
      }else if(Conductor.songPosition>marker.end+700){
        visible=false;
        PlayState.mikaShit.shift();
      }
    }
    super.update(elapsed);
  }
}
