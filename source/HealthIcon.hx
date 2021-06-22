package;

import flixel.FlxSprite;

class HealthIcon extends FlxSprite
{
	/**
	 * Used for FreeplayState! If you use it elsewhere, prob gonna annoying
	 */
	public var iWidth:Float = 150;
	public var sprTracker:FlxSprite;

	public function changeCharacter(char:String){
		antialiasing=true;
		if(char=='spirit' || char=='senpai-angry' || char=='senpai')
			antialiasing=false;

		loadGraphic(Paths.image("icons/"+char,"shared"),true,150,150);
		animation.add("icon",[0,1,2],0,false);

		animation.play("icon",true,false,1);
		if(char=="omega" || char=="angry-omega" || char=="omegabf" || char=="flexy" || char=="omegafriendly" || char=="senpai" || char=="senpai-angry" || char=="spirit" || char=="bf-pixel"){
			iWidth = width*.8;
			centerOffsets();
		}
		setGraphicSize(Std.int(iWidth));
		scrollFactor.set(1,1);
	}

	public function new(char:String = 'bf', isPlayer:Bool = false)
	{
		super();
		flipX = isPlayer;
		changeCharacter(char);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (sprTracker != null)
			setPosition(sprTracker.x + sprTracker.width + 10, sprTracker.y - 30);
	}
}
