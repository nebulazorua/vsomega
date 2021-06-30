package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.addons.text.FlxTypeText;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxSpriteGroup;
import flixel.input.FlxKeyManager;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxState;

using StringTools;

class CutsceneState extends MusicBeatState {
  var cutsceneData:Array<String>;
  var transRights:FlxState;
  public function new(cutsceneData:Array<String>,state:FlxState){
    this.cutsceneData=cutsceneData;
    transRights=state;
    super();
  }

  override public function create(){
    var cutscene = new Cutscene(cutsceneData);
    cutscene.finishThing = function(){
      LoadingState.loadAndSwitchState(transRights);
    }
    add(cutscene);
    super.create();
  }
}
