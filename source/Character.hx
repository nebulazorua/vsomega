package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.animation.FlxBaseAnimation;
import flixel.graphics.frames.FlxAtlasFrames;
import flash.display.BitmapData;
import sys.io.File;

using StringTools;

class Character extends FlxSprite
{
	public var animOffsets:Map<String, Array<Dynamic>>;
	public var offsetNames:Array<String>=[];
	public var debugMode:Bool = false;

	public var isPlayer:Bool = false;
	public var curCharacter:String = 'bf';
	public var holding:Bool=false;
	public var disabledDance:Bool = false;
	public var backupCharacter:Bool=false;
	public var holdTimer:Float = 0;
	public var isReskin=false;

	public function new(x:Float, y:Float, ?character:String = "bf", ?isPlayer:Bool = false, ?backup:Bool=false)
	{
		super(x, y);
		backupCharacter=backup;
		animOffsets = new Map<String, Array<Dynamic>>();
		curCharacter = character;
		this.isPlayer = isPlayer;

		var tex:FlxAtlasFrames;
		antialiasing = true;
		trace(curCharacter);
		switch (curCharacter)
		{
			case 'gf':
				// GIRLFRIEND CODE
				tex = Paths.getSparrowAtlas('characters/GF_assets','shared');
				frames = tex;
				animation.addByPrefix('cheer', 'GF Cheer', 24, false);
				animation.addByPrefix('singLEFT', 'GF left note', 24, false);
				animation.addByPrefix('singRIGHT', 'GF Right Note', 24, false);
				animation.addByPrefix('singUP', 'GF Up Note', 24, false);
				animation.addByPrefix('singDOWN', 'GF Down Note', 24, false);
				animation.addByIndices('sad', 'gf sad', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "", 24, false);
				animation.addByIndices('danceLeft', 'GF Dancing Beat', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
				animation.addByIndices('danceRight', 'GF Dancing Beat', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
				animation.addByIndices('hairBlow', "GF Dancing Beat Hair blowing", [0, 1, 2, 3], "", 24);
				animation.addByIndices('hairFall', "GF Dancing Beat Hair Landing", [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11], "", 24, false);
				animation.addByPrefix('scared', 'GF FEAR', 24);

				loadOffsets();
				playAnim('danceRight');
			case 'lizzy':
				// GIRLFRIEND CODE
				tex = Paths.getSparrowAtlas('characters/cutie','shared');
				frames = tex;
				animation.addByPrefix('cheer', 'GF Cheer', 24, false);
				animation.addByPrefix('singLEFT', 'GF left note', 24, false);
				animation.addByPrefix('singRIGHT', 'GF Right Note', 24, false);
				animation.addByPrefix('singUP', 'GF Up Note', 24, false);
				animation.addByPrefix('singDOWN', 'GF Down Note', 24, false);
				animation.addByIndices('sad', 'gf sad', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "", 24, false);
				animation.addByIndices('danceLeft', 'GF Dancing Beat', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
				animation.addByIndices('danceRight', 'GF Dancing Beat', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
				animation.addByIndices('hairBlow', "GF Dancing Beat Hair blowing", [0, 1, 2, 3], "", 24);
				animation.addByIndices('hairFall', "GF Dancing Beat Hair Landing", [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11], "", 24, false);
				animation.addByPrefix('scared', 'GF FEAR', 24);
				loadOffsets();
				playAnim('danceRight');
			case 'gf-christmas':
				tex = Paths.getSparrowAtlas('characters/gfChristmas','shared');
				frames = tex;
				animation.addByPrefix('cheer', 'GF Cheer', 24, false);
				animation.addByPrefix('singLEFT', 'GF left note', 24, false);
				animation.addByPrefix('singRIGHT', 'GF Right Note', 24, false);
				animation.addByPrefix('singUP', 'GF Up Note', 24, false);
				animation.addByPrefix('singDOWN', 'GF Down Note', 24, false);
				animation.addByIndices('sad', 'gf sad', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "", 24, false);
				animation.addByIndices('danceLeft', 'GF Dancing Beat', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
				animation.addByIndices('danceRight', 'GF Dancing Beat', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
				animation.addByIndices('hairBlow', "GF Dancing Beat Hair blowing", [0, 1, 2, 3], "", 24);
				animation.addByIndices('hairFall', "GF Dancing Beat Hair Landing", [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11], "", 24, false);
				animation.addByPrefix('scared', 'GF FEAR', 24);

				loadOffsets();
				playAnim('danceRight');
			case 'gf-rave':
				tex = Paths.getSparrowAtlas('characters/raveGf','shared');
				frames = tex;
				animation.addByPrefix('cheer', 'GF Cheer', 24, false);
				animation.addByPrefix('singLEFT', 'GF left note', 24, false);
				animation.addByPrefix('singRIGHT', 'GF Right Note', 24, false);
				animation.addByPrefix('singUP', 'GF Up Note', 24, false);
				animation.addByPrefix('singDOWN', 'GF Down Note', 24, false);
				animation.addByIndices('sad', 'gf sad', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "", 24, false);
				animation.addByIndices('danceLeft', 'GF Dancing Beat', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
				animation.addByIndices('danceRight', 'GF Dancing Beat', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
				animation.addByIndices('hairBlow', "GF Dancing Beat Hair blowing", [0, 1, 2, 3], "", 24);
				animation.addByIndices('hairFall', "GF Dancing Beat Hair Landing", [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11], "", 24, false);
				animation.addByPrefix('scared', 'GF FEAR', 24);

				loadOffsets();
				playAnim('danceRight');
			case 'gf-raveFaceless':
				tex = Paths.getSparrowAtlas('characters/raveGfFaceless','shared');
				frames = tex;
				animation.addByPrefix('cheer', 'GF Cheer', 24, false);
				animation.addByPrefix('singLEFT', 'GF left note', 24, false);
				animation.addByPrefix('singRIGHT', 'GF Right Note', 24, false);
				animation.addByPrefix('singUP', 'GF Up Note', 24, false);
				animation.addByPrefix('singDOWN', 'GF Down Note', 24, false);
				animation.addByIndices('sad', 'gf sad', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "", 24, false);
				animation.addByIndices('danceLeft', 'GF Dancing Beat', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
				animation.addByIndices('danceRight', 'GF Dancing Beat', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
				animation.addByIndices('hairBlow', "GF Dancing Beat Hair blowing", [0, 1, 2, 3], "", 24);
				animation.addByIndices('hairFall', "GF Dancing Beat Hair Landing", [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11], "", 24, false);
				animation.addByPrefix('scared', 'GF FEAR', 24);

				loadOffsets();
				playAnim('danceRight');

			case 'gf-child':
				tex = Paths.getSparrowAtlas('characters/GF_ass_sets_fighting','shared');
				frames = tex;
				animation.addByIndices('singUP', 'GF Dancing fight Beat', [0], "", 24, false);
				animation.addByIndices('danceRight', 'GF Dancing fight Beat', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
				animation.addByIndices('danceLeft', 'GF Dancing fight Beat', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24,
					false);

				loadOffsets();
				playAnim('danceRight');

			case 'gf-car':
				tex = Paths.getSparrowAtlas('characters/gfCar','shared');
				frames = tex;
				animation.addByIndices('singUP', 'GF Dancing Beat Hair blowing CAR', [0], "", 24, false);
				animation.addByIndices('danceLeft', 'GF Dancing Beat Hair blowing CAR', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
				animation.addByIndices('danceRight', 'GF Dancing Beat Hair blowing CAR', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24,
					false);

				loadOffsets();
				playAnim('danceRight');

			case 'gf-pixel':
				tex = Paths.getSparrowAtlas('characters/gfPixel','shared');
				frames = tex;
				animation.addByIndices('singUP', 'GF Pixel', [0], "", 24, false);
				animation.addByIndices('danceLeft', 'GF Pixel', [4,5,4,5,4,5,4,5,4,5,4,1,1,1,1], "", 24, false);
				animation.addByIndices('danceRight', 'GF Pixel', [10,11,10,11,10,11,10,11,10,11,10,1,1,1,1], "", 24, false);

				loadOffsets();
				playAnim('danceRight');

				setGraphicSize(Std.int(width * PlayState.daPixelZoom));
				updateHitbox();
				antialiasing = false;

			case 'dad':
				// DAD ANIMATION LOADING CODE
				tex = Paths.getSparrowAtlas('characters/DADDY_DEAREST','shared');
				frames = tex;

				loadAnimations();

				loadOffsets();

				playAnim('idle');
			case 'father':
				// DAD ANIMATION LOADING CODE
				tex = Paths.getSparrowAtlas('characters/FATHER_TIME','shared');
				frames = tex;
				animation.addByPrefix('idle', "Dad idle dance", 24, false);
				animation.addByPrefix('singUP', "Dad Sing note UP", 24, false);
				animation.addByPrefix('singDOWN', "Dad Sing Note DOWN", 24, false);
				animation.addByPrefix('singLEFT', 'dad sing note right', 24, false);
				animation.addByPrefix('singRIGHT', 'Dad Sing Note LEFT', 24, false);

				loadOffsets();

				playAnim('idle');
			case 'spooky':
				tex = Paths.getSparrowAtlas('characters/spooky_kids_assets','shared');
				frames = tex;
				animation.addByPrefix('singUP', 'spooky UP NOTE', 24, false);
				animation.addByPrefix('singDOWN', 'spooky DOWN note', 24, false);
				animation.addByPrefix('singLEFT', 'note sing left', 24, false);
				animation.addByPrefix('singRIGHT', 'spooky sing right', 24, false);
				animation.addByIndices('danceLeft', 'spooky dance idle', [0, 2, 6], "", 12, false);
				animation.addByIndices('danceRight', 'spooky dance idle', [8, 10, 12, 14], "", 12, false);

				loadOffsets();

				playAnim('danceRight');
			case 'mom':
				tex = Paths.getSparrowAtlas('characters/Mom_Assets','shared');
				frames = tex;

				animation.addByPrefix('idle', "Mom Idle", 24, false);
				animation.addByPrefix('singUP', "Mom Up Pose", 24, false);
				animation.addByPrefix('singDOWN', "MOM DOWN POSE", 24, false);
				animation.addByPrefix('singLEFT', 'Mom Left Pose', 24, false);
				animation.addByPrefix('singRIGHT', 'Mom Pose Left', 24, false);

				loadOffsets();

				playAnim('idle');

			case 'mom-car':
				tex = Paths.getSparrowAtlas('characters/momCar','shared');
				frames = tex;

				animation.addByPrefix('idle', "Mom Idle", 24, false);
				animation.addByPrefix('singUP', "Mom Up Pose", 24, false);
				animation.addByPrefix('singDOWN', "MOM DOWN POSE", 24, false);
				animation.addByPrefix('singLEFT', 'Mom Left Pose', 24, false);
				// ANIMATION IS CALLED MOM LEFT POSE BUT ITS FOR THE RIGHT
				// CUZ DAVE IS DUMB!
				animation.addByPrefix('singRIGHT', 'Mom Pose Left', 24, false);

				loadOffsets();

				playAnim('idle');
			case 'monster':
				tex = Paths.getSparrowAtlas('characters/Monster_Assets','shared');
				frames = tex;
				animation.addByPrefix('idle', 'monster idle', 24, false);
				animation.addByPrefix('singUP', 'monster up note', 24, false);
				animation.addByPrefix('singDOWN', 'monster down', 24, false);
				animation.addByPrefix('singLEFT', 'Monster Right note', 24, false);
				animation.addByPrefix('singRIGHT', 'Monster left note', 24, false);

				loadOffsets();
				playAnim('idle');
			case 'monster-christmas':
				tex = Paths.getSparrowAtlas('characters/monsterChristmas','shared');
				frames = tex;
				animation.addByPrefix('idle', 'monster idle', 24, false);
				animation.addByPrefix('singUP', 'monster up note', 24, false);
				animation.addByPrefix('singDOWN', 'monster down', 24, false);
				animation.addByPrefix('singLEFT', 'Monster Right note', 24, false);
				animation.addByPrefix('singRIGHT', 'Monster left note', 24, false);
				loadOffsets();

				playAnim('idle');
			case 'pico':
				tex = Paths.getSparrowAtlas('characters/Pico_FNF_assetss','shared');
				frames = tex;
				animation.addByPrefix('idle', "Pico Idle Dance", 24, false);
				animation.addByPrefix('singUP', 'pico Up note0', 24, false);
				animation.addByPrefix('singDOWN', 'Pico Down Note0', 24, false);
				if (isPlayer)
				{
					animation.addByPrefix('singLEFT', 'Pico NOTE LEFT0', 24, false);
					animation.addByPrefix('singRIGHT', 'Pico Note Right0', 24, false);
					animation.addByPrefix('singRIGHTmiss', 'Pico Note Right Miss', 24, false);
					animation.addByPrefix('singLEFTmiss', 'Pico NOTE LEFT miss', 24, false);
				}
				else
				{
					// Need to be flipped! REDO THIS LATER!
					animation.addByPrefix('singLEFT', 'Pico Note Right0', 24, false);
					animation.addByPrefix('singRIGHT', 'Pico NOTE LEFT0', 24, false);
					animation.addByPrefix('singRIGHTmiss', 'Pico NOTE LEFT miss', 24, false);
					animation.addByPrefix('singLEFTmiss', 'Pico Note Right Miss', 24, false);
				}

				animation.addByPrefix('singUPmiss', 'pico Up note miss', 24);
				animation.addByPrefix('singDOWNmiss', 'Pico Down Note MISS', 24);

				loadOffsets();
				playAnim('idle');

				flipX = true;

			case 'bf':
				var tex = Paths.getSparrowAtlas('characters/BOYFRIEND','shared');
				frames = tex;
				animation.addByPrefix('idle', 'BF idle dance', 24, false);
				animation.addByPrefix('singUP', 'BF NOTE UP0', 24, false);
				animation.addByPrefix('singLEFT', 'BF NOTE LEFT0', 24, false);
				animation.addByPrefix('singRIGHT', 'BF NOTE RIGHT0', 24, false);
				animation.addByPrefix('singDOWN', 'BF NOTE DOWN0', 24, false);
				animation.addByPrefix('singUPmiss', 'BF NOTE UP MISS', 24, false);
				animation.addByPrefix('singLEFTmiss', 'BF NOTE LEFT MISS', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'BF NOTE RIGHT MISS', 24, false);
				animation.addByPrefix('singDOWNmiss', 'BF NOTE DOWN MISS', 24, false);
				animation.addByPrefix('hey', 'BF HEY', 24, false);

				animation.addByPrefix('cut', 'BF hit', 24, false);

				animation.addByPrefix('firstDeath', "BF dies", 24, false);
				animation.addByPrefix('deathLoop', "BF Dead Loop", 24, true);
				animation.addByPrefix('deathConfirm', "BF Dead confirm", 24, false);

				animation.addByPrefix('scared', 'BF idle shaking', 24);
				var scaredFrames=[];
				for(i in 0...24){
					scaredFrames.push(i%3);
				}
				animation.addByIndices('dischargeScared', 'BF idle shaking', scaredFrames, "", 24, false);

				loadOffsets();
				addOffset("dischargeScared",animOffsets.get("scared")[0],animOffsets.get("scared")[1]);
				playAnim('idle');

				flipX = true;

			case 'black':
				var tex = Paths.getSparrowAtlas('characters/BLACKFRIEND','shared');
				frames = tex;
				animation.addByPrefix('idle', 'BF idle dance', 24, false);
				animation.addByPrefix('singUP', 'BF NOTE UP0', 24, false);
				animation.addByPrefix('singLEFT', 'BF NOTE LEFT0', 24, false);
				animation.addByPrefix('singRIGHT', 'BF NOTE RIGHT0', 24, false);
				animation.addByPrefix('singDOWN', 'BF NOTE DOWN0', 24, false);
				animation.addByPrefix('singUPmiss', 'BF NOTE UP MISS', 24, false);
				animation.addByPrefix('singLEFTmiss', 'BF NOTE LEFT MISS', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'BF NOTE RIGHT MISS', 24, false);
				animation.addByPrefix('singDOWNmiss', 'BF NOTE DOWN MISS', 24, false);
				animation.addByPrefix('hey', 'BF HEY', 24, false);

				animation.addByPrefix('cut', 'BF hit', 24, false);

				animation.addByPrefix('firstDeath', "BF dies", 24, false);
				animation.addByPrefix('deathLoop', "BF Dead Loop", 24, true);
				animation.addByPrefix('deathConfirm', "BF Dead confirm", 24, false);

				animation.addByPrefix('scared', 'BF idle shaking', 24);
				var scaredFrames=[];
				for(i in 0...24){
					scaredFrames.push(i%3);
				}
				animation.addByIndices('dischargeScared', 'BF idle shaking', scaredFrames, "", 24, false);

				loadOffsets();
				addOffset("dischargeScared",animOffsets.get("scared")[0],animOffsets.get("scared")[1]);
				playAnim('idle');

				flipX = true;

			case 'tgr':
				isReskin=true;
				var tex = Paths.getSparrowAtlas('characters/reskins/theghostreaper','shared');
				frames = tex;
				animation.addByPrefix('idle', 'BF idle dance', 24, false);
				animation.addByPrefix('singUP', 'BF NOTE UP0', 24, false);
				animation.addByPrefix('singLEFT', 'BF NOTE LEFT0', 24, false);
				animation.addByPrefix('singRIGHT', 'BF NOTE RIGHT0', 24, false);
				animation.addByPrefix('singDOWN', 'BF NOTE DOWN0', 24, false);
				animation.addByPrefix('singUPmiss', 'BF NOTE UP MISS', 24, false);
				animation.addByPrefix('singLEFTmiss', 'BF NOTE LEFT MISS', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'BF NOTE RIGHT MISS', 24, false);
				animation.addByPrefix('singDOWNmiss', 'BF NOTE DOWN MISS', 24, false);
				animation.addByPrefix('hey', 'BF HEY', 24, false);

				animation.addByPrefix('cut', 'BF hit', 24, false);

				animation.addByPrefix('firstDeath', "BF dies", 24, false);
				animation.addByPrefix('deathLoop', "BF Dead Loop", 24, true);
				animation.addByPrefix('deathConfirm', "BF Dead confirm", 24, false);

				animation.addByPrefix('scared', 'BF idle shaking', 24);
				var scaredFrames=[];
				for(i in 0...24){
					scaredFrames.push(i%3);
				}
				animation.addByIndices('dischargeScared', 'BF idle shaking', scaredFrames, "", 24, false);

				loadOffsets();
				addOffset("dischargeScared",animOffsets.get("scared")[0],animOffsets.get("scared")[1]);
				playAnim('idle');

				flipX = true;

			case 'mikeeey':
				isReskin=true;
				var tex = Paths.getSparrowAtlas('characters/reskins/mikeeey','shared');
				frames = tex;
				animation.addByPrefix('idle', 'BF idle dance', 24, false);
				animation.addByPrefix('singUP', 'BF NOTE UP0', 24, false);
				animation.addByPrefix('singLEFT', 'BF NOTE LEFT0', 24, false);
				animation.addByPrefix('singRIGHT', 'BF NOTE RIGHT0', 24, false);
				animation.addByPrefix('singDOWN', 'BF NOTE DOWN0', 24, false);
				animation.addByPrefix('singUPmiss', 'BF NOTE UP MISS', 24, false);
				animation.addByPrefix('singLEFTmiss', 'BF NOTE LEFT MISS', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'BF NOTE RIGHT MISS', 24, false);
				animation.addByPrefix('singDOWNmiss', 'BF NOTE DOWN MISS', 24, false);
				animation.addByPrefix('hey', 'BF HEY', 24, false);

				animation.addByPrefix('cut', 'BF hit', 24, false);

				animation.addByPrefix('firstDeath', "BF dies", 24, false);
				animation.addByPrefix('deathLoop', "BF Dead Loop", 24, true);
				animation.addByPrefix('deathConfirm', "BF Dead confirm", 24, false);

				animation.addByPrefix('scared', 'BF idle shaking', 24);
				var scaredFrames=[];
				for(i in 0...24){
					scaredFrames.push(i%3);
				}
				animation.addByIndices('dischargeScared', 'BF idle shaking', scaredFrames, "", 24, false);

				loadOffsets();
				addOffset("dischargeScared",animOffsets.get("scared")[0],animOffsets.get("scared")[1]);
				playAnim('idle');

				flipX = true;

			case 'erderi':
				isReskin=true;
				var tex = Paths.getSparrowAtlas('characters/reskins/erderi','shared');
				frames = tex;
				animation.addByPrefix('idle', 'BF idle dance', 24, false);
				animation.addByPrefix('singUP', 'BF NOTE UP0', 24, false);
				animation.addByPrefix('singLEFT', 'BF NOTE LEFT0', 24, false);
				animation.addByPrefix('singRIGHT', 'BF NOTE RIGHT0', 24, false);
				animation.addByPrefix('singDOWN', 'BF NOTE DOWN0', 24, false);
				animation.addByPrefix('singUPmiss', 'BF NOTE UP MISS', 24, false);
				animation.addByPrefix('singLEFTmiss', 'BF NOTE LEFT MISS', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'BF NOTE RIGHT MISS', 24, false);
				animation.addByPrefix('singDOWNmiss', 'BF NOTE DOWN MISS', 24, false);
				animation.addByPrefix('hey', 'BF HEY', 24, false);

				animation.addByPrefix('cut', 'BF hit', 24, false);

				animation.addByPrefix('firstDeath', "BF dies", 24, false);
				animation.addByPrefix('deathLoop', "BF Dead Loop", 24, true);
				animation.addByPrefix('deathConfirm', "BF Dead confirm", 24, false);

				animation.addByPrefix('scared', 'BF idle shaking', 24);
				var scaredFrames=[];
				for(i in 0...24){
					scaredFrames.push(i%3);
				}
				animation.addByIndices('dischargeScared', 'BF idle shaking', scaredFrames, "", 24, false);

				loadOffsets();
				addOffset("dischargeScared",animOffsets.get("scared")[0],animOffsets.get("scared")[1]);
				playAnim('idle');

				flipX = true;
			case 'naikaze':
				isReskin=true;
				var tex = Paths.getSparrowAtlas('characters/reskins/Naikaze','shared');
				frames = tex;
				animation.addByPrefix('idle', 'Naikaze idle dance', 24, false);
				animation.addByPrefix('singUP', 'Naikaze Sing Note Up0', 24, false);
				animation.addByPrefix('singLEFT', 'Naikaze Sing Note Right0', 24, false);
				animation.addByPrefix('singRIGHT', 'Naikaze Sing Note LEFT0', 24, false);
				animation.addByPrefix('singDOWN', 'Naikaze Sing Note DOWN0', 24, false);
				animation.addByPrefix('singUPmiss', 'Naikaze Sing Note Up Miss', 24, false);
				animation.addByPrefix('singLEFTmiss', 'Naikaze Sing Note Right Miss', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'Naikaze Sing Note LEFT Miss', 24, false);
				animation.addByPrefix('singDOWNmiss', 'Naikaze Sing Note DOWN Miss', 24, false);
				animation.addByPrefix('hey', 'BF HEY', 24, false);

				animation.addByPrefix('cut', 'BF hit copy', 24, false);

				animation.addByPrefix('firstDeath', "BF dies", 24, false);
				animation.addByPrefix('deathLoop', "BF DEAD Loop", 24, true);
				animation.addByPrefix('deathConfirm', "BF Dead confirm", 24, false);

				animation.addByPrefix('scared', 'Naikaze idle shaking', 24);
				var scaredFrames=[];
				for(i in 0...24){
					scaredFrames.push(i%3);
				}
				animation.addByIndices('dischargeScared', 'Naikaze idle shaking', scaredFrames, "", 24, false);

				loadOffsets();
				addOffset("dischargeScared",animOffsets.get("scared")[0],animOffsets.get("scared")[1]);
				playAnim('idle');

				flipX = true;

			case 'bfside':
				isReskin=true;
				var tex = Paths.getSparrowAtlas('characters/reskins/Mini_Brightside','shared');
				frames = tex;
				animation.addByPrefix('idle', 'Brighty_Idle0', 24, false);
				animation.addByPrefix('singUP', 'Brighty_Up0', 24, false);
				animation.addByPrefix('singLEFT', 'Brighty_Left0', 24, false);
				animation.addByPrefix('singRIGHT', 'Brighty_Right0', 24, false);
				animation.addByPrefix('singDOWN', 'Brighty_Down0', 24, false);
				animation.addByPrefix('singUPmiss', 'Brighty_Up Miss', 24, false);
				animation.addByPrefix('singLEFTmiss', 'Brighty_Left Miss', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'Brighty_Right Miss', 24, false);
				animation.addByPrefix('singDOWNmiss', 'Brighty_Down Miss', 24, false);
				animation.addByPrefix('hey', 'Brighty_Hey', 24, false);

				animation.addByPrefix('cut', 'Brighty_Hit', 24, false);

				animation.addByPrefix('firstDeath', "Brighty_having_a_breakdown", 24, false);
				animation.addByPrefix('deathLoop', "Brighty_breakdown_loop", 24, true);
				animation.addByPrefix('deathConfirm', "Brighty_breakdown_accept", 24, false);

				animation.addByPrefix('scared', 'Brighty_Idle Shaking', 24);
				var scaredFrames=[];
				for(i in 0...24){
					scaredFrames.push(i%3);
				}
				animation.addByIndices('dischargeScared', 'Brighty_Idle Shaking', scaredFrames, "", 24, false);
				setGraphicSize(Std.int(width*1.5));
				updateHitbox();
				loadOffsets();
				addOffset("dischargeScared",animOffsets.get("scared")[0],animOffsets.get("scared")[1]);
				playAnim('idle');

				flipX = true;
			case 'babyvase':
				isReskin=true;
				var tex = Paths.getSparrowAtlas('characters/reskins/Mini_Vase','shared');
				frames = tex;
				animation.addByPrefix('idle', 'Mini_Vase Idle0', 24, false);
				animation.addByPrefix('singUP', 'Mini_Vase Up0', 24, false);
				animation.addByPrefix('singLEFT', 'Mini_Vase Left0', 24, false);
				animation.addByPrefix('singRIGHT', 'Mini_Vase Right0', 24, false);
				animation.addByPrefix('singDOWN', 'Mini_Vase Down0', 24, false);
				animation.addByPrefix('singUPmiss', 'Mini_Vase Up Miss', 24, false);
				animation.addByPrefix('singLEFTmiss', 'Mini_Vase Left Miss', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'Mini_Vase Right Miss', 24, false);
				animation.addByPrefix('singDOWNmiss', 'Mini_Vase Down Miss', 24, false);
				animation.addByPrefix('hey', 'Mini_Vase Pose', 24, false);

				animation.addByPrefix('cut', 'Mini_Vase Ouch', 24, false);

				animation.addByPrefix('firstDeath', "Mini_Vase Die0", 24, false);
				animation.addByPrefix('deathLoop', "Mini_Vase Die_Loop", 24, true);
				animation.addByPrefix('deathConfirm', "Mini_Vase Die_Confirm", 24, false);

				animation.addByPrefix('scared', 'Mini_Vase Shaking Idle', 24);
				var scaredFrames=[];
				for(i in 0...24){
					scaredFrames.push(i%3);
				}
				animation.addByIndices('dischargeScared', 'Mini_Vase Shaking Idle', scaredFrames, "", 24, false);
				setGraphicSize(Std.int(width*1.3));
				loadOffsets();
				addOffset("dischargeScared",animOffsets.get("scared")[0],animOffsets.get("scared")[1]);
				playAnim('idle');

				flipX = true;

			case 'sword' | 'arrow' | 'depressed' | 'twat' | 'swordarrow' | 'swordtwat' | 'sworddepressed' | 'swordarrowtwat' | 'swordarrowdepressed' | 'swordtwatdepressed' | 'arrowtwat' | 'arrowdepressed' | 'twatdepressed' | 'arrowtwatdepressed' | 'swordarrowtwatdepressed':
				isReskin=true;
				var tex = Paths.getSparrowAtlas('characters/items/${curCharacter}','shared');
				frames = tex;
				animation.addByPrefix('idle', 'BF idle dance', 24, false);
				animation.addByPrefix('singUP', 'BF NOTE UP0', 24, false);
				animation.addByPrefix('singLEFT', 'BF NOTE LEFT0', 24, false);
				animation.addByPrefix('singRIGHT', 'BF NOTE RIGHT0', 24, false);
				animation.addByPrefix('singDOWN', 'BF NOTE DOWN0', 24, false);
				animation.addByPrefix('singUPmiss', 'BF NOTE UP MISS', 24, false);
				animation.addByPrefix('singLEFTmiss', 'BF NOTE LEFT MISS', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'BF NOTE RIGHT MISS', 24, false);
				animation.addByPrefix('singDOWNmiss', 'BF NOTE DOWN MISS', 24, false);
				animation.addByPrefix('hey', 'BF HEY', 24, false);

				animation.addByPrefix('cut', 'BF hit', 24, false);

				animation.addByPrefix('firstDeath', "BF dies", 24, false);
				animation.addByPrefix('deathLoop', "BF Dead Loop", 24, true);
				animation.addByPrefix('deathConfirm', "BF Dead confirm", 24, false);

				animation.addByPrefix('scared', 'BF idle shaking', 24);
				var scaredFrames=[];
				for(i in 0...24){
					scaredFrames.push(i%3);
				}
				animation.addByIndices('dischargeScared', 'BF idle shaking', scaredFrames, "", 24, false);

				loadOffsets();
				addOffset("dischargeScared",animOffsets.get("scared")[0],animOffsets.get("scared")[1]);
				playAnim('idle');

				flipX = true;

			case 'bf-neb':
				isReskin=true;
				var tex = Paths.getSparrowAtlas('characters/nebBF','shared');
				frames = tex;
				animation.addByPrefix('idle', 'BF idle dance', 24, false);
				animation.addByPrefix('singUP', 'BF NOTE UP0', 24, false);
				animation.addByPrefix('singLEFT', 'BF NOTE LEFT0', 24, false);
				animation.addByPrefix('singRIGHT', 'BF NOTE RIGHT0', 24, false);
				animation.addByPrefix('singDOWN', 'BF NOTE DOWN0', 24, false);
				animation.addByPrefix('singUPmiss', 'BF NOTE UP MISS', 24, false);
				animation.addByPrefix('singLEFTmiss', 'BF NOTE LEFT MISS', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'BF NOTE RIGHT MISS', 24, false);
				animation.addByPrefix('singDOWNmiss', 'BF NOTE DOWN MISS', 24, false);
				animation.addByPrefix('hey', 'BF HEY', 24, false);

				animation.addByPrefix('firstDeath', "BF dies", 24, false);
				animation.addByPrefix('deathLoop', "BF Dead Loop", 24, true);
				animation.addByPrefix('deathConfirm', "BF Dead confirm", 24, false);

				animation.addByPrefix('scared', 'BF idle shaking', 24);

				loadOffsets();
				playAnim('idle');

				flipX = true;

			case 'bf-christmas':
				var tex = Paths.getSparrowAtlas('characters/bfChristmas','shared');
				frames = tex;
				animation.addByPrefix('idle', 'BF idle dance', 24, false);
				animation.addByPrefix('singUP', 'BF NOTE UP0', 24, false);
				animation.addByPrefix('singLEFT', 'BF NOTE LEFT0', 24, false);
				animation.addByPrefix('singRIGHT', 'BF NOTE RIGHT0', 24, false);
				animation.addByPrefix('singDOWN', 'BF NOTE DOWN0', 24, false);
				animation.addByPrefix('singUPmiss', 'BF NOTE UP MISS', 24, false);
				animation.addByPrefix('singLEFTmiss', 'BF NOTE LEFT MISS', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'BF NOTE RIGHT MISS', 24, false);
				animation.addByPrefix('singDOWNmiss', 'BF NOTE DOWN MISS', 24, false);
				animation.addByPrefix('hey', 'BF HEY', 24, false);

				loadOffsets();
				playAnim('idle');

				flipX = true;
			case 'bf-car':
				var tex = Paths.getSparrowAtlas('characters/bfCar','shared');
				frames = tex;
				animation.addByPrefix('idle', 'BF idle dance', 24, false);
				animation.addByPrefix('singUP', 'BF NOTE UP0', 24, false);
				animation.addByPrefix('singLEFT', 'BF NOTE LEFT0', 24, false);
				animation.addByPrefix('singRIGHT', 'BF NOTE RIGHT0', 24, false);
				animation.addByPrefix('singDOWN', 'BF NOTE DOWN0', 24, false);
				animation.addByPrefix('singUPmiss', 'BF NOTE UP MISS', 24, false);
				animation.addByPrefix('singLEFTmiss', 'BF NOTE LEFT MISS', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'BF NOTE RIGHT MISS', 24, false);
				animation.addByPrefix('singDOWNmiss', 'BF NOTE DOWN MISS', 24, false);

				loadOffsets();
				playAnim('idle');

				flipX = true;
			case 'bf-pixel':
				frames = Paths.getSparrowAtlas('characters/bfPixel','shared');
				animation.addByPrefix('idle', 'idle', 24, false);
				animation.addByPrefix('singUP', 'up0', 24, false);
				animation.addByPrefix('singLEFT', 'left0', 24, false);
				animation.addByPrefix('singRIGHT', 'right0', 24, false);
				animation.addByPrefix('singDOWN', 'down0', 24, false);
				animation.addByPrefix('singUPmiss', 'up MISS', 24, false);
				animation.addByPrefix('singLEFTmiss', 'left MISS', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'right MISS', 24, false);
				animation.addByPrefix('singDOWNmiss', 'down MISS', 24, false);

				setGraphicSize(Std.int(width * PlayState.daPixelZoom));
				updateHitbox();
				loadOffsets();
				playAnim('idle');

				width -= 100;
				height -= 100;

				antialiasing = false;

				flipX = true;
			case 'bf-pixel-dead':
				frames = Paths.getSparrowAtlas('characters/bfPixelsDEAD','shared');
				animation.addByPrefix('singUP', "BF Dies pixel", 24, false);
				animation.addByPrefix('firstDeath', "BF Dies pixel", 24, false);
				animation.addByPrefix('deathLoop', "Retry Loop", 24, true);
				animation.addByPrefix('deathConfirm', "RETRY CONFIRM", 24, false);
				animation.play('firstDeath');

				loadOffsets();
				playAnim('firstDeath');
				// pixel bullshit
				setGraphicSize(Std.int(width * 6));
				updateHitbox();
				antialiasing = false;
				flipX = true;
			case 'bf-FUCKING-DIES':
				frames = Paths.getSparrowAtlas('characters/BFFUCKINGDIES','shared');
				animation.addByPrefix('singUP', "BF dies", 24, false);
				animation.addByPrefix('firstDeath', "BF dies", 24, false);
				animation.addByPrefix('deathLoop', "BF Dead Loop", 24, true);
				animation.addByPrefix('deathConfirm', "BF Dead confirm", 24, false);
				animation.play('firstDeath');

				loadOffsets();
				playAnim('firstDeath');
				updateHitbox();
				antialiasing = true;
				flipX = true;
			case 'naikaze-FUCKING-DIES' | 'tgr-FUCKING-DIES' | 'erderi-FUCKING-DIES' | 'mikeeey-FUCKING-DIES':
				isReskin=true;
				frames = Paths.getSparrowAtlas('characters/reskins/${curCharacter.toLowerCase()}','shared');
				animation.addByPrefix('singUP', "BF dies", 24, false);
				animation.addByPrefix('firstDeath', "BF dies", 24, false);
				animation.addByPrefix('deathLoop', "BF Dead Loop", 24, true);
				animation.addByPrefix('deathConfirm', "BF Dead confirm", 24, false);
				animation.play('firstDeath');

				loadOffsets();
				playAnim('firstDeath');
				updateHitbox();
				antialiasing = true;
				flipX = true;
			case 'senpai':
				frames = Paths.getSparrowAtlas('characters/Senpai_Assets','shared');
				animation.addByPrefix('idle', 'SENPAI Idle', 24, false);
				animation.addByPrefix('singUP', 'SENPAI UP NOTE', 24, false);
				animation.addByPrefix('singLEFT', 'SENPAI LEFT NOTE', 24, false);
				animation.addByPrefix('singRIGHT', 'SENPAI RIGHT NOTE', 24, false);
				animation.addByPrefix('singDOWN', 'SENPAI DOWN NOTE', 24, false);

				loadOffsets();
				playAnim('idle');

				setGraphicSize(Std.int(width * PlayState.daPixelZoom * 1.25));
				updateHitbox();

				antialiasing = false;
			case 'senpai-angry':
				frames = Paths.getSparrowAtlas('characters/Senpai_Assets','shared');
				animation.addByPrefix('idle', 'ANGRY SENPAI Idle', 24, false);
				animation.addByPrefix('singUP', 'ANGRY SENPAI UP NOTE', 24, false);
				animation.addByPrefix('singLEFT', 'ANGRY SENPAI LEFT NOTE', 24, false);
				animation.addByPrefix('singRIGHT', 'ANGRY SENPAI RIGHT NOTE', 24, false);
				animation.addByPrefix('singDOWN', 'ANGRY SENPAI DOWN NOTE', 24, false);

				loadOffsets();
				playAnim('idle');

				setGraphicSize(Std.int(width * PlayState.daPixelZoom * 1.25));
				updateHitbox();

				antialiasing = false;

			case 'spirit':
				frames = Paths.getSparrowAtlas('characters/Spirit_Assets','shared');
				animation.addByPrefix('idle', "idle0", 24, false);
				animation.addByPrefix('singUP', "up0", 24, false);
				animation.addByPrefix('singRIGHT', "right0", 24, false);
				animation.addByPrefix('singLEFT', "left0", 24, false);
				animation.addByPrefix('singDOWN', "down0", 24, false);

				loadOffsets();
				setGraphicSize(Std.int(width * PlayState.daPixelZoom));
				updateHitbox();

				playAnim('idle');

				antialiasing = false;

			case 'parents-christmas':
				frames = Paths.getSparrowAtlas('characters/mom_dad_christmas_assets','shared');
				animation.addByPrefix('idle', 'Parent Christmas Idle', 24, false);
				animation.addByPrefix('singUP', 'Parent Up Note Dad', 24, false);
				animation.addByPrefix('singDOWN', 'Parent Down Note Dad', 24, false);
				animation.addByPrefix('singLEFT', 'Parent Left Note Dad', 24, false);
				animation.addByPrefix('singRIGHT', 'Parent Right Note Dad', 24, false);

				animation.addByPrefix('singUP-alt', 'Parent Up Note Mom', 24, false);

				animation.addByPrefix('singDOWN-alt', 'Parent Down Note Mom', 24, false);
				animation.addByPrefix('singLEFT-alt', 'Parent Left Note Mom', 24, false);
				animation.addByPrefix('singRIGHT-alt', 'Parent Right Note Mom', 24, false);

				loadOffsets();

				playAnim('idle');
			case 'army' | 'armyRight':
				frames = Paths.getSparrowAtlas("characters/Army_Assets","shared");
				animation.addByPrefix('idle', 'army IDLE', 24, false);
				animation.addByPrefix('singUP', ' army UP ', 24, false);
				animation.addByPrefix('singDOWN', ' army DOWN', 24, false);
				animation.addByPrefix('singLEFT', ' army LEFT', 24, false);
				animation.addByPrefix('singRIGHT', ' army RIGHT', 24, false);

				animation.addByIndices('singDOWNHold',' army DOWN',[6,7], "", 24, false);

				animation.addByIndices('singDOWNRepeat',' army DOWN',[3,4,5,6,7], "", 24, false);
				if(curCharacter!='armyRight')
					flipX=true;

				loadOffsets();

				playAnim("idle");
			case 'omega':
				frames = Paths.getSparrowAtlas('characters/omega_assets','shared');
				animation.addByPrefix('idle', 'Omega idle dance', 24, false);
				animation.addByPrefix('singUP', 'Omega Sing Note UP0', 24, false);
				animation.addByPrefix('singDOWN', 'Omega Sing Note DOWN0', 24, false);
				animation.addByPrefix('singLEFT', 'Omega Sing Note LEFT0', 24, false);
				animation.addByPrefix('singRIGHT', 'Omega Sing Note RIGHT0', 24, false);

				animation.addByPrefix('singUPmiss', 'Omega Sing Note UP miss', 24, false);
				animation.addByPrefix('singDOWNmiss', 'Omega Sing Note DOWN MISS', 24, false);
				animation.addByPrefix('singLEFTmiss', 'Omega Sing Note LEFT Miss', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'Omega Sing Note RIGHT miss', 24, false);

				animation.addByIndices("grabChild","Omega Alt Note0", [1,2,3,4,5,6,7,8,9,10], "", 24, false);
				animation.addByIndices("throwChild","Omega Alt Note0", [11,12,13,14,15,16,17,18,19,20,21,22,23,24,25], "", 32, false);

				loadOffsets();
				playAnim('idle');
			case 'angry-omega':
				frames = Paths.getSparrowAtlas("characters/mad_omega","shared");
				animation.addByPrefix('idle', 'omega boss idle', 24);
				animation.addByPrefix('singUP', 'omega boss UP', 24, false);
				animation.addByPrefix('singDOWN', 'OMEGA FUCKING DOWN ', 24, false);
				animation.addByPrefix('singLEFT', 'OMEGA LEFT', 24, false);
				animation.addByPrefix('singRIGHT', 'OMEGA RIGHT', 24, false);

				loadOffsets();
				playAnim("idle");
			case 'noke':
				frames = Paths.getSparrowAtlas("characters/noke","shared");
				animation.addByPrefix('idle', 'noke idle', 24);
				animation.addByPrefix('singUP', 'noke up', 24, true);
				animation.addByPrefix('singDOWN', 'noke down', 24, true);
				animation.addByPrefix('singLEFT', 'noke left', 24, true);
				animation.addByPrefix('singRIGHT', 'noke right', 24, true);

				animation.addByPrefix('singUPHHold', 'noke up', 24, true);
				animation.addByPrefix('singDOWNHold', 'noke down', 24, true);
				animation.addByPrefix('singLEFTHold', 'noke left', 24, true);
				animation.addByPrefix('singRIGHTHold', 'noke right', 24, true);

				loadOffsets();
				playAnim("idle");
				setGraphicSize(Std.int((width*2)*.6));
			case 'king':
				frames = Paths.getSparrowAtlas("characters/King","shared");
				animation.addByPrefix('idle', 'King Idle', 24, false);
				animation.addByPrefix('singUP', 'King Up', 24, false);
				animation.addByPrefix('singDOWN', 'King Down', 24, false);
				animation.addByPrefix('singLEFT', 'King Left', 24, false);
				animation.addByPrefix('singRIGHT', 'King Right', 24, false);
				flipX=true;
				loadOffsets();
				playAnim("idle");

			case 'flexy':
				frames = Paths.getSparrowAtlas("characters/Flexy","shared");
				animation.addByPrefix('idle', 'flexy idle', 24, false);
				animation.addByPrefix('singUP', 'flexy up note', 24, false);
				animation.addByPrefix('singDOWN', 'flexy down note', 24, false);
				animation.addByPrefix('singLEFT', 'flexy left note', 24, false);
				animation.addByPrefix('singRIGHT', 'flexy right note', 24, false);

				loadOffsets();
				playAnim("idle");

			case 'mika':
				frames = Paths.getSparrowAtlas("characters/mika_passive_assets","shared");
				animation.addByPrefix('idle', 'CHILD idle passive', 24, false);
				animation.addByPrefix('singUP', 'CHILD up passive', 24, false);
				animation.addByPrefix('singDOWN', 'CHILD down passive', 24, false);
				animation.addByPrefix('singLEFT', 'CHILD left passive', 24, false);
				animation.addByPrefix('singRIGHT', 'CHILD right passive', 24, false);

				loadOffsets();
				playAnim("idle");
			case 'angry-fucking-child':
				frames = Paths.getSparrowAtlas("characters/mika_agressive","shared");
				animation.addByPrefix('idle', 'CHILD idle', 24, false);
				animation.addByPrefix('singUP', 'CHILD up', 24, false);
				animation.addByPrefix('singDOWN', 'CHILD down', 24, false);
				animation.addByPrefix('singLEFT', 'CHILD left', 24, false);
				animation.addByPrefix('singRIGHT', 'CHILD right', 24, false);
				animation.addByIndices('cry', 'CHILD down', [0,1,2,3,4,5,6,7,8], "", 16, false);

				loadOffsets();
				addOffset("cry",animOffsets.get("singDOWN")[0],animOffsets.get("singDOWN")[1]);


				playAnim("idle");

			case 'demetrios':
				frames = Paths.getSparrowAtlas("characters/demetrios","shared");
				animation.addByPrefix('idle', 'idle', 24, false);
				animation.addByPrefix('singUP', 'demetrios up', 24, false);
				animation.addByPrefix('singDOWN', 'demetrios down', 24, false);
				animation.addByPrefix('singLEFT', 'demetrios left', 24, false);
				animation.addByPrefix('singRIGHT', 'demetrios right', 24, false);
				animation.addByIndices('discharge', 'demetrios alt', [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,17,18,19,20,21,22,23], '', 24, false);

				animation.addByIndices('singUPHold', 'demetrios up', [11], "", 24, false);
				animation.addByIndices('singDOWNHold', 'demetrios down', [11], "", 24, false);
				animation.addByIndices('singLEFTHold', 'demetrios left', [11], "", 24, false);
				animation.addByIndices('singRIGHTHold', 'demetrios right', [11], "", 24, false);

				loadOffsets();
				playAnim("idle");

				setGraphicSize(Std.int(width*1.35));

			case 'thehivemind':
				frames = Paths.getSparrowAtlas("philly/glasshouses","week3");
				animation.addByPrefix("idle","idle",24,false);
				animation.addByPrefix("singDOWN","down",24,false);
				animation.addByPrefix("singUP","up",24,false);
				animation.addByPrefix("singLEFT","left",24,false);
				animation.addByPrefix("singRIGHT","right",24,false);

				loadOffsets();
				playAnim("idle");
			case 'kapi':
				frames = Paths.getSparrowAtlas("characters/emokapi","shared");
				animation.addByPrefix("idle","kapi idle",24,false);
				animation.addByPrefix("singUP","kapi up",24,false);
				animation.addByPrefix("singDOWN","kapi down",24,false);
				animation.addByPrefix("singLEFT","kapi left",24,false);
				animation.addByPrefix("singRIGHT","kapi right",24,false);

				loadOffsets();
				setGraphicSize(Std.int(width*.9) );

				playAnim("idle");
			case 'anders':
				frames = Paths.getSparrowAtlas("characters/AndersFromTheAndersMod","shared");
				animation.addByPrefix("idle","anders_f_idle",24,false);
				animation.addByPrefix("singUP","anders_f_up_note",24,false);
				animation.addByPrefix("singDOWN","anders_f_down_note",24,false);
				animation.addByPrefix("singLEFT","anders_f_left_note",24,false);
				animation.addByPrefix("singRIGHT","anders_f_right_note",24,false);

				loadOffsets();

				playAnim("idle");
			case 'merchant':
				frames = Paths.getSparrowAtlas("characters/merchant","shared");
				animation.addByPrefix("idle","merchant idle",24,false);
				animation.addByPrefix("singUP","merchant up",24,false);
				animation.addByPrefix("singDOWN","merchant down",24,false);
				animation.addByPrefix("singLEFT","merchant left",24,false);
				animation.addByPrefix("singRIGHT","merchant right",24,false);
				loadOffsets();

				playAnim("idle");
		}


		dance();

		if (isPlayer && !backupCharacter)
		{
			flipX = !flipX;

			// Doesn't flip for BF, since his are already in the right place???
			if (!curCharacter.startsWith('bf') && !isReskin)
			{
				// var animArray
				var oldRight = animation.getByName('singRIGHT').frames;
				animation.getByName('singRIGHT').frames = animation.getByName('singLEFT').frames;
				animation.getByName('singLEFT').frames = oldRight;

				// IF THEY HAVE MISS ANIMATIONS??
				if (animation.getByName('singRIGHTmiss') != null)
				{
					var oldMiss = animation.getByName('singRIGHTmiss').frames;
					animation.getByName('singRIGHTmiss').frames = animation.getByName('singLEFTmiss').frames;
					animation.getByName('singLEFTmiss').frames = oldMiss;
				}
			}
		}
	}

	public function loadOffsets(){
		var offsets:Array<String>= CoolUtil.coolTextFile(Paths.txtImages('characters/offsets/${curCharacter}Offsets',"shared"));
		for(idx in 0...offsets.length){
			var s = offsets[idx];
			var stuff:Array<String> = s.split(" ");
			addOffset(stuff[0],Std.parseFloat(stuff[1]),Std.parseFloat(stuff[2]));
		}
	}

	public function loadAnimations(){
		trace("loading anims for " + curCharacter);
		try {
			var anims:Array<String>;
			anims = CoolUtil.coolTextFile(Paths.txtImages("characters/"+curCharacter+"Anims","shared"));
			for(s in anims){
				var stuff:Array<String> = s.split(" ");
				var type = stuff.splice(0,1)[0];
				var name = stuff.splice(0,1)[0];
				var fps = Std.parseInt(stuff.splice(0,1)[0]);
				trace(type,name,stuff.join(" "),fps);
				if(type.toLowerCase()=='prefix'){
					animation.addByPrefix(name, stuff.join(" "), fps, false);
				}else if(type.toLowerCase()=='indices'){
					var shit = stuff.join(" ");
					var indiceShit = shit.split("/")[1];
					var prefixShit = shit.split("/")[0];
					var newArray:Array<Int> = [];
					for(i in indiceShit.split(" ")){
						newArray.push(Std.parseInt(i));
					};
					animation.addByIndices(name, prefixShit, newArray, "", fps, false);
				}
			}
		} catch(e:Dynamic) {
			trace("FUCK" + e);
		}
	}

	override function update(elapsed:Float)
	{

		if (!isPlayer)
		{
			if(animation.getByName('${animation.curAnim.name}Hold')!=null){
				holding=false;
				if(animation.curAnim.name.startsWith("sing") && !animation.curAnim.name.endsWith("Hold") && animation.curAnim.finished){
					playAnim(animation.curAnim.name + "Hold",true);
				}
			}

			if (animation.curAnim.name.startsWith('sing'))
			{
				holdTimer += elapsed;
			}

			var dadVar:Float = 4;

			switch(curCharacter){
				case 'dad' | 'omega' | 'angry-omega' | 'father':
					dadVar = 6.1;
			}

			if (holdTimer >= Conductor.stepCrochet * dadVar * 0.001)
			{
				dance();

				holdTimer = 0;
			}
		}

		switch (curCharacter)
		{
			case 'gf':
				if ((animation.curAnim.name == 'hairFall' || animation.curAnim.name=='cheer') && animation.curAnim.finished)
					playAnim('danceRight');
			case 'omega':
				if (animation.curAnim.name == 'throwChild' && animation.curAnim.finished)
					playAnim('idle');
			case 'demetrios':
				if (animation.curAnim.name == 'discharge' && animation.curAnim.finished)
					playAnim('idle');
			default:
				if ((animation.curAnim.name == 'cut' || animation.curAnim.name=="dischargeScared") && animation.curAnim.finished)
					playAnim('idle');
		}

		super.update(elapsed);

		if(holding)
			animation.curAnim.curFrame=0;
	}

	private var danced:Bool = false;

	/**
	 * FOR GF DANCING SHIT
	 */
	public function dance()
	{
		if (!debugMode && !disabledDance)
		{
			holding=false;
			switch(curCharacter){
			case 'angry-fucking-child':
				if(animation.curAnim.name!='cry')
					playAnim('idle');
			case 'demetrios':
				if(animation.curAnim.name!='discharge')
					playAnim('idle');
			case 'omega':
				if(animation.curAnim.name!='throwChild' && animation.curAnim.name!='grabChild')
					playAnim('idle');
			default:
				if(animation.curAnim.name!='cut' && animation.curAnim.name!='dischargeScared'){
					if(animation.getByName("idle")!=null)
						playAnim("idle");
					else if (animation.getByName("danceRight")!=null && animation.getByName("danceLeft")!=null){
						if (!animation.curAnim.name.startsWith('hair') && animation.curAnim.name!='cheer')
						{
							danced = !danced;

							if (danced)
								playAnim('danceRight');
							else
								playAnim('danceLeft');
						}
					}
				}
			}
		}
	}

	public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0):Void
	{
		if(animation.curAnim!=null && AnimName!='grabChild' && AnimName!='throwChild' && (animation.curAnim.name=='grabChild' || animation.curAnim.name=='throwChild') && AnimName!='idle')
			return;

		if(AnimName.endsWith("miss") && animation.getByName(AnimName)==null ){
			AnimName = AnimName.substring(0,AnimName.length-4);
		}

		//animation.getByName(AnimName).frameRate=animation.getByName(AnimName).frameRate;
		animation.play(AnimName, Force, Reversed, Frame);

		var daOffset = animOffsets.get(AnimName);
		if (animOffsets.exists(AnimName))
		{
			offset.set(daOffset[0], daOffset[1]);
		}
		else
			offset.set(0, 0);

		if (curCharacter == 'gf')
		{
			if (AnimName == 'singLEFT')
			{
				danced = true;
			}
			else if (AnimName == 'singRIGHT')
			{
				danced = false;
			}

			if (AnimName == 'singUP' || AnimName == 'singDOWN')
			{
				danced = !danced;
			}
		}
	}

	public function addOffset(name:String, x:Float = 0, y:Float = 0)
	{
		offsetNames.push(name);
		animOffsets[name] = [x, y];
	}
}
