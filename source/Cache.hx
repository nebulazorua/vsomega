package;
import flixel.graphics.frames.FlxFramesCollection;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.FlxG;
import LuaClass;
class Cache {
  public static var offsetData = new Map<String,String>();
  public static var animData = new Map<String,String>();
  public static var charFrames = new Map<String,FlxFramesCollection>();
  public static var xmlData = new Map<String,String>();
  public static var miscFrames:Array<FlxFramesCollection> = [];
  public static function Clear(){
    offsetData.clear();
    animData.clear();
    charFrames.clear();
    xmlData.clear();
    LuaStorage.objectProperties.clear();
    trace("CLEARED CACHE!");
  }
}
