https://github.com/nebulazorua/andromeda-engine build instructions and also https://github.com/GrowtopiaFli/openfl-haxeflixel-video-code/ instructions

NOTE THAT IT'LL COMPLAIN ABOUT HIVECHARTS
ADD A FILE NAMED "HiveCharts.hx" AND HAVE IT 

```haxe
class HiveCharts 
{
  public static var normal='';
  public static var alpha='';
}
```

IF IT COMPLAINS ABOUT SECRETSHIT THEN

```haxe
import flixel.input.keyboard.FlxKeyboard;
class SecretShit extends FlxKeyboard
{}
```

IN "SecretShit.hx"
THAT SHOULD WORK???
