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
	public var canMiss:Bool=false;
	public var beingCharted:Bool=false;
	public var keyAmount = 4;

	public var isSword:Bool = false;
	public var isGlitch:Bool=false;
	public var isShield:Bool=false;
	public var isDischarge:Bool=false;
	public var whoSingsShit:String = '0';
	public var susOffset:Float = 0;

	public var noteScore:Float = 1;

	public static var swagWidth:Float = 160 * 0.7;
	public static var PURP_NOTE:Int = 0;
	public static var GREEN_NOTE:Int = 2;
	public static var BLUE_NOTE:Int = 1;
	public static var RED_NOTE:Int = 3;

	public function new(strumTime:Float, noteData:Int, ?prevNote:Note, ?gottaHitNote:Bool=false, ?sustainNote:Bool = false, ?sword:Bool = false, ?glitch:Bool = false, ?singingShit:String = "0", ?shield:Bool=false,?discharge:Bool=false,?type:Int=0)
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
			case '0' | '1' | '2':
				whoSingsShit=singingShit;
			default:
				whoSingsShit='0';
		}


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

		if(type!=0 && noteType==0){
			noteType=type;
		}
		this.prevNote = prevNote;
		isSustainNote = sustainNote;

		x += 50;
		// MAKE SURE ITS DEFINITELY OFF SCREEN?
		y -= 2000;
		this.strumTime = strumTime;

		this.noteData = noteData;

		var daStage:String = PlayState.curStage;
		var scale = gottaHitNote?PlayState.currentPState.modchart.playerNoteScale:PlayState.currentPState.modchart.opponentNoteScale;

		switch (daStage)
		{
			case 'school' | 'schoolEvil':
				if(noteType==2){
					canMiss=true;

					loadGraphic(Paths.image('weeb/pixelUI/arrows-pixels-glitch'), true, 16, 16);
					animation.add('greenScroll', [2]);
					animation.add('redScroll', [3]);
					animation.add('blueScroll', [1]);
					animation.add('purpleScroll', [0]);
				}else{
					loadGraphic(Paths.image('weeb/pixelUI/arrows-pixels'), true, 16, 16);

					animation.add('greenScroll', [6]);
					animation.add('redScroll', [7]);
					animation.add('blueScroll', [5]);
					animation.add('purpleScroll', [4]);
				}


				if (isSustainNote)
				{
					if(noteType==2)
						loadGraphic(Paths.image('weeb/pixelUI/glitchEnds'), true, 7, 6);
					else
						loadGraphic(Paths.image('weeb/pixelUI/arrowEnds'), true, 7, 6);


					animation.add('greenScroll', [6]);
					animation.add('redScroll', [7]);
					animation.add('blueScroll', [5]);
					animation.add('purpleScroll', [4]);

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
				switch(noteType){
					case 1:
						canMiss=true;
						var widMult = .7;
						frames = Paths.getSparrowAtlas('SWORD_NOTE');
						var animationName = "Sword0";
						if(PlayState.SONG.player2=='mika' || PlayState.SONG.player2=='angry-fucking-child'){ // TODO: player2 == mika
							animationName = 'Shadow0';
						}else if(PlayState.SONG.player2=='army' || PlayState.SONG.player2=='armyRight'){
							animationName = 'spear0';
						}
						animation.addByPrefix('greenScroll', animationName);
						animation.addByPrefix('redScroll', animationName);
						animation.addByPrefix('blueScroll', animationName);
						animation.addByPrefix('purpleScroll', animationName);

						animation.addByPrefix('yellowScroll', animationName);
						animation.addByPrefix('navyScroll', animationName);
						animation.addByPrefix('lavenderScroll', animationName);

						setGraphicSize(Std.int((width * widMult)*scale));

						updateHitbox();
						antialiasing = true;
					case 2:
						canMiss=true;
						var widMult = .7;
						frames = Paths.getSparrowAtlas("GLITCH_NOTE");
						animation.addByPrefix('purpleScroll', 'glitchRIGHT0', 24, true);
						animation.addByPrefix('greenScroll', 'glitchUP0', 24, true);
						animation.addByPrefix('redScroll', 'glitchLEFT0', 24, true);
						animation.addByPrefix('blueScroll', 'glitchDOWN0', 24, true);

						animation.addByPrefix('yellowScroll', 'glitchRIGHT0', 24, true);
						animation.addByPrefix('lavenderScroll', 'glitchUP0', 24, true);
						animation.addByPrefix('navyScroll', 'glitchLEFT0', 24, true);

						animation.addByPrefix('purplehold', 'glitch sus0', 24);
						animation.addByPrefix('greenhold', 'glitch sus0', 24);
						animation.addByPrefix('redhold', 'glitch sus0', 24);
						animation.addByPrefix('bluehold', 'glitch sus0', 24);

						animation.addByPrefix('yellowhold', 'glitch sus0', 24, true);
						animation.addByPrefix('lavenderhold', 'glitch sus0', 24, true);
						animation.addByPrefix('navyhold', 'glitch sus0', 24, true);

						animation.addByPrefix('purpleholdend', 'glitch sus end', 24);
						animation.addByPrefix('greenholdend', 'glitch sus end', 24);
						animation.addByPrefix('redholdend', 'glitch sus end', 24);
						animation.addByPrefix('blueholdend', 'glitch sus end', 24);

						animation.addByPrefix('yellowholdend', 'glitch sus end', 24, true);
						animation.addByPrefix('lavenderholdend', 'glitch sus end', 24, true);
						animation.addByPrefix('navyholdend', 'glitch sus end', 24, true);

						setGraphicSize(Std.int((width * widMult)*scale));
						updateHitbox();
						antialiasing = true;
					case 3:
						canMiss=true;
						var widMult = .7;
						isSustainNote=false;
						if(PlayState.SONG.player2=='merchant' ){
							frames = Paths.getSparrowAtlas('Gold_notes');

							animation.addByPrefix('greenScroll', 'green0');
							animation.addByPrefix('redScroll', 'red0');
							animation.addByPrefix('blueScroll', 'blue0');
							animation.addByPrefix('purpleScroll', 'purple0');

							animation.addByPrefix('navyScroll', 'red0');
							animation.addByPrefix('lavenderScroll', 'green0');
							animation.addByPrefix('yellowScroll', 'purple0');

							setGraphicSize(Std.int((width * widMult)*scale));
							updateHitbox();
							antialiasing = true;
						}else{
							frames = Paths.getSparrowAtlas('SHIELD_NOTE');

							animation.addByPrefix('greenScroll', 'Shield Note0');
							animation.addByPrefix('redScroll', 'Shield Note0');
							animation.addByPrefix('blueScroll', 'Shield Note0');
							animation.addByPrefix('purpleScroll', 'Shield Note0');

							animation.addByPrefix('navyScroll', 'Shield Note0');
							animation.addByPrefix('lavenderScroll', 'Shield Note0');
							animation.addByPrefix('yellowScroll', 'Shield Note0');
							setGraphicSize(Std.int((width * widMult)*scale));
							updateHitbox();
							antialiasing = true;
						}
					case 4:
						isSustainNote=false;
						var widMult = .7;
						frames = Paths.getSparrowAtlas('FoguCrush_NOTE');

						animation.addByPrefix('greenScroll', 'Lightning0');
						animation.addByPrefix('redScroll', 'Lightning0');
						animation.addByPrefix('blueScroll', 'Lightning0');
						animation.addByPrefix('purpleScroll', 'Lightning0');

						animation.addByPrefix('navyScroll', 'Lightning0');
						animation.addByPrefix('lavenderScroll', 'Lightning0');
						animation.addByPrefix('yellowScroll', 'Lightning0');


						setGraphicSize(Std.int((width * widMult)*scale));
						updateHitbox();
						offset.x += (width/4);
						offset.y += (width/4);
						antialiasing = true;
					case 5: // torch
						canMiss=true;
						isSustainNote=false;
						var widMult = .6;
						frames = Paths.getSparrowAtlas('TORCHES');

						animation.addByPrefix('greenScroll', 'green0');
						animation.addByPrefix('redScroll', 'red0');
						animation.addByPrefix('blueScroll', 'blue0');
						animation.addByPrefix('purpleScroll', 'purple0');

						animation.addByPrefix('navyScroll', 'red0');
						animation.addByPrefix('lavenderScroll', 'green0');
						animation.addByPrefix('yellowScroll', 'purple0');
						setGraphicSize(Std.int((width * widMult)*scale));
						//offset.x += (width*widMult)/2 - 13.8;
						//offset.y += (height*widMult)/2 + 16;
						updateHitbox();
						antialiasing = true;
						offset.x += 4;
						offset.y += (height/4)+8;
					case 6: // gem
						var widMult = .7;
						if(isSustainNote){
							if(PlayState.keyAmount==6){
								frames = Paths.getSparrowAtlas('6K_NOTE_assets');

								animation.addByPrefix('redScroll', 'red0');
								animation.addByPrefix('blueScroll', 'blue0');
								animation.addByPrefix('purpleScroll', 'purple0');

								animation.addByPrefix('yellowScroll', 'yellow0');
								animation.addByPrefix('lavenderScroll', 'lavender0');
								animation.addByPrefix('navyScroll', 'navy0');

								animation.addByPrefix('purpleholdend', 'pruple end hold');
								animation.addByPrefix('redholdend', 'red hold end');
								animation.addByPrefix('blueholdend', 'blue hold end');

								animation.addByPrefix('yellowholdend', 'yellow end hold');
								animation.addByPrefix('lavenderholdend', 'lavender hold end');
								animation.addByPrefix('navyholdend', 'navy hold end');

								animation.addByPrefix('purplehold', 'purple hold piece');
								animation.addByPrefix('redhold', 'red hold piece');
								animation.addByPrefix('bluehold', 'blue hold piece');

								animation.addByPrefix('yellowhold', 'yellow hold piece');
								animation.addByPrefix('lavenderhold', 'lavender hold piece');
								animation.addByPrefix('navyhold', 'navy hold piece');
							}else{
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
							}
						}else{
							frames = Paths.getSparrowAtlas('GEMS');

							animation.addByPrefix('greenScroll', 'green0');
							animation.addByPrefix('redScroll', 'red0');
							animation.addByPrefix('blueScroll', 'blue0');
							animation.addByPrefix('purpleScroll', 'purple0');

							animation.addByPrefix('navyScroll', 'red0');
							animation.addByPrefix('lavenderScroll', 'green0');
							animation.addByPrefix('yellowScroll', 'purple0');
						}
						setGraphicSize(Std.int((width * widMult)*scale));
						/*if(!isSustainNote){
							offset.x += (width*widMult)/2 - 30;
							offset.y += 13;
						}else
							updateHitbox();*/
						updateHitbox();
						antialiasing = true;


					case 7: // black gem
						isSustainNote=false;
						var widMult = .7;
						frames = Paths.getSparrowAtlas('BLACKGEMS');

						animation.addByPrefix('greenScroll', 'green0');
						animation.addByPrefix('redScroll', 'red0');
						animation.addByPrefix('blueScroll', 'blue0');
						animation.addByPrefix('purpleScroll', 'purple0');

						animation.addByPrefix('navyScroll', 'red0');
						animation.addByPrefix('lavenderScroll', 'green0');
						animation.addByPrefix('yellowScroll', 'purple0');
						setGraphicSize(Std.int((width * widMult)*scale));
						updateHitbox();
						//offset.x += (width*widMult)/2 - 30;
						//offset.y += 13;
						antialiasing = true;
					default:
						var widMult = .7;
						if(PlayState.keyAmount==6){
							frames = Paths.getSparrowAtlas('6K_NOTE_assets');

							animation.addByPrefix('redScroll', 'red0');
							animation.addByPrefix('blueScroll', 'blue0');
							animation.addByPrefix('purpleScroll', 'purple0');

							animation.addByPrefix('yellowScroll', 'yellow0');
							animation.addByPrefix('lavenderScroll', 'lavender0');
							animation.addByPrefix('navyScroll', 'navy0');

							animation.addByPrefix('purpleholdend', 'pruple end hold');
							animation.addByPrefix('redholdend', 'red hold end');
							animation.addByPrefix('blueholdend', 'blue hold end');

							animation.addByPrefix('yellowholdend', 'yellow end hold');
							animation.addByPrefix('lavenderholdend', 'lavender hold end');
							animation.addByPrefix('navyholdend', 'navy hold end');

							animation.addByPrefix('purplehold', 'purple hold piece');
							animation.addByPrefix('redhold', 'red hold piece');
							animation.addByPrefix('bluehold', 'blue hold piece');

							animation.addByPrefix('yellowhold', 'yellow hold piece');
							animation.addByPrefix('lavenderhold', 'lavender hold piece');
							animation.addByPrefix('navyhold', 'navy hold piece');
						}else{
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
						}


						setGraphicSize(Std.int((width * widMult)*scale));
						updateHitbox();
						antialiasing = true;
					}
		}

		var names = ["purple","blue","green","red"];
		if(PlayState.keyAmount==6){
			names=["purple","blue","red","yellow","lavender","navy"];
		}
		x += (swagWidth*scale)*noteData;
		animation.play(names[noteData] + "Scroll");
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

			susOffset = width/2;
			lastSustainPiece=true;

			animation.play(names[noteData]+"holdend");

			updateHitbox();

			if(PlayState.currentPState.currentOptions.downScroll){
				this.scale.y *= -1;
			}

			susOffset -= width/ 2;
			if (PlayState.curStage.startsWith('school'))
				susOffset += 30*scale;
			else
				susOffset +=1;


			if(noteType==2 || PlayState.curStage.startsWith("school")){
				alpha = 1;
			}

			offset.x *= scale;
			offset.y *= scale;

			if (prevNote.isSustainNote)
			{
				prevNote.lastSustainPiece=false;
				prevNote.animation.play(names[noteData]+"hold");

				prevNote.scale.y *= Conductor.stepCrochet / 100 * 1.5 * FlxMath.roundDecimal(PlayState.SONG.speed,2) * (1/scale);

				prevNote.updateHitbox();
				prevNote.offset.x *= scale;
				prevNote.offset.y *= scale;
			}
		}
	}

	override function update(elapsed:Float)
	{
		if(!beingCharted){
			if (mustPress)
			{
				if ((noteType==1 || noteType==2 || noteType==5) && strumTime<Conductor.songPosition-20 || strumTime < Conductor.songPosition - Conductor.safeZoneOffset && !wasGoodHit)
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
						case 5: // torch
							if (strumTime > Conductor.songPosition - Conductor.safeZoneOffset*1
								&& strumTime < Conductor.songPosition + (Conductor.safeZoneOffset * .75))
								canBeHit = true;
							else
								canBeHit = false;
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
