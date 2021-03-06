package;

#if desktop
import Discord.DiscordClient;
#end
import Options;
import Conductor.BPMChangeEvent;
import Section.SwagSection;
import RunningChild.MikaRunAnimMarker;
import Song.SwagSong;
import WiggleEffect.WiggleEffectType;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.effects.FlxTrail;
import flixel.addons.effects.FlxTrailArea;
import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.atlas.FlxAtlas;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxCollision;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;
import haxe.Json;
import openfl.display.BlendMode;
import openfl.display.StageQuality;
import openfl.filters.ShaderFilter;
import flash.display.BitmapData;
import flash.display.Bitmap;
import Shaders;
import haxe.Exception;
import openfl.utils.Assets;
import ModChart;
import flixel.group.FlxSpriteGroup;

using StringTools;

class PlayState extends MusicBeatState
{
	public static var currentPState:PlayState;
	private var trackedAssets:Array<Dynamic> = [];

	public static var curStage:String = '';
	public static var SONG:SwagSong;
	public static var didIntro:Bool = false;
	public static var doIntro:Bool=false;

	public static var isStoryMode:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 1;
	public var dontSync:Bool=false;
	public var currentTrackPos:Float = 0;
	public var currentVisPos:Float = 0;
	var beenSavedByResistance:Bool = false;
	var currentSVIndex:Int = 0;

	var halloweenLevel:Bool = false;

	private var vocals:FlxSound;

	private var dad:Character;
	private var gf:Character;
	private var boyfriend:Boyfriend;
	private var omega:Boyfriend;
	private var mika:Character;
	private var armyRight:Character;
	private var mikaRun:RunningChild;

	private var renderedNotes:FlxTypedGroup<Note>;
	private var opponentRenderedNotes:FlxTypedGroup<Note>;
	private var playerRenderedNotes:FlxTypedGroup<Note>;
	private var hittableNotes:Array<Note> = [];
	private var unspawnNotes:Array<Note> = [];

	private var strumLine:FlxSprite;
	private var curSection:Int = 0;

	private var camFollow:FlxObject;
	private var aCamFollow:FlxObject;

	public var currentOptions:Options;

	private var prevCamFollow:FlxObject;
	private var lastHitDadNote:Note;
	private var strumLineNotes:FlxSpriteGroup;
	private var playerStrums:FlxSpriteGroup;
	private var dadStrums:FlxSpriteGroup;
	private var grayscaleStrumLines:FlxSpriteGroup;
	private var grayscalePlayerStrums:FlxSpriteGroup;
	private var grayscaleDadStrums:FlxSpriteGroup;
	private var playerStrumLines:FlxSpriteGroup;
	public var refNotes:FlxSpriteGroup;
	public var opponentRefNotes:FlxSpriteGroup;
	private var opponentStrumLines:FlxSpriteGroup;
	public static var keyAmount:Int = 4;
	public static var blueballs:Int = 0;

	public var mikaShit:Array<MikaRunAnimMarker> = [];

	private var camZooming:Bool = true;
	private var curSong:String = "";

	private var gfSpeed:Int = 1;
	private var health:Float = 1;
	private var previousHealth:Float = 1;
	private var combo:Int = 0;
	private var highestCombo:Int = 0;

	private var healthBarBG:FlxSprite;
	private var healthBar:FlxBar;
	private var displayedHealth:Float = 1;

	private var generatedMusic:Bool = false;
	private var startingSong:Bool = false;

	private var iconP1:HealthIcon;
	private var iconP2:HealthIcon;
	private var camHUD:FlxCamera;
	public static var pauseHUD:FlxCamera;
	private var camGame:FlxCamera;
	public var modchart:ModChart;
	public var botplayPressTimes:Array<Float> = [0,0,0,0];
	public var botplayHoldTimes:Array<Float> = [0,0,0,0];
	public var botplayHoldMaxTimes:Array<Float> = [0,0,0,0];

	public var songPos:Float = 0;

	public static var dishonorNotes:FlxAtlasFrames;
	var disabledTime:Float = 0;
	var fuckedUpReceptors:Float = 0;
	var noteOrder:Array<Int> = [0,1,2,3];

	public var playerNoteOffsets:Array<Array<Float>> = [
		[0,0], // left
		[0,0], // down
		[0,0], // up / right (6K)
		[0,0],// right / left(6K)
		[0,0], // up (6K)
		[0,0], // right (6K)
	];

	public var opponentNoteOffsets:Array<Array<Float>> = [
		[0,0], // left
		[0,0], // down
		[0,0], // up / right (6K)
		[0,0],// right / left(6K)
		[0,0], // up (6K)
		[0,0], // right (6K)
	];

	public var playerNoteAlpha:Array<Float>=[
		1,
		1,
		1,
		1,
		1,
		1
	];

	public var opponentNoteAlpha:Array<Float>=[
		1,
		1,
		1,
		1,
		1,
		1
	];
	var singAnims = ["singLEFT","singDOWN","singUP","singRIGHT"];


	var dialogue:Array<String> = ['blah blah blah', 'coolswag'];
	var disabledHud=false;
	var dadRock:FlxSprite;
	var bfRock:FlxSprite;
	var void1:FlxSprite;
	var void2:FlxSprite;
	var des1:FlxSprite;
	var des2:FlxSprite;

	var frontBoppers:FlxSprite;
	var backBoppers:FlxSprite;
	var raveGlow:FlxSprite;

	var halloweenBG:FlxSprite;
	var nokeTxt:FlxText; // DISCONNECTED/RECONNECTED
	var nokeFG:FlxSprite; // foreground
	var nokeHFG:FlxSprite; // hollow foreground
	var nokeFG2:FlxSprite; // foreground for scroll
	var nokeHFG2:FlxSprite; // hollow foreground for scroll
	var nokeBG:FlxSprite; // bg
	var nokeHBG:FlxSprite; // hollow bg
	var nokeBG2:FlxSprite; // bg for scroll
	var nokeHBG2:FlxSprite; // hollow bg for scroll
	var nokeFl:FlxSprite; // floor
	var nokeHFl:FlxSprite; // hollow floor
	var isHalloween:Bool = false;
	var discharging:Bool = false; // is demetrios discharging
	var dischargeHP:Float = 1; // so he cant kill you or anything and only leaves you at a low amount, while still allowing you to heal n shit

	var cage1:FlxSprite; // demetrios cage bars
	var cage2:FlxSprite; // demetrios cage bars but like where he sticks out
	var labOverlay:FlxSprite; // green glow thing at the top
	var glowBG:FlxSprite; // bg for when demetrios does his discharge
	var glowCage1:FlxSprite; // ditto, but for cage1
	var glowCage2:FlxSprite; // ditto for cage2

	var queen:FlxSprite;

	var burnTimer:Float = 0; // time to hurt bf for (TORCH NOTES)
	var burnTicks:Float = .25; // interval between each hit of damage while burning (TORCH NOTES)

	var phillyCityLights:FlxSpriteGroup;
	var lightFadeShader:BuildingEffect;
	var glitchNoteEffect:ChromaticAbberationEffect;
	var vcrDistortionHUD:VCRDistortionEffect;
	var grayscaleShader:GrayscaleEffect;
	var isGrayscale:Bool = false;
	var rainShader:RainEffect;
	var vcrDistortionGame:VCRDistortionEffect;
	var phillyTrain:FlxSprite;
	var trainSound:FlxSound;
	var goldOverlay:FlxSprite;
	var goldOverlayTween:FlxTween;
	var limo:FlxSprite;
	var grpLimoDancers:FlxTypedGroup<BackgroundDancer>;
	var fastCar:FlxSprite;

	var anders:FlxSprite; // flecy
	var racistgfwtf:FlxSprite; // ditto
	var carol:FlxSprite; // ditto
	var kfc:FlxSprite; // ditto

	var backroomFG:FlxSprite;

	var vietnamFlashbacks=false; // IM NOT FINISHED YET

	var daKing:FlxSprite; // merchant
	var tabi:FlxSprite; // ditto
	var garlo:FlxSprite; // ditto
	var myBeloved:FlxSprite; // ditto
	var fgShops:FlxSprite; // ditto
	var curseEternalVignette:FlxSprite; // man i hate curse eternal
	// not because its bad but because im a little bitch and cant take it :(
	var upperBoppers:FlxSprite;
	var bottomBoppers:FlxSprite;
	var santa:FlxSprite;
	var slash:FlxSprite;

	var bgGirls:BackgroundGirls;
	var wiggleShit:WiggleEffect = new WiggleEffect();

	var talking:Bool = true;
	var songScore:Int = 0;
	var scoreTxt:FlxText;
	var shitsTxt:FlxText;
	var epicsTxt:FlxText;
	var badsTxt:FlxText;
	var goodsTxt:FlxText;
	var sicksTxt:FlxText;
	var highComboTxt:FlxText;
	var presetTxt:FlxText;
	var missesTxt:FlxText;

	var accuracy:Float = 1;
	var hitNotes:Float = 0;
	var totalNotes:Float = 0;

	var grade:String = ScoreUtils.gradeArray[0];
	var misses:Float = 0;
	var sicks:Float = 0;
	var epics:Float = 0;
	var goods:Float = 0;
	var bads:Float = 0;
	var shits:Float = 0;

	var velocityMarkers:Array<Float>=[];


	public static var campaignScore:Int = 0;

	var defaultCamZoom:Float = 1.05;

	// how big to stretch the pixel art assets
	public static var daPixelZoom:Float = 36;

	var inCutscene:Bool = false;

	#if desktop
	// Discord RPC variables
	var storyDifficultyText:String = "";
	var iconRPC:String = "";
	var songLength:Float = 0;
	var detailsText:String = "";
	var detailsPausedText:String = "";
	#end

	override public function create()
	{
		dishonorNotes = Paths.getSparrowAtlas('DISHONORED_NOTES');
		FlxG.bitmap.undumpCache();
		modchart = new ModChart(this);
		FlxG.sound.music.looped=false;
		currentPState=this;
		currentOptions = OptionUtils.options.clone();
		ScoreUtils.ratingWindows = OptionUtils.ratingWindowTypes[currentOptions.ratingWindow];
		ScoreUtils.ghostTapping = currentOptions.ghosttapping;
		ScoreUtils.botPlay = currentOptions.botPlay;

		Conductor.safeZoneOffset = ScoreUtils.ratingWindows[ScoreUtils.ratingWindows.length-1]; // same as shit ms
		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		controls.setKeyboardScheme(Custom,true);

		grade = ScoreUtils.gradeArray[0] + " (FC)";
		hitNotes=0;
		totalNotes=0;
		misses=0;
		bads=0;
		goods=0;
		sicks=0;
		shits=0;
		accuracy=1;

		// var gameCam:FlxCamera = FlxG.camera;
		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		pauseHUD = new FlxCamera();
		pauseHUD.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD);
		FlxG.cameras.add(pauseHUD);

		FlxCamera.defaultCameras = [camGame];

		persistentUpdate = true;
		persistentDraw = true;

		if (SONG == null)
			SONG = Song.loadFromJson('tutorial');

		SONG.initialSpeed=SONG.speed*.45;
		if(SONG.sliderVelocities!=null){
			SONG.sliderVelocities.sort((a,b)->Std.int(a.startTime-b.startTime));
		}
		mapVelocityChanges();

		// should probably make this switch/case
		// .. whatever lmao

		if(SONG.song.toLowerCase()=='2v200' || SONG.song.toLowerCase()=='hivemind')
			currentOptions.middleScroll=true;

		if(SONG.song.toLowerCase()=='curse-eternal')
			modchart.healthGain = false;

		if(SONG.song.toLowerCase()=='dishonor' ){
			modchart.susHeal=false;
			modchart.noteHPGain = .01;
		}

		if(SONG.song.toLowerCase()=='father-time'){
			modchart.susHeal=false;
			modchart.noteHPGain = .02;
			modchart.opponentHPDrain=.005;
		}


		if(SONG.song.toLowerCase()=='2v200'){
			controls.setKeyboardScheme(SixK,true);
		}
		if(SONG.song.toLowerCase().startsWith('last-stand')){
			modchart.opponentHPDrain = .01;
		}

		if(SONG.song.toLowerCase()=='hivemind'){
			currentOptions.downScroll=true;
			currentOptions.ratingInHUD=true;
			modchart.hudVisible=false;
			modchart.playerNoteScale=1.3;
			modchart.opponentNoteScale=.7;
		}

		var omegaSongs = FreeplayState.unlockables;
		if(FlxG.save.data.unlockedOmegaSongs==null){
			FlxG.save.data.unlockedOmegaSongs=[];
		}
		if(!FlxG.save.data.unlockedOmegaSongs.contains(SONG.song.toLowerCase() )){
			FlxG.save.data.unlockedOmegaSongs.push(SONG.song.toLowerCase());
		}

		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);

		switch (SONG.song.toLowerCase())
		{
			case 'tutorial':
				dialogue = ["Hey you're pretty cute.", 'Use the arrow keys to keep up \nwith me singing.'];
			case 'bopeebo':
				dialogue = [
					'HEY!',
					"You think you can just sing\nwith my daughter like that?",
					"If you want to date her...",
					"You're going to have to go \nthrough ME first!"
				];
			case 'fresh':
				dialogue = ["Not too shabby boy.", ""];
			case 'dadbattle':
				dialogue = [
					"gah you think you're hot stuff?",
					"If you can beat me here...",
					"Only then I will even CONSIDER letting you\ndate my daughter!"
				];
			case 'senpai':
				dialogue = CoolUtil.coolTextFile(Paths.txt('senpai/senpaiDialogue'));
			case 'roses':
				dialogue = CoolUtil.coolTextFile(Paths.txt('roses/rosesDialogue'));
			case 'thorns':
				dialogue = CoolUtil.coolTextFile(Paths.txt('thorns/thornsDialogue'));
			default:
				try {
					dialogue = CoolUtil.coolTextFile(Paths.txt(SONG.song.toLowerCase() + "/dialogue"));
				} catch(e){
					trace("epic style " + e.message);
				}
		}

		#if desktop
		// Making difficulty text for Discord Rich Presence.
		switch (storyDifficulty)
		{
			case 0:
				storyDifficultyText = "Easy";
			case 1:
				storyDifficultyText = "Normal";
			case 2:
				storyDifficultyText = "Hard";
			case 3:
				storyDifficultyText = "Glitch";
		}

		iconRPC = SONG.player2;

		// To avoid having duplicate images in Discord assets
		switch (iconRPC)
		{
			case 'senpai-angry':
				iconRPC = 'senpai';
			case 'monster-christmas':
				iconRPC = 'monster';
			case 'mom-car':
				iconRPC = 'mom';
		}

		// String that contains the mode defined here so it isn't necessary to call changePresence for each mode
		if (isStoryMode)
		{
			detailsText = "Story Mode: Week " + storyWeek+ " ";
		}
		else
		{
			detailsText = "Freeplay"+ " ";
		}

		// String for when the game is paused
		detailsPausedText = "Paused - " + detailsText;

		// Updating Discord Rich Presence.
		DiscordClient.changePresence(detailsText + SONG.song + " (" + storyDifficultyText + ")", iconRPC);
		#end
		try{
			vcrDistortionHUD = new VCRDistortionEffect();
			vcrDistortionGame = new VCRDistortionEffect();
		}catch(e:Any){
			trace(e);
		}
		try{
			glitchNoteEffect = new ChromaticAbberationEffect();
			modchart.addCamEffect(glitchNoteEffect);
			modchart.addHudEffect(glitchNoteEffect);
		}catch(e:Any){
			trace(e);
		}


		try{
			grayscaleShader = new GrayscaleEffect();
		}catch(e:Any){
			trace(e);
		}

		switch (SONG.song.toLowerCase())
		{
              case 'spookeez' | 'south' | 'salem':
              {
								defaultCamZoom = .9;
                curStage = 'spooky';
								var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('week_2_back'));
								bg.screenCenter(XY);
								bg.setGraphicSize(Std.int(bg.width*2.25));
								bg.antialiasing=true;
								bg.scrollFactor.set(.85, .85);
								add(bg);

								var fg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('week_2_ground'));
								fg.screenCenter(XY);
								fg.setGraphicSize(Std.int(fg.width*2.25));
								fg.antialiasing=true;
								fg.scrollFactor.set(1, 1);
								add(fg);
		          }
		          case 'pico' | 'blammed' | 'philly-nice':
                        {
		                  curStage = 'philly';
											if(currentOptions.picoShaders){
												try{
													var grayscale = new GrayscaleEffect();
													grayscale.influence=1;
													grayscale.update();
													modchart.addCamEffect(grayscale);
												}catch(e:Any){
													trace(e);
												}
											}
		                  var bg:FlxSprite = new FlxSprite(-100).loadGraphic(Paths.image('philly/sky'));
		                  bg.scrollFactor.set(0.1, 0.1);
		                  add(bg);

	                          var city:FlxSprite = new FlxSprite(-10).loadGraphic(Paths.image('philly/city'));
		                  city.scrollFactor.set(0.3, 0.3);
		                  city.setGraphicSize(Std.int(city.width * 0.85));
		                  city.updateHitbox();
		                  add(city);
											//modchart.addCamEffect(rainShader);

		                  var streetBehind:FlxSprite = new FlxSprite(-40, 50).loadGraphic(Paths.image('philly/behindTrain'));
		                  add(streetBehind);

											phillyTrain = new FlxSprite(2000, 70).loadGraphic(Paths.image('philly/train'));
											phillyTrain.scrollFactor.set(.6,.6);
								add(phillyTrain);


		                  // var cityLights:FlxSprite = new FlxSprite().loadGraphic(AssetPaths.win0.png);

		                  var street:FlxSprite = new FlxSprite(-40, streetBehind.y).loadGraphic(Paths.image('philly/street'));
	                          add(street);


                trainSound = new FlxSound().loadEmbedded(Paths.sound('train_passes'));
                FlxG.sound.list.add(trainSound);
		          }
		          case 'milf' | 'satin-panties' | 'high':
		          {
		                  curStage = 'limo';
		                  defaultCamZoom = 0.7;

		                  var skyBG:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('limo/sky'));
											skyBG.screenCenter(XY);
											skyBG.y -= 275;
		                  skyBG.scrollFactor.set(0.1, 0.1);
		                  add(skyBG);

											des1 = new FlxSprite(-600, -200).loadGraphic(Paths.image('limo/desert'));
											des1.antialiasing = true;
											des1.setGraphicSize(Std.int(des1.width*2));
											des1.updateHitbox();
											des1.x = -400;
											des1.scrollFactor.set(0.2, 0.2);
											des1.active = false;
											add(des1);

											des2 = new FlxSprite(-600, -200).loadGraphic(Paths.image('limo/desert'));
											des2.antialiasing = true;
											des2.setGraphicSize(Std.int(des2.width*2));
											des2.updateHitbox();
											des2.scrollFactor.set(0.2, 0.2);
											des2.active = false;
											des2.x = -(des2.width)-400;
											add(des2);


		                  var train:FlxSprite = new FlxSprite(90, 157).loadGraphic(Paths.image("limo/train"));
											train.scale.y = 1.2;
											train.scale.x = 1.2;
		                  train.scrollFactor.set(1, 1);
											train.x = -195;
											train.y = 360;
		                  add(train);




		          }
		          case 'cocoa' | 'eggnog':
		          {
	                    curStage = 'mall';

		                  defaultCamZoom = 1;

		                  var bg:FlxSprite = new FlxSprite(-1000, -500).loadGraphic(Paths.image('shit/bg'));
		                  bg.antialiasing = true;
		                  bg.scrollFactor.set(1, 1);
		                  bg.active = false;
											bg.setGraphicSize(Std.int(bg.width*1.3));
											bg.updateHitbox();
											bg.screenCenter(XY);
		                  add(bg);

											var uggos:FlxSprite = new FlxSprite(-1000, -500).loadGraphic(Paths.image('shit/obscured'));
		                  uggos.antialiasing = true;
		                  uggos.scrollFactor.set(.8, .8);
		                  uggos.active = false;
											uggos.setGraphicSize(Std.int(uggos.width*1.3));
											uggos.updateHitbox();
											uggos.screenCenter(XY);
											uggos.y += 35;
		                  add(uggos);

											backBoppers = new FlxSprite();
											backBoppers.frames = Paths.getSparrowAtlas("shit/bgbop");
											backBoppers.animation.addByPrefix("bop","back bop",24,false);
											backBoppers.antialiasing = true;
											backBoppers.scrollFactor.set(.8,.8);
											backBoppers.setGraphicSize(Std.int(backBoppers.width*1.3));
											backBoppers.updateHitbox();
											backBoppers.screenCenter(XY);
											backBoppers.y -= 110;
											add(backBoppers);

											var sidefuckers:FlxSprite = new FlxSprite(-1000, -500).loadGraphic(Paths.image('shit/sidefuckers'));
		                  sidefuckers.antialiasing = true;
		                  sidefuckers.scrollFactor.set(.8, .8);
		                  sidefuckers.active = false;
											sidefuckers.setGraphicSize(Std.int(sidefuckers.width*1.3));
											sidefuckers.updateHitbox();
											sidefuckers.screenCenter(XY);
		                  add(sidefuckers);

											var stage:FlxSprite = new FlxSprite(-1000, -500).loadGraphic(Paths.image('shit/stage'));
		                  stage.antialiasing = true;
		                  stage.scrollFactor.set(1, 1);
		                  stage.active = false;
											stage.setGraphicSize(Std.int(stage.width*1.3));
											stage.updateHitbox();
											stage.screenCenter(XY);
		                  add(stage);

											raveGlow = new FlxSprite().loadGraphic(Paths.image('shit/glow'));
											raveGlow.antialiasing = true;
											raveGlow.scrollFactor.set(1.05,.1);
											raveGlow.active = false;
											raveGlow.setGraphicSize(Std.int(raveGlow.width*1.7));
											raveGlow.updateHitbox();
											raveGlow.screenCenter(XY);

											frontBoppers = new FlxSprite();
											frontBoppers.frames = Paths.getSparrowAtlas("shit/frontbop");
											frontBoppers.animation.addByPrefix("bop","front bop",24,false);
											frontBoppers.antialiasing = true;
											frontBoppers.scrollFactor.set(1.1,1.1);
											frontBoppers.setGraphicSize(Std.int(frontBoppers.width*1.3));
											frontBoppers.updateHitbox();
											frontBoppers.screenCenter(XY);
											frontBoppers.y += 25;
		          }
		          case 'winter-horrorland' | 'monster':
		          {
		                  curStage = 'mallEvil';
											var bg:FlxSprite = new FlxSprite(-1000, -500).loadGraphic(Paths.image('evil/bg'));
											bg.antialiasing = true;
											bg.scrollFactor.set(1, 1);
											bg.active = false;
											bg.setGraphicSize(Std.int(bg.width*1.3));
											bg.updateHitbox();
											bg.screenCenter(XY);
											add(bg);

											var stage:FlxSprite = new FlxSprite(-1000, -500).loadGraphic(Paths.image('evil/stage'));
											stage.antialiasing = true;
											stage.scrollFactor.set(1, 1);
											stage.active = false;
											stage.setGraphicSize(Std.int(stage.width*1.3));
											stage.updateHitbox();
											stage.screenCenter(XY);
											add(stage);


                        }
		          case 'senpai' | 'roses':
		          {
		                  curStage = 'school';
											if(currentOptions.senpaiShaders){
												if(vcrDistortionHUD!=null){
													vcrDistortionHUD.setVignetteMoving(false);
													vcrDistortionGame.setVignette(false);
													if(SONG.song.toLowerCase()=='senpai'){
														vcrDistortionHUD.setDistortion(false);
														vcrDistortionGame.setDistortion(false);
													}else{
														vcrDistortionGame.setGlitchModifier(.025);
														vcrDistortionHUD.setGlitchModifier(.025);
													}
													modchart.addCamEffect(vcrDistortionGame);
													modchart.addHudEffect(vcrDistortionHUD);
												}
											}



		                  // defaultCamZoom = 0.9;

		                  var bgSky = new FlxSprite().loadGraphic(Paths.image('weeb/weebSky'));
		                  bgSky.scrollFactor.set(0.1, 0.1);
		                  add(bgSky);

		                  var repositionShit = -200;

		                  var bgSchool:FlxSprite = new FlxSprite(repositionShit, 0).loadGraphic(Paths.image('weeb/weebSchool'));
		                  bgSchool.scrollFactor.set(0.6, 0.90);
		                  add(bgSchool);

		                  var bgStreet:FlxSprite = new FlxSprite(repositionShit).loadGraphic(Paths.image('weeb/weebStreet'));
		                  bgStreet.scrollFactor.set(0.95, 0.95);
		                  add(bgStreet);

		                  var widShit = Std.int(bgSky.width * 24);

		                  bgSky.setGraphicSize(Std.int(311*6),Std.int(161*6));
		                  bgSchool.setGraphicSize(Std.int(311*6),Std.int(161*6));
		                  bgStreet.setGraphicSize(Std.int(311*6),Std.int(161*6));

		                  bgSky.updateHitbox();
		                  bgSchool.updateHitbox();
		                  bgStreet.updateHitbox();
		          }
		          case 'thorns':
		          {
		                  curStage = 'schoolEvil';
											if(currentOptions.senpaiShaders){
												if(vcrDistortionHUD!=null){
													vcrDistortionGame.setGlitchModifier(.2);
													vcrDistortionHUD.setGlitchModifier(.2);
													modchart.addCamEffect(vcrDistortionGame);
													modchart.addHudEffect(vcrDistortionHUD);
												}
											}

		                  var waveEffectBG = new FlxWaveEffect(FlxWaveMode.ALL, 2, -1, 3, 2);
		                  var waveEffectFG = new FlxWaveEffect(FlxWaveMode.ALL, 2, -1, 5, 2);

		                  var posX = 500;
	                    var posY = 450;

                     var bg:FlxSprite = new FlxSprite(posX, posY).loadGraphic(Paths.image('weeb/evilSchoolBG'));
                     bg.scale.set(6, 6);
                     bg.setGraphicSize(Std.int(311*6),Std.int(161*6));
                     // bg.updateHitbox();
                     add(bg);

                     var fg:FlxSprite = new FlxSprite(posX, posY).loadGraphic(Paths.image('weeb/evilSchoolFG'));
                     fg.scale.set(6, 6);
                     fg.setGraphicSize(Std.int(311*6),Std.int(161*6));
                     // fg.updateHitbox();
                     add(fg);
		          }
							case 'hivemind':
								curStage = 'void';
								var bg = new FlxSprite().makeGraphic(FlxG.width*2,FlxG.height*2,FlxColor.BLACK);
								add(bg);
								defaultCamZoom = .7;
							case 'fragmented-surreality':
								curStage = 'elevator';
								defaultCamZoom = .7;
								nokeBG = new FlxSprite().loadGraphic(Paths.image("cavern/Crystal_Background"));
								nokeBG.screenCenter(X);
								nokeBG.setGraphicSize(Std.int(nokeBG.width*2));
								nokeBG.y = -nokeBG.height+1600;
								nokeBG.scrollFactor.set(0,0);


								nokeHBG = new FlxSprite().loadGraphic(Paths.image("cavern/Crystal_Background_Hollow"));
								nokeHBG.screenCenter(X);
								nokeHBG.setGraphicSize(Std.int(nokeHBG.width*2));
								nokeHBG.y = -nokeBG.height+1600;
								nokeHBG.scrollFactor.set(0,0);

								add(nokeHBG);
								add(nokeBG);

								nokeBG2 = new FlxSprite().loadGraphic(Paths.image("cavern/Crystal_Background"));
								nokeBG2.screenCenter(X);
								nokeBG2.setGraphicSize(Std.int(nokeBG2.width*2));
								nokeBG2.y = -nokeBG2.height*2+1600;
								nokeBG2.scrollFactor.set(0,0);

								nokeHBG2 = new FlxSprite().loadGraphic(Paths.image("cavern/Crystal_Background_Hollow"));
								nokeHBG2.screenCenter(X);
								nokeHBG2.setGraphicSize(Std.int(nokeHBG2.width*2));
								nokeHBG2.y = -nokeHBG2.height*2+1600;
								nokeHBG2.scrollFactor.set(0,0);

								add(nokeHBG2);
								add(nokeBG2);

								nokeFl = new FlxSprite().loadGraphic(Paths.image("cavern/Crystal_Platform"));
								nokeFl.screenCenter(XY);
								nokeFl.setGraphicSize(Std.int(nokeFl.width*2));
								nokeFl.scrollFactor.set(.9,.9);
								nokeFl.y += 550;
								nokeFl.x += 50;

								nokeHFl = new FlxSprite().loadGraphic(Paths.image("cavern/Crystal_Platform_Hollow"));
								nokeHFl.setGraphicSize(Std.int(nokeHFl.width*2));
								nokeHFl.screenCenter(XY);
								nokeHFl.scrollFactor.set(.9,.9);
								nokeHFl.y += 550;
								nokeHFl.x += 50;

								add(nokeHFl);
								add(nokeFl);

								nokeFG = new FlxSprite().loadGraphic(Paths.image("cavern/Crystal_Walls"));
								nokeFG.screenCenter(X);
								nokeFG.setGraphicSize(Std.int(nokeFG.width*2));
								nokeFG.y = -(nokeFG.height+1600);
								nokeFG.scrollFactor.set(0,0);


								nokeHFG = new FlxSprite().loadGraphic(Paths.image("cavern/Crystal_Walls_Hollow"));
								nokeHFG.screenCenter(X);
								nokeHFG.setGraphicSize(Std.int(nokeHFG.width*2));
								nokeHFG.y = -(nokeHFG.height+1600);
								nokeHFG.scrollFactor.set(0,0);

								add(nokeHFG);
								add(nokeFG);

								nokeFG2 = new FlxSprite().loadGraphic(Paths.image("cavern/Crystal_Walls"));
								nokeFG2.screenCenter(X);
								nokeFG2.setGraphicSize(Std.int(nokeFG2.width*2));
								nokeFG2.y = -nokeFG2.height*2+1600;
								nokeFG2.scrollFactor.set(0,0);


								nokeHFG2 = new FlxSprite().loadGraphic(Paths.image("cavern/Crystal_Walls_Hollow"));
								nokeHFG2.setGraphicSize(Std.int(nokeHFG2.width*2));
								nokeHFG2.screenCenter(X);
								nokeHFG2.y = -nokeFG2.height*2+1600;
								nokeHFG2.scrollFactor.set(0,0);


								add(nokeHFG2);
								add(nokeFG2);
						case 'dishonor':
							defaultCamZoom=.85;
							curStage='castle';
							if(currentOptions.dishonorShaders){
								if(grayscaleShader!=null){
									modchart.addCamEffect(grayscaleShader);
								}
							}

							var bg:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('castle/background'));
							bg.setGraphicSize(Std.int(bg.width*1.1));
							bg.screenCenter(XY);
							bg.antialiasing = true;
							bg.scrollFactor.set(.6,.6);
							bg.active = false;
							add(bg);

							var stage:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('castle/stage'));
							stage.setGraphicSize(Std.int(stage.width*1.2));
							stage.screenCenter(XY);
							stage.y += 125;
							stage.x -= 25;
							stage.antialiasing = true;
							stage.scrollFactor.set(1,1);
							stage.active = false;
							add(stage);

							queen = new FlxSprite(-365,160);
							queen.frames = Paths.getSparrowAtlas("castle/Queen");
							queen.flipX = true;
							queen.animation.addByPrefix("idle","queen",24,false);
							queen.setGraphicSize(Std.int(queen.width*.9));
							queen.antialiasing = true;
							queen.scrollFactor.set(1,1);
							add(queen);

							var fg:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('castle/foreground'));
							fg.setGraphicSize(Std.int(bg.width*1.1));
							fg.screenCenter(XY);
							fg.antialiasing = true;
							fg.scrollFactor.set(1,1);
							fg.active = false;
							add(fg);
						case 'oxidation':
							defaultCamZoom = .8;
							curStage='backrooms';
							var bg:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('backrooms/backroomswithcameos'));
							if(FlxG.random.bool(1)){
								bg.loadGraphic(Paths.image('backrooms/red_in_the_backrooms'));
							}
							bg.setGraphicSize(Std.int(bg.width*2.2));
							bg.screenCenter(XY);
							bg.y += 15;
							bg.antialiasing = true;
							bg.scrollFactor.set(1,1);
							bg.active = false;
							add(bg);


							backroomFG = new FlxSprite(0, 0).loadGraphic(Paths.image('backrooms/walls'));
							backroomFG.setGraphicSize(Std.int(backroomFG.width*2.2));
							backroomFG.screenCenter(XY);
							backroomFG.y += 5;
							backroomFG.antialiasing = true;
							backroomFG.scrollFactor.set(1,1);
							backroomFG.active = false;

						case 'no-arm-shogun':
							defaultCamZoom = .4;
							curStage='dojo';
							var bg:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('japan/bg'));
							bg.setGraphicSize(Std.int(bg.width*1));
							bg.screenCenter(XY);
							bg.antialiasing = true;
							bg.y -= 200;
							bg.scrollFactor.set(1, 1);
							bg.active = false;
							add(bg);

						 	anders = new FlxSprite(0, 0);
							anders.frames = Paths.getSparrowAtlas("japan/anders");
							anders.animation.addByPrefix("idle","anders my lover",24,false);
							anders.setGraphicSize(Std.int(anders.width*1));
							anders.screenCenter(XY);
							anders.x += 850;
							anders.y -= 1050;
							anders.antialiasing = true;
							anders.scrollFactor.set(1, 1);
							add(anders);

							racistgfwtf = new FlxSprite(0, 0);
							racistgfwtf.frames = Paths.getSparrowAtlas("japan/gf");
							racistgfwtf.animation.addByPrefix("idle","gf",24,false);
							racistgfwtf.setGraphicSize(Std.int(racistgfwtf.width*1.25));
							racistgfwtf.screenCenter(XY);
							racistgfwtf.flipX = true;
							racistgfwtf.x += 1450;
							racistgfwtf.y += 335;
							racistgfwtf.antialiasing = true;
							racistgfwtf.scrollFactor.set(1, 1);
							add(racistgfwtf);

							carol = new FlxSprite(0, 0);
							carol.frames = Paths.getSparrowAtlas("japan/carol");
							carol.animation.addByPrefix("idle","carol",24,false);
							carol.setGraphicSize(Std.int(carol.width*1.25));
							carol.screenCenter(XY);
							carol.flipX = true;
							carol.x -= 1650;
							carol.y += 235;
							carol.antialiasing = true;
							carol.scrollFactor.set(1, 1);
							add(carol);

							kfc = new FlxSprite(375, 200);
							kfc.frames = Paths.getSparrowAtlas("japan/kfcman");
							kfc.animation.addByPrefix("idle","colonel s(anders) and friend",24,false);
							kfc.setGraphicSize(Std.int(kfc.width*1));
							kfc.x -= 0;
							kfc.y += 0;
							kfc.antialiasing = true;
							kfc.scrollFactor.set(1, 1);
							add(kfc);
						case 'free-soul':
							// TODO: settings
							try{
								wiggleShit.effectType = WiggleEffectType.WAVY;
								wiggleShit.waveAmplitude = 0.01;
								wiggleShit.waveFrequency = 40;
								wiggleShit.waveSpeed = 1;
								camHUD.setFilters([new ShaderFilter(wiggleShit.shader)]);
							}catch(e:Any){
								trace("WHAT");
							}
							curStage='drugmart';
							defaultCamZoom=.7;
							var bg:FlxSprite = new FlxSprite(-182, -311).loadGraphic(Paths.image('drugmarket/bg'));
							bg.setGraphicSize(Std.int(bg.width*1));
							bg.antialiasing = true;
							bg.scrollFactor.set(1, 1);
							bg.active = false;
							add(bg);

							var bgShop:FlxSprite = new FlxSprite(-182, -316).loadGraphic(Paths.image('drugmarket/shop-backs'));
							bgShop.setGraphicSize(Std.int(bgShop.width*1));
							bgShop.antialiasing = true;
							bgShop.scrollFactor.set(1, 1);
							bgShop.active = false;
							add(bgShop);

							daKing = new FlxSprite(975,-600);
							daKing.frames = Paths.getSparrowAtlas("drugmarket/bk");
							daKing.animation.addByPrefix("idle","bk",24,false);
							daKing.setGraphicSize(Std.int(daKing.width*.5));
							daKing.antialiasing = true;
							daKing.scrollFactor.set(1, 1);
							add(daKing);

							myBeloved = new FlxSprite(825, -200);
							myBeloved.frames = Paths.getSparrowAtlas("drugmarket/anders");
							myBeloved.animation.addByPrefix("idle","anders",24,false);
							myBeloved.setGraphicSize(Std.int(myBeloved.width*.5));
							myBeloved.antialiasing = true;
							myBeloved.scrollFactor.set(1, 1);
							add(myBeloved);

							tabi = new FlxSprite(-185, -325);
							tabi.frames = Paths.getSparrowAtlas("drugmarket/tabi");
							tabi.animation.addByPrefix("idle","tabi",24,false);
							tabi.setGraphicSize(Std.int(tabi.width*.5));
							tabi.antialiasing = true;
							tabi.scrollFactor.set(1, 1);
							add(tabi);

							var bgShops:FlxSprite = new FlxSprite(-182, -310).loadGraphic(Paths.image('drugmarket/bg-shops-w-hand'));
							bgShops.setGraphicSize(Std.int(bgShops.width*1));
							bgShops.antialiasing = true;
							bgShops.scrollFactor.set(1, 1);
							bgShops.active = false;
							add(bgShops);


							garlo = new FlxSprite(1400, -500);
							garlo.frames = Paths.getSparrowAtlas("drugmarket/garlo");
							garlo.animation.addByPrefix("idle","garlo",24,false);
							garlo.setGraphicSize(Std.int(garlo.width*.5));
							garlo.antialiasing = true;
							garlo.scrollFactor.set(1, 1);
							add(garlo);

							fgShops = new FlxSprite(-182, -308).loadGraphic(Paths.image('drugmarket/fg-red-blue-store'));
							fgShops.setGraphicSize(Std.int(fgShops.width*1));
							fgShops.antialiasing = true;
							fgShops.scrollFactor.set(1.1, 1.1);
							fgShops.active = false;


						case 'new-retro':
							defaultCamZoom = .7;
							curStage = 'apocalypse';
							var bg:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('apocalypse/sky'));
							bg.setGraphicSize(Std.int(bg.width*1.25));
							bg.screenCenter(XY);
							bg.antialiasing = true;
							bg.scrollFactor.set(.1,.1);
							bg.active = false;
							add(bg);

							var ground:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('apocalypse/ground'));
							ground.setGraphicSize(Std.int(ground.width*1.25));
							ground.screenCenter(XY);
							ground.x -=40;
							ground.y +=470;
							ground.antialiasing = true;
							ground.scrollFactor.set(.4,.4);
							ground.active = false;
							add(ground);

							var houses:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('apocalypse/bg'));
							houses.setGraphicSize(Std.int(houses.width*1.25));
							houses.screenCenter(XY);
							houses.y -= 140;
							houses.antialiasing = true;
							houses.scrollFactor.set(.325,.325);
							houses.active = false;
							add(houses);

							var chars:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('apocalypse/groundchars'));
							chars.setGraphicSize(Std.int(chars.width*1.25));
							chars.screenCenter(XY);
							chars.y += 180;
							chars.y += 320;
							chars.antialiasing = true;
							chars.scrollFactor.set(.5,.4);
							chars.active = false;
							add(chars);

							var fg:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('apocalypse/foreground'));
							fg.setGraphicSize(Std.int(fg.width*1.25));
							fg.screenCenter(XY);
							fg.y += 260;
							fg.antialiasing = true;
							fg.scrollFactor.set(1, 1);
							fg.active = false;
							add(fg);
						case '57.5hz':
							defaultCamZoom = .85;
							curStage = 'lab';
							// TODO: Glowy for discharge
							var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image("lab/labfiltered_BGChar") );
							bg.setGraphicSize(Std.int(bg.width*2*1.1));
							bg.screenCenter(XY);
							bg.y += 90;
							bg.antialiasing=true;
							bg.scrollFactor.set(.95,.95);
							add(bg);

							cage1 = new FlxSprite().loadGraphic(Paths.image("lab/FG1") );
							cage1.setGraphicSize(Std.int(cage1.width*2));
							cage1.screenCenter(XY);
							cage1.x -= 465;
							cage1.y += 115;
							cage1.antialiasing=true;
							cage1.scrollFactor.set(1,1);

							cage2 = new FlxSprite().loadGraphic(Paths.image("lab/FG2") );
							cage2.setGraphicSize(Std.int(cage2.width*2));
							cage2.screenCenter(XY);
							cage2.x -= 465;
							cage2.y += 115;
							cage2.antialiasing=true;
							cage2.scrollFactor.set(1,1);

							glowBG = new FlxSprite().loadGraphic(Paths.image("lab/labfiltered_BGChar_GLOW") );
							glowBG.setGraphicSize(Std.int(glowBG.width*2*1.1));
							glowBG.screenCenter(XY);
							glowBG.alpha = 0;
							glowBG.y += 90;
							glowBG.antialiasing=true;
							glowBG.scrollFactor.set(.95,.95);
							add(glowBG);

							glowCage1 = new FlxSprite().loadGraphic(Paths.image("lab/FG1_GLOW") );
							glowCage1.setGraphicSize(Std.int(glowCage1.width*2));
							glowCage1.screenCenter(XY);
							glowCage1.alpha = 0;
							glowCage1.x -= 465;
							glowCage1.y += 115;
							glowCage1.antialiasing=true;
							glowCage1.scrollFactor.set(1,1);

							glowCage2 = new FlxSprite().loadGraphic(Paths.image("lab/FG2_GLOW") );
							glowCage2.setGraphicSize(Std.int(glowCage2.width*2));
							glowCage2.screenCenter(XY);
							glowCage2.alpha = 0;
							glowCage2.x -= 465;
							glowCage2.y += 115;
							glowCage2.antialiasing=true;
							glowCage2.scrollFactor.set(1,1);

							labOverlay = new FlxSprite().loadGraphic(Paths.image("lab/FG3") );
							labOverlay.setGraphicSize(Std.int(labOverlay.width*2*1.1));
							labOverlay.screenCenter(XY);
							labOverlay.antialiasing=true;
							labOverlay.scrollFactor.set();

						case 'mercenary'|'odd-job'|'guardian'|'2v200'|'after-the-ashes'|'curse-eternal'|'last-stand'|'last-stand-beta':
							defaultCamZoom = 0.75;
							curStage = 'omegafield';
							var suffix = '';
							if(SONG.song.toLowerCase()=='2v200' || SONG.song.toLowerCase()=='last-stand' || SONG.song.toLowerCase()=='last-stand-beta' || SONG.song.toLowerCase()=='curse-eternal'){
								suffix='-rain';
								if(SONG.song.toLowerCase()=='curse-eternal')suffix+='-dark';
								try{
									rainShader = new RainEffect();
									modchart.addCamEffect(rainShader);
								}catch(e:Any){
									trace("no shaders!");
								}
							}
							var bg:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('omega/biggerskymod${suffix}'));
							bg.setGraphicSize(Std.int(bg.width*2));
							bg.screenCenter(XY);
							bg.antialiasing = true;
							bg.scrollFactor.set(0.1, 0.1);
							bg.active = false;
							add(bg);

							var hills:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('omega/hills'));
							hills.setGraphicSize(Std.int(bg.width*2));
							hills.screenCenter(XY);
							hills.x += 300;
							hills.y += 50;
							hills.antialiasing = true;
							hills.scrollFactor.set(.65, .65);
							hills.active = false;
							add(hills);

							var mountain:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('omega/mountain'));
							mountain.screenCenter(XY);
							mountain.setGraphicSize(Std.int(mountain.width*2*1.1));
							mountain.x -= 600;
							mountain.antialiasing = true;
							mountain.scrollFactor.set(.8,.8);
							mountain.active = false;
							add(mountain);

							var backisland:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('omega/backisland'));
							backisland.setGraphicSize(Std.int(backisland.width*2*.8));
							backisland.screenCenter(XY);
							backisland.antialiasing = true;
							backisland.y += 25;
							backisland.x += 225;
							backisland.scrollFactor.set(0.5, 0.5);
							backisland.active = false;
							add(backisland);

							var frontisland:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('omega/frontisland'));
							frontisland.setGraphicSize(Std.int(frontisland.width*2*.8));
							frontisland.screenCenter(XY);
							frontisland.y += 25;
							frontisland.x += 225;
							frontisland.antialiasing = true;
							frontisland.scrollFactor.set(0.6, 0.6);
							frontisland.active = false;
							add(frontisland);

							var bgGrass:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('omega/backgrass'));
							bgGrass.setGraphicSize(Std.int(bgGrass.width*2));
							bgGrass.screenCenter(XY);
							bgGrass.y -= 50;
							bgGrass.antialiasing = true;
							bgGrass.scrollFactor.set(.65, .9);
							bgGrass.active = false;
							add(bgGrass);

							var grass:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('omega/grass${suffix}'));
							grass.setGraphicSize(Std.int(grass.width*2));
							grass.screenCenter(XY);
							grass.antialiasing = true;
							grass.scrollFactor.set(.9, .9);
							grass.active = false;
							add(grass);

							if(SONG.song.toLowerCase()=='curse-eternal' ){
								var garcellomega:FlxSprite = new FlxSprite(-750, 650).loadGraphic(Paths.image('omega/omega_no_crys'));
								garcellomega.setGraphicSize(Std.int(garcellomega.width*.75));
								garcellomega.antialiasing = true;
								garcellomega.scrollFactor.set(1, 1);
								garcellomega.active = false;
								add(garcellomega);
							}
						case 'father-time' | 'prelude':
							curStage='time-void';
							defaultCamZoom = .7;
							void1 = new FlxSprite(-600, -500).loadGraphic(Paths.image('thevoid/void'));
							void1.antialiasing = true;
							void1.setGraphicSize(Std.int(void1.width*3));
							void1.updateHitbox();
							void1.x = -600;
							void1.scrollFactor.set(0.4, 0.4);
							void1.active = false;
							add(void1);

							void2 = new FlxSprite(-600, -500).loadGraphic(Paths.image('thevoid/void'));
							void2.antialiasing = true;
							void2.setGraphicSize(Std.int(void2.width*3));
							void2.updateHitbox();
							void2.scrollFactor.set(0.4, 0.4);
							void2.active = false;
							void2.x = -(void1.width)-600;
							add(void2);

							dadRock = new FlxSprite(-300, -300).loadGraphic(Paths.image('thevoid/bigrock'));
							dadRock.setGraphicSize(Std.int(dadRock.width*.6));
							dadRock.updateHitbox();
							dadRock.antialiasing = true;
							dadRock.scrollFactor.set(1, 1);
							dadRock.active = false;
							add(dadRock);
							if(SONG.song.toLowerCase()=='prelude' )
								dadRock.visible=false;

							bfRock = new FlxSprite(1070, 450).loadGraphic(Paths.image('thevoid/smallrock'));
							bfRock.setGraphicSize(Std.int(bfRock.width*.6));
							bfRock.updateHitbox();
							bfRock.antialiasing = true;
							bfRock.scrollFactor.set(1, 1);
							bfRock.active = false;
							add(bfRock);
	          default:
	          {
										if(SONG.noBG!=true){
	                  defaultCamZoom = 1;
	                  curStage = 'stage';
	                  var bg:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('stageback'));
	                  bg.antialiasing = true;
	                  bg.scrollFactor.set(0.9, 0.9);
	                  bg.active = false;
	                  add(bg);

	                  var stageFront:FlxSprite = new FlxSprite(-650, 600).loadGraphic(Paths.image('stagefront'));
	                  stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
	                  stageFront.updateHitbox();
	                  stageFront.antialiasing = true;
	                  stageFront.scrollFactor.set(0.9, 0.9);
	                  stageFront.active = false;
	                  add(stageFront);

	                  var stageCurtains:FlxSprite = new FlxSprite(-500, -300).loadGraphic(Paths.image('stagecurtains'));
	                  stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
	                  stageCurtains.updateHitbox();
	                  stageCurtains.antialiasing = true;
	                  stageCurtains.scrollFactor.set(1.3, 1.3);
	                  stageCurtains.active = false;

	                  add(stageCurtains);
									}else{
										curStage='custom';
									}
	          }
          }

		var gfVersion:String = 'gf';

		goldOverlay = new FlxSprite(0,0).loadGraphic(Paths.image('Gold_note_overlay'));
		goldOverlay.setGraphicSize(1280, 720);
		goldOverlay.antialiasing = true;
		goldOverlay.alpha = 0;
		goldOverlay.screenCenter(XY);
		goldOverlay.active = false;
		goldOverlay.cameras = [pauseHUD];
		add(goldOverlay);

		switch (curStage)
		{
			case 'limo':
				gfVersion = 'gf-car';
			case 'mall' | 'mallEvil':
				gfVersion = 'gf-rave';
			case 'school':
				gfVersion = 'gf-pixel';
			case 'schoolEvil':
				gfVersion = 'gf-pixel';
		}

		if(SONG.song.toLowerCase()=='winter-horrorland')
			gfVersion = 'gf-raveFaceless';



		if(SkinState.selectedSkin=='bf-neb' || StoryMenuState.cameos.contains(SONG.song) && FlxG.random.bool(.1))
			gfVersion = 'lizzy';

		if(SONG.song.toLowerCase()=='last-stand' || SONG.song.toLowerCase()=='last-stand-beta' )
			gfVersion='gf-child';
		gf = new Character(400, 130, gfVersion);
		gf.scrollFactor.set(0.95, 0.95);

		dad = new Character(100, 100, SONG.player2);
		mika = new Character(100, 385, "mika");

		mikaRun = new RunningChild();
		mikaRun.y = 425;
		armyRight = new Character(100,100,"armyRight");
		armyRight.visible=false;

		var camPos:FlxPoint = new FlxPoint(dad.getGraphicMidpoint().x, dad.getGraphicMidpoint().y);

		switch (SONG.player2)
		{
			case 'gf':
				dad.setPosition(gf.x, gf.y);
				gf.visible=false;
				if (isStoryMode)
				{
					camPos.x += 600;
					tweenCamIn();
				}
			case 'angry-fucking-child' | 'mika':
				dad.y += 225;
			case 'kapi':
				dad.y += 175;
			case 'flexy':
				dad.y += 200;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y - 600);
			case 'merchant':
				dad.y += 225;
				camPos.set(dad.getGraphicMidpoint().x + 375, dad.getGraphicMidpoint().y - 250);
			case 'omega':
				dad.x -= 100;
				mika.x -= 100;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
			case 'angry-omega':
				dad.x -= 250;
				mika.x -= 250;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
			case "spooky":
				dad.y += 150;
			case 'demetrios':
				dad.y -= 390;
				camPos.set(dad.getGraphicMidpoint().x, dad.getGraphicMidpoint().y+ 100);
			case "monster":
				dad.y += 100;
			case 'monster-christmas':
				dad.y += 100;
			case 'dad':
				camPos.x += 400;
			case 'pico':
				camPos.x += 600;
				dad.y += 300;
			case 'parents-christmas':
				dad.x -= 500;
				mika.x -= 500;
				camPos.set(dad.getGraphicMidpoint().x+200,dad.getGraphicMidpoint().y-300);
			case 'noke':
				dad.y += dad.height/2;
				dad.y -= 5;
				dad.x += dad.width/2;
				mika.x += dad.width/2;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
			case 'senpai':
				dad.x += 50;
				dad.y += 500;
				mika.x += 50;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y-500);
			case 'senpai-angry':
				dad.x += 210;
				dad.y += 500;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y-500);
			case 'spirit':
				dad.x -= 150;
				dad.y += 200;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
			case 'king':
				dad.x -= 175;
			case 'army':
				dad.x -= 1000;
				dad.y -= 500;

				armyRight.x += 1000;
				armyRight.y -= 500;
		}

		mika.x = dad.x-50;

		if(curStage=='elevator'){
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
		}

		var bfwithitems:Bool = false;

		if(SONG.player1!='bf-pixel'){
			if(SONG.player1.startsWith('bf') && SkinState.selectedSkin!='bf' ){
				boyfriend = new Boyfriend(770, 450, SkinState.selectedSkin);
			}else if(SONG.player1.startsWith('bf') && SkinState.selectedSkin=='bf' && ItemState.equipped.length>0){
				bfwithitems=true;
				var name = '';
				var shit = ["sword","arrow","twat","depressed"];
				for(cum in shit){
					if(ItemState.equipped.contains(cum)){
						name+=cum;
					}
				}
				if(name=='')name = SONG.player1;

				boyfriend = new Boyfriend(770, 450, name);
			}else{
				boyfriend = new Boyfriend(770, 450, SONG.player1);
			}
		}else{
			boyfriend = new Boyfriend(770, 450, 'bf-pixel');
		}


		omega = new Boyfriend(1000,70,"omega",true);
		if(SONG.song.toLowerCase()!='2v200')
			omega.visible=false;

		// REPOSITIONING PER STAGE
		switch (curStage)
		{
			case 'limo':
				boyfriend.y -= 325;
				dad.y -= 385;
				gf.y -= 325;
				boyfriend.x += 225;
			case 'mall' | 'mallEvil':
				gf.y -= 300;
				boyfriend.y -= 300;
				dad.y -= 300;
			case 'lab':
				boyfriend.x += 90;
				gf.y -= 50;
				dad.x -= 195;
			case 'dojo':
				dad.x -= 100;
				boyfriend.x += 100;

				dad.y += 135;
				boyfriend.y += 135;
			case 'time-void':
				dad.x -= 125;
				boyfriend.x += 700;
				gf.x += 900;
				if(dad.curCharacter=='gf'){
					gf.x -= 100;
					boyfriend.x += 100;
					dad.x = gf.x;
				}

			case 'backrooms':
				dad.x -= 75;
				gf.y -= 50;
				boyfriend.x += 75;
			case 'castle':

				boyfriend.y += 95;
			case 'school':
				boyfriend.x += 200;
				boyfriend.y += 290;
				gf.x += 180;
				gf.y += 425;
			case 'schoolEvil':

				boyfriend.x += 200;
				boyfriend.y += 290;
				gf.x += 180;
				gf.y += 425;
			case 'apocalypse':
				boyfriend.x += 100;
				boyfriend.y -= 0;
				gf.x += 500;
				gf.y += 25;
				gf.scrollFactor.set(1,1);
				dad.x -= 350;
				dad.y -= 245;
			case 'elevator':
				boyfriend.x += 100;
			case 'drugmart':
				boyfriend.x += 175;
				gf.scrollFactor.set(1,1);
				gf.y -= 150;
			case 'omegafield':
				if(SONG.song.toLowerCase()=='2v200'){
					boyfriend.x -= 150;
					omega.x -= 150;
				}else if(SONG.song.toLowerCase()=='last-stand'){
					boyfriend.x += 200;
					omega.x += 200;
				}else{
					boyfriend.x += 150;
					omega.x += 150;
				}
		}
		if(boyfriend.curCharacter=='spirit'){
			var evilTrail = new FlxTrail(boyfriend, null, 4, 24, 0.3, 0.069);
			add(evilTrail);
		}
		if(dad.curCharacter=='spirit'){
			var evilTrail = new FlxTrail(dad, null, 4, 24, 0.3, 0.069);
			add(evilTrail);
		}
		switch(boyfriend.curCharacter){
			case 'bf-neb':
				boyfriend.y -= 75;
			case 'naikaze':
				boyfriend.y -= 90;
			case 'bfside':
				boyfriend.y -= 150;
			case 'babyvase':
				boyfriend.y -= 110;
		}


		add(gf);

		// Shitty layering but whatev it works LOL

		if(curStage=='lab'){
			add(cage1);
			add(glowCage1);
		}

		if(curStage=='backrooms'){
			add(backroomFG);
		}

		if(curStage=='omegafield' && SONG.song.toLowerCase()!='last-stand' && SONG.song.toLowerCase()!='after-the-ashes'  || curStage=='void' || curStage=='dojo' || curStage=='castle')
			gf.visible=false;

		if(SONG.song.toLowerCase()=='salem')
			burnTicks=.1;

		if(curStage=='void')
			boyfriend.visible=false;

		add(dad);
		if(SONG.song.toLowerCase()=='2v200' && dad.curCharacter=='army'){
			armyRight.visible=true;
			add(armyRight);
			add(omega);
		}


		if(SONG.song.toLowerCase()=='guardian')
			add(mikaRun);
		if(SONG.song.toLowerCase()=='guardian' || SONG.song.toLowerCase()=='after-the-ashes'){
			add(mika);
			if(SONG.song.toLowerCase()=='guardian'){
				mika.visible=false;
			}
		}


		add(boyfriend);

		if(dad.curCharacter=='noke'){
			nokeTxt = new FlxText(0,0,0,"DISCONNECTED",78);
			nokeTxt.color = FlxColor.RED;
			nokeTxt.font = 'Pixel Arial 11 Bold';
			nokeTxt.visible=false;
			add(nokeTxt);
		}

		if(curStage=='lab'){
			add(cage2);
			add(glowCage2);
			add(labOverlay);
		}else if(curStage=='drugmart'){
			add(fgShops);
		}else if(curStage=='mall'){
			add(frontBoppers);
			add(raveGlow);
		}

		curseEternalVignette = new FlxSprite().loadGraphic(Paths.image("vignette"));
		curseEternalVignette.alpha=0;
		curseEternalVignette.setGraphicSize(FlxG.width,FlxG.height);
		curseEternalVignette.scrollFactor.set();
		curseEternalVignette.screenCenter();
		curseEternalVignette.cameras=[pauseHUD];

		slash = new FlxSprite(boyfriend.x,boyfriend.y);
		slash.frames = Paths.getSparrowAtlas('slash');
		slash.visible = false;
		slash.animation.addByPrefix('slash', 'Slash', 24, false);
		slash.setGraphicSize(Std.int(slash.width*1.3));
		slash.x = boyfriend.x+30;
		slash.y = boyfriend.y+25;
		slash.updateHitbox();
		slash.antialiasing = true;
		slash.animation.finishCallback = function(name:String){
			if(name=='slash')
				slash.visible = false;
		};
		add(slash);

		disabledHud = modchart.hudVisible;
		var doof:Null<DialogueBox>=null;
		if(dialogue.length>0){
			doof = new DialogueBox(false, dialogue);
			doof.scrollFactor.set();
			doof.finishThing = startCountdown;
		}
		if(SONG.song.toLowerCase()=='2v200')
			keyAmount=6;
		else
			keyAmount=4;

		if(keyAmount==6){
			singAnims = ["singLEFT","singDOWN","singRIGHT","singLEFT","singUP","singRIGHT"];
		}
		modchart.playerNoteScale *= 4/keyAmount;
		modchart.opponentNoteScale *= 4/keyAmount;

		if(SONG.song.toLowerCase()=='guardian'){
			for (i in 0...SONG.notes.length){
				if(SONG.notes[i].altAnim){
					var notes = SONG.notes[i].sectionNotes;
					var startStrum = -1;
					var endStrum = 0;

					for(note in notes){
						var hit = SONG.notes[i].mustHitSection;
						if(note[1]>keyAmount-1){
							hit=!hit;
						}
						if(hit==false && startStrum==-1){
							startStrum=note[0];
						}
						if(hit==false){
							endStrum=note[0];
						}
					}
					mikaShit.push(
						{
							start: startStrum,
							end: endStrum
						}
					);
				}
			}
		}

		mikaShit.sort((a,b)->Std.int(a.start - b.start));
		mikaRun.schedule = mikaShit;

		Conductor.songPosition = -5000;

		strumLine = new FlxSprite(0, 50).makeGraphic(FlxG.width, 10);
		if(currentOptions.downScroll){
			strumLine.y = FlxG.height-150;
		}
		strumLine.scrollFactor.set();

		strumLineNotes = new FlxSpriteGroup();
		//add(strumLineNotes);
		//strumLineNotes.visible=false;

		playerStrumLines = new FlxSpriteGroup();
		opponentStrumLines = new FlxSpriteGroup();
		refNotes = new FlxSpriteGroup();
		opponentRefNotes = new FlxSpriteGroup();
		playerStrums = new FlxSpriteGroup();
		dadStrums = new FlxSpriteGroup();
		grayscalePlayerStrums = new FlxSpriteGroup();
		grayscaleDadStrums = new FlxSpriteGroup();
		add(curseEternalVignette);
		// startCountdown();
		// TODO: Start lua shit here
		generateSong(SONG.song);

		// add(strumLine);

		camFollow = new FlxObject(0, 0, 1, 1);
		aCamFollow = new FlxObject(0,0,1,1);

		if (prevCamFollow != null)
		{
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}

		add(camFollow);

		FlxG.camera.follow(aCamFollow, LOCKON, 0.01);
		// FlxG.camera.setScrollBounds(0, FlxG.width, 0, FlxG.height);
		FlxG.camera.zoom = defaultCamZoom;
		FlxG.camera.focusOn(camFollow.getPosition());
		camFollow.setPosition(camPos.x, camPos.y);
		aCamFollow.setPosition(camPos.x,camPos.y);

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		FlxG.fixedTimestep = false;

		healthBarBG = new FlxSprite(0, FlxG.height * 0.9).loadGraphic(Paths.image('healthBar'));
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		add(healthBarBG);
		if(currentOptions.downScroll){
			healthBarBG.y = FlxG.height*.1;
		}

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this,
			'displayedHealth', 0, 2);
		healthBar.numDivisions=200;
		healthBar.scrollFactor.set();
		var p1Color = 0xFF66FF33;
		var p2Color = 0xFFFF0000; // TODO: GIVE EVERYONE CUSTOM HP BAR COLOURS!!!
		// AND MAKE IT BETTER WITH A NOTEPAD FILE OR SOMETHING!!

		switch(boyfriend.curCharacter){
			case 'bf-neb':
				p1Color = 0xFF9534EB;
			case 'bf' | 'bf-car' | 'bf-pixel' | 'bf-christmas':
				p1Color = 0xFF31B0D1;
			default:
				p1Color = 0xFF66FF33;
		}

		switch(SONG.player2){
			case 'bf-neb':
				p2Color = 0xFF9534EB;
			case 'bf' | 'bf-car' | 'bf-pixel' | 'bf-christmas':
				p2Color = 0xFF31B0D1;
			default:
				p2Color=0xFFFF0000;
		}



		healthBar.createFilledBar(p2Color,p1Color);
		// healthBar
		add(healthBar);

		scoreTxt = new FlxText(healthBarBG.x + healthBarBG.width / 2 - 190, healthBarBG.y + 30, 0, "", 20);
		scoreTxt.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		scoreTxt.scrollFactor.set();

		presetTxt = new FlxText(0, FlxG.height-180, 0, "", 20);
		presetTxt.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
		presetTxt.scrollFactor.set();
		presetTxt.visible=false;

		highComboTxt = new FlxText(30, presetTxt.y+20, 0, "", 20);
		highComboTxt.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
		highComboTxt.scrollFactor.set();

		epicsTxt = new FlxText(30, presetTxt.y+40, 0, "", 20);
		epicsTxt.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
		epicsTxt.scrollFactor.set();

		sicksTxt = new FlxText(30, presetTxt.y+60, 0, "", 20);
		sicksTxt.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
		sicksTxt.scrollFactor.set();

		goodsTxt = new FlxText(30, presetTxt.y+80, 0, "", 20);
		goodsTxt.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
		goodsTxt.scrollFactor.set();

		badsTxt = new FlxText(30, presetTxt.y+100, 0, "", 20);
		badsTxt.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
		badsTxt.scrollFactor.set();

		shitsTxt = new FlxText(30, presetTxt.y+120, 0, "", 20);
		shitsTxt.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
		shitsTxt.scrollFactor.set();

		missesTxt = new FlxText(30, presetTxt.y+140, 0, "", 20);
		missesTxt.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
		missesTxt.scrollFactor.set();

		missesTxt.text = "Miss: " + misses;
		sicksTxt.text = "Sick: " + sicks;
		goodsTxt.text = "Good: " + goods;
		badsTxt.text = "Bad: " + bads;
		shitsTxt.text = "Shit: " + shits;
		epicsTxt.text = "Epic: " + epics;

		highComboTxt.text = "Highest Combo: " + highestCombo;
		if(currentOptions.ratingWindow!=0){
			var y = presetTxt.y;
			presetTxt.text = OptionUtils.ratingWindowNames[currentOptions.ratingWindow] + " Judgement";
			presetTxt.x = 30;
			presetTxt.y = y;
			presetTxt.visible=true;
		}

		var hpIcon = boyfriend.curCharacter;
		switch(SONG.song.toLowerCase()){
			case '2v200':
				hpIcon = "omegabf";
			default:
				hpIcon = boyfriend.curCharacter;
		}

		if(bfwithitems){
			hpIcon = 'bf';
		}

		iconP1 = new HealthIcon(hpIcon, true);
		iconP1.y = healthBar.y - (iconP1.height / 2);
		add(iconP1);

		iconP2 = new HealthIcon((SONG.song.toLowerCase()=='after-the-ashes' && SONG.player2=='omega')?'omegafriendly':SONG.player2, false);
		iconP2.y = healthBar.y - (iconP2.height / 2);
		add(iconP2);

		if(ScoreUtils.botPlay){
			var botplayTxt = new FlxText(0, 80, 0, "[BOTPLAY]", 30);
			botplayTxt.cameras = [camHUD];
			botplayTxt.screenCenter(X);
			botplayTxt.setFormat(Paths.font("vcr.ttf"), 30, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
			botplayTxt.scrollFactor.set();

			add(botplayTxt);
		}

		if(curStage=='philly'){
			if(currentOptions.picoShaders){
				try{
					var grayscale = new GrayscaleEffect();
					grayscale.influence=1;
					grayscale.update();
					iconP1.shader = grayscale.shader;
					iconP2.shader = grayscale.shader;
					healthBar.shader = grayscale.shader;
				}catch(e:Any){
					trace(e);
				}
			}
		}

		add(highComboTxt);
		add(sicksTxt);
		add(goodsTxt);
		add(badsTxt);
		add(shitsTxt);
		add(epicsTxt);
		add(missesTxt);
		add(presetTxt);
		add(scoreTxt);

		playerStrums.cameras=[camHUD];
		grayscalePlayerStrums.cameras=[camHUD];
		dadStrums.cameras=[camHUD];
		grayscaleDadStrums.cameras=[camHUD];
		strumLineNotes.cameras = [camHUD];
		renderedNotes.cameras = [camHUD];
		playerRenderedNotes.cameras = [camHUD];
		opponentRenderedNotes.cameras = [camHUD];
		healthBar.cameras = [camHUD];
		healthBarBG.cameras = [camHUD];
		iconP1.cameras = [camHUD];
		iconP2.cameras = [camHUD];
		scoreTxt.cameras = [camHUD];
		doof.cameras = [pauseHUD];
		missesTxt.cameras = [camHUD];
		sicksTxt.cameras = [camHUD];
		goodsTxt.cameras = [camHUD];
		badsTxt.cameras = [camHUD];
		shitsTxt.cameras = [camHUD];
		epicsTxt.cameras = [camHUD];
		highComboTxt.cameras = [camHUD];
		presetTxt.cameras = [camHUD];
		// if (SONG.song == 'South')
		// FlxG.camera.alpha = 0.7;
		// UI_camera.zoom = 1;

		// cameras = [FlxG.cameras.list[1]];
		startingSong = true;


		if ((isStoryMode || doIntro) && !didIntro)
		{
			didIntro=true;
			switch (curSong.toLowerCase())
			{
				case "winter-horrorland":
					var blackScreen:FlxSprite = new FlxSprite(0, 0).makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
					add(blackScreen);
					blackScreen.scrollFactor.set();
					camHUD.visible = false;

					new FlxTimer().start(0.1, function(tmr:FlxTimer)
					{
						remove(blackScreen);
						FlxG.sound.play(Paths.sound('Lights_Turn_On'));
						aCamFollow.y = gf.getGraphicMidpoint().y-160;
						aCamFollow.x = gf.getGraphicMidpoint().x+10;

						camFollow.x = aCamFollow.x;
						camFollow.y = aCamFollow.y;

						FlxG.camera.focusOn(aCamFollow.getPosition());
						camZooming=false;
						FlxG.camera.zoom = 2;
						FlxTween.tween(camFollow, {x:dad.getGraphicMidpoint().x,y:dad.getGraphicMidpoint().y-175 }, .5, {
							ease: FlxEase.quadInOut,
							startDelay: 1,
							onComplete: function(twn:FlxTween)
							{
								new FlxTimer().start(1, function(tmr:FlxTimer)
								{
									camHUD.visible = true;
									remove(blackScreen);
									FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, 2.5, {
										ease: FlxEase.quadInOut,
										onComplete: function(twn:FlxTween)
										{
											camZooming=true;
											startCountdown();
										}
									});
								});
							}
						});

					});
				case 'senpai':
					schoolIntro(doof);
				case 'roses':
					FlxG.sound.play(Paths.sound('ANGRY'));
					schoolIntro(doof);
				case 'thorns':
					schoolIntro(doof);
				case 'last-stand':
					doof.finishThing = cutthefuckinnotes;
					showDialogue(doof);
				case 'last-stand-beta':
					cutthefuckinnotes();
				case 'new-retro' | 'fragmented-surreality' | 'free-soul' | 'oxidation' | '57.5hz' | 'no-arm-shogun':
					showDialogue(doof);
				default:
					startCountdown();
			}
		}else if((isStoryMode || doIntro) && didIntro && SONG.song.toLowerCase()=='last-stand' && blueballs>0){
			var shit = CoolUtil.coolTextFile(Paths.txt('last-stand/deathsdialogue'));
			var dialogue = [];
			for(idx in 0...shit.length){
				var hm = shit[idx];
				var cumshitcunt = new EReg("\\[(.+)\\]","ig");
				if(cumshitcunt.match(hm)){
					var num = Std.parseInt(cumshitcunt.matched(1));
					if(blueballs<num){
						break;
					}
					dialogue = [];
				}else{
					dialogue.push(hm);
				}
			}
			var box:DialogueBox = new DialogueBox(false, dialogue);
			box.scrollFactor.set();
			box.finishThing = cutthefuckinnotes;
			box.cameras = [pauseHUD];
			showDialogue(box);
		}
		else
		{
			switch (curSong.toLowerCase())
			{
				default:
					startCountdown();
			}
		}

		super.create();
	}

	function showDialogue(?d:DialogueBox):Void {
		new FlxTimer().start(0.3, function(tmr:FlxTimer){
			if (d != null)
			{
				inCutscene = true;
				add(d);
			}
		});
	}

	public function cutthefuckinnotes(){
		var weebShit = new FlxSprite();
		weebShit.frames = Paths.getSparrowAtlas("OMEGAWEEB");
		weebShit.animation.addByPrefix("weeb","WEEB",24,false);
		weebShit.setGraphicSize(Std.int(FlxG.width),Std.int(FlxG.height));
		weebShit.updateHitbox();
		weebShit.antialiasing=true;
		weebShit.screenCenter(XY);
		weebShit.scrollFactor.set();
		weebShit.cameras = [camHUD];

		FlxG.sound.play(Paths.sound("omegaAnimeMoment"),.8);
		weebShit.animation.finishCallback = function(name:String){
			FlxTween.tween(weebShit,{alpha:0},0.4,{
					startDelay:2,
					onComplete: function(tw:FlxTween){
						cumBreakNotes();
						remove(weebShit);
						if(blueballs==0 && SONG.song.toLowerCase()=='last-stand'){
							var box:DialogueBox = new DialogueBox(false, CoolUtil.coolTextFile(Paths.txt("last-stand/dialogueCut")));
							box.scrollFactor.set();
							box.finishThing = startCountdown;
							box.cameras = [pauseHUD];
							showDialogue(box);
						}else{
							startCountdown();
						}
					}
			});
		};

		add(weebShit);
		weebShit.animation.play("weeb");
	}

	function schoolIntro(?dialogueBox:DialogueBox):Void
	{
		modchart.hudVisible=false;
		var black:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
		black.scrollFactor.set();
		add(black);

		var red:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, 0xFFff1b31);
		red.scrollFactor.set();

		var senpaiEvil:FlxSprite = new FlxSprite();
		senpaiEvil.frames = Paths.getSparrowAtlas('weeb/Senpai_explode');
		senpaiEvil.animation.addByPrefix('idle', '4bit Senpai Pre Explosion', 24, false);
		senpaiEvil.setGraphicSize(Std.int(senpaiEvil.width * daPixelZoom));
		senpaiEvil.scrollFactor.set();
		senpaiEvil.updateHitbox();
		senpaiEvil.screenCenter();

		if (SONG.song.toLowerCase() == 'roses' || SONG.song.toLowerCase() == 'thorns')
		{
			remove(black);

			if (SONG.song.toLowerCase() == 'thorns')
			{
				add(red);
			}
		}

		new FlxTimer().start(0.3, function(tmr:FlxTimer)
		{
			black.alpha -= 0.15;

			if (black.alpha > 0)
			{
				tmr.reset(0.3);
			}
			else
			{
				if (dialogueBox != null)
				{
					inCutscene = true;

					if (SONG.song.toLowerCase() == 'thorns')
					{
						add(senpaiEvil);
						senpaiEvil.alpha = 0;
						new FlxTimer().start(0.3, function(swagTimer:FlxTimer)
						{
							senpaiEvil.alpha += 0.15;
							if (senpaiEvil.alpha < 1)
							{
								swagTimer.reset();
							}
							else
							{
								senpaiEvil.animation.play('idle');
								FlxG.sound.play(Paths.sound('Senpai_Dies'), 1, false, null, true, function()
								{
									remove(senpaiEvil);
									remove(red);
									FlxG.camera.fade(FlxColor.WHITE, 0.01, true, function()
									{
										add(dialogueBox);
									}, true);
								});
								new FlxTimer().start(3.2, function(deadTime:FlxTimer)
								{
									FlxG.camera.fade(FlxColor.WHITE, 1.6, false);
								});
							}
						});
					}
					else
					{
						add(dialogueBox);
					}
				}
				else
					startCountdown();

				remove(black);
			}
		});
	}

	var startTimer:FlxTimer;
	var perfectMode:Bool = false;


	function cumBreakNotes(){
		var plrBrokenNotes=[];
		var dadBrokenNotes=[];

		var sides = ["LEFT","DOWN","UP","RIGHT"];
		for(idx in 0...3){
			var brokenArrow = new FlxSprite();
			brokenArrow.frames = Paths.getSparrowAtlas("CUNTNOTES");
			brokenArrow.animation.addByPrefix("cut",'CUT${sides[idx]}',24,false);
			brokenArrow.scrollFactor.set(0,0);
			brokenArrow.setGraphicSize(Std.int(brokenArrow.width*.7));
			brokenArrow.updateHitbox();
			brokenArrow.cameras=[camHUD];
			brokenArrow.antialiasing=true;
			brokenArrow.visible=false;
			add(brokenArrow);
			plrBrokenNotes.push(brokenArrow);
		}
		for(idx in 0...3){
			var brokenArrow = new FlxSprite();
			brokenArrow.frames = Paths.getSparrowAtlas("CUNTNOTES");
			brokenArrow.animation.addByPrefix("cut",'CUT${sides[idx]}',24,false);
			brokenArrow.scrollFactor.set(0,0);
			brokenArrow.setGraphicSize(Std.int(brokenArrow.width*.7));
			brokenArrow.updateHitbox();
			brokenArrow.cameras=[camHUD];
			brokenArrow.antialiasing=true;
			brokenArrow.visible=false;
			add(brokenArrow);
			dadBrokenNotes.push(brokenArrow);
		}

		var idx=0;
		for(i in dadBrokenNotes){
			i.animation.play("cut");
			i.updateHitbox();
			i.visible=true;
			switch(idx){
				case 0:
					i.x = 520-(FlxG.width/2);
					if(currentOptions.downScroll){
						i.y = FlxG.height-100;
					}else{
						i.y = 0;
					}
				case 1:
					i.x = 745-(FlxG.width/2);
					if(currentOptions.downScroll){
						i.y = FlxG.height-100;
					}else{
						i.y = 0;
					}
				case 2:
					i.x = 835-(FlxG.width/2);
					if(currentOptions.downScroll){
						i.y = FlxG.height-130;
					}else{
						i.y = 0;
					}
				case 3:
					i.x = 1025-(FlxG.width/2);
					if(currentOptions.downScroll){
						i.y = FlxG.height-95;
					}else{
						i.y = 0;
					}
			}
			idx++;
		}
		for(cum in dadStrums){
			cum.visible=false;
		}

		var idx=0;
		for(i in plrBrokenNotes){
			i.animation.play("cut");
			i.updateHitbox();
			i.visible=true;
			switch(idx){
				case 0:
					i.x = 520;
					if(currentOptions.downScroll){
						i.y = FlxG.height-100;
					}else{
						i.y = 0;
					}
				case 1:
					i.x = 745;
					if(currentOptions.downScroll){
						i.y = FlxG.height-100;
					}else{
						i.y = 0;
					}
				case 2:
					i.x = 835;
					if(currentOptions.downScroll){
						i.y = FlxG.height-130;
					}else{
						i.y = 0;
					}
				case 3:
					i.x = 1025;
					if(currentOptions.downScroll){
						i.y = FlxG.height-95;
					}else{
						i.y = 0;
					}
			}
			idx++;
		}
		for(cum in playerStrums){
			cum.visible=false;
		}
	}
	function startCountdown():Void
	{
		modchart.hudVisible=disabledHud;
		inCutscene = false;

		generateStaticArrows(0);
		generateStaticArrows(1);

		generateStaticArrows(0,true);
		generateStaticArrows(1,true);

		grayscaleDadStrums.alpha=0;
		grayscalePlayerStrums.alpha=0;


		talking = false;
		startedCountdown = true;
		Conductor.songPosition = 0;
		Conductor.songPosition -= Conductor.crochet * 5;

		var swagCounter:Int = 0;

		startTimer = new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
		{
			dad.dance();
			gf.dance();
			armyRight.dance();
			mika.dance();
			boyfriend.dance();
			omega.dance();

			var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
			introAssets.set('default', ['ready', "set", "go"]);
			introAssets.set('school', ['weeb/pixelUI/ready-pixel', 'weeb/pixelUI/set-pixel', 'weeb/pixelUI/date-pixel']);
			introAssets.set('schoolEvil', ['weeb/pixelUI/ready-pixel', 'weeb/pixelUI/set-pixel', 'weeb/pixelUI/date-pixel']);

			var introAlts:Array<String> = introAssets.get('default');
			var altSuffix:String = "";

			for (value in introAssets.keys())
			{
				if (value == curStage)
				{
					introAlts = introAssets.get(value);
					altSuffix = '-pixel';
				}
			}

			switch (swagCounter)
			{
				case 0:
					if((SONG.song.toLowerCase()=='last-stand' || SONG.song.toLowerCase()=='last-stand-beta') && !isStoryMode){
						cumBreakNotes();
					}
					FlxG.sound.play(Paths.sound('intro3${altSuffix}'), 0.6);
				case 1:
					var ready:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[0]));
					ready.scrollFactor.set();
					ready.updateHitbox();

					if (curStage.startsWith('school'))
						ready.setGraphicSize(Std.int(ready.width * 6));

					ready.screenCenter();
					add(ready);
					FlxTween.tween(ready, {y: ready.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							ready.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('intro2${altSuffix}'), 0.6);
				case 2:
					var set:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[1]));
					set.scrollFactor.set();

					if (curStage.startsWith('school'))
						set.setGraphicSize(Std.int(set.width * 6));

					set.screenCenter();
					add(set);
					FlxTween.tween(set, {y: set.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							set.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('intro1${altSuffix}'), 0.6);
				case 3:
					var go:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[2]));
					go.scrollFactor.set();

					if (curStage.startsWith('school'))
						go.setGraphicSize(Std.int(go.width * 6));

					go.updateHitbox();

					go.screenCenter();
					add(go);
					FlxTween.tween(go, {y: go.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							go.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('introGo${altSuffix}'), 0.6);
				case 4:
			}

			swagCounter += 1;
			// generateSong('fresh');
		}, 5);
	}

	var previousFrameTime:Int = 0;
	var lastReportedPlayheadPosition:Int = 0;
	var songTime:Float = 0;

	function startSong():Void
	{
		startingSong = false;

		previousFrameTime = FlxG.game.ticks;
		lastReportedPlayheadPosition = 0;

		if (!paused)
			FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 1, false);
			FlxG.sound.music.looped=false;
			if(currentOptions.noteOffset==0)
				FlxG.sound.music.onComplete = endSong;
			else
				FlxG.sound.music.onComplete = function(){
					dontSync=true;
				};



		vocals.play();

		#if desktop
		// Song duration in a float, useful for the time left feature
		songLength = FlxG.sound.music.length;

		// Updating Discord Rich Presence (with Time Left)
		DiscordClient.changePresence(detailsText + SONG.song + " (" + storyDifficultyText + ")", grade + " | Acc: " + truncateFloat(accuracy*100,2) + "%", iconRPC, true, songLength);
		#end
	}

	var debugNum:Int = 0;

	private function generateSong(dataPath:String):Void
	{
		// FlxG.log.add(ChartParser.parse());

		var songData = SONG;
		Conductor.changeBPM(songData.bpm);

		curSong = songData.song;

		if (songData.needsVoices){
			vocals = new FlxSound().loadEmbedded(Paths.voices(songData.song));
		}else
			vocals = new FlxSound();

		FlxG.sound.list.add(vocals);

		renderedNotes = new FlxTypedGroup<Note>();
		//add(renderedNotes);

		opponentRenderedNotes = new FlxTypedGroup<Note>();
		add(dadStrums);
		add(grayscaleDadStrums);
		add(opponentRenderedNotes);


		playerRenderedNotes = new FlxTypedGroup<Note>();
		add(playerStrums);
		add(grayscalePlayerStrums);
		add(playerRenderedNotes);


		var noteData:Array<SwagSection>;

		// NEW SHIT
		noteData = songData.notes;

		var playerCounter:Int = 0;

		var daBeats:Int = 0; // Not exactly representative of 'daBeats' lol, just how much it has looped
		for (section in noteData)
		{
			var coolSection:Int = Std.int(section.lengthInSteps / 4);

			for (songNotes in section.sectionNotes)
			{
				var daStrumTime:Float = songNotes[0] + currentOptions.noteOffset;
				var daNoteData:Int = Std.int(songNotes[1] % keyAmount);
				var gottaHitNote:Bool = section.mustHitSection;

				if (songNotes[1] > keyAmount-1)
				{
					gottaHitNote = !section.mustHitSection;
				}

				if(!gottaHitNote && section.altAnim && SONG.song.toLowerCase()=='guardian')
					continue;

				var oldNote:Note;
				if (unspawnNotes.length > 0)
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
				else
					oldNote = null;

				var grayscale=false;

				if(SONG.song.toLowerCase()=='dishonor'){
					var lastChange:BPMChangeEvent = {
						stepTime: 0,
						songTime: 0,
						bpm: 0
					}
					for (i in 0...Conductor.bpmChangeMap.length)
					{
						if (daStrumTime - OptionUtils.options.noteOffset >= Conductor.bpmChangeMap[i].songTime)
							lastChange = Conductor.bpmChangeMap[i];
					}

					var step = lastChange.stepTime + Math.floor((daStrumTime - OptionUtils.options.noteOffset - lastChange.songTime) / Conductor.stepCrochet);
					if(step>=2048 || step>=1024 && step<1280){
						grayscale=true;
					}
				}
				var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote, gottaHitNote, false, songNotes[3], songNotes[4], songNotes[5],songNotes[6],songNotes[7],songNotes[8],currentOptions.downScroll,grayscale);
				swagNote.initialPos = getPosFromTime(daStrumTime);
				swagNote.sustainLength = songNotes[2];
				swagNote.scrollFactor.set(0, 0);

				var susLength:Float = swagNote.sustainLength;

				susLength = susLength / Conductor.stepCrochet;

				unspawnNotes.push(swagNote);

				for (susNote in 0...Math.floor(susLength))
				{
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

					var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet, daNoteData, oldNote, gottaHitNote, true, songNotes[3],songNotes[4], songNotes[5],songNotes[6],songNotes[7],songNotes[8],currentOptions.downScroll,grayscale);
					sustainNote.initialPos = getPosFromTime(sustainNote.strumTime);
					sustainNote.scrollFactor.set();
					unspawnNotes.push(sustainNote);

					sustainNote.mustPress = gottaHitNote;

					if (sustainNote.mustPress)
					{
						sustainNote.x += FlxG.width / 2; // general offset
						sustainNote.defaultX = sustainNote.x;
					}
				}

				swagNote.mustPress = gottaHitNote;

				if (swagNote.mustPress)
				{
					swagNote.x += FlxG.width / 2; // general offset
					swagNote.defaultX = swagNote.x;
				}
				else {}
			}
			daBeats += 1;
		}

		// trace(unspawnNotes.length);
		// playerCounter += 1;

		unspawnNotes.sort(sortByShit);

		generatedMusic = true;
	}

	function sortByShit(Obj1:Note, Obj2:Note):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	function mapVelocityChanges(){
		if(SONG.sliderVelocities.length==0)
			return;

		var pos:Float = SONG.sliderVelocities[0].startTime*(SONG.initialSpeed);
		velocityMarkers.push(pos);
		for(i in 1...SONG.sliderVelocities.length){
			pos+=(SONG.sliderVelocities[i].startTime-SONG.sliderVelocities[i-1].startTime)*(SONG.initialSpeed*SONG.sliderVelocities[i-1].multiplier);
			velocityMarkers.push(pos);
		}
	};

	private function generateStaticArrows(player:Int,?grayscale:Bool=false):Void
	{
		for (i in 0...keyAmount)
		{
			// FlxG.log.add(i);
			var babyArrow:FlxSprite = new FlxSprite(0, strumLine.y);
			if(currentOptions.middleScroll && player==0 && SONG.song.toLowerCase()!='hivemind' )
				babyArrow.visible=false;


			var scale = modchart.opponentNoteScale;

			if(player==1)
				scale=modchart.playerNoteScale;

			var width = Note.swagWidth*scale;

			switch (curStage)
			{
				case 'school' | 'schoolEvil':
					babyArrow.loadGraphic(Paths.image('weeb/pixelUI/arrows-pixels'), true, 16, 16);
					babyArrow.animation.add('green', [5]);
					babyArrow.animation.add('red', [7]);
					babyArrow.animation.add('blue', [6]);
					babyArrow.animation.add('purple', [4]);

					babyArrow.setGraphicSize(Std.int(babyArrow.width * 6 * scale ));
					babyArrow.updateHitbox();
					babyArrow.antialiasing = false;

					switch (Math.abs(i))
					{
						case 0: // left
							babyArrow.x += width * 0;
							babyArrow.animation.add('static', [0]);
							babyArrow.animation.add('confirm', [8], 12, false);
							babyArrow.animation.add('pressed', [12], 24, false);
						case 1: // down
							babyArrow.x += width * 1;
							babyArrow.animation.add('static', [1]);
							babyArrow.animation.add('confirm', [9], 12, false);
							babyArrow.animation.add('pressed', [13], 24, false);
						case 2: // up
							babyArrow.x += width * 2;
							babyArrow.animation.add('static', [2]);
							babyArrow.animation.add('confirm', [10], 12, false);
							babyArrow.animation.add('pressed', [14], 24, false);
						case 3: // right
							babyArrow.x += width * 3;
							babyArrow.animation.add('static', [3]);
							babyArrow.animation.add('confirm', [11], 12, false);
							babyArrow.animation.add('pressed', [15], 24, false);
					}

				default:
					if(grayscale){
						babyArrow.frames = dishonorNotes;
					}else if(keyAmount==6){
						babyArrow.frames = Paths.getSparrowAtlas('6K_NOTE_assets');
					}else{
						babyArrow.frames = Paths.getSparrowAtlas('NOTE_assets');
					}

					babyArrow.animation.addByPrefix('green', 'arrowUP');
					babyArrow.animation.addByPrefix('blue', 'arrowDOWN');
					babyArrow.animation.addByPrefix('purple', 'arrowLEFT');
					babyArrow.animation.addByPrefix('red', 'arrowRIGHT');
					babyArrow.animation.addByPrefix('yellow', 'arrowLEFT');
					babyArrow.animation.addByPrefix('navy', 'arrowRIGHT');
					babyArrow.animation.addByPrefix('lavender', 'arrowUP');

					babyArrow.antialiasing = true;
					babyArrow.setGraphicSize(Std.int(babyArrow.width * 0.7 * scale));

					var statics = ["LEFT","DOWN","UP","RIGHT"];
					var interacts = ["left","down","up","right"];
					if(keyAmount==6){
						statics = ["LEFT","DOWN","RIGHT","LEFT","UP","RIGHT"];
						if(grayscale)
							interacts = ["left","down","right","left","up","right"];
						else
							interacts = ["left","down","right","left2","up","right2"];

					}
					var key = Std.int(Math.abs(i));
					babyArrow.x += width*key;
					babyArrow.animation.addByPrefix("static","arrow"+statics[key]);
					babyArrow.animation.addByPrefix("pressed",interacts[key] + " press",24,false);
					babyArrow.animation.addByPrefix("confirm",interacts[key] + " confirm",24,false);
			}

			babyArrow.updateHitbox();
			babyArrow.scrollFactor.set();

			babyArrow.ID = i;
			var newStrumLine:FlxSprite = new FlxSprite(0, strumLine.y).makeGraphic(10, 10);
			newStrumLine.scrollFactor.set();

			var newNoteRef:FlxSprite = new FlxSprite(0,-1000).makeGraphic(10, 10);
			newNoteRef.scrollFactor.set();

			if (player == 1)
			{
				if(!grayscale){
					playerStrums.add(babyArrow);
					playerStrumLines.add(newStrumLine);
					refNotes.add(newNoteRef);
				}else
					grayscalePlayerStrums.add(babyArrow);


			}else{
				if(!grayscale){
					dadStrums.add(babyArrow);
					opponentStrumLines.add(newStrumLine);
					opponentRefNotes.add(newNoteRef);
				}else
					grayscaleDadStrums.add(babyArrow);


			}

			if (!isStoryMode)
			{
				newStrumLine.y -= 10;
				babyArrow.alpha = 0;
				FlxTween.tween(newNoteRef, {alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
				FlxTween.tween(newStrumLine,{y: babyArrow.y + 10}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
			}

			babyArrow.animation.play('static');
			if(!currentOptions.middleScroll){
				babyArrow.x += 50;
				babyArrow.x += ((FlxG.width / 2) * player);
			}

			newStrumLine.x = babyArrow.x;
			if(!grayscale)
				strumLineNotes.add(babyArrow);
		}
	}

	function tweenCamIn():Void
	{
		FlxTween.tween(FlxG.camera, {zoom: 1.3}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.backOut});
	}

	function updateAccuracy():Void
	{
		if(totalNotes==0)
			accuracy = 1;
		else
			accuracy = hitNotes / totalNotes;

		grade = ScoreUtils.AccuracyToGrade(accuracy) + (misses==0 ? " (FC)" : ""); // TODO: Diff types of FC?? (MFC, SFC, GFC, BFC, WTFC)
		missesTxt.text = "Miss: " + misses;
		sicksTxt.text = "Sick: " + sicks;
		goodsTxt.text = "Good: " + goods;
		badsTxt.text = "Bad: " + bads;
		shitsTxt.text = "Shit: " + shits;
		epicsTxt.text = "Epic: " + epics;
	}
	override function openSubState(SubState:FlxSubState)
	{
		if (paused)
		{
			if (FlxG.sound.music != null)
			{
				FlxG.sound.music.pause();
				vocals.pause();
			}

			if (!startTimer.finished)
				startTimer.active = false;
		}

		super.openSubState(SubState);
	}

	override function closeSubState()
	{
		if (paused)
		{
			if (FlxG.sound.music != null && !startingSong)
			{
				resyncVocals();
			}

			if (!startTimer.finished)
				startTimer.active = true;
			paused = false;
			persistentUpdate = true;
			persistentDraw = true;

			#if desktop
			if (startTimer.finished)
			{
				DiscordClient.changePresence(detailsText + SONG.song + " (" + storyDifficultyText + ")", grade + " | Acc: " + truncateFloat(accuracy*100,2) + "%", iconRPC, true, songLength- Conductor.songPosition);
			}
			else
			{
				DiscordClient.changePresence(detailsText + SONG.song + " (" + storyDifficultyText + ")", grade + " | Acc: " + truncateFloat(accuracy*100,2) + "%", iconRPC);
			}
			#end
		}

		super.closeSubState();
	}

	override public function onFocus():Void
	{
		#if desktop
		if (health > 0 && !paused)
		{
			if (Conductor.songPosition > 0.0)
			{
				DiscordClient.changePresence(detailsText + SONG.song + " (" + storyDifficultyText + ")", grade + " | Acc: " + truncateFloat(accuracy*100,2) + "%", iconRPC, true, songLength-Conductor.songPosition);
			}
			else
			{
				DiscordClient.changePresence(detailsText + SONG.song + " (" + storyDifficultyText + ")", grade + " | Acc: " + truncateFloat(accuracy*100,2) + "%", iconRPC);
			}
		}
		#end

		super.onFocus();
	}

	override public function onFocusLost():Void
	{
		#if desktop
		if (health > 0 && !paused)
		{
			DiscordClient.changePresence(detailsPausedText + SONG.song + " (" + storyDifficultyText + ")", grade + " | Acc: " + truncateFloat(accuracy*100,2) + "%", iconRPC);
		}
		#end

		super.onFocusLost();
	}

	function resyncVocals():Void
	{
		if(!dontSync){
			vocals.pause();

			FlxG.sound.music.play();
			Conductor.songPosition = FlxG.sound.music.time;
			vocals.time = Conductor.songPosition;
			vocals.play();
		}
	}

	private var paused:Bool = false;
	var startedCountdown:Bool = false;
	var canPause:Bool = true;
	var disconnected=false;

	function truncateFloat( number : Float, precision : Int): Float {
		var num = number;
		num = num * Math.pow(10, precision);
		num = Math.round( num ) / Math.pow(10, precision);
		return num;
	}

	//public float GetSpritePosition(long offset, float initialPos) => HitPosition + ((initialPos - offset) * (ScrollDirection.Equals(ScrollDirection.Down) ? -HitObjectManagerKeys.speed : HitObjectManagerKeys.speed) / HitObjectManagerKeys.TrackRounding);
	// ADAPTED FROM QUAVER!!!
	// COOL GUYS FOR OPEN SOURCING
	// https://github.com/Quaver/Quaver
	// https://github.com/Quaver/Quaver
	// https://github.com/Quaver/Quaver
	function getPosFromTime(strumTime:Float):Float{
		var idx:Int = 0;
		while(idx<SONG.sliderVelocities.length){
			if(strumTime<SONG.sliderVelocities[idx].startTime)
				break;
			idx++;
		}
		return getPosFromTimeSV(strumTime,idx);
	}

	public static function getSVFromTime(strumTime:Float):Float{
		var idx:Int = 0;
		while(idx<SONG.sliderVelocities.length){
			if(strumTime<SONG.sliderVelocities[idx].startTime)
				break;
			idx++;
		}
		idx--;
		if(idx<=0)
			return SONG.initialSpeed;
		return SONG.initialSpeed*SONG.sliderVelocities[idx].multiplier;
	}

	function getPosFromTimeSV(strumTime:Float,?svIdx:Int=0):Float{
		if(svIdx==0)
			return strumTime*SONG.initialSpeed;

		svIdx--;
		var curPos = velocityMarkers[svIdx];
		curPos += ((strumTime-SONG.sliderVelocities[svIdx].startTime)*(SONG.initialSpeed*SONG.sliderVelocities[svIdx].multiplier));
		return curPos;
	}

	function updatePositions(){
		currentVisPos = Conductor.songPosition-currentOptions.noteOffset;
		while(currentSVIndex<SONG.sliderVelocities.length && currentVisPos>=SONG.sliderVelocities[currentSVIndex].startTime)
			currentSVIndex++;

		currentTrackPos = getPosFromTimeSV(currentVisPos,currentSVIndex);
	}

	function getYPosition(note:Note):Float{
		var hitPos = playerStrumLines.members[note.noteData];
		if(!note.mustPress){
			hitPos = opponentStrumLines.members[note.noteData];
		}
		return hitPos.y + ((note.initialPos-currentTrackPos) * (currentOptions.downScroll?-1:1));
	}

	// ADAPTED FROM QUAVER!!!
	// COOL GUYS FOR OPEN SOURCING
	// https://github.com/Quaver/Quaver
	// https://github.com/Quaver/Quaver
	// https://github.com/Quaver/Quaver

	var disconnectTextTimer:Float = 0;
	function NokeDisconnect(){
		if(!disconnected){
			disconnected=true;
			if(curStage=='elevator'){
				nokeFl.alpha=0;
				nokeBG.alpha=0;
				nokeFG.alpha=0;
			}

			nokeTxt.text = "DISCONNECTED";
			nokeTxt.visible=true;
			nokeTxt.x = dad.x-150+FlxG.random.int(-75,75);
			nokeTxt.y = dad.y+150+FlxG.random.int(-75,75);
			nokeTxt.angle = FlxG.random.int(-25,25);
			disconnectTextTimer=0;
		}
	}

	function NokeReconnect(){
		if(disconnected){
			disconnected=false;
			if(curStage=='elevator'){
				nokeFl.alpha=1;
				nokeBG.alpha=1;
				nokeFG.alpha=1;
			}
			nokeTxt.text = "RECONNECTED";
			nokeTxt.visible=true;
			nokeTxt.x = dad.x-150+FlxG.random.int(-75,75);
			nokeTxt.y = dad.y+150+FlxG.random.int(-75,75);
			nokeTxt.angle = FlxG.random.int(-25,25);
			disconnectTextTimer=0;
		}
	}

	var burnTicker:Float = 0;
	var salemBurnTicker:Float = 0;
	var shittyDischargeTimer:Float=0;
	var gvTime:Float = 0;
	var timer:Float=0;
	override public function update(elapsed:Float)
	{
		#if !debug
		perfectMode = false;
		#end
		if(SONG.song.toLowerCase()=='curse-eternal')
			health+=elapsed*.01;
		else if(SONG.song.toLowerCase()=='2v200')
			health-=elapsed*.01;

		timer += elapsed;
		wiggleShit.update(elapsed);
		//							dadRock = new FlxSprite(-100, -300).loadGraphic(Paths.image('thevoid/bigrock'));
		//							bfRock = new FlxSprite(770, 450).loadGraphic(Paths.image('thevoid/smallrock'));


		if(ItemState.equipped.contains("twat") && accuracy<0.9){
			beenSavedByResistance=true;
			health=-100;
		}

		if(disabledTime>0){
			disabledTime -= elapsed;
		}else{
			disabledTime = 0;
		}

		if(fuckedUpReceptors>0){
			fuckedUpReceptors -= elapsed;
			if(glitchNoteEffect!=null)
				glitchNoteEffect.strength = FlxMath.lerp(glitchNoteEffect.strength,.5,0.02);
		}else{
			if(glitchNoteEffect!=null)
				glitchNoteEffect.strength = FlxMath.lerp(glitchNoteEffect.strength,0,0.02);
			fuckedUpReceptors = 0;
		}

		if(glitchNoteEffect!=null)
			glitchNoteEffect.update();

		if(vcrDistortionHUD!=null){
			vcrDistortionHUD.update(elapsed);
			vcrDistortionGame.update(elapsed);
		}
		if(grayscaleShader!=null){

			if(isGrayscale){
				grayscaleShader.influence = FlxMath.lerp(grayscaleShader.influence,1,0.06);

			}else{
				grayscaleShader.influence = FlxMath.lerp(grayscaleShader.influence,0,0.06);
			}
			grayscaleShader.update();
		}
		if(rainShader!=null){
			rainShader.update(elapsed);
		}
		if(isGrayscale){
			grayscaleDadStrums.alpha=FlxMath.lerp(grayscaleDadStrums.alpha,1,0.06);
			grayscalePlayerStrums.alpha=FlxMath.lerp(grayscalePlayerStrums.alpha,1,0.06);
			dadStrums.alpha=FlxMath.lerp(dadStrums.alpha,0,0.06);
			playerStrums.alpha=FlxMath.lerp(playerStrums.alpha,0,0.06);
		}else{
			grayscaleDadStrums.alpha=FlxMath.lerp(grayscaleDadStrums.alpha,0,0.06);
			grayscalePlayerStrums.alpha=FlxMath.lerp(grayscalePlayerStrums.alpha,0,0.06);
			dadStrums.alpha=FlxMath.lerp(dadStrums.alpha,1,0.06);
			playerStrums.alpha=FlxMath.lerp(playerStrums.alpha,1,0.06);
		}
		modchart.update(elapsed);

		if(SONG.song.toLowerCase()=='curse-eternal' && curStep>=1476){
			if(defaultCamZoom<1.2){
				defaultCamZoom+=elapsed/6;
				if(defaultCamZoom>1.2) defaultCamZoom=1.2;
			}
			curseEternalVignette.alpha += elapsed/4;
			camHUD.alpha -= elapsed/4;
		}

		if(dad.curCharacter=='demetrios' && dad.animation.curAnim.name!='discharge' && glowBG.alpha==1 && curStage=='lab'){
			FlxTween.tween(glowBG, {alpha: 0}, .1);
			FlxTween.tween(glowCage1, {alpha: 0}, .1);
			FlxTween.tween(glowCage2, {alpha: 0}, .1);
		}

		disconnectTextTimer+=elapsed;
		if(disconnectTextTimer>.5 && dad.curCharacter=='noke'){
			nokeTxt.visible=false;
		}

		switch (curStage)
		{
			case 'time-void':
				dadRock.y = -500-25*Math.sin(timer);
				bfRock.y = -200-25*Math.cos(timer*1.25);
				boyfriend.y = 0-25*Math.cos(timer*1.25);


				gf.y = -280-25*Math.cos(timer*1.25);
				if(dad.curCharacter=='gf')
					dad.y = gf.y
				else
					dad.y = -760-25*Math.sin(timer);

				switch(boyfriend.curCharacter){
					case 'bf-neb':
						boyfriend.y -= 75;
					case 'naikaze':
						boyfriend.y -= 90;
					case 'bfside':
						boyfriend.y -= 150;
					case 'babyvase':
						boyfriend.y -= 110;
				}
				slash.y = boyfriend.y+25;

				var nextXBG = void1.x+(elapsed*256);
				var nextXBG2 = void2.x+(elapsed*256);

				void1.x = nextXBG;
				void2.x = nextXBG2;


				if(nextXBG>=3000){
					void1.x = void2.x-void2.width;
				}

				if(nextXBG2>=3000){
					void2.x = void1.x-void1.width;
				}

			case 'limo':
				camGame.shake(.0015,.1,null,true,X);
				camHUD.shake(.0015,.1,null,true,X);

				var nextXBG = des1.x+(elapsed*72);
				var nextXBG2 = des2.x+(elapsed*72);

				des1.x = nextXBG;
				des2.x = nextXBG2;


				if(nextXBG>=2000){
					des1.x = des2.x-des2.width;
				}

				if(nextXBG2>=2000){
					des2.x = des1.x-des1.width;
				}

			case 'elevator':
				camGame.shake(Conductor.bpm*.000025,.1);
				camHUD.shake(Conductor.bpm*.000025,.1);
				var nextYBG = nokeBG.y+((Conductor.bpm*8)*elapsed);
				var nextYBG2 = nokeBG2.y+((Conductor.bpm*8)*elapsed);
				var nextYFG = nokeFG.y+((Conductor.bpm*13)*elapsed);
				var nextYFG2 = nokeFG2.y+((Conductor.bpm*13)*elapsed);


				nokeBG.y = nextYBG;
				nokeBG2.y = nextYBG2;
				nokeFG.y = nextYFG;
				nokeFG2.y = nextYFG2;
				if(nextYBG>=3000){
					nokeBG.y = nokeBG2.y-nokeBG.height*2;
				}

				if(nextYBG2>=3000){
					nokeBG2.y = nokeBG.y-nokeBG.height*2;
				}

				if(nextYFG>=3000){
					nokeFG.y = nokeFG2.y-nokeFG.height*2;
				}
				if(nextYFG2>=3000	){
					nokeFG2.y = nokeFG.y-nokeFG.height*2;
				}

				nokeHBG.y = nokeBG.y;
				nokeHBG.x = nokeBG.x;
				nokeHBG2.y = nokeBG2.y;
				nokeHBG2.x = nokeBG2.x;

				nokeBG2.alpha = nokeBG.alpha;
				nokeFG2.alpha = nokeFG.alpha;

				nokeHFG.y = nokeFG.y;
				nokeHFG.x = nokeFG.x;
				nokeHFG2.y = nokeFG2.y;
				nokeHFG2.x = nokeFG2.x;
			case 'philly':
				if (trainMoving)
				{
					trainFrameTiming += elapsed;

					if (trainFrameTiming >= 1 / 24)
					{
						updateTrainPos();
						trainFrameTiming = 0;
					}
				}
				//phillyCityLights.members[curLight].alpha -= (Conductor.crochet / 1000) * FlxG.elapsed * 1.5;
		}


		iconP1.visible = modchart.hudVisible;
		iconP2.visible = modchart.hudVisible;
		healthBar.visible = modchart.hudVisible;
		healthBarBG.visible = modchart.hudVisible;
		sicksTxt.visible = ScoreUtils.botPlay?false:modchart.hudVisible;
		badsTxt.visible = ScoreUtils.botPlay?false:modchart.hudVisible;
		shitsTxt.visible = ScoreUtils.botPlay?false:modchart.hudVisible;
		epicsTxt.visible = ScoreUtils.botPlay?false:modchart.hudVisible;
		goodsTxt.visible = ScoreUtils.botPlay?false:modchart.hudVisible;
		missesTxt.visible = ScoreUtils.botPlay?false:modchart.hudVisible;
		highComboTxt.visible = ScoreUtils.botPlay?false:modchart.hudVisible;
		scoreTxt.visible = modchart.hudVisible;
		scoreTxt.screenCenter(X);
		if(presetTxt!=null)
			presetTxt.visible = ScoreUtils.botPlay?false:modchart.hudVisible;

		if(vietnamFlashbacks){
			gvTime+=elapsed;
			camHUD.x = 8*Math.cos(gvTime*2);
			camHUD.y = 16*Math.cos(gvTime*4);
			// TODO: toggle
			aCamFollow.x = camFollow.x + 4*Math.cos(gvTime*2);
			aCamFollow.y = camFollow.y + 12*Math.cos(gvTime*4);
		}else{
			camHUD.x = FlxMath.lerp(camHUD.x, 0, 0.1);
			camHUD.y = FlxMath.lerp(camHUD.y, 0, 0.1);
			aCamFollow.x = camFollow.x;
			aCamFollow.y = camFollow.y;
		}
		super.update(elapsed);
		if(burnTimer>0){
			// TODO: Animation?
			burnTimer-=elapsed;
			burnTicker+=elapsed;
			if(burnTimer<0)burnTimer=0;
			if(burnTicker>=burnTicks){
				burnTicker-=burnTicks;
				if(ItemState.equipped.contains("depressed")){
					health-=.025;
				}else{
					health-=.05;
				}

			}
		}

		if(SONG.song.toLowerCase()=='salem'){
			salemBurnTicker+=elapsed;
			if(salemBurnTicker>=.3){
				salemBurnTicker-=.3;
				/*if(health>.01){
					health-=.01;
				}*/
			}
		}

		if(discharging){
			gf.playAnim("scared",true);
			var damage = 2*elapsed;
			var newHP = health-damage;
			if(newHP<=.001){
				discharging=false;
				newHP=.001;
			}
			health=newHP;
			dischargeHP-=damage;
			if(dischargeHP<=0)
				discharging=false;
		}

		scoreTxt.text = "Score:" + songScore + " | Accuracy:" + truncateFloat(accuracy*100, 2) + "% | " + grade;

		displayedHealth = FlxMath.lerp(displayedHealth,health,.2/(openfl.Lib.current.stage.frameRate/60));

		previousHealth=health;
		if (FlxG.keys.justPressed.ENTER && startedCountdown && canPause)
		{
			persistentUpdate = false;
			persistentDraw = true;
			paused = true;

			// 1 / 1000 chance for Gitaroo Man easter egg
			if (FlxG.random.bool(0.1))
			{
				// gitaroo man easter egg

				FlxG.switchState(new GitarooPause());
				//unloadAssets();
			}
			else
				openSubState(new PauseSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));

			#if desktop
			DiscordClient.changePresence(detailsPausedText + SONG.song + " (" + storyDifficultyText + ")", grade + " | Acc: " + truncateFloat(accuracy*100,2) + "%", iconRPC);
			#end
		}

		if (FlxG.keys.justPressed.SEVEN)
		{

			FlxG.switchState(new ChartingState());
			//unloadAssets();
			#if desktop
			DiscordClient.changePresence("Chart Editor", null, null, true);
			#end
		}

		// FlxG.watch.addQuick('VOL', vocals.amplitudeLeft);
		// FlxG.watch.addQuick('VOLRight', vocals.amplitudeRight);

		iconP1.setGraphicSize(Std.int(FlxMath.lerp(iconP1.width, iconP1.iWidth, 0.09/(openfl.Lib.current.stage.frameRate/60))));
		iconP2.setGraphicSize(Std.int(FlxMath.lerp(iconP2.width, iconP2.iWidth, 0.09/(openfl.Lib.current.stage.frameRate/60))));

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		var iconOffset:Int = 26;

		iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01) - iconOffset);
		iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (iconP2.width - iconOffset);

		if (health > 2){
			health = 2;
			previousHealth = health;
		}


		if (healthBar.percent <= 20)
			iconP1.animation.curAnim.curFrame = 0;
		else if(healthBar.percent >= 80)
			iconP1.animation.curAnim.curFrame = 2;
		else
			iconP1.animation.curAnim.curFrame = 1;

		if (healthBar.percent <= 20)
			iconP2.animation.curAnim.curFrame = 2;
		else if(healthBar.percent >= 80)
			iconP2.animation.curAnim.curFrame = 0;
		else
			iconP2.animation.curAnim.curFrame = 1;

		/* if (FlxG.keys.justPressed.NINE)
			FlxG.switchState(new Charting()); */

		if (FlxG.keys.justPressed.EIGHT){
				FlxG.switchState(new AnimationDebug(dad.curCharacter));
				//unloadAssets();
			}
		else if (FlxG.keys.justPressed.SIX){
				FlxG.switchState(new AnimationDebug("bf-FUCKING-DIES"));
				//unloadAssets();
			}
		if (startingSong)
		{
			if (startedCountdown)
			{
				Conductor.songPosition += FlxG.elapsed * 1000;
				updatePositions();
				if (Conductor.songPosition >= 0)
					startSong();
			}
		}
		else
		{
			// Conductor.songPosition = FlxG.sound.music.time;
			Conductor.songPosition += FlxG.elapsed * 1000;
			updatePositions();

			if (!paused)
			{
				songTime += FlxG.game.ticks - previousFrameTime;
				previousFrameTime = FlxG.game.ticks;

				// Interpolation type beat
				if (Conductor.lastSongPos != Conductor.songPosition)
				{
					songTime = (songTime + Conductor.songPosition) / 2;
					Conductor.lastSongPos = Conductor.songPosition;
					// Conductor.songPosition += FlxG.elapsed * 1000;
					// trace('MISSED FRAME');
				}
			}

			// Conductor.lastSongPos = FlxG.sound.music.time;
		}


		if (generatedMusic && PlayState.SONG.notes[Std.int(curStep / 16)] != null)
		{
			if (curBeat % 4 == 0)
			{
				// trace(PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection);
			}
			if(Conductor.songPosition>=0){
				if(SONG.song.toLowerCase()!='hivemind' && curStage!='elevator'){
					if (camFollow.x != dad.getMidpoint().x + 150 && !PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection)
					{
						camFollow.setPosition(dad.getMidpoint().x + 150, dad.getMidpoint().y - 100);
						// camFollow.setPosition(lucky.getMidpoint().x - 120, lucky.getMidpoint().y + 210);

						switch (dad.curCharacter)
						{
							case 'mom' | 'mom-car':
								camFollow.y = dad.getMidpoint().y + 80;
								camFollow.x = dad.getMidpoint().x + 190;
							case 'senpai':
								camFollow.y = dad.getMidpoint().y - 300;
								camFollow.x = dad.getMidpoint().x + 100;
							case 'senpai-angry':
								camFollow.y = dad.getMidpoint().y - 300;
								camFollow.x = dad.getMidpoint().x - 100;
							case 'mika' | 'angry-fucking-child':
								camFollow.setPosition(dad.getMidpoint().x+100,boyfriend.getMidpoint().y-100);
							case 'army':
								if(SONG.song.toLowerCase()=='2v200'){
									camFollow.x = boyfriend.getMidpoint().x + 150;
									camFollow.y = boyfriend.getMidpoint().y - 300;
								}
							case 'flexy':
								camFollow.y = dad.getMidpoint().y - 350;
							case 'merchant':
								camFollow.x = dad.getMidpoint().x + 380;
							case 'anders':
								camFollow.y = dad.getMidpoint().y - 15;
							case 'kapi':
								camFollow.y = dad.getMidpoint().y - 35;
							case 'demetrios':
								camFollow.y = dad.getMidpoint().y + 150;
						}

						if (dad.curCharacter == 'mom')
							vocals.volume = 1;

						if (SONG.song.toLowerCase() == 'tutorial')
						{
							tweenCamIn();
						}else if (SONG.song.toLowerCase() == '2v200'){
							FlxTween.tween(FlxG.camera, {zoom: .65}, .1, {ease: FlxEase.linear});
						}else if(SONG.song.toLowerCase() == '2v200'){
							FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, .1, {ease: FlxEase.linear});
						}
					}

					if (PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection && camFollow.x != boyfriend.getMidpoint().x - 100)
					{
						camFollow.setPosition(boyfriend.getMidpoint().x - 100, boyfriend.getMidpoint().y - 100);

						switch (curStage)
						{
							case 'limo':
								camFollow.x = boyfriend.getMidpoint().x - 175;
							case 'mall':
								camFollow.y = boyfriend.getMidpoint().y - 200;
							case 'school':
								camFollow.x = boyfriend.getMidpoint().x - 200;
								camFollow.y = boyfriend.getMidpoint().y - 250;
							case 'schoolEvil':
								camFollow.x = boyfriend.getMidpoint().x - 200;
								camFollow.y = boyfriend.getMidpoint().y - 250;
							case 'apocalypse':
								camFollow.setPosition(boyfriend.getMidpoint().x - 100, boyfriend.getMidpoint().y - 125);
							case 'omegafield':
								if(SONG.song.toLowerCase()=='2v200'){
									camFollow.x = boyfriend.getMidpoint().x + 150;
									camFollow.y = boyfriend.getMidpoint().y - 200;
								}
							case 'lab':
								camFollow.setPosition(boyfriend.getMidpoint().x - 175,boyfriend.getMidpoint().y - 150);
							case 'drugmart':
								camFollow.setPosition(boyfriend.getMidpoint().x - 175,boyfriend.getMidpoint().y - 200);
							case 'dojo':
								camFollow.setPosition(boyfriend.getMidpoint().x - 150,boyfriend.getMidpoint().y - 500);
						}

						if(boyfriend.curCharacter=='bf-pixel' && SONG.song.toLowerCase()=='father-time'){
							camFollow.x = boyfriend.getMidpoint().x - 200;
							camFollow.y = boyfriend.getMidpoint().y - 200;
						}

						if (SONG.song.toLowerCase() == 'tutorial')
						{
							FlxTween.tween(FlxG.camera, {zoom: 1}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.backOut});
						}
					}
				}
			}else if(SONG.song.toLowerCase()=='hivemind'){
				camFollow.setPosition(dad.getMidpoint().x+125,dad.getMidpoint().y);
			}else{
				camFollow.setPosition(dad.getMidpoint().x+400,dad.getMidpoint().y);
			}
		}

		if (camZooming)
		{
			FlxG.camera.zoom = FlxMath.lerp(FlxG.camera.zoom,defaultCamZoom, 0.05);
			camHUD.zoom = FlxMath.lerp(camHUD.zoom,1, 0.05);
		}

		FlxG.watch.addQuick("beatShit", curBeat);
		FlxG.watch.addQuick("stepShit", curStep);

		if (curSong == 'Fresh')
		{
			switch (curBeat)
			{
				case 16:
					camZooming = true;
					gfSpeed = 2;
				case 48:
					gfSpeed = 1;
				case 80:
					gfSpeed = 2;
				case 112:
					gfSpeed = 1;
				case 163:
					// FlxG.sound.music.stop();
					// FlxG.switchState(new TitleState());
			}
		}

		if(curSong == 'Spookeez'){
			switch (curStep){
				case 444,445:
					gf.playAnim("cheer",true);
					boyfriend.playAnim("hey",true);
			}
		}

		if (curSong == 'Bopeebo')
		{
			switch (curBeat)
			{
				case 128, 129, 130:
					vocals.volume = 0;
					// FlxG.sound.music.stop();
					// FlxG.switchState(new PlayState());
			}
		}
		// better streaming of shit

		// RESET = Quick Game Over Screen
		if (controls.RESET)
		{
			health = 0;
			trace("RESET = True");
		}

		// CHEAT = brandon's a pussy
		if (controls.CHEAT)
		{
			health += 1;
			previousHealth = health;
			trace("User is cheating!");
		}

		if (health <= 0)
		{
			if(!ItemState.equipped.contains("arrow") || beenSavedByResistance){
				boyfriend.stunned = true;

				persistentUpdate = false;
				persistentDraw = false;
				paused = true;

				vocals.stop();
				FlxG.sound.music.stop();
				if(storyDifficulty==0 && SONG.song.toLowerCase()=='prelude'){
					FlxG.save.data.unlocked.push("Thats not how you do it");

				}
				blueballs++;
				if(blueballs==10){
					FlxG.save.data.getResistance=true;
					UnlockingItemState.unlocking.push("resistance");
				}else if(blueballs==99 && SONG.song.toLowerCase()=='last-stand'){
					AchievementState.toUnlock.push("Waste of Time");
					FlxG.save.data.unlocked.push("Waste of Time");
				}

				openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y, boyfriend.isReskin?boyfriend.curCharacter:'bf', fuckedUpReceptors>0 ));
				//unloadAssets();
				// FlxG.switchState(new GameOverState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));

				#if desktop
				// Game Over doesn't get his own variable because it's only used here
				DiscordClient.changePresence("Game Over - " + detailsText + SONG.song + " (" + storyDifficultyText + ")", grade + " | Acc: " + truncateFloat(accuracy*100,2) + "%", iconRPC);
				#end
			}else if(ItemState.equipped.contains("arrow") && !beenSavedByResistance){
				FlxG.sound.play(Paths.sound('Gold_Note_Hit'), 0.7);
				goldOverlay.alpha = 1;
				if(goldOverlayTween!=null)
					goldOverlayTween.cancel();
				goldOverlayTween = FlxTween.tween(goldOverlay, {alpha: 0}, .25);

				if(curStage.startsWith("school"))
					FlxG.sound.play(Paths.music('gameOverEnd-pixel'));
				else
					FlxG.sound.play(Paths.music('gameOverEnd'));

				songScore-=12500;
				hitNotes-=6;
				burnTimer=0;
				beenSavedByResistance=true;
				health = 1;
				previousHealth=health;
			}
		}

		if (unspawnNotes[0] != null)
		{
			if (unspawnNotes[0].strumTime - Conductor.songPosition < 1500)
			{
				var dunceNote:Note = unspawnNotes[0];
				renderedNotes.add(dunceNote);
				if(dunceNote.mustPress)
					playerRenderedNotes.add(dunceNote);
				else
					opponentRenderedNotes.add(dunceNote);
				hittableNotes.push(dunceNote);

				var index:Int = unspawnNotes.indexOf(dunceNote);
				unspawnNotes.splice(index, 1);

				playerRenderedNotes.sort((br,a, b) -> Std.int(a.strumTime - b.strumTime));
				opponentRenderedNotes.sort((br,a, b) -> Std.int(a.strumTime - b.strumTime));

				hittableNotes.sort((a,b)->Std.int(a.strumTime-b.strumTime));
			}
		}

		if (generatedMusic)
		{

			if(ItemState.equipped.contains("drunk")){
				for(idx in 0...opponentRefNotes.length){
					opponentRefNotes.members[idx].angle = 15*Math.cos((timer*2)+idx*2);
					opponentNoteOffsets[idx][0]=(100*Math.cos(((timer*4)+idx/2)));
					opponentNoteOffsets[idx][1]=(40*Math.sin((timer*2)+idx*2));
				}
				for(idx in 0...refNotes.length){
					refNotes.members[idx].angle = 15*Math.cos((timer*2)+(idx+keyAmount-1)*2);
					playerNoteOffsets[idx][0]=(100*Math.cos(((timer*4)+(idx+keyAmount-1)/2)));
					playerNoteOffsets[idx][1]=(40*Math.sin((timer*2)+(idx+keyAmount-1)*2));
				}
			}
			for(idx in 0...playerStrumLines.length){
				var width = (Note.swagWidth*modchart.playerNoteScale);
				var line = playerStrumLines.members[idx];
				if(currentOptions.middleScroll){
					line.screenCenter(X);
					line.x += width*(-(keyAmount/2) +idx) + playerNoteOffsets[idx][0];
				}else{
					line.x = (width*idx) + 50 + ((FlxG.width / 2)) + playerNoteOffsets[idx][0];
				}
				line.y = strumLine.y+playerNoteOffsets[idx][1];
			}
			for(idx in 0...opponentStrumLines.length){
				var width = (Note.swagWidth*modchart.opponentNoteScale);
				var line = opponentStrumLines.members[idx];
				if(currentOptions.middleScroll){
					line.screenCenter(X);
					line.x += width*(-2+idx) + opponentNoteOffsets[idx][0] ;
				}else{
					line.x = (width*idx) + 50 +opponentNoteOffsets[idx][0];
				}
				line.y = strumLine.y+opponentNoteOffsets[idx][1];
			}

			for (idx in 0...strumLineNotes.length){
				var note = strumLineNotes.members[idx];
				var offset = opponentNoteOffsets[idx%keyAmount];
				var strumLine = opponentStrumLines.members[idx%keyAmount];
				var alpha = opponentRefNotes.members[idx%keyAmount].alpha;
				var angle = opponentRefNotes.members[idx%keyAmount].angle;
				if(idx>keyAmount-1){
					offset = playerNoteOffsets[idx%keyAmount];
					strumLine = playerStrumLines.members[idx%keyAmount];
					if(fuckedUpReceptors>0){
						if(noteOrder.indexOf(idx%keyAmount)!=-1){
							strumLine = playerStrumLines.members[noteOrder.indexOf(idx%keyAmount)];
						}
					}
					alpha = refNotes.members[idx%keyAmount].alpha;
					angle = refNotes.members[idx%keyAmount].angle;
				}
				note.x = strumLine.x;
				note.y = strumLine.y;

				note.alpha = alpha;
				note.angle=angle;
			}

			var hittingData:Array<Array<Dynamic>>=[];
			renderedNotes.forEachAlive(function(daNote:Note)
			{
				var strumLine = strumLine;
				if(modchart.playerNotesFollowReceptors){
					strumLine = playerStrumLines.members[daNote.noteData];
					if(fuckedUpReceptors>0){
						if(noteOrder.indexOf(daNote.noteData)!=-1){
							strumLine = playerStrumLines.members[noteOrder.indexOf(daNote.noteData)];
						}
					}
				}



				var alpha = refNotes.members[daNote.noteData].alpha;
				if(!daNote.mustPress){
					alpha = opponentRefNotes.members[daNote.noteData].alpha;
					if(modchart.opponentNotesFollowReceptors)
						strumLine = opponentStrumLines.members[daNote.noteData];
				}

				if (daNote.y > FlxG.height)
				{
					daNote.active = false;

					daNote.visible = false;
				}
				else
				{
					if((daNote.mustPress || SONG.song.toLowerCase()=='hivemind' || !daNote.mustPress && !currentOptions.middleScroll )){
						daNote.visible = true;
					}

					daNote.active = true;
				}

				if(!daNote.mustPress && currentOptions.middleScroll && SONG.song.toLowerCase()!='hivemind'){
					daNote.visible=false;
				}
				var width = Note.swagWidth;
				if(daNote.mustPress)
					width*=modchart.playerNoteScale;
				else
					width*=modchart.opponentNoteScale;

				if(dad.curCharacter=='angry-fucking-child' && dad.animation.curAnim.name=='cry'){
					daNote.canBeHit=false;
				}
				var brr = strumLine.y + width/2;
				daNote.y = getYPosition(daNote);
				if(currentOptions.downScroll){
					if(daNote.isSustainNote){
						if(daNote.animation.curAnim.name.endsWith("end") && daNote.prevNote!=null){
							daNote.y += daNote.prevNote.height;
						}else{
							daNote.y += daNote.height/2;
						}
					}
					if (daNote.isSustainNote
						&& daNote.y-daNote.offset.y*Math.abs(daNote.scale.y)+daNote.height>=brr
						&& (!daNote.mustPress && daNote.canBeHit || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit))))
					{
						var swagRect = new FlxRect(0,0,daNote.frameWidth*2,daNote.frameHeight*2);
						swagRect.height = (brr-daNote.y)/Math.abs(daNote.scale.y);
						swagRect.y = daNote.frameHeight-swagRect.height;

						daNote.clipRect = swagRect;
					}
				}else{
					if (daNote.isSustainNote
						&& daNote.y + daNote.offset.y * Math.abs(daNote.scale.y) <= brr
						&& (!daNote.mustPress && daNote.canBeHit || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit))))
					{
						var swagRect = new FlxRect(0,0,daNote.width/daNote.scale.x,daNote.height/Math.abs(daNote.scale.y));
						swagRect.y = (brr-daNote.y)/Math.abs(daNote.scale.y);
						swagRect.height -= swagRect.y;

						daNote.clipRect = swagRect;
					}
				}

				if(modchart.playerNotesFollowReceptors && daNote.mustPress || modchart.opponentNotesFollowReceptors && !daNote.mustPress)
					daNote.x = strumLine.x+daNote.susOffset;
				else{
					var scale = daNote.mustPress?modchart.playerNoteScale:modchart.opponentNoteScale;
					if(currentOptions.middleScroll){
						daNote.screenCenter(X);
						daNote.x += width*(-(keyAmount/2) +daNote.noteData);
					}else
						daNote.x = 50+(width*daNote.noteData)+(daNote.mustPress?FlxG.width/2:0)+daNote.susOffset;
				}
				if(daNote.isSustainNote){
					if(curStage.startsWith("school"))
						daNote.alpha = FlxMath.lerp(1, 0, 1-alpha);
					else{
						if(daNote.tooLate)
							daNote.alpha = FlxMath.lerp(.3, 0, 1-alpha);
						else
							daNote.alpha = FlxMath.lerp(.6, 0, 1-alpha);
					}
				}else{
					if(daNote.tooLate)
						daNote.alpha = .3;
					else
						daNote.alpha = alpha;
				}

				if (!daNote.mustPress && daNote.canBeHit && !daNote.wasGoodHit)
				{
					var d=0;
					dadStrums.forEach(function(spr:FlxSprite)
					{
						if (Math.abs(daNote.noteData) == spr.ID)
						{
							spr.animation.play('confirm', true);
							grayscaleDadStrums.members[spr.ID].animation.play('confirm',true);
						}
					});
					if (SONG.song != 'Tutorial' && SONG.song != 'Prelude')
						camZooming = true;
					else
						camZooming = false;

					var altAnim:String = "";

					if (SONG.notes[Math.floor(curStep / 16)] != null)
					{
						if (SONG.notes[Math.floor(curStep / 16)].altAnim && SONG.song.toLowerCase()!='guardian' && SONG.song.toLowerCase()!='after-the-ashes')
							altAnim = '-alt';
					}

					if(modchart.susHeal || !daNote.isSustainNote){
						var drain = modchart.opponentHPDrain;
						if(ItemState.equipped.contains("resistance"))
							drain-=drain*.5;

						health -= drain;
					}

					var anim = "";

					anim = singAnims[daNote.noteData] + altAnim;

					switch (anim)
					{
						case 'singUP' | 'singDOWN' | 'singDOWN-alt' | 'singUP-alt':
							if(dad.curCharacter=='noke'){
								NokeDisconnect();
							}
						default:
							if(dad.curCharacter=='noke'){
								NokeReconnect();
							}
					}

					if(daNote.noteType==3){
							FlxG.sound.play(Paths.sound('Gold_Note_Hit'), 0.7);
							goldOverlay.alpha = 1;
							if(goldOverlayTween!=null)
								goldOverlayTween.cancel();
							goldOverlayTween = FlxTween.tween(goldOverlay, {alpha: 0}, .25);
							if(ItemState.equipped.contains("depressed"))
								health -= .125;
							else
								health -= .25;
					}

					if(daNote.noteType==4){
						anim='discharge';
						if(curStage=='lab'){
							FlxTween.tween(glowBG, {alpha: 1}, .1);
							FlxTween.tween(glowCage1, {alpha: 1}, .1);
							FlxTween.tween(glowCage2, {alpha: 1}, .1);
						}
						dad.holding=false;
						dad.playAnim("discharge",true);
						new FlxTimer().start(.358, function(tmr:FlxTimer){
							boyfriend.playAnim("dischargeScared",true);
							gf.playAnim("scared",true);
							discharging=true;
							if(ItemState.equipped.contains("depressed"))
								dischargeHP=health/2;
							else
								dischargeHP=health;

							camGame.shake(.01,.4);
							camHUD.shake(.01,.4);
							FlxG.sound.play(Paths.sound('discharge'), 1);
						});
					}else if (daNote.noteType==6){
						if(ItemState.equipped.contains("depressed"))
							health-=.0075;
						else
							health-=.015;
					}else if (daNote.noteType==7){
						health=.01;
					}


					if(daNote.noteType!=4)
						hittingData.push([daNote.noteData,daNote.strumTime,anim,daNote.isSustainNote,daNote.holdParent]);


					if (SONG.needsVoices)
						vocals.volume = 1;
					daNote.wasGoodHit=true;
					lastHitDadNote=daNote;
					if(!daNote.isSustainNote){
						daNote.kill();
						hittableNotes.remove(daNote);
						renderedNotes.remove(daNote, true);
						daNote.destroy();
					}
				}

				if(isGrayscale){
					camHUD.shake(.005,.1);
					camGame.shake(.005,.1);
				}

				// I KNOW I CAN DO THIS BETTER
				// BUT I DONT CARE!!!! IT WORKS!!!!
				// GOD ITS SO CONVOLUTED LOL WHY DID I DO THIS

				// OK TURNS OUT I DONT EVEN NEED TO DO THIS BUT IDC IM KEEPING THE CODE BECAUSE IDK IF IT HANDLES SHIT W/ TRYING TO USE LEFT-MOST ANIM BETTER
				// IT DOES NOT BUT IDC


				if(hittingData.length>0){
					var aids:Array<Dynamic>=[];
					for(i in hittingData){
						var noteData:Float=i[0];
						var strumTime:Float=i[1];
						var anim:String=i[2];
						var sustain:Bool=i[3];
						var holdParent:Bool=i[4];

						var shouldAddShit=true;
						if(aids[1]>strumTime || aids[2]<noteData){
							shouldAddShit=false;
						}

						if(shouldAddShit){
							aids = [strumTime,noteData,holdParent,sustain,anim];
						}
					}

					var isSussy = aids[3];
					var anim = aids[4];
					var holdParent = aids[2];
					var char = dad;

					if(SONG.notes[Math.floor(curStep / 16)].altAnim && SONG.song.toLowerCase()=='after-the-ashes' )
						char=mika;

					var canHold = isSussy && char.animation.getByName(anim+"Hold")!=null;
					if(canHold && !char.animation.curAnim.name.startsWith(anim)){
						char.playAnim(anim,true);
					}else if(currentOptions.pauseHoldAnims && !canHold){
						char.playAnim(anim,true);
						if(holdParent )
							char.holding=true;
						else{
							char.holding=false;
						}
					}else if(!currentOptions.pauseHoldAnims && !canHold){
						char.playAnim(anim,true);
					}
					char.holdTimer=0;

					if(armyRight.visible){
						var canHold2 = isSussy && armyRight.animation.getByName(anim+"Hold")!=null;
						if(canHold2 && !armyRight.animation.curAnim.name.startsWith(anim)){
							armyRight.playAnim(anim,true);
						}else if(currentOptions.pauseHoldAnims && !canHold2){
							armyRight.playAnim(anim,true);
							if(holdParent )
								armyRight.holding=true;
							else{
								armyRight.holding=false;
							}
						}else if(!currentOptions.pauseHoldAnims && !canHold2){
							armyRight.playAnim(anim,true);
						}
						armyRight.holdTimer = 0;
					}
				}

				if ((!currentOptions.downScroll && daNote.y < -daNote.height || currentOptions.downScroll && daNote.y>FlxG.height) && daNote.mustPress)
				{
					if ((daNote.tooLate || !daNote.wasGoodHit) && !daNote.canMiss)
					{
						trace("miss");
						if(!daNote.isSustainNote){
							if(daNote.noteType==7){
								health -= 1.99;
							}
							noteMiss(daNote.noteData,daNote);
						}else{
							combo=0;
							misses++;
							if(SONG.song.toLowerCase()!='curse-eternal')
								health-=.01;
						}

						totalNotes++;
						vocals.volume = 0;
						updateAccuracy();
					}

					daNote.active = false;
					daNote.visible = false;

					daNote.kill();
					hittableNotes.remove(daNote);
					renderedNotes.remove(daNote, true);
					daNote.destroy();
				}
			});
		}
		dadStrums.forEach(function(spr:FlxSprite)
		{
			if(spr.animation.curAnim.name!='confirm' && SONG.song.toLowerCase().startsWith('last-stand')){
				spr.visible=false;
				grayscaleDadStrums.members[spr.ID].visible=false;
			}else if(spr.animation.curAnim.name=='confirm' && SONG.song.toLowerCase().startsWith('last-stand')){
				spr.visible=true;
				grayscaleDadStrums.members[spr.ID].visible=true;
			}

			if (spr.animation.finished && spr.animation.curAnim.name=='confirm')
			{
				spr.animation.play('static',true);
				grayscaleDadStrums.members[spr.ID].animation.play("static",true);
				spr.centerOffsets();
			}

			if (spr.animation.curAnim.name == 'confirm' && !curStage.startsWith('school'))
			{
				spr.centerOffsets();
				spr.offset.x -= 13*(1/modchart.opponentNoteScale);
				spr.offset.y -= 13*(1/modchart.opponentNoteScale);
			}
			else
				spr.centerOffsets();


			grayscaleDadStrums.members[spr.ID].x = spr.x;
			grayscaleDadStrums.members[spr.ID].y = spr.y;
			grayscaleDadStrums.members[spr.ID].angle = spr.angle;
			grayscaleDadStrums.members[spr.ID].offset.set(spr.offset.x,spr.offset.y);
		});

		if (!inCutscene)
			keyShit();

		if(Conductor.songPosition-currentOptions.noteOffset>=FlxG.sound.music.length){
			if(FlxG.sound.music.volume>0 || vocals.volume>0)
				endSong();

			FlxG.sound.music.volume=0;
			vocals.volume=0;
		}
		#if debug
		if (FlxG.keys.justPressed.ONE)
			endSong();
		#end
	}

	function endSong():Void
	{
		FlxG.sound.music.stop();
		didIntro = false;
		canPause = false;
		FlxG.sound.music.volume = 0;
		vocals.volume = 0;

		if(!ScoreUtils.botPlay){
			if (SONG.validScore)
			{
				#if !switch
				Highscore.saveScore(SONG.song, songScore, storyDifficulty);
				#end
			}
			blueballs=0;
			if(accuracy>=.9 && !FlxG.save.data.beATwat){
				FlxG.save.data.beATwat=true;
				UnlockingItemState.unlocking.push('twatmode');
			}

			if(!FlxG.save.data.finishedSongs.contains(SONG.song.toLowerCase()))
				FlxG.save.data.finishedSongs.push(SONG.song.toLowerCase());

			var isHard = (storyDifficulty>=2 || SONG.song.toLowerCase()=='dishonor' || SONG.song.toLowerCase()=='hivemind' );
			if(misses==0 && isHard  && !FlxG.save.data.perfectedSongs.contains(SONG.song.toLowerCase())){
				FlxG.save.data.perfectedSongs.push(SONG.song.toLowerCase());
			}
			if(ItemState.equipped.contains("twat") && isHard && !FlxG.save.data.flashySongs.contains(SONG.song.toLowerCase()) ){
				FlxG.save.data.flashySongs.push(SONG.song.toLowerCase());
			}
			if(storyDifficulty==3 && !FlxG.save.data.glitchSongs.contains(SONG.song.toLowerCase()) ){
				FlxG.save.data.glitchSongs.push(SONG.song.toLowerCase());
			}
			if(songScore==69420){
				AchievementState.toUnlock.push("LOL");
				FlxG.save.data.unlocked.push("LOL");
			}
		}

		AchievementState.checkUnlocks();

		if (isStoryMode)
		{
			campaignScore += songScore;

			storyPlaylist.remove(storyPlaylist[0]);
			if(SONG.song.toLowerCase()=='guardian' ){
				AchievementState.checkUnlocks();
				LoadingState.loadAndSwitchState(new CutsceneState(CoolUtil.coolTextFile(Paths.txt('guardian/decidetime')),new PlayState()));
			}else{

				if (storyPlaylist.length <= 0)
				{
					if(SONG.song.toLowerCase()=='curse-eternal' ){
						var state:MusicBeatState = new MainMenuState();
						if(!ScoreUtils.botPlay){
							if(!FlxG.save.data.omegaBadEnding){
								UnlockingItemState.unlocking.push('coldheart');
								state = new UnlockingItemState();
								FlxG.save.data.omegaBadEnding=true;
							}
						}
						LoadingState.loadAndSwitchState(new VideoState('assets/videos/CryAboutIt.webm', state));

						//unloadAssets();
					}else if(SONG.song.toLowerCase()=='after-the-ashes'){
						if(!ScoreUtils.botPlay){
							FlxG.save.data.daddyTimeTime=true;
							if(!FlxG.save.data.omegaGoodEnding){
								FlxG.save.data.omegaGoodEnding=true;
								UnlockingItemState.unlocking.push('omegasword');
							}
						}

					}

					transIn = FlxTransitionableState.defaultTransIn;
					transOut = FlxTransitionableState.defaultTransOut;

					if(SONG.song.toLowerCase()=='father-time'){

						var state:MusicBeatState = new MainMenuState();
						if(!ScoreUtils.botPlay){
							if(!FlxG.save.data.canGlitch){
								UnlockingItemState.unlocking.push('glitchdiff');
								state = new UnlockingItemState();
								FlxG.save.data.canGlitch=true;
							}
						}
						if(SkinState.selectedSkin=='bfside'){
							LoadingState.loadAndSwitchState(new CutsceneState(CoolUtil.coolTextFile(Paths.txt('father-time/fatherPOUNDED')),new VideoState('assets/videos/DO NOT DELETE OR GAME WILL CRASH/YouFoundSomethingYouShouldntHave.webm', state)));
						}else{
							LoadingState.loadAndSwitchState(new CutsceneState(CoolUtil.coolTextFile(Paths.txt('father-time/fatherPOUNDED')),state));
						}
					}else if(UnlockingItemState.unlocking.length!=0){
						FlxG.switchState(new UnlockingItemState());
					}else if(SONG.song.toLowerCase()=='after-the-ashes'){
						FlxG.switchState(new MainMenuState());
					}else{
						FlxG.switchState(new StoryMenuState());
					}

					StoryMenuState.weekUnlocked[Std.int(Math.min(storyWeek + 1, StoryMenuState.weekUnlocked.length - 1))] = true;

					if (SONG.validScore)
					{
						Highscore.saveWeekScore(storyWeek, campaignScore, storyDifficulty);
					}

					FlxG.save.data.weekUnlocked = StoryMenuState.weekUnlocked;
					FlxG.save.flush();
				}
				else
				{
					var difficulty:String = "";

					if (storyDifficulty == 0)
						difficulty = '-easy';

					if (storyDifficulty == 2)
						difficulty = '-hard';

					if (storyDifficulty == 3)
						difficulty = '-glitch';
					trace('LOADING NEXT SONG');
					trace(PlayState.storyPlaylist[0].toLowerCase() + difficulty);

					if (SONG.song.toLowerCase() == 'monster')
					{
						var blackShit:FlxSprite = new FlxSprite(-FlxG.width * FlxG.camera.zoom,
							-FlxG.height * FlxG.camera.zoom).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
						blackShit.scrollFactor.set();
						add(blackShit);
						camHUD.visible = false;

						var cum = FlxG.sound.play(Paths.sound('Lights_Shut_off'));
						cum.persist=true;
					}

					FlxTransitionableState.skipNextTransIn = true;
					FlxTransitionableState.skipNextTransOut = true;
					prevCamFollow = camFollow;

					PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + difficulty, PlayState.storyPlaylist[0]);
					FlxG.sound.music.stop();
					FlxG.save.flush();
					switch(SONG.song.toLowerCase()){
						case 'odd-job'|'guardian'|'2v200'|'after-the-ashes'|'last-stand'|'curse-eternal':
							LoadingState.loadAndSwitchState(new CutsceneState(CoolUtil.coolTextFile(Paths.txt('${SONG.song.toLowerCase()}/cutscene')),new PlayState()));
						case 'mercenary':
							if(FlxG.save.data.omegaGoodEnding || FlxG.save.data.omegaBadEnding)
								LoadingState.loadAndSwitchState(new CutsceneState(CoolUtil.coolTextFile(Paths.txt('mercenary/playedbefore')),new PlayState()));
							else
								LoadingState.loadAndSwitchState(new CutsceneState(CoolUtil.coolTextFile(Paths.txt('mercenary/pre')),new PlayState()));
						default:
							LoadingState.loadAndSwitchState(new PlayState());
					}
				}
			}
		}
		else
		{
			if(!ScoreUtils.botPlay){
				if(SONG.song.toLowerCase()=='father-time'){
					if(!FlxG.save.data.canGlitch){
						UnlockingItemState.unlocking.push('glitchdiff');
						FlxG.save.data.canGlitch=true;
					}
				}
			}
			var state:MusicBeatState = new FreeplayState();
			if(UnlockingItemState.unlocking.length>0){
				state = new UnlockingItemState();
			}
			if(doIntro && SONG.song.toLowerCase()=='father-time'){
				AchievementState.checkUnlocks();
				if(SkinState.selectedSkin=='bfside'){
					LoadingState.loadAndSwitchState(new CutsceneState(CoolUtil.coolTextFile(Paths.txt('father-time/fatherPOUNDED')),new VideoState('assets/videos/DO NOT DELETE OR GAME WILL CRASH/YouFoundSomethingYouShouldntHave.webm', state)));
				}else{
					LoadingState.loadAndSwitchState(new CutsceneState(CoolUtil.coolTextFile(Paths.txt('father-time/fatherPOUNDED')),state));
				}
			}else{
				AchievementState.checkUnlocks();
				trace('WENT BACK TO FREEPLAY??');
				FlxG.switchState(state);
			}
		}

	}

	var endingSong:Bool = false;

	private function popUpScore(noteDiff:Float,?gold=false):Void
	{
		var daRating = ScoreUtils.DetermineRating(noteDiff);
		if(daRating!='sick'){
			if(ItemState.equipped.contains("flippy")){
				switch(daRating){
					case 'bad' | 'shit':
						beenSavedByResistance = true;
						health = -2;
					case 'good':
						health -= .5;
					case 'epic':
						health += .1;
				}
			}
		}

		totalNotes++;
		// boyfriend.playAnim('hey');
		vocals.volume = 1;

		var placement:String = Std.string(combo);

		var coolText:FlxText = new FlxText(0, 0, 0, placement, 32);
		coolText.screenCenter();
		coolText.x = FlxG.width * 0.55;
		if(curStage=='time-void'){
			coolText.x += 600;
			coolText.y -= 100;
		}
		//

		var rating:FlxSprite = new FlxSprite();
		var score:Int = gold?0:ScoreUtils.RatingToScore(daRating);

		switch(daRating){
			case 'shit':
				shits++;
			case 'bad':
				bads++;
			case 'good':
				goods++;
			case 'epic':
				epics++;
			case 'sick':
				sicks++;
		}

		hitNotes += ScoreUtils.RatingToHit(daRating);
		songScore += score;

		var pixelShitPart1:String = "";
		var pixelShitPart2:String = '';

		if (curStage.startsWith('school'))
		{
			pixelShitPart1 = 'weeb/pixelUI/';
			pixelShitPart2 = '-pixel';
		}

		rating.loadGraphic(Paths.image(pixelShitPart1 + daRating + pixelShitPart2));
		rating.screenCenter();
		rating.x = coolText.x - 40;
		rating.y -= 60;
		rating.acceleration.y = 550;
		rating.velocity.y -= FlxG.random.int(140, 175);
		rating.velocity.x -= FlxG.random.int(0, 10);

		var comboSpr:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'combo' + pixelShitPart2));
		comboSpr.screenCenter();
		comboSpr.x = coolText.x;
		comboSpr.acceleration.y = 600;
		comboSpr.velocity.y -= 150;
		comboSpr.velocity.x += FlxG.random.int(1, 10);
		add(rating);

		if (!curStage.startsWith('school'))
		{
			rating.setGraphicSize(Std.int(rating.width * 0.7));
			rating.antialiasing = true;
			comboSpr.setGraphicSize(Std.int(comboSpr.width * 0.7));
			comboSpr.antialiasing = true;
		}
		else
		{
			rating.setGraphicSize(Std.int(rating.width * 6 * 0.7));
			comboSpr.setGraphicSize(Std.int(comboSpr.width * 6 * 0.7));
		}

		comboSpr.updateHitbox();
		rating.updateHitbox();
		if(currentOptions.ratingInHUD){
			comboSpr.cameras = [camHUD];
			rating.cameras = [camHUD];
			coolText.cameras = [camHUD];

			coolText.scrollFactor.set(0,0);
			rating.scrollFactor.set(0,0);
			comboSpr.scrollFactor.set(0,0);

			rating.x -= 175;
			coolText.x -= 175;
			comboSpr.x -= 175;
		}
		var seperatedScore:Array<String> = Std.string(combo).split("");
		var displayedMS = truncateFloat(noteDiff,2);
		var seperatedMS:Array<String> = Std.string(displayedMS).split("");
		var daLoop:Float = 0;
		for (i in seperatedScore)
		{
			var numScore:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'num' + Std.parseInt(i) + pixelShitPart2));
			numScore.screenCenter();
			numScore.x = coolText.x + (43 * daLoop) - 90;
			numScore.y += 80;

			if (!curStage.startsWith('school'))
			{
				numScore.antialiasing = true;
				numScore.setGraphicSize(Std.int(numScore.width * 0.5));
			}
			else
			{
				numScore.y += 50;
				numScore.setGraphicSize(Std.int(numScore.width * 6));
			}
			numScore.updateHitbox();

			numScore.acceleration.y = FlxG.random.int(200, 300);
			numScore.velocity.y -= FlxG.random.int(140, 160);
			numScore.velocity.x = FlxG.random.float(-5, 5);

			if(currentOptions.ratingInHUD){
				numScore.cameras = [camHUD];
				numScore.scrollFactor.set(0,0);
			}
			if (combo >= 10 || combo == 0)
				add(numScore);

			FlxTween.tween(numScore, {alpha: 0}, 0.2, {
				onComplete: function(tween:FlxTween)
				{
					numScore.destroy();
				},
				startDelay: Conductor.crochet * 0.002
			});

			daLoop++;
		}

		daLoop=0;
		if(currentOptions.showMS){
			for (i in seperatedMS)
			{
				if(i=="."){
					i = "point";
					daLoop-=.5;
				}

				var numScore:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'num' + i + pixelShitPart2));
				numScore.screenCenter();
				numScore.x = coolText.x + (32 * daLoop) - 25;
				numScore.y += 130;
				if(curStage.startsWith("school")){
					numScore.y += 50;
				}
				if(i=='point'){
					if(!curStage.startsWith("school")){
						numScore.x += 25;
					}else{
						numScore.y += 35;
						numScore.x += 24;
					}
				}

				switch(daRating){
					case 'epic':
						numScore.color = 0x75f0d9;
					case 'sick':
						numScore.color = 0xfcba03;
					case 'good':
						numScore.color = 0x14cc00;
					case 'bad':
						numScore.color = 0xa30a11;
					case 'shit':
						numScore.color = 0x5c2924;
				}
				if (!curStage.startsWith('school'))
				{
					numScore.antialiasing = true;
					numScore.setGraphicSize(Std.int((numScore.width * 0.5)*.75));
				}
				else
				{
					numScore.setGraphicSize(Std.int((numScore.width * 6)*.75));
				}
				numScore.updateHitbox();

				numScore.acceleration.y = FlxG.random.int(100, 150);
				numScore.velocity.y -= FlxG.random.int(50, 75);
				numScore.velocity.x = FlxG.random.float(-2.5, 2.5);

				if(currentOptions.ratingInHUD){
					numScore.cameras = [camHUD];
					numScore.scrollFactor.set(0,0);
				}

				add(numScore);

				FlxTween.tween(numScore, {alpha: 0}, 0.2, {
					onComplete: function(tween:FlxTween)
					{
						numScore.destroy();
					},
					startDelay: Conductor.crochet * 0.0005
				});

				daLoop++;
			}
		}
		/*
			trace(combo);
			trace(seperatedScore);
		 */

		coolText.text = Std.string(seperatedScore);
		// add(coolText);

		FlxTween.tween(rating, {alpha: 0}, 0.2, {
			startDelay: Conductor.crochet * 0.001
		});

		FlxTween.tween(comboSpr, {alpha: 0}, 0.2, {
			onComplete: function(tween:FlxTween)
			{
				coolText.destroy();
				comboSpr.destroy();

				rating.destroy();
			},
			startDelay: Conductor.crochet * 0.001
		});


		updateAccuracy();
		curSection += 1;
	}


	private function keyShit():Void
	{
		// HOLDING
		var up = controls.UP;
		var right = controls.RIGHT;
		var down = controls.DOWN;
		var left = controls.LEFT;

		var upP = controls.UP_P;
		var rightP = controls.RIGHT_P;
		var downP = controls.DOWN_P;
		var leftP = controls.LEFT_P;

		var holdArray:Array<Bool> = [left,down,up,right];
		var controlArray:Array<Bool> = [leftP, downP, upP, rightP];

		if(keyAmount==6){
			var right2 = controls.RIGHT2;
			var left2 = controls.LEFT2;
			var right2P = controls.RIGHT2_P;
			var left2P = controls.LEFT2_P;

			holdArray = [left,down,right,left2,up,right2];
			controlArray  = [leftP,downP,rightP,left2P,upP,right2P];
		}

		if(ScoreUtils.botPlay){
			for(i in 0...keyAmount){
				holdArray[i]=false;
				controlArray[i]=false;
			}

			for(note in hittableNotes){
				if(!note.canMiss || note.noteType==3){
					if(note.mustPress && note.canBeHit && note.strumTime<=Conductor.songPosition){
						if(note.sustainLength>0 && botplayHoldMaxTimes[note.noteData]<note.sustainLength){
							controlArray[note.noteData]=true;
							botplayHoldTimes[note.noteData] = (note.sustainLength/1000);
						}else if(note.isSustainNote && botplayHoldMaxTimes[note.noteData]==0){
							holdArray[note.noteData] = true;
						}
						if(!note.isSustainNote){
							controlArray[note.noteData]=true;
							if(botplayHoldTimes[note.noteData]<=.05){
								botplayHoldTimes[note.noteData] = .05;
							}
						}
					}
				}
			}
			for(idx in 0...botplayHoldTimes.length){
				if(botplayHoldTimes[idx]>0){
					holdArray[idx]=true;
					botplayHoldTimes[idx]-=FlxG.elapsed;
				}
			}
		}

		if(disabledTime>0){
			for(i in 0...holdArray.length){
				holdArray[i]=false;
			}
			for(i in 0...controlArray.length){
				controlArray[i]=false;
			}
		}

		if(holdArray.contains(true) && generatedMusic ){
			var hitting=[];
			var beenHit=[];
			for(daNote in hittableNotes){
				if(daNote.isSustainNote && daNote.canBeHit && daNote.mustPress && holdArray[daNote.noteData] && !beenHit.contains(daNote.noteData)){
					noteHit(daNote);
				}
			};

		};

		if (controlArray.contains(true) && generatedMusic)
			{
				var possibleNotes:Array<Note> = [];
				var ignoreList = [];
				var what = [];
				var checkDirAgain=[false,false,false,false,false,false];
				for(daNote in hittableNotes){
					if(daNote.canBeHit && daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit && !daNote.isSustainNote){
						if(ignoreList.contains(daNote.noteData)){
							if(!checkDirAgain[daNote.noteData]){
								checkDirAgain[daNote.noteData]=true; // idk hopin 2 make fogu not lag every time she hits a key lmao
								for(note in possibleNotes){
									if(note.noteData==daNote.noteData && Math.abs(daNote.strumTime-note.strumTime)<10){
										what.push(daNote);
									}else if(note.noteData==daNote.noteData && daNote.strumTime<note.strumTime){
										possibleNotes.remove(note);
										possibleNotes.push(daNote);
										break;
									}
								}
							}
						}else{
							possibleNotes.push(daNote);
							ignoreList.push(daNote.noteData);
						};
					};
				};

				for(daNote in what){
					daNote.kill();
					renderedNotes.remove(daNote,true);
					hittableNotes.remove(daNote);
					daNote.destroy();
				};

				possibleNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));

				if(perfectMode){
					noteHit(possibleNotes[0]);
				}else if(possibleNotes.length>0){
					for (idx in 0...controlArray.length){
						var pressed = controlArray[idx];
						if(pressed && ignoreList.contains(idx)==false && currentOptions.ghosttapping==false )
							badNoteCheck();
					}
					for (daNote in possibleNotes){
						if(controlArray[daNote.noteData])
							noteHit(daNote);
					};
				}else{
					if(currentOptions.ghosttapping==false){
						badNoteCheck();
					}
				};
			}

			var bfVar:Float=4;
			if(boyfriend.curCharacter=='dad')
				bfVar=6.1;
			else if(boyfriend.curCharacter == 'parasite' || boyfriend.curCharacter == 'vase')
				bfVar=10;

			if (boyfriend.holdTimer > Conductor.stepCrochet * bfVar * 0.001 && !holdArray.contains(true))
			{
				if (boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss'))
				{
					boyfriend.dance();
				}
			}


			if (omega.holdTimer >= Conductor.stepCrochet * bfVar * 0.001 && !holdArray.contains(true))
			{
				if (omega.animation.curAnim.name.startsWith('sing') && !omega.animation.curAnim.name.endsWith('miss'))
				{
					omega.dance();
				}
			}


			playerStrums.forEach(function(spr:FlxSprite)
			{
				if(spr.animation.curAnim.name!='confirm' && SONG.song.toLowerCase().startsWith('last-stand')){
					spr.visible=false;
					grayscalePlayerStrums.members[spr.ID].visible=false;
				}else if(spr.animation.curAnim.name=='confirm' && SONG.song.toLowerCase().startsWith('last-stand')){
					spr.visible=true;
					grayscalePlayerStrums.members[spr.ID].visible=true;
				}
				if(controlArray[spr.ID] && spr.animation.curAnim.name!="confirm"){
					spr.animation.play("pressed");
					grayscalePlayerStrums.members[spr.ID].animation.play("pressed");
				}

				if(!holdArray[spr.ID]){
					spr.animation.play("static");
					grayscalePlayerStrums.members[spr.ID].animation.play("static");
				}
				if (spr.animation.curAnim.name == 'confirm' && !curStage.startsWith('school'))
				{
					spr.centerOffsets();
					spr.offset.x -= 13*(1/modchart.playerNoteScale);
					spr.offset.y -= 13*(1/modchart.playerNoteScale);
				}
				else
					spr.centerOffsets();

					grayscalePlayerStrums.members[spr.ID].x = spr.x;
					grayscalePlayerStrums.members[spr.ID].y = spr.y;
					grayscalePlayerStrums.members[spr.ID].angle = spr.angle;
					grayscalePlayerStrums.members[spr.ID].offset.set(spr.offset.x,spr.offset.y);
			});

	}


	function noteMiss(direction:Int = 1,?note:Note):Void
	{
		if(note!=null) direction=note.noteData;

		if(ItemState.equipped.contains("flippy")){
			beenSavedByResistance=true;
			health=-100;
		}
		boyfriend.holding=false;
		misses++;
		var missDmg = 0.04;

		switch(SONG.song.toLowerCase()){
			case 'curse-eternal':
				if(!ItemState.equipped.contains("depressed"))
					missDmg = 0;
			case 'dishonor':
				missDmg = .2;
			case 'father-time':
				missDmg = .1;
			default:
				missDmg = 0.04;
		}

		if(ItemState.equipped.contains("depressed") && fuckedUpReceptors<=0){
			missDmg = missDmg-(missDmg*.5); // 50% less for cold heart
		}

		if(fuckedUpReceptors>0)
			missDmg*=1.5;

		health -= missDmg;

		previousHealth=health;
		if (combo > 5 && gf.animOffsets.exists('sad'))
		{
			gf.playAnim('sad');
		}
		combo = 0;

		songScore -= 10;

		FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.3, 0.6));

		var anim = singAnims[direction] + "miss";
		if(note!=null){
			note.whoSingsShit = note.whoSingsShit==null?"0":note.whoSingsShit;
			if(note.whoSingsShit=='0' || note.whoSingsShit == '2')
				boyfriend.playAnim(anim,true);

			if(note.whoSingsShit=='1' || note.whoSingsShit == '2')
				omega.playAnim(anim,true);
		}else{
			boyfriend.playAnim(anim);
		}


		updateAccuracy();

	}

	function badNoteCheck()
	{
		// just double pasting this shit cuz fuk u
		// REDO THIS SYSTEM!
		var upP = controls.UP_P;
		var rightP = controls.RIGHT_P;
		var downP = controls.DOWN_P;
		var leftP = controls.LEFT_P;

		if (leftP)
			noteMiss(0);
		if (downP)
			noteMiss(1);
		if (upP)
			noteMiss(2);
		if (rightP)
			noteMiss(3);
	}

	function noteCheck(keyP:Bool, note:Note):Void
	{
		if (keyP)
			goodNoteHit(note);
		else
		{
			//badNoteCheck();
		}
	}

	function noteHit(note:Note):Void
	{
		if (!note.wasGoodHit){
			switch(note.noteType){
				case 0:
					goodNoteHit(note);
				case 1:
					swordNoteHit(note);
				case 2:
					glitchNoteHit(note);
				case 5:
					torchNoteHit(note);
				default:
					goodNoteHit(note);
			}
			note.wasGoodHit=true;
			playerStrums.forEach(function(spr:FlxSprite)
			{
				if (Math.abs(note.noteData) == spr.ID)
				{
					spr.animation.play('confirm', true);
					grayscalePlayerStrums.members[spr.ID].animation.play("confirm",true);
				}
			});
			if (!note.isSustainNote)
			{
				note.kill();
				hittableNotes.remove(note);
				renderedNotes.remove(note, true);
				note.destroy();
			}
		}

	}

	function swordNoteHit(note:Note):Void
		{

			if (!note.wasGoodHit)
			{
				if (!note.isSustainNote)
				{
					combo=0;

					if(combo>highestCombo)
						highestCombo=combo;

					highComboTxt.text = "Highest Combo: " + highestCombo;
				}

				if(ItemState.equipped.contains("flippy")){
					beenSavedByResistance=true;
					health=-100;
				}

				if(SONG.player2 == 'angry-omega'){
					var damage = FlxMath.lerp(0,1.35,health/2);

					if(damage<.5)
						damage=.5;

					if(ItemState.equipped.contains("arrow"))
						damage-=damage*.5;

					health-=damage;
				}else if(SONG.song.toLowerCase()=='curse-eternal'){
					if(ItemState.equipped.contains("depressed"))
						health = -100;
					else
						health-=.05;
				}else{
					if(ItemState.equipped.contains("arrow"))
						health-=.25;
					else
						health-=.5;

				}
				FlxG.sound.play(Paths.sound('slash'), FlxG.random.float(0.4, 0.6));
				slash.visible = true;
				slash.animation.play("slash",true);
				songScore -= 100;
				boyfriend.playAnim('cut', true);
				misses++;

				note.wasGoodHit = true;
				vocals.volume = 0;

				updateAccuracy();
				missesTxt.text = "Miss: " + misses;
			}
		}

		function glitchNoteHit(note:Note):Void
		{

			if (!note.wasGoodHit)
			{
				if (!note.isSustainNote)
				{
					combo=0;

					if(combo>highestCombo)
						highestCombo=combo;

					highComboTxt.text = "Highest Combo: " + highestCombo;
				}

				if(ItemState.equipped.contains("flippy")){
					beenSavedByResistance=true;
					health=-100;
				}

				/*
				var bullshit = FlxG.random.weightedPick([5,25,5,5,3,7]);
				// 5% chance for sword note effect
				// 25% chance to disable your receptors for 3 to 5 seconds
				// 5% chance to do torch note effect
				// 5% chance to set your HP to a random number between .1 and double your current HP, capping at 2 HP
				// 3% chance to just.. kill you.
				// 7% chance to hide your receptors for 3 to 5 seconds


				if(bullshit==0){
					health-=.5;
					FlxG.sound.play(Paths.sound('slash'), FlxG.random.float(0.4, 0.6));
					slash.visible = true;
					slash.animation.play("slash",true);
					songScore -= 100;
					boyfriend.playAnim('cut', true);
					misses++;
					vocals.volume = 0;
				}else if(bullshit==1){
					disabledTime = FlxG.random.float(3,5);
				}else if(bullshit==2){
					if(burnTimer<=0)
						burnTimer=2;
					else
						burnTimer+=.25;

					misses++;
					FlxG.sound.play(Paths.sound('TorchSFX'), 1);
					vocals.volume = 0;
				}else if(bullshit==3){
					var newHP = FlxG.random.float(0.1,health*2);
					if(newHP>2)newHP=2;
					health=newHP;
				}else if(bullshit==4){
					if(ItemState.equipped.contains("depressed"))
						health-=1;
					else
						health-=2;
				}else if(bullshit==4){

				}*/
				// IF SOMEONE WANTS TO DO THAT ^ THAT'S FINE BY ME
				// ECHO DIDNT WANT RANDOM EFFECTS APPARENTLY
				// HE FUCKING SUCKS >:(

				// NEW IDEA:
				// FUCKS UP YOUR RECEPTORS
				// DOES DAMAGE TOO
				// HE DID NOT LIKE THAT EITHER

				// COMMUNITY DID THOUGH!!!! FUCK YOU ECHO
				// GLITCH NOTE OVERHAUL TIME

				FlxG.sound.play(Paths.sound('hitGlitch'),1);

				misses++;

				disabledTime = 1.5;

				if(ItemState.equipped.contains("depressed")){
					health -= .125;
					fuckedUpReceptors += 3;
				}else{
					health -= .25;
					fuckedUpReceptors += 5;
				}



				FlxG.random.shuffle(noteOrder);
				note.wasGoodHit = true;

				updateAccuracy();
				missesTxt.text = "Miss: " + misses;
			}
		}

	function torchNoteHit(note:Note):Void
		{

			if (!note.wasGoodHit)
			{
				if (!note.isSustainNote)
				{
					combo=0;

					if(combo>highestCombo)
						highestCombo=combo;

					highComboTxt.text = "Highest Combo: " + highestCombo;
				}
				if(SONG.song.toLowerCase()=='salem'){
					if(burnTimer<=0)
						burnTimer=1;
					else
						burnTimer+=.5;
				}else{
					if(burnTimer<=0)
						burnTimer=2;
					else
						burnTimer+=.25;
				}

				FlxG.sound.play(Paths.sound('TorchSFX'), 1);

				misses++;

				note.wasGoodHit = true;
				vocals.volume = 0;

				updateAccuracy();
				missesTxt.text = "Miss: " + misses;
			}
		}

	function goodNoteHit(note:Note):Void
	{
		if (!note.isSustainNote)
		{
			combo++;
			var noteDiff:Float = Math.abs(Conductor.songPosition - note.strumTime);
			popUpScore(noteDiff);
			if(combo>highestCombo)
				highestCombo=combo;

			highComboTxt.text = "Highest Combo: " + highestCombo;
		}else{
			hitNotes++;
			totalNotes++;
		}

		if(currentOptions.hitSound && !note.isSustainNote)
			FlxG.sound.play(Paths.sound('Normal_Hit'),1);

		if(note.noteType==3){ // STOLE MY OWN CODE https://github.com/Echolocated/VSFlexy/blob/main/source/PlayState.hx
			FlxG.sound.play(Paths.sound('Gold_Note_Hit'), 0.7);
			goldOverlay.alpha = 1;
			if(goldOverlayTween!=null)
				goldOverlayTween.cancel();
			health += .25;
			goldOverlayTween = FlxTween.tween(goldOverlay, {alpha: 0}, .25);
		}


		if(modchart.healthGain){
			if(!note.isSustainNote || modchart.susHeal && note.isSustainNote ){
				if (note.noteType ==6)
					if(ItemState.equipped.contains("sword"))
						health += modchart.gemHPGain+(modchart.gemHPGain*.5);
					else
						health += modchart.gemHPGain;
				else if(note.noteType==7)
					health = .01;
				else{
					if(ItemState.equipped.contains("sword"))
						health += modchart.noteHPGain+(modchart.noteHPGain*.5);
					else
						health += modchart.noteHPGain;
					}
			}
		}

		previousHealth=health;

		//if(!note.isSustainNote){
		var anim = singAnims[note.noteData];

		if(note.whoSingsShit=='0' || note.whoSingsShit=='2'){
			var canHold = note.isSustainNote && boyfriend.animation.getByName(anim+"Hold")!=null;
			if(canHold && !boyfriend.animation.curAnim.name.startsWith(anim)){
				boyfriend.playAnim(anim,true);
			}else if(currentOptions.pauseHoldAnims && !canHold){
				boyfriend.playAnim(anim,true);
				if(note.holdParent ){
					boyfriend.holding=true;
				}else{
					boyfriend.holding=false;
				}
			}else if(!currentOptions.pauseHoldAnims && !canHold){
				boyfriend.playAnim(anim,true);
			}
			boyfriend.holdTimer=0;
		}

		if(note.whoSingsShit=='1' || note.whoSingsShit=='2'){
			var canHold = note.isSustainNote && omega.animation.getByName(anim+"Hold")!=null;
			if(canHold && !omega.animation.curAnim.name.startsWith(anim)){
				omega.playAnim(anim,true);
			}else if(currentOptions.pauseHoldAnims && !canHold){
				omega.playAnim(anim,true);
				if(note.holdParent ){
					omega.holding=true;
				}else{
					omega.holding=false;
				}
			}else if(!currentOptions.pauseHoldAnims && !canHold){
				omega.playAnim(anim,true);
			}
			omega.holdTimer=0;
		}

		//}
		vocals.volume = 1;
		updateAccuracy();

	}


	var trainMoving:Bool = false;
	var trainFrameTiming:Float = 0;

	var trainCars:Int = 8;
	var trainFinishing:Bool = false;
	var trainCooldown:Int = 0;

	function trainStart():Void
	{
		trainMoving = true;
		trainSound.play(true,0);
	}

	var startedMoving:Bool = false;

	function updateTrainPos():Void
	{
		if (trainSound.time >= 4700)
		{
			startedMoving = true;
			gf.playAnim('hairBlow');
		}

		if (startedMoving)
		{
			if(currentOptions.picoCamshake)
				camGame.shake(.0025,.1,null,true,X);

			phillyTrain.x -= 400;

			if (phillyTrain.x < -2000 && !trainFinishing)
			{
				phillyTrain.x = -1150;
				trainCars -= 1;

				if (trainCars <= 0)
					trainFinishing = true;
			}

			if (phillyTrain.x < -4000 && trainFinishing)
				trainReset();
		}
	}

	function trainReset():Void
	{
		gf.playAnim('hairFall');
		phillyTrain.x = FlxG.width + 200;
		trainMoving = false;
		// trainSound.stop();
		// trainSound.time = 0;
		trainCars = 8;
		trainFinishing = false;
		startedMoving = false;
	}

	function lightningStrikeShit():Void
	{
	}

	override function stepHit()
	{
		super.stepHit();
		if (FlxG.sound.music.time-currentOptions.noteOffset > Conductor.songPosition-currentOptions.noteOffset + 20 || FlxG.sound.music.time-currentOptions.noteOffset < Conductor.songPosition-currentOptions.noteOffset - 20)
		{
			if(FlxG.sound.music.volume>0 && vocals.volume>0)
				resyncVocals();
		}

		switch(SONG.song.toLowerCase() ){
			case 'free-soul':
				if(curStep==672 || curStep==736)
					vietnamFlashbacks=!vietnamFlashbacks;
			case 'dishonor':
				if(curStep==2048 || curStep==1024){
					isGrayscale=true;
					modchart.opponentHPDrain=.0175;
					modchart.noteHPGain = .018;
				}else if(curStep==1280){
					isGrayscale=false;
					modchart.noteHPGain = .0075;
					modchart.susHeal=false;
					modchart.opponentHPDrain=0;
				}
			case 'curse-eternal':
				if(dad.curCharacter=='angry-fucking-child'){
					switch(curStep){
						case 1447 | 1476 | 1482 | 1490 | 1492 | 1498 | 1501 | 1510 | 1512 | 1526 | 1535 | 1545 | 1549 | 1550:
							dad.playAnim("cry");
							//nebula.playAnim("cry");
					}
				}
			case 'prelude':
				if(dad.curCharacter=='gf'){
					switch (curStep){
						case 240 | 751:
							dad.playAnim("cheer",true);
					}
				}
		}



	}

	var lightningStrikeBeat:Int = 0;
	var lightningOffset:Int = 8;

	override function beatHit()
	{
		super.beatHit();

		if (SONG.notes[Math.floor(curStep / 16)] != null)
		{
			if (SONG.notes[Math.floor(curStep / 16)].changeBPM)
			{
				Conductor.changeBPM(SONG.notes[Math.floor(curStep / 16)].bpm);
				FlxG.log.add('CHANGED BPM!');
			}
			// else
			// Conductor.changeBPM(SONG.bpm);

			// Dad doesnt interupt his own notes
			if (!dad.animation.curAnim.name.startsWith("sing")){
				if(dad.curCharacter=='noke')
					NokeReconnect();

				dad.dance();
			}

			if (!armyRight.animation.curAnim.name.startsWith("sing"))
			{
				armyRight.dance();
			}

			if (!mika.animation.curAnim.name.startsWith("sing"))
			{
				mika.dance();
			}
		}

		// FlxG.log.add('change bpm' + SONG.notes[Std.int(curStep / 16)].changeBPM);

		// HARDCODING FOR MILF ZOOMS!
		if (curSong.toLowerCase() == 'milf' && curBeat >= 168 && curBeat < 200 && camZooming && FlxG.camera.zoom < 1.35)
		{
			FlxG.camera.zoom += 0.015;
			camHUD.zoom += 0.03;
		}

		if (camZooming && FlxG.camera.zoom < 1.35 && curBeat % 4 == 0)
		{
			FlxG.camera.zoom += 0.015;
			camHUD.zoom += 0.03;
		}

		iconP1.setGraphicSize(Std.int(iconP1.width + 30));
		iconP2.setGraphicSize(Std.int(iconP2.width + 30));

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		if (curBeat % gfSpeed == 0)
		{
			gf.dance();
		}

		if (!boyfriend.animation.curAnim.name.startsWith("sing"))
		{
			boyfriend.dance();
		}

		if (!omega.animation.curAnim.name.startsWith("sing"))
		{
			omega.dance();
		}


		if (curBeat % 8 == 7 && curSong == 'Bopeebo')
		{
			boyfriend.playAnim('hey', true);
		}

		if (curBeat % 16 == 15 && SONG.song == 'Tutorial' && dad.curCharacter == 'gf' && curBeat > 16 && curBeat < 48)
		{
			boyfriend.playAnim('hey', true);
			dad.playAnim('cheer', true);
		}


		switch (curStage)
		{

			case 'mall':
				frontBoppers.animation.play("bop",true);
				backBoppers.animation.play("bop",true);
			case 'dojo':
				if(curBeat%2==0){
					anders.animation.play("idle",true);
					racistgfwtf.animation.play("idle",true);
					carol.animation.play("idle",true);
					kfc.animation.play("idle",true);
				}
			case 'drugmart':
				daKing.animation.play("idle",true);
				tabi.animation.play("idle",true);
				myBeloved.animation.play("idle",true);
				garlo.animation.play("idle",true);
			case 'castle':
				if(curBeat%2==0)
					queen.animation.play("idle",true);

			case "philly":
				if (!trainMoving)
					trainCooldown += 1;


				if (curBeat % 8 == 4 && FlxG.random.bool(30) && !trainMoving && trainCooldown > 8)
				{
					trainCooldown = FlxG.random.int(-4, 0);
					trainStart();
				}
		}
	}

	function unloadAssets():Void
	{

	}
	override function destroy(){
		return super.destroy();
	}
	var curLight:Int = 0;
}
