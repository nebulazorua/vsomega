package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import Options;

class OMenuItem extends FlxSpriteGroup
{
	public var targetX:Float = 0;
	public var targetY:Float = 0;

	public var targettedX:Float = 0;
	public var targettedY:Float = 0;

	public var week:FlxSprite;
	public var flashingInt:Int = 0;
	public var daX:Float = 0;
	public function new(x:Float, y:Float, frameName:String, ?assetName:String="WeekAssets")
	{
		super(x, y);
		//week = new FlxSprite().loadGraphic(Paths.image('storymenu/week' + weekNum));
		daX = x;
		week = new FlxSprite();
		week.frames = Paths.getSparrowAtlas(assetName);
		week.animation.addByPrefix('default', frameName);
		week.animation.play('default');
		add(week);
	}

	private var isFlashing:Bool = false;

	public function startFlashing():Void
	{
		isFlashing = true;
	}

	// if it runs at 60fps, fake framerate will be 6
	// if it runs at 144 fps, fake framerate will be like 14, and will update the graphic every 0.016666 * 3 seconds still???
	// so it runs basically every so many seconds, not dependant on framerate??
	// I'm still learning how math works thanks whoever is reading this lol
	var fakeFramerate:Int = Math.round((1 / FlxG.elapsed) / 10);

	public function calculateWantedXY(){
		targettedY = -75 + (targetY * 160) + FlxG.height/2;
		targettedX = daX+(targetX*50);
	}

	public function gotoTargetPosition(){
		calculateWantedXY();
		x = targettedX;
		y = targettedY;
	}

	override function update(elapsed:Float)
	{
		calculateWantedXY();
		y = FlxMath.lerp(y, targettedY, .17);
		x = FlxMath.lerp(x, targettedX, .17);
		super.update(elapsed);
		if (isFlashing)
			flashingInt += 1;

		if (OptionUtils.options.menuFlash && flashingInt % fakeFramerate >= Math.floor(fakeFramerate / 2) || !OptionUtils.options.menuFlash && flashingInt>=1 )
			week.color = 0xFF33ffff;
		else
			week.color = FlxColor.WHITE;
	}
}
