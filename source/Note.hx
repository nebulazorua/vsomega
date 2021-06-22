package;

import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
#if polymod
import polymod.format.ParseRules.TargetSignatureElement;
#end

using StringTools;

class Note extends FlxSprite
{
	public var strumTime:Float = 0;

	public var mustPress:Bool = false;
	public var noteData:Int = 0;
	public var canBeHit:Bool = false;
	public var tooLate:Bool = false;
	public var wasGoodHit:Bool = false;
	public var prevNote:Note;
	public var hit:Bool = false;
	public var rating:String = "sick";
	public var lastSustainPiece = false;
	public var defaultX:Float = 0;
	public var sustainLength:Float = 0;
	public var isSustainNote:Bool = false;
	public var rawNoteData:Int = 0; // for charting shit and thats it LOL
	public var holdParent:Bool=false;
	public var noteType:Int = 0;
	public var beingCharted:Bool=false;

	public var isSword:Bool = false;
	public var isGlitch:Bool=false;
	public var isShield:Bool=false;
	public var isDischarge:Bool=false;
	public var whoSingsShit:String = '0';

	public var noteScore:Float = 1;

	public static var swagWidth:Float = 160 * 0.7;
	public static var PURP_NOTE:Int = 0;
	public static var GREEN_NOTE:Int = 2;
	public static var BLUE_NOTE:Int = 1;
	public static var RED_NOTE:Int = 3;

	public function new(strumTime:Float, noteData:Int, ?prevNote:Note, ?gottaHitNote:Bool=false, ?sustainNote:Bool = false, ?sword:Bool = false, ?glitch:Bool = false, ?singingShit:String = "0", ?shield:Bool=false,?discharge:Bool=false)
	{
		super();

		if (prevNote == null)
			prevNote = this;

		switch(singingShit){
			case 'bf':
				whoSingsShit='0';
			case 'omega':
				whoSingsShit='1';
			case 'both':
				whoSingsShit='2';
			default:
				whoSingsShit='0';
		}
		whoSingsShit = singingShit;
		mustPress = gottaHitNote;
		// cringe old code
		if(sword)
			noteType=1;

		if(glitch)
			noteType=2;

		if(shield)
			noteType=3;

		if(discharge)
			noteType=4;
		this.prevNote = prevNote;
		isSustainNote = sustainNote;

		x += 50;
		// MAKE SURE ITS DEFINITELY OFF SCREEN?
		y -= 2000;
		this.strumTime = strumTime;

		this.noteData = noteData;

		var daStage:String = PlayState.curStage;

		switch (daStage)
		{
			case 'school' | 'schoolEvil':
				var scale = gottaHitNote?PlayState.currentPState.modchart.playerNoteScale:PlayState.currentPState.modchart.opponentNoteScale;
				loadGraphic(Paths.image('weeb/pixelUI/arrows-pixels'), true, 16, 16);

				animation.add('greenScroll', [6]);
				animation.add('redScroll', [7]);
				animation.add('blueScroll', [5]);
				animation.add('purpleScroll', [4]);

				if (isSustainNote)
				{
					loadGraphic(Paths.image('weeb/pixelUI/arrowEnds'), true, 7, 6);

					animation.add('purpleholdend', [4]);
					animation.add('greenholdend', [6]);
					animation.add('redholdend', [7]);
					animation.add('blueholdend', [5]);

					animation.add('purplehold', [0]);
					animation.add('greenhold', [2]);
					animation.add('redhold', [3]);
					animation.add('bluehold', [1]);
				}

				setGraphicSize(Std.int(width * 6 * scale));
				updateHitbox();

			default:
				var scale = gottaHitNote?PlayState.currentPState.modchart.playerNoteScale:PlayState.currentPState.modchart.opponentNoteScale;
				switch(noteType){
					case 1:
						var widMult = .7*scale;
						frames = Paths.getSparrowAtlas('SWORD_NOTE');
						var animationName = "Sword0";
						if(PlayState.SONG.song.toLowerCase()=='curse-eternal'){ // TODO: player2 == mika
							animationName = 'Shadow0';
						}else if(PlayState.SONG.player2=='army' || PlayState.SONG.player2=='armyRight'){
							animationName = 'spear0';
						}
						animation.addByPrefix('greenScroll', animationName);
						animation.addByPrefix('redScroll', animationName);
						animation.addByPrefix('blueScroll', animationName);
						animation.addByPrefix('purpleScroll', animationName);
						setGraphicSize(Std.int(width * widMult));

						updateHitbox();
						offset.x -= 10*scale;
						antialiasing = true;
					case 2:
						var widMult = .7*scale;
						frames = Paths.getSparrowAtlas("GLITCH_NOTE");
						animation.addByPrefix('purpleScroll', 'glitchRIGHT0', 24);
						animation.addByPrefix('greenScroll', 'glitchUP0', 24);
						animation.addByPrefix('redScroll', 'glitchLEFT0', 24);
						animation.addByPrefix('blueScroll', 'glitchDOWN0', 24);

						animation.addByPrefix('purplehold', 'glitch sus0', 24);
						animation.addByPrefix('greenhold', 'glitch sus0', 24);
						animation.addByPrefix('redhold', 'glitch sus0', 24);
						animation.addByPrefix('bluehold', 'glitch sus0', 24);

						animation.addByPrefix('purpleholdend', 'glitch sus end', 24);
						animation.addByPrefix('greenholdend', 'glitch sus end', 24);
						animation.addByPrefix('redholdend', 'glitch sus end', 24);
						animation.addByPrefix('blueholdend', 'glitch sus end', 24);

						setGraphicSize(Std.int(width * widMult));
						updateHitbox();
						antialiasing = true;
					case 3:
						var widMult = .7*scale;
						isSustainNote=false;
						if(PlayState.SONG.player2=='merchant' ){
							frames = Paths.getSparrowAtlas('Gold_notes');

							animation.addByPrefix('greenScroll', 'green0');
							animation.addByPrefix('redScroll', 'red0');
							animation.addByPrefix('blueScroll', 'blue0');
							animation.addByPrefix('purpleScroll', 'purple0');
							setGraphicSize(Std.int(width * widMult));
							updateHitbox();
							antialiasing = true;
						}else{
							frames = Paths.getSparrowAtlas('SHIELD_NOTE');

							animation.addByPrefix('greenScroll', 'Shield Note0');
							animation.addByPrefix('redScroll', 'Shield Note0');
							animation.addByPrefix('blueScroll', 'Shield Note0');
							animation.addByPrefix('purpleScroll', 'Shield Note0');
							setGraphicSize(Std.int(width * widMult));
							updateHitbox();
							antialiasing = true;
						}
					case 4:
						isSustainNote=false;
						var widMult = .7*scale;
						frames = Paths.getSparrowAtlas('FoguCrush_NOTE');

						animation.addByPrefix('greenScroll', 'Lightning0');
						animation.addByPrefix('redScroll', 'Lightning0');
						animation.addByPrefix('blueScroll', 'Lightning0');
						animation.addByPrefix('purpleScroll', 'Lightning0');


						setGraphicSize(Std.int(width * widMult));
						offset.x += (width*widMult)/2 - 13.8;
						offset.y += (width*widMult)/2 - 13;
						antialiasing = true;
					default:
						var widMult = .7*scale;
						frames = Paths.getSparrowAtlas('NOTE_assets');

						animation.addByPrefix('greenScroll', 'green0');
						animation.addByPrefix('redScroll', 'red0');
						animation.addByPrefix('blueScroll', 'blue0');
						animation.addByPrefix('purpleScroll', 'purple0');

						animation.addByPrefix('purpleholdend', 'pruple end hold');
						animation.addByPrefix('greenholdend', 'green hold end');
						animation.addByPrefix('redholdend', 'red hold end');
						animation.addByPrefix('blueholdend', 'blue hold end');

						animation.addByPrefix('purplehold', 'purple hold piece');
						animation.addByPrefix('greenhold', 'green hold piece');
						animation.addByPrefix('redhold', 'red hold piece');
						animation.addByPrefix('bluehold', 'blue hold piece');

						setGraphicSize(Std.int(width * widMult));
						updateHitbox();
						antialiasing = true;
					}
		}

		switch (noteData)
		{
			case 0:
				x += swagWidth * 0;
				animation.play('purpleScroll');
			case 1:
				x += swagWidth * 1;
				animation.play('blueScroll');
			case 2:
				x += swagWidth * 2;
				animation.play('greenScroll');
			case 3:
				x += swagWidth * 3;
				animation.play('redScroll');
		}
		switch(noteType){
			case 1:
				isSustainNote=false;
			default:

		}

		// trace(prevNote);

		if (isSustainNote && prevNote != null)
		{
			var scale = gottaHitNote?PlayState.currentPState.modchart.playerNoteScale:PlayState.currentPState.modchart.opponentNoteScale;
			prevNote.holdParent=true;
			noteScore * 0.2;
			if(!PlayState.curStage.startsWith("school"))
				alpha = 0.6;

			//var off = -width;
			var off = -width/4;
			//x+=width/2;
			lastSustainPiece=true;

			switch (noteData)
			{
				case 2:
					animation.play('greenholdend');
				case 3:
					animation.play('redholdend');
				case 1:
					animation.play('blueholdend');
				case 0:
					animation.play('purpleholdend');
			}

			updateHitbox();

			if(PlayState.currentPState.currentOptions.downScroll){
				flipY=true;
			}

			//off -= width / 2;
			//x -= width / 2;
			if (PlayState.curStage.startsWith('school'))
				off -= 34;
			else
				off -= 2;


			if(noteType==2 || PlayState.curStage.startsWith("school")){
				alpha = 1;
			}
			offset.x = off;

			if (prevNote.isSustainNote)
			{
				prevNote.lastSustainPiece=false;
				var offset = prevNote.offset.x;
				switch (prevNote.noteData)
				{
					case 0:
						prevNote.animation.play('purplehold');
					case 1:
						prevNote.animation.play('bluehold');
					case 2:
						prevNote.animation.play('greenhold');
					case 3:
						prevNote.animation.play('redhold');
				}

				prevNote.scale.y = (Conductor.stepCrochet / 100 * prevNote.scale.y * 1.5 * FlxMath.roundDecimal(PlayState.SONG.speed,2));
				prevNote.scale.y+=prevNote.scale.y*(1-scale);

				prevNote.updateHitbox();
				prevNote.offset.x = offset;
				// prevNote.setGraphicSize();
			}
		}
	}

	override function update(elapsed:Float)
	{
		if(!beingCharted){
			if (mustPress)
			{
				if ((noteType==1 || noteType==2) && strumTime<Conductor.songPosition-20 || strumTime < Conductor.songPosition - Conductor.safeZoneOffset && !wasGoodHit)
					tooLate = true;

				if(!tooLate){
					switch(noteType){
						case 2: // glitch notes
							if(isSustainNote){
								if (strumTime > Conductor.songPosition - 25
									&& strumTime < Conductor.songPosition + 50)
									canBeHit = true;
								else
									canBeHit = false;
							}else{
								if (strumTime > Conductor.songPosition - Conductor.safeZoneOffset*.75
									&& strumTime < Conductor.songPosition + (Conductor.safeZoneOffset * .5))
									canBeHit = true;
								else
									canBeHit = false;
							}


						default: // all others
							if(isSustainNote){
								if (strumTime > Conductor.songPosition - 80
									&& strumTime < Conductor.songPosition + 60)
									canBeHit = true;
								else
									canBeHit = false;
							}else{
								if (strumTime > Conductor.songPosition - (Conductor.safeZoneOffset * 1.5)
									&& strumTime < Conductor.songPosition + (Conductor.safeZoneOffset * 1))
									canBeHit = true;
								else
									canBeHit = false;
							}
					}
				}
				if(tooLate)
					canBeHit=false;
			}
			else
			{
				if (strumTime <= Conductor.songPosition && noteType!=1 && noteType!=2)
					canBeHit = true;
			}

			if (tooLate && !PlayState.curStage.startsWith("school"))
			{
				if (alpha > 0.3)
					alpha = 0.3;
			}
		}
		super.update(elapsed);
	}
}
