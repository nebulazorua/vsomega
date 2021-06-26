package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.util.FlxTimer;

using StringTools;

class Boyfriend extends Character
{
	public var stunned:Bool = false;

	public function new(x:Float, y:Float, ?char:String = 'bf', ?backup:Bool=false)
	{
		super(x, y, char, true, backup);
	}

	override function update(elapsed:Float)
	{
		if (!debugMode)
		{
			if (animation.curAnim.name.startsWith('sing'))
			{
				holdTimer += elapsed;
			}
			else
				holdTimer = 0;

			if (animation.curAnim.name.endsWith('miss') && animation.curAnim.finished && !debugMode)
			{
				dance();
			}

			if (animation.curAnim.name == 'firstDeath' && animation.curAnim.finished)
			{
				if(curCharacter=='bf-FUCKING-DIES' && !FlxG.save.data.seenLastStandOmegaGameOver)
					FlxG.save.data.seenLastStandOmegaGameOver=true;
				
				playAnim('deathLoop');
			}
		}

		super.update(elapsed);
	}
}
