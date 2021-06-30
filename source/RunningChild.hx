package;

import flixel.FlxSprite;
import flixel.FlxG;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;

typedef MikaRunAnimMarker =
{
		var start:Float;
		var end:Float;
}

class RunningChild extends FlxSprite {
	public var schedule:Array<MikaRunAnimMarker> = [];
	public var started:Bool = false;

  public function new(){
    super();
    scrollFactor.set(.9,.9);
    x = 400;
    frames = Paths.getSparrowAtlas('dumbchild','shared');
    animation.addByPrefix("run","run child0",24,false);
    animation.addByPrefix("slide","child going zoom",24);
    visible=false;

    animation.play("slide");
  }
  override function update(elapsed){
		if(schedule.length>0){
	    var marker = schedule[0];
	    if(marker!=null){
	      if(Conductor.songPosition>=marker.start-275 && Conductor.songPosition<=marker.end+200){
	        if(Conductor.songPosition>=marker.start && Conductor.songPosition<marker.end+200){
	          visible=false;
	          @:privateAccess
	          if(PlayState.currentPState.dad.animation.curAnim.name!='grabChild'){
	            @:privateAccess
	            PlayState.currentPState.dad.playAnim("grabChild",true);
	          }
	        }else{
	          visible=true;
	          animation.play("run");
	          offset.y = 0;
	          var startA = marker.start-Conductor.songPosition;
	          var endA = 275;
	          var endPoint = -325;
	          x = FlxMath.lerp(450,endPoint,startA/endA);
	        }
	      }else if(Conductor.songPosition>=marker.start && Conductor.songPosition<marker.end+500){
	        @:privateAccess
	        if(PlayState.currentPState.dad.animation.curAnim.name=='grabChild'){
	          @:privateAccess
	          PlayState.currentPState.dad.playAnim("throwChild",true);
	        }
				}else if(Conductor.songPosition>=marker.start+200 && Conductor.songPosition<=marker.end+800){
					animation.play("slide");
					offset.y=-180;
					visible=true;
					var startA = (Conductor.songPosition-marker.end)-500;
					var endA = 300;

					var endPoint = -600;
					x = FlxMath.lerp(270,endPoint,FlxEase.quadOut(startA/endA) );
	      }else if(Conductor.songPosition>marker.end+800){
	        visible=false;
	        PlayState.mikaShit.shift();
	      }
	    }
		}
    super.update(elapsed);
  }
}
