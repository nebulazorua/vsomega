package;
import flixel.system.FlxAssets.FlxShader;
import openfl.filters.ShaderFilter;
import openfl.filters.BitmapFilter;
import Shaders;
import Options;
class ModChart {
  private var playState:PlayState;
  private var camShaders=[];
  private var hudShaders=[];

  public var playerNotesFollowReceptors=true;
  public var opponentNotesFollowReceptors=true;
  public var hudVisible=true;
  public var hideBF=false;
  public var hideGF=false;
  public var hideDad=false;
  public var playerNoteScale:Float=1;
  public var opponentNoteScale:Float=1;
  public var opponentHPDrain:Float = 0;

  public function new(playState:PlayState){
    this.playState=playState;

  }

  public function addCamEffect(effect:ShaderEffect){
    camShaders.push(effect);
    var newCamEffects:Array<BitmapFilter>=[]; // IT SHUTS HAXE UP IDK WHY BUT WHATEVER IDK WHY I CANT JUST ARRAY<SHADERFILTER>
    for(i in camShaders){
      newCamEffects.push(new ShaderFilter(i.shader));
    }
    @:privateAccess
    playState.camGame.setFilters(newCamEffects);
  }

  public function removeCamEffect(effect:ShaderEffect){
    camShaders.remove(effect);
    var newCamEffects:Array<BitmapFilter>=[];
    for(i in camShaders){
      newCamEffects.push(new ShaderFilter(i.shader));
    }
    @:privateAccess
    playState.camGame.setFilters(newCamEffects);
  }

  public function clearCamEffects(){
    for(i in camShaders){
      camShaders.remove(i);
    }
    @:privateAccess
    playState.camGame.setFilters([]);
  }

  public function clearHUDEffects(){
    for(i in hudShaders){
      hudShaders.remove(i);
    }
    @:privateAccess
    playState.camHUD.setFilters([]);
  }

  public function addHudEffect(effect:ShaderEffect){
    hudShaders.push(effect);
    var newCamEffects:Array<BitmapFilter>=[];
    for(i in camShaders){
      newCamEffects.push(new ShaderFilter(i.shader));
    }
    @:privateAccess
    playState.camHUD.setFilters(newCamEffects);
  }

  public function removeHudEffect(effect:ShaderEffect){
    hudShaders.remove(effect);
    var newCamEffects:Array<BitmapFilter>=[];
    for(i in camShaders){
      newCamEffects.push(new ShaderFilter(i.shader));
    }
    @:privateAccess
    playState.camHUD.setFilters(newCamEffects);
  }


  public function update(elapsed:Float){

  }
}
