package;

#if desktop
import Discord.DiscordClient;
#end
import Options;
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
import LuaClass;
import flash.display.BitmapData;
import flash.display.Bitmap;
import Shaders;
import haxe.Exception;
import openfl.utils.Assets;
import ModChart;
#if windows
import vm.lua.LuaVM;
import vm.lua.Exception;
import Sys;
import sys.FileSystem;
import llua.Convert;
import llua.Lua;
import llua.State;
import llua.LuaL;
#end

using StringTools;

class PlayState extends MusicBeatState
{
	public static var currentPState:PlayState;

	public static var curStage:String = '';
	public static var SONG:SwagSong;
	public static var isStoryMode:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 1;
	public var dontSync:Bool=false;

	var halloweenLevel:Bool = false;

	private var vocals:FlxSound;

	private var dad:Character;
	private var gf:Character;
	private var boyfriend:Boyfriend;
	private var omega:Boyfriend;
	private var armyRight:Character;
	private var mika:RunningChild;

	private var renderedNotes:FlxTypedGroup<Note>;
	private var opponentRenderedNotes:FlxTypedGroup<Note>;
	private var playerRenderedNotes:FlxTypedGroup<Note>;
	private var hittableNotes:Array<Note> = [];
	private var unspawnNotes:Array<Note> = [];

	private var strumLine:FlxSprite;
	private var curSection:Int = 0;

	private var camFollow:FlxObject;
	public var currentOptions:Options;

	private static var prevCamFollow:FlxObject;
	private var lastHitDadNote:Note;
	private var strumLineNotes:FlxTypedGroup<FlxSprite>;
	private var playerStrums:FlxTypedGroup<FlxSprite>;
	private var dadStrums:FlxTypedGroup<FlxSprite>;
	private var playerStrumLines:FlxTypedGroup<FlxSprite>;
	public var refNotes:FlxTypedGroup<FlxSprite>;
	public var opponentRefNotes:FlxTypedGroup<FlxSprite>;
	private var opponentStrumLines:FlxTypedGroup<FlxSprite>;
	public var luaSprites:Map<String, Dynamic>;
	public var luaObjects:Map<String, Dynamic>;
	public var unnamedLuaSprites:Int=0;
	public var unnamedLuaObjects:Int=0;
	public var dadLua:LuaCharacter;
	public var gfLua:LuaCharacter;
	public var bfLua:LuaCharacter;

	public static var mikaShit:Array<MikaRunAnimMarker> = [];

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
	private var pauseHUD:FlxCamera;
	private var camGame:FlxCamera;
	public var modchart:ModChart;

	public var playerNoteOffsets:Array<Array<Float>> = [
		[0,0], // left
		[0,0], // down
		[0,0], // up
		[0,0]// right
	];

	public var opponentNoteOffsets:Array<Array<Float>> = [
		[0,0], // left
		[0,0], // down
		[0,0], // up
		[0,0] // right
	];

	public var playerNoteAlpha:Array<Float>=[
		1,
		1,
		1,
		1
	];

	public var opponentNoteAlpha:Array<Float>=[
		1,
		1,
		1,
		1
	];
	var lua:LuaVM;

	var dialogue:Array<String> = ['blah blah blah', 'coolswag'];
	var disabledHud=false;

	var halloweenBG:FlxSprite;
	var nokeTxt:FlxText;
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
	var discharging:Bool = false;
	var dischargeHP:Float = 1;

	var phillyCityLights:FlxTypedGroup<FlxSprite>;
	var lightFadeShader:BuildingEffect;
	var vcrDistortionHUD:VCRDistortionEffect;
	var rainShader:RainEffect;
	var vcrDistortionGame:VCRDistortionEffect;
	var phillyTrain:FlxSprite;
	var trainSound:FlxSound;
	var goldOverlay:FlxSprite;
	var goldOverlayTween:FlxTween;
	var limo:FlxSprite;
	var grpLimoDancers:FlxTypedGroup<BackgroundDancer>;
	var fastCar:FlxSprite;

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
	var luaModchartExists = false;

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
		Cache.Clear();
		modchart = new ModChart(this);
		FlxG.sound.music.looped=false;
		unnamedLuaSprites=0;
		unnamedLuaObjects=0;
		currentPState=this;
		currentOptions = OptionUtils.options.clone();
		ScoreUtils.ratingWindows = OptionUtils.ratingWindowTypes[currentOptions.ratingWindow];
		ScoreUtils.ghostTapping = currentOptions.ghosttapping;
		Conductor.safeZoneOffset = ScoreUtils.ratingWindows[3]; // same as shit ms
		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		//lua = new LuaVM();
		#if windows
			luaModchartExists = FileSystem.exists(Paths.modchart(SONG.song.toLowerCase()));
		#end



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

		if(SONG.song.toLowerCase()=='2v200' || SONG.song.toLowerCase()=='hivemind')
			currentOptions.middleScroll=true;

		if(SONG.song.toLowerCase()=='hivemind'){
			currentOptions.downScroll=true;
			modchart.hudVisible=false;
			modchart.hideBF=true;
			modchart.hideGF=true;
			modchart.playerNoteScale=1.3;
			modchart.opponentNoteScale=.7;
		}
		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);
		if(SONG.song.toLowerCase()=='guardian'){
			for (i in 0...SONG.notes.length){
				if(SONG.notes[i].altAnim){
					var notes = SONG.notes[i].sectionNotes;
					var startStrum = -1;
					var endStrum = 0;

					for(note in notes){
						var hit = SONG.notes[i].mustHitSection;
						if(note[1]>3){
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

		switch (SONG.song.toLowerCase())
		{
                        case 'spookeez' | 'monster' | 'south' | 'salem':
                        {
                                curStage = 'spooky';
	                          halloweenLevel = true;

		                  var hallowTex = Paths.getSparrowAtlas('halloween_bg');

	                          halloweenBG = new FlxSprite(-200, -100);
		                  halloweenBG.frames = hallowTex;
	                          halloweenBG.animation.addByPrefix('idle', 'halloweem bg0');
	                          halloweenBG.animation.addByPrefix('lightning', 'halloweem bg lightning strike', 24, false);
	                          halloweenBG.animation.play('idle');
	                          halloweenBG.antialiasing = true;
	                          add(halloweenBG);

		                  isHalloween = true;
		          }
		          case 'pico' | 'blammed' | 'philly-nice':
                        {
		                  curStage = 'philly';


		                  var bg:FlxSprite = new FlxSprite(-100).loadGraphic(Paths.image('philly/sky'));
		                  bg.scrollFactor.set(0.1, 0.1);
		                  add(bg);

	                          var city:FlxSprite = new FlxSprite(-10).loadGraphic(Paths.image('philly/city'));
		                  city.scrollFactor.set(0.3, 0.3);
		                  city.setGraphicSize(Std.int(city.width * 0.85));
		                  city.updateHitbox();
		                  add(city);
											if(currentOptions.picoShaders){
												try{
													//rainShader = new RainEffect();
													lightFadeShader = new BuildingEffect();
												}catch(e:Any){
													trace("no shaders!");
												}
											}
											//modchart.addCamEffect(rainShader);

		                  phillyCityLights = new FlxTypedGroup<FlxSprite>();
		                  add(phillyCityLights);

		                  for (i in 0...5)
		                  {
		                          var light:FlxSprite = new FlxSprite(city.x).loadGraphic(Paths.image('philly/win' + i));
		                          light.scrollFactor.set(0.3, 0.3);
		                          light.visible = false;
		                          light.setGraphicSize(Std.int(light.width * 0.85));
		                          light.updateHitbox();
		                          light.antialiasing = true;
															if(currentOptions.picoShaders) light.shader=lightFadeShader.shader;
		                          phillyCityLights.add(light);
		                  }

		                  var streetBehind:FlxSprite = new FlxSprite(-40, 50).loadGraphic(Paths.image('philly/behindTrain'));
		                  add(streetBehind);

	                          phillyTrain = new FlxSprite(2000, 360).loadGraphic(Paths.image('philly/train'));
		                  add(phillyTrain);

		                  trainSound = new FlxSound().loadEmbedded(Paths.sound('train_passes'));
		                  FlxG.sound.list.add(trainSound);

		                  // var cityLights:FlxSprite = new FlxSprite().loadGraphic(AssetPaths.win0.png);

		                  var street:FlxSprite = new FlxSprite(-40, streetBehind.y).loadGraphic(Paths.image('philly/street'));
	                          add(street);
		          }
		          case 'milf' | 'satin-panties' | 'high':
		          {
		                  curStage = 'limo';
		                  defaultCamZoom = 0.90;

		                  var skyBG:FlxSprite = new FlxSprite(-120, -50).loadGraphic(Paths.image('limo/limoSunset'));
		                  skyBG.scrollFactor.set(0.1, 0.1);
		                  add(skyBG);

		                  var bgLimo:FlxSprite = new FlxSprite(-200, 480);
		                  bgLimo.frames = Paths.getSparrowAtlas('limo/bgLimo');
		                  bgLimo.animation.addByPrefix('drive', "background limo pink", 24);
		                  bgLimo.animation.play('drive');
		                  bgLimo.scrollFactor.set(0.4, 0.4);
		                  add(bgLimo);

		                  grpLimoDancers = new FlxTypedGroup<BackgroundDancer>();
		                  add(grpLimoDancers);

		                  for (i in 0...5)
		                  {
		                          var dancer:BackgroundDancer = new BackgroundDancer((370 * i) + 130, bgLimo.y - 400);
		                          dancer.scrollFactor.set(0.4, 0.4);
		                          grpLimoDancers.add(dancer);
		                  }

		                  var overlayShit:FlxSprite = new FlxSprite(-500, -600).loadGraphic(Paths.image('limo/limoOverlay'));
		                  overlayShit.alpha = 0.5;
		                  // add(overlayShit);

		                  // var shaderBullshit = new BlendModeEffect(new OverlayShader(), FlxColor.RED);

		                  // FlxG.camera.setFilters([new ShaderFilter(cast shaderBullshit.shader)]);

		                  // overlayShit.shader = shaderBullshit;

		                  var limoTex = Paths.getSparrowAtlas('limo/limoDrive');

		                  limo = new FlxSprite(-120, 550);
		                  limo.frames = limoTex;
		                  limo.animation.addByPrefix('drive', "Limo stage", 24);
		                  limo.animation.play('drive');
		                  limo.antialiasing = true;

		                  fastCar = new FlxSprite(-300, 160).loadGraphic(Paths.image('limo/fastCarLol'));
		                  // add(limo);
		          }
		          case 'cocoa' | 'eggnog':
		          {
	                          curStage = 'mall';

		                  defaultCamZoom = 0.80;

		                  var bg:FlxSprite = new FlxSprite(-1000, -500).loadGraphic(Paths.image('christmas/bgWalls'));
		                  bg.antialiasing = true;
		                  bg.scrollFactor.set(0.2, 0.2);
		                  bg.active = false;
		                  bg.setGraphicSize(Std.int(bg.width * 0.8));
		                  bg.updateHitbox();
		                  add(bg);

		                  upperBoppers = new FlxSprite(-240, -90);
		                  upperBoppers.frames = Paths.getSparrowAtlas('christmas/upperBop');
		                  upperBoppers.animation.addByPrefix('bop', "Upper Crowd Bob", 24, false);
		                  upperBoppers.antialiasing = true;
		                  upperBoppers.scrollFactor.set(0.33, 0.33);
		                  upperBoppers.setGraphicSize(Std.int(upperBoppers.width * 0.85));
		                  upperBoppers.updateHitbox();
		                  add(upperBoppers);

		                  var bgEscalator:FlxSprite = new FlxSprite(-1100, -600).loadGraphic(Paths.image('christmas/bgEscalator'));
		                  bgEscalator.antialiasing = true;
		                  bgEscalator.scrollFactor.set(0.3, 0.3);
		                  bgEscalator.active = false;
		                  bgEscalator.setGraphicSize(Std.int(bgEscalator.width * 0.9));
		                  bgEscalator.updateHitbox();
		                  add(bgEscalator);

		                  var tree:FlxSprite = new FlxSprite(370, -250).loadGraphic(Paths.image('christmas/christmasTree'));
		                  tree.antialiasing = true;
		                  tree.scrollFactor.set(0.40, 0.40);
		                  add(tree);

		                  bottomBoppers = new FlxSprite(-300, 140);
		                  bottomBoppers.frames = Paths.getSparrowAtlas('christmas/bottomBop');
		                  bottomBoppers.animation.addByPrefix('bop', 'Bottom Level Boppers', 24, false);
		                  bottomBoppers.antialiasing = true;
	                          bottomBoppers.scrollFactor.set(0.9, 0.9);
	                          bottomBoppers.setGraphicSize(Std.int(bottomBoppers.width * 1));
		                  bottomBoppers.updateHitbox();
		                  add(bottomBoppers);

		                  var fgSnow:FlxSprite = new FlxSprite(-600, 700).loadGraphic(Paths.image('christmas/fgSnow'));
		                  fgSnow.active = false;
		                  fgSnow.antialiasing = true;
		                  add(fgSnow);

		                  santa = new FlxSprite(-840, 150);
		                  santa.frames = Paths.getSparrowAtlas('christmas/santa');
		                  santa.animation.addByPrefix('idle', 'santa idle in fear', 24, false);
		                  santa.antialiasing = true;
		                  add(santa);
		          }
		          case 'winter-horrorland':
		          {
		                  curStage = 'mallEvil';
		                  var bg:FlxSprite = new FlxSprite(-400, -500).loadGraphic(Paths.image('christmas/evilBG'));
		                  bg.antialiasing = true;
		                  bg.scrollFactor.set(0.2, 0.2);
		                  bg.active = false;
		                  bg.setGraphicSize(Std.int(bg.width * 0.8));
		                  bg.updateHitbox();
		                  add(bg);

		                  var evilTree:FlxSprite = new FlxSprite(300, -300).loadGraphic(Paths.image('christmas/evilTree'));
		                  evilTree.antialiasing = true;
		                  evilTree.scrollFactor.set(0.2, 0.2);
		                  add(evilTree);

		                  var evilSnow:FlxSprite = new FlxSprite(-200, 700).loadGraphic(Paths.image("christmas/evilSnow"));
	                          evilSnow.antialiasing = true;
		                  add(evilSnow);
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

		                  /*var bg:FlxSprite = new FlxSprite(posX, posY);
		                  bg.frames = Paths.getSparrowAtlas('weeb/animatedEvilSchool');
		                  bg.animation.addByPrefix('idle', 'background 2', 24);
		                  bg.animation.play('idle');
		                  bg.scrollFactor.set(0.8, 0.9);
		                  bg.scale.set(6, 6);
		                  add(bg);*/


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

		                           wiggleShit.effectType = WiggleEffectType.DREAMY;
		                           wiggleShit.waveAmplitude = 0.01;
		                           wiggleShit.waveFrequency = 60;
		                           wiggleShit.waveSpeed = 0.8;


		                  // bg.shader = wiggleShit.shader;
		                  // fg.shader = wiggleShit.shader;

		                  /*
		                            var waveSprite = new FlxEffectSprite(bg, [waveEffectBG]);
		                            var waveSpriteFG = new FlxEffectSprite(fg, [waveEffectFG]);

		                            // Using scale since setGraphicSize() doesnt work???
		                            waveSprite.scale.set(6, 6);
		                            waveSpriteFG.scale.set(6, 6);
		                            waveSprite.setPosition(posX, posY);
		                            waveSpriteFG.setPosition(posX, posY);

		                            waveSprite.scrollFactor.set(0.7, 0.8);
		                            waveSpriteFG.scrollFactor.set(0.9, 0.8);

		                            // waveSprite.setGraphicSize(Std.int(waveSprite.width * 6));
		                            // waveSprite.updateHitbox();
		                            // waveSpriteFG.setGraphicSize(Std.int(fg.width * 6));
		                            // waveSpriteFG.updateHitbox();

		                            add(waveSprite);
		                            add(waveSpriteFG);
		                    */
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

								nokeTxt = new FlxText(0,0,0,"DISCONNECTED",78);
								nokeTxt.color = FlxColor.RED;
								nokeTxt.font = 'Pixel Arial 11 Bold';
								nokeTxt.visible=false;
						case 'mercenary'|'odd-job'|'guardian'|'2v200'|'after-the-ashes'|'curse-eternal'|'last-stand':
							defaultCamZoom = 0.75;
							curStage = 'omegafield';
							var suffix = '';
							if(SONG.song.toLowerCase()=='2v200' || SONG.song.toLowerCase()=='last-stand' || SONG.song.toLowerCase()=='curse-eternal'){
								suffix='-rain';
							}
							var bg:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('omega/biggerskymod' + suffix));
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

							var grass:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('omega/grass' + suffix));
							grass.setGraphicSize(Std.int(grass.width*2));
							grass.screenCenter(XY);
							grass.antialiasing = true;
							grass.scrollFactor.set(.9, .9);
							grass.active = false;
							add(grass);
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
		goldOverlay.cameras = [camHUD];
		add(goldOverlay);

		switch (curStage)
		{
			case 'limo':
				gfVersion = 'gf-car';
			case 'mall' | 'mallEvil':
				gfVersion = 'gf-christmas';
			case 'school':
				gfVersion = 'gf-pixel';
			case 'schoolEvil':
				gfVersion = 'gf-pixel';
		}

		if (curStage == 'limo')
			gfVersion = 'gf-car';

		if(SONG.player1=='bf-neb')
			gfVersion = 'lizzy';

		gf = new Character(400, 130, gfVersion);
		gf.scrollFactor.set(0.95, 0.95);

		dad = new Character(100, 100, SONG.player2);
		mika = new RunningChild();
		mika.y = 425;
		armyRight = new Character(100,100,"armyRight");
		if(SONG.song.toLowerCase()!='2v200' || dad.curCharacter!='army')
			armyRight.visible=false;

		var camPos:FlxPoint = new FlxPoint(dad.getGraphicMidpoint().x, dad.getGraphicMidpoint().y);

		switch (SONG.player2)
		{
			case 'gf':
				dad.setPosition(gf.x, gf.y);
				gf.visible = false;
				if (isStoryMode)
				{
					camPos.x += 600;
					tweenCamIn();
				}
			case 'kapi':
				dad.y += 175;
			case 'flexy':
				dad.y += 200;
			case 'merchant':
				dad.y += 225;
			case 'omega':
				dad.x -= 100;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
			case 'angry-omega':
				dad.x -= 250;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);

			case "spooky":
				dad.y += 150;
			case 'demetrios':
				dad.y -= 390;
				camPos.set(dad.getGraphicMidpoint().x, dad.getGraphicMidpoint().y-100);
			case "monster":
				dad.y += 100;
			case 'monster-christmas':
				dad.y += 130;
			case 'dad':
				camPos.x += 400;
			case 'pico':
				camPos.x += 600;
				dad.y += 300;
			case 'parents-christmas':
				dad.x -= 500;
			case 'senpai':
				dad.x += 50;
				dad.y += 500;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y-500);
			case 'senpai-angry':
				dad.x += 210;
				dad.y += 500;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y-500);
			case 'spirit':
				dad.x -= 150;
				dad.y += 200;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
			case 'army':
				dad.x -= 1000;
				dad.y -= 500;

				armyRight.x += 1000;
				armyRight.y -= 500;
		}

		if(curStage=='elevator'){
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
		}

		boyfriend = new Boyfriend(770, 450, SONG.player1);
		omega = new Boyfriend(1000,70,"omega",true);
		if(SONG.song.toLowerCase()!='2v200')
			omega.visible=false;

		// REPOSITIONING PER STAGE
		switch (curStage)
		{
			case 'limo':
				boyfriend.y -= 220;
				boyfriend.x += 260;

				resetFastCar();
				add(fastCar);

			case 'mall':
				boyfriend.x += 200;

			case 'mallEvil':
				boyfriend.x += 320;
				dad.y -= 80;
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
			case 'elevator':
				boyfriend.x += 100;
			case 'omegafield':
				if(SONG.song.toLowerCase()=='2v200'){
					boyfriend.x -= 150;
					omega.x -= 150;
				}else{
					boyfriend.x += 100;
					omega.x += 100;
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
		if(SONG.player1=='bf-neb')
			boyfriend.y -= 75;

		add(gf);

		// Shitty layering but whatev it works LOL
		if (curStage == 'limo')
			add(limo);

		if(curStage=='omegafield')
			gf.visible=false;

		add(dad);
		add(armyRight);
		add(omega);
		if(SONG.song.toLowerCase()=='guardian')
			add(mika);
		add(boyfriend);

		if(dad.curCharacter=='noke' && curStage=='elevator')
			add(nokeTxt);

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
		var doof:DialogueBox = new DialogueBox(false, dialogue);
		// doof.x += 70;
		// doof.y = FlxG.height * 0.5;
		doof.scrollFactor.set();
		doof.finishThing = startCountdown;

		Conductor.songPosition = -5000;

		strumLine = new FlxSprite(0, 50).makeGraphic(FlxG.width, 10);
		if(currentOptions.downScroll){
			strumLine.y = FlxG.height-150;
		}
		strumLine.scrollFactor.set();

		strumLineNotes = new FlxTypedGroup<FlxSprite>();
		//add(strumLineNotes);
		//strumLineNotes.visible=false;

		playerStrumLines = new FlxTypedGroup<FlxSprite>();
		opponentStrumLines = new FlxTypedGroup<FlxSprite>();
		luaSprites = new Map<String, FlxSprite>();
		luaObjects = new Map<String, FlxBasic>();
		refNotes = new FlxTypedGroup<FlxSprite>();
		opponentRefNotes = new FlxTypedGroup<FlxSprite>();
		playerStrums = new FlxTypedGroup<FlxSprite>();
		dadStrums = new FlxTypedGroup<FlxSprite>();

		// startCountdown();
		// TODO: Start lua shit here
		generateSong(SONG.song);

		// add(strumLine);

		camFollow = new FlxObject(0, 0, 1, 1);

		camFollow.setPosition(camPos.x, camPos.y);

		if (prevCamFollow != null)
		{
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}

		add(camFollow);

		FlxG.camera.follow(camFollow, LOCKON, 0.01);
		// FlxG.camera.setScrollBounds(0, FlxG.width, 0, FlxG.height);
		FlxG.camera.zoom = defaultCamZoom;
		FlxG.camera.focusOn(camFollow.getPosition());

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

		switch(SONG.player1){
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

		var hpIcon = SONG.player1;
		switch(SONG.song.toLowerCase()){
			case '2v200':
				hpIcon = "omegabf";
			default:
				hpIcon = SONG.player1;
		}

		iconP1 = new HealthIcon(hpIcon, true);
		iconP1.y = healthBar.y - (iconP1.height / 2);
		add(iconP1);

		iconP2 = new HealthIcon((SONG.song.toLowerCase()=='after-the-ashes' && SONG.player2=='omega')?'omegafriendly':SONG.player2, false);
		iconP2.y = healthBar.y - (iconP2.height / 2);
		add(iconP2);

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
		dadStrums.cameras=[camHUD];
		strumLineNotes.cameras = [camHUD];
		renderedNotes.cameras = [camHUD];
		playerRenderedNotes.cameras = [camHUD];
		opponentRenderedNotes.cameras = [camHUD];
		healthBar.cameras = [camHUD];
		healthBarBG.cameras = [camHUD];
		iconP1.cameras = [camHUD];
		iconP2.cameras = [camHUD];
		scoreTxt.cameras = [camHUD];
		doof.cameras = [camHUD];
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
		if(luaModchartExists && currentOptions.loadModcharts){
			lua = new LuaVM();
			lua.setGlobalVar("defaultCamZoom",defaultCamZoom);
			lua.setGlobalVar("curBeat",0);
			lua.setGlobalVar("curStep",0);
			lua.setGlobalVar("songPosition",Conductor.songPosition);
			lua.setGlobalVar("bpm",Conductor.bpm);
			lua.setGlobalVar("health",health);
			lua.setGlobalVar("XY","XY");
			lua.setGlobalVar("X","X");
			lua.setGlobalVar("Y","Y");

			Lua_helper.add_callback(lua.state,"newSprite", function(?x:Int=0,?y:Int=0,?drawBehind:Bool=false,?spriteName:String){
				var sprite = new FlxSprite(x,y);
				var name = "UnnamedSprite"+unnamedLuaSprites;
				unnamedLuaSprites++;
				if(spriteName!=null) name=spriteName;

				var lSprite = new LuaSprite(sprite,name,spriteName!=null);
				var classIdx = Lua.gettop(lua.state)+1;
				lSprite.Register(lua.state);
				Lua.pushvalue(lua.state,classIdx);
				if(drawBehind){
					var idx=0;
					var foundGF=-1;
					var foundBF=-1;
					var foundDad=-1;
					var daIndex=-1;
					this.forEach( function(blegh:FlxBasic){ // WEIRD LAYERING SHIT BUT HEY IT WORKS
						if(blegh==gf){
							foundGF=idx;
						}
						if(blegh==boyfriend){
							foundBF=idx;
						}
						if(blegh==dad){
							foundDad=idx;
						}

						if(foundDad!=-1 && foundGF!=-1 && foundBF!=-1 && daIndex==-1){
							var bruh = [foundDad,foundGF,foundBF];
							var curr = foundDad;
							for(v in bruh){
								if(v<curr){
									curr=v;
								}
							}
							daIndex=curr;
						}
						idx++;
					});
					if(daIndex!=-1){
						members.insert(daIndex,sprite);
						@:bypassAccessor
							this.length++;
					}else{
						add(sprite);
					}
				}else{
					add(sprite);
				};
			});

			var leftPlayerNote = new LuaNote(0,true);
			var downPlayerNote = new LuaNote(1,true);
			var upPlayerNote = new LuaNote(2,true);
			var rightPlayerNote = new LuaNote(3,true);

			var leftDadNote = new LuaNote(0,false);
			var downDadNote = new LuaNote(1,false);
			var upDadNote = new LuaNote(2,false);
			var rightDadNote = new LuaNote(3,false);

			bfLua = new LuaCharacter(boyfriend,"bf",true);
			gfLua = new LuaCharacter(gf,"gf",true);
			dadLua = new LuaCharacter(dad,"dad",true);

			var bfIcon = new LuaSprite(iconP1,"iconP1",true);
			var dadIcon = new LuaSprite(iconP2,"iconP2",true);

			var window = new LuaWindow();

			var luaGameCam = new LuaCam(FlxG.camera,"gameCam");
			var luaHUDCam = new LuaCam(camHUD,"HUDCam");
			for(i in [leftPlayerNote,downPlayerNote,upPlayerNote,rightPlayerNote,leftDadNote,downDadNote,upDadNote,rightDadNote,window,bfLua,gfLua,dadLua,bfIcon,dadIcon,luaGameCam,luaHUDCam])
				i.Register(lua.state);

			try {
				lua.runFile(Paths.modchart(SONG.song.toLowerCase()));
			}catch (e:Exception){
				trace("ERROR: " + e);
			};

			if(lua!=null && luaModchartExists)
				lua.call("init",[]);


		}

		if (isStoryMode)
		{
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
						camFollow.y = -2050;
						camFollow.x += 200;
						FlxG.camera.focusOn(camFollow.getPosition());
						FlxG.camera.zoom = 1.5;

						new FlxTimer().start(0.8, function(tmr:FlxTimer)
						{
							camHUD.visible = true;
							remove(blackScreen);
							FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, 2.5, {
								ease: FlxEase.quadInOut,
								onComplete: function(twn:FlxTween)
								{
									startCountdown();
								}
							});
						});
					});
				case 'senpai':
					schoolIntro(doof);
				case 'roses':
					FlxG.sound.play(Paths.sound('ANGRY'));
					schoolIntro(doof);
				case 'thorns':
					schoolIntro(doof);
				default:
					startCountdown();
			}
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

	public function swapCharacterByLuaName(spriteName:String,newCharacter:String){
		var sprite = luaSprites[spriteName];
		if(sprite!=null){
			var newSprite:Character;
			var spriteX = sprite.x;
			var spriteY = sprite.y;
			var currAnim:String = "idle";
			if(sprite.animation.curAnim!=null)
				currAnim=sprite.animation.curAnim.name;
			trace(currAnim);
			remove(sprite);
			// TODO: Make this BETTER!!!
			if(spriteName=="bf"){
				boyfriend = new Boyfriend(spriteX,spriteY,newCharacter); // TODO: layer it
				newSprite = boyfriend;
				bfLua.sprite = boyfriend;
				iconP1.changeCharacter(newCharacter);
			}else if(spriteName=="dad"){
				dad = new Character(spriteX,spriteY,newCharacter);
				newSprite = dad;
				dadLua.sprite = dad;
				iconP2.changeCharacter(newCharacter);
			}else if(spriteName=="gf"){
				gf = new Character(spriteX,spriteY,newCharacter);
				newSprite = gf;
				gfLua.sprite = gf;
			}else{
				newSprite = new Character(spriteX,spriteY,newCharacter);
			}

			luaSprites[spriteName]=newSprite;
			add(newSprite);
			trace(currAnim);
			if(currAnim!="idle" && !currAnim.startsWith("dance")){
				newSprite.playAnim(currAnim);
			}else if(currAnim=='idle' || currAnim.startsWith("dance")){
				newSprite.dance();
			}


		}
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

	function startCountdown():Void
	{
		modchart.hudVisible=disabledHud;
		inCutscene = false;

		generateStaticArrows(0);
		generateStaticArrows(1);

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
					FlxG.sound.play(Paths.sound('intro3'), 0.6);
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
					FlxG.sound.play(Paths.sound('intro2'), 0.6);
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
					FlxG.sound.play(Paths.sound('intro1'), 0.6);
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
					FlxG.sound.play(Paths.sound('introGo'), 0.6);
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
		add(opponentRenderedNotes);


		playerRenderedNotes = new FlxTypedGroup<Note>();
		add(playerStrums);
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
				var daNoteData:Int = Std.int(songNotes[1] % 4);
				var gottaHitNote:Bool = section.mustHitSection;

				if (songNotes[1] > 3)
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

				var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote, gottaHitNote, false, songNotes[3], songNotes[4], songNotes[5],songNotes[6],songNotes[7]);

				swagNote.sustainLength = songNotes[2];
				swagNote.scrollFactor.set(0, 0);

				var susLength:Float = swagNote.sustainLength;

				susLength = susLength / Conductor.stepCrochet;

				unspawnNotes.push(swagNote);

				for (susNote in 0...Math.floor(susLength))
				{
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

					var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet, daNoteData, oldNote, gottaHitNote, true, songNotes[3],songNotes[4], songNotes[5],songNotes[6],songNotes[7]);
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

	private function generateStaticArrows(player:Int):Void
	{
		for (i in 0...4)
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
						case 0:
							babyArrow.x += width * 0;
							babyArrow.animation.add('static', [0]);
							babyArrow.animation.add('confirm', [8], 12, false);
							babyArrow.animation.add('pressed', [12], 24, false);
						case 1:
							babyArrow.x += width * 1;
							babyArrow.animation.add('static', [1]);
							babyArrow.animation.add('confirm', [9], 12, false);
							babyArrow.animation.add('pressed', [13], 24, false);
						case 2:
							babyArrow.x += width * 2;
							babyArrow.animation.add('static', [2]);
							babyArrow.animation.add('confirm', [10], 12, false);
							babyArrow.animation.add('pressed', [14], 24, false);
						case 3:
							babyArrow.x += width * 3;
							babyArrow.animation.add('static', [3]);
							babyArrow.animation.add('confirm', [11], 12, false);
							babyArrow.animation.add('pressed', [15], 24, false);
					}

				default:
					babyArrow.frames = Paths.getSparrowAtlas('NOTE_assets');
					babyArrow.animation.addByPrefix('green', 'arrowUP');
					babyArrow.animation.addByPrefix('blue', 'arrowDOWN');
					babyArrow.animation.addByPrefix('purple', 'arrowLEFT');
					babyArrow.animation.addByPrefix('red', 'arrowRIGHT');

					babyArrow.antialiasing = true;
					babyArrow.setGraphicSize(Std.int(babyArrow.width * 0.7 * scale));

					switch (Math.abs(i))
					{
						case 0:
							babyArrow.x += width * 0;
							babyArrow.animation.addByPrefix('static', 'arrowLEFT');
							babyArrow.animation.addByPrefix('pressed', 'left press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'left confirm', 24, false);
						case 1:
							babyArrow.x += width * 1;
							babyArrow.animation.addByPrefix('static', 'arrowDOWN');
							babyArrow.animation.addByPrefix('pressed', 'down press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'down confirm', 24, false);
						case 2:
							babyArrow.x += width * 2;
							babyArrow.animation.addByPrefix('static', 'arrowUP');
							babyArrow.animation.addByPrefix('pressed', 'up press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'up confirm', 24, false);
						case 3:
							babyArrow.x += width * 3;
							babyArrow.animation.addByPrefix('static', 'arrowRIGHT');
							babyArrow.animation.addByPrefix('pressed', 'right press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'right confirm', 24, false);
					}
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
				playerStrums.add(babyArrow);
				playerStrumLines.add(newStrumLine);
				refNotes.add(newNoteRef);
			}else{
				dadStrums.add(babyArrow);
				opponentStrumLines.add(newStrumLine);
				opponentRefNotes.add(newNoteRef);
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

			strumLineNotes.add(babyArrow);
		}
	}

	function tweenCamIn():Void
	{
		FlxTween.tween(FlxG.camera, {zoom: 1.3}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut});
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

	function truncateFloat( number : Float, precision : Int): Float {
		var num = number;
		num = num * Math.pow(10, precision);
		num = Math.round( num ) / Math.pow(10, precision);
		return num;
	}

	var disconnectTextTimer:Float = 0;
	function NokeDisconnect(){
		if(nokeBG.alpha==1){
			nokeFl.alpha=0;
			nokeBG.alpha=0;
			nokeFG.alpha=0;
			nokeTxt.text = "DISCONNECTED";
			nokeTxt.visible=true;
			nokeTxt.x = dad.x-150+FlxG.random.int(-75,75);
			nokeTxt.y = dad.y+150+FlxG.random.int(-75,75);
			nokeTxt.angle = FlxG.random.int(-25,25);
			disconnectTextTimer=0;
		}
	}

	function NokeReconnect(){
		if(nokeBG.alpha==0){
			nokeFl.alpha=1;
			nokeBG.alpha=1;
			nokeFG.alpha=1;
			nokeTxt.text = "RECONNECTED";
			nokeTxt.visible=true;
			nokeTxt.x = dad.x-150+FlxG.random.int(-75,75);
			nokeTxt.y = dad.y+150+FlxG.random.int(-75,75);
			nokeTxt.angle = FlxG.random.int(-25,25);
			disconnectTextTimer=0;
		}
	}

	override public function update(elapsed:Float)
	{
		#if !debug
		perfectMode = false;
		#end

		if(vcrDistortionHUD!=null){
			vcrDistortionHUD.update(elapsed);
			vcrDistortionGame.update(elapsed);
		}
		if(rainShader!=null){
			rainShader.update(elapsed);
		}
		modchart.update(elapsed);

		if (FlxG.keys.justPressed.NINE)
		{
			if (iconP1.animation.curAnim.name == 'bf-old')
				iconP1.animation.play(SONG.player1);
			else
				iconP1.animation.play('bf-old');
		}

		disconnectTextTimer+=elapsed;
		if(disconnectTextTimer>.5 && curStage=='elevator'){
			nokeTxt.visible=false;
		}

		switch (curStage)
		{
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
				if(currentOptions.picoShaders && lightFadeShader!=null)
					lightFadeShader.addAlpha((Conductor.crochet / 1000) * FlxG.elapsed * 1.5);
				else
					phillyCityLights.members[curLight].alpha -= (Conductor.crochet / 1000) * FlxG.elapsed * 1.5;
		}
		if(luaModchartExists && lua!=null){
			lua.call("update",[elapsed]);
		}

		boyfriend.visible = !modchart.hideBF;
		gf.visible = !modchart.hideGF;
		dad.visible = !modchart.hideDad;
		iconP1.visible = modchart.hudVisible;
		iconP2.visible = modchart.hudVisible;
		healthBar.visible = modchart.hudVisible;
		healthBarBG.visible = modchart.hudVisible;
		sicksTxt.visible = modchart.hudVisible;
		badsTxt.visible = modchart.hudVisible;
		shitsTxt.visible = modchart.hudVisible;
		epicsTxt.visible = modchart.hudVisible;
		goodsTxt.visible = modchart.hudVisible;
		missesTxt.visible = modchart.hudVisible;
		highComboTxt.visible = modchart.hudVisible;
		scoreTxt.visible = modchart.hudVisible;
		scoreTxt.screenCenter(X);
		if(presetTxt!=null)
			presetTxt.visible = modchart.hudVisible;


		super.update(elapsed);
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
		if(luaModchartExists && lua!=null){
			var luaHealth = lua.getGlobalVar("health","float");
			if(luaHealth!=previousHealth && luaHealth!=health)
				health = luaHealth;
			lua.setGlobalVar("health",health);

			var luaCamZoom = lua.getGlobalVar("defaultCamZoom","float");
			if(luaCamZoom!=defaultCamZoom){
				defaultCamZoom=luaCamZoom;
				FlxG.camera.zoom = defaultCamZoom;
			}
		}

		displayedHealth = FlxMath.lerp(displayedHealth,health,.2/(openfl.Lib.current.stage.frameRate/60));


		if(misses>0 && currentOptions.failForMissing){
			health=0;
		}
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
				Cache.Clear();
			}
			else
				openSubState(new PauseSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));

			#if desktop
			DiscordClient.changePresence(detailsPausedText + SONG.song + " (" + storyDifficultyText + ")", grade + " | Acc: " + truncateFloat(accuracy*100,2) + "%", iconRPC);
			#end
		}

		if (FlxG.keys.justPressed.SEVEN)
		{


			#if windows
			if(lua!=null){
				lua.destroy();
				trace("cringe");
				lua=null;
			}
			#end
			FlxG.switchState(new ChartingState());
			Cache.Clear();

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
			if(luaModchartExists && lua!=null)
				lua.setGlobalVar("health",health);
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
				FlxG.switchState(new AnimationDebug(SONG.player2));
				Cache.Clear();
				#if windows
				if(lua!=null){
					lua.destroy();
					lua=null;
				}
				#end
			}
			if (FlxG.keys.justPressed.NINE){
				FlxG.switchState(new AnimationDebug(SONG.player1));
				Cache.Clear();
				#if windows
				if(lua!=null){
					lua.destroy();
					lua=null;
				}
				#end
			}
		if (startingSong)
		{
			if (startedCountdown)
			{
				Conductor.songPosition += FlxG.elapsed * 1000;
				if (Conductor.songPosition >= 0)
					startSong();
			}
		}
		else
		{
			// Conductor.songPosition = FlxG.sound.music.time;
			Conductor.songPosition += FlxG.elapsed * 1000;

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

		if(luaModchartExists && lua!=null)
			lua.setGlobalVar("songPosition",Conductor.songPosition);

		if (generatedMusic && PlayState.SONG.notes[Std.int(curStep / 16)] != null)
		{
			if (curBeat % 4 == 0)
			{
				// trace(PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection);
			}
			if(SONG.song.toLowerCase()!='hivemind' && curStage!='elevator'){
				if (camFollow.x != dad.getMidpoint().x + 150 && !PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection)
				{
					camFollow.setPosition(dad.getMidpoint().x + 150, dad.getMidpoint().y - 100);
					// camFollow.setPosition(lucky.getMidpoint().x - 120, lucky.getMidpoint().y + 210);

					switch (dad.curCharacter)
					{
						case 'mom':
							camFollow.y = dad.getMidpoint().y;
						case 'senpai':
							camFollow.y = dad.getMidpoint().y - 300;
							camFollow.x = dad.getMidpoint().x + 100;
						case 'senpai-angry':
							camFollow.y = dad.getMidpoint().y - 300;
							camFollow.x = dad.getMidpoint().x - 100;
						case 'army':
							if(SONG.song.toLowerCase()=='2v200'){
								camFollow.x = boyfriend.getMidpoint().x + 150;
								camFollow.y = boyfriend.getMidpoint().y - 300;
							}
						case 'anders':
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
							camFollow.x = boyfriend.getMidpoint().x - 300;
						case 'mall':
							camFollow.y = boyfriend.getMidpoint().y - 200;
						case 'school':
							camFollow.x = boyfriend.getMidpoint().x - 200;
							camFollow.y = boyfriend.getMidpoint().y - 250;
						case 'schoolEvil':
							camFollow.x = boyfriend.getMidpoint().x - 200;
							camFollow.y = boyfriend.getMidpoint().y - 250;
						case 'omegafield':
							if(SONG.song.toLowerCase()=='2v200'){
								camFollow.x = boyfriend.getMidpoint().x + 150;
								camFollow.y = boyfriend.getMidpoint().y - 200;
							}
					}

					if(boyfriend.curCharacter=='bf-pixel' && SONG.song.toLowerCase()=='father-time'){
						camFollow.x = boyfriend.getMidpoint().x - 200;
						camFollow.y = boyfriend.getMidpoint().y - 200;
					}

					if (SONG.song.toLowerCase() == 'tutorial')
					{
						FlxTween.tween(FlxG.camera, {zoom: 1}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut});
					}
				}
			}
		}else if(SONG.song.toLowerCase()=='hivemind'){
			camFollow.setPosition(dad.getMidpoint().x+125,dad.getMidpoint().y);
		}else{
			camFollow.setPosition(dad.getMidpoint().x+400,dad.getMidpoint().y);
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
			if(luaModchartExists && lua!=null)
				lua.setGlobalVar("health",health);
			trace("User is cheating!");
		}

		if (health <= 0)
		{
			boyfriend.stunned = true;

			persistentUpdate = false;
			persistentDraw = false;
			paused = true;

			vocals.stop();
			FlxG.sound.music.stop();

			openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));

			// FlxG.switchState(new GameOverState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));

			#if desktop
			// Game Over doesn't get his own variable because it's only used here
			DiscordClient.changePresence("Game Over - " + detailsText + SONG.song + " (" + storyDifficultyText + ")", grade + " | Acc: " + truncateFloat(accuracy*100,2) + "%", iconRPC);
			#end
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

				hittableNotes.sort((a,b)->Std.int(a.strumTime-b.strumTime));
			}
		}

		if (generatedMusic)
		{
			for(idx in 0...playerStrumLines.length){
				var width = (Note.swagWidth*modchart.playerNoteScale);
				var line = playerStrumLines.members[idx];
				if(currentOptions.middleScroll){
					line.screenCenter(X);
					line.x += width*(-2+idx) + playerNoteOffsets[idx][0];
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
				var offset = opponentNoteOffsets[idx%4];
				var strumLine = opponentStrumLines.members[idx%4];
				var alpha = opponentRefNotes.members[idx%4].alpha;
				var angle = opponentRefNotes.members[idx%4].angle;
				if(idx>3){
					offset = playerNoteOffsets[idx%4];
					strumLine = playerStrumLines.members[idx%4];
					alpha = refNotes.members[idx%4].alpha;
					angle = refNotes.members[idx%4].angle;
				}
				if(modchart.opponentNotesFollowReceptors && idx>3 || idx<=3 && modchart.playerNotesFollowReceptors){
					note.x = strumLine.x;
					note.y = strumLine.y;
				}else{

				}

				note.alpha = alpha;
				note.angle=angle;
			}

			var dadAnim = '';
			var dadDir = -1;
			var isSussy = false;

			renderedNotes.forEachAlive(function(daNote:Note)
			{
				var strumLine = strumLine;
				if(modchart.playerNotesFollowReceptors)
					strumLine = playerStrumLines.members[daNote.noteData];


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

				var brr = strumLine.y + width/2;
				if(currentOptions.downScroll){
					daNote.y = (strumLine.y + 0.45 * (Conductor.songPosition - daNote.strumTime) * FlxMath.roundDecimal(SONG.speed, 2));
					if(daNote.isSustainNote){
						if(daNote.animation.curAnim.name.endsWith("end") && daNote.prevNote!=null){
							daNote.y += daNote.prevNote.height;
						}else{
							daNote.y += daNote.height/2;
						}
					}
					if (daNote.isSustainNote
						&& daNote.y-daNote.offset.y*daNote.scale.y+daNote.height>=brr
						&& (!daNote.mustPress || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit))))
					{
						var swagRect = new FlxRect(0,0,daNote.frameWidth*2,daNote.frameHeight*2);
						swagRect.height = (brr-daNote.y)/daNote.scale.y;
						swagRect.y = daNote.frameHeight-swagRect.height;

						daNote.clipRect = swagRect;
					}
				}else{
					daNote.y = (strumLine.y - 0.45 * (Conductor.songPosition - daNote.strumTime) * FlxMath.roundDecimal(SONG.speed, 2));
					if (daNote.isSustainNote
						&& daNote.y + daNote.offset.y * daNote.scale.y <= brr
						&& (!daNote.mustPress || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit))))
					{
						var swagRect = new FlxRect(0,0,daNote.width/daNote.scale.x,daNote.height/daNote.scale.y);
						swagRect.y = (brr-daNote.y)/daNote.scale.y;
						swagRect.height -= swagRect.y;

						daNote.clipRect = swagRect;
					}
				}

				daNote.x = strumLine.x;
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
					dadStrums.forEach(function(spr:FlxSprite)
					{
						if (Math.abs(daNote.noteData) == spr.ID)
						{
							spr.animation.play('confirm', true);
						}
					});
					if (SONG.song != 'Tutorial')
						camZooming = true;

					var altAnim:String = "";

					if (SONG.notes[Math.floor(curStep / 16)] != null)
					{
						if (SONG.notes[Math.floor(curStep / 16)].altAnim && SONG.song.toLowerCase()!='guardian')
							altAnim = '-alt';
					}
					if(luaModchartExists && lua!=null){
						lua.call("dadNoteHit",[Math.abs(daNote.noteData),daNote.strumTime,Conductor.songPosition]); // TODO: Note lua class???
					}
					health -= modchart.opponentHPDrain;

						//if(!daNote.isSustainNote){

						var anim = "";
						switch (Math.abs(daNote.noteData))
						{
							case 0:
								anim='singLEFT' + altAnim;
							case 1:
								anim='singDOWN' + altAnim;
							case 2:
								anim='singUP' + altAnim;
							case 3:
								anim='singRIGHT' + altAnim;
						}

						switch (Math.abs(daNote.noteData))
						{
							case 2:
								if(curStage=='elevator' && dad.curCharacter=='noke'){
									NokeDisconnect();
								}
							case 3:
								if(curStage=='elevator'){
									NokeReconnect();
								}
							case 1:
								if(curStage=='elevator' && dad.curCharacter=='noke'){
									NokeDisconnect();
								}
							case 0:
								if(curStage=='elevator'){
									NokeReconnect();
								}
						}

						if(daNote.noteType==3){
								FlxG.sound.play(Paths.sound('Gold_Note_Hit'), 0.7);
								goldOverlay.alpha = 1;
								if(goldOverlayTween!=null)
									goldOverlayTween.cancel();
								goldOverlayTween = FlxTween.tween(goldOverlay, {alpha: 0}, .25);
								health -= .25;
						}

						if(daNote.noteType==4){
							anim='discharge';
							dadAnim='discharge';
							dad.holding=false;
							isSussy=false;
							dadDir=-1;
							dad.playAnim("discharge",true);
							new FlxTimer().start(.358, function(tmr:FlxTimer){
								boyfriend.playAnim("scared",true);
								gf.playAnim("scared",true);
								discharging=true;
								dischargeHP=health;
								camGame.shake(.01,.4);
								camHUD.shake(.01,.4);
								FlxG.sound.play(Paths.sound('discharge'), 1);
							});
						}

						if((dadDir==-1 || daNote.noteData<dadDir || anim=='discharge') && dadAnim!='discharge' ){
							dadDir=daNote.noteData;
							dadAnim=anim;
							isSussy=daNote.isSustainNote;
						}


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

				if(dadDir!=-1){
					var anim = dadAnim;
					var canHold = isSussy && dad.animation.getByName(anim+"Hold")!=null;
					if(canHold && !dad.animation.curAnim.name.startsWith(anim)){
						dad.playAnim(anim,true);
					}else if(currentOptions.pauseHoldAnims && !canHold){
						dad.playAnim(anim,true);
						if(daNote.holdParent )
							dad.holding=true;
						else{
							dad.holding=false;
						}
					}else if(!currentOptions.pauseHoldAnims && !canHold){
						dad.playAnim(anim,true);
					}

					if(armyRight.visible){
						var canHold2 = isSussy && armyRight.animation.getByName(anim+"Hold")!=null;
						if(canHold2 && !armyRight.animation.curAnim.name.startsWith(anim)){
							armyRight.playAnim(anim,true);
						}else if(currentOptions.pauseHoldAnims && !canHold2){
							armyRight.playAnim(anim,true);
							if(daNote.holdParent )
								armyRight.holding=true;
							else{
								armyRight.holding=false;
							}
						}else if(!currentOptions.pauseHoldAnims && !canHold2){
							armyRight.playAnim(anim,true);
						}
					}
					dad.holdTimer = 0;
					armyRight.holdTimer = 0;
				}

				// WIP interpolation shit? Need to fix the pause issue
				// daNote.y = (strumLine.y - (songTime - daNote.strumTime) * (0.45 * PlayState.SONG.speed));

				if ((!currentOptions.downScroll && daNote.y < -daNote.height || currentOptions.downScroll && daNote.y>FlxG.height) && daNote.mustPress)
				{
					if ((daNote.tooLate || !daNote.wasGoodHit) && daNote.noteType==0)
					{
						trace("miss");
						if(!daNote.isSustainNote){
							noteMiss(daNote.noteData);
						}else{
							combo=0;
							misses++;
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
			if (spr.animation.finished && spr.animation.curAnim.name=='confirm' && (lastHitDadNote==null || !lastHitDadNote.isSustainNote || lastHitDadNote.animation.curAnim==null || lastHitDadNote.animation.curAnim.name.endsWith("end")))
			{
				spr.animation.play('static',true);
				spr.centerOffsets();
			}

			if (spr.animation.curAnim.name == 'confirm' && !curStage.startsWith('school'))
			{
				spr.centerOffsets();
				spr.offset.x -= 13;
				spr.offset.y -= 13;
			}
			else
				spr.centerOffsets();
		});

		if (!inCutscene)
			keyShit();

		if(Conductor.songPosition-currentOptions.noteOffset>=FlxG.sound.music.length){
			if(FlxG.sound.music.volume>0)
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
		canPause = false;
		FlxG.sound.music.volume = 0;
		vocals.volume = 0;

		#if windows
		if(lua!=null){
			lua.destroy();
			lua=null;
		}
		#end
		if (SONG.validScore)
		{
			#if !switch
			Highscore.saveScore(SONG.song, songScore, storyDifficulty);
			#end
		}

		if (isStoryMode)
		{
			campaignScore += songScore;

			storyPlaylist.remove(storyPlaylist[0]);

			if (storyPlaylist.length <= 0)
			{

				FlxG.sound.playMusic(Paths.music('freakyMenu'));

				transIn = FlxTransitionableState.defaultTransIn;
				transOut = FlxTransitionableState.defaultTransOut;

				FlxG.switchState(new StoryMenuState());
				Cache.Clear();

				// if ()
				StoryMenuState.weekUnlocked[Std.int(Math.min(storyWeek + 1, StoryMenuState.weekUnlocked.length - 1))] = true;

				if (SONG.validScore)
				{
					//NGio.unlockMedal(60961);
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

				trace('LOADING NEXT SONG');
				trace(PlayState.storyPlaylist[0].toLowerCase() + difficulty);

				if (SONG.song.toLowerCase() == 'eggnog')
				{
					var blackShit:FlxSprite = new FlxSprite(-FlxG.width * FlxG.camera.zoom,
						-FlxG.height * FlxG.camera.zoom).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
					blackShit.scrollFactor.set();
					add(blackShit);
					camHUD.visible = false;

					FlxG.sound.play(Paths.sound('Lights_Shut_off'));
				}

				FlxTransitionableState.skipNextTransIn = true;
				FlxTransitionableState.skipNextTransOut = true;
				prevCamFollow = camFollow;

				PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + difficulty, PlayState.storyPlaylist[0]);
				FlxG.sound.music.stop();

				LoadingState.loadAndSwitchState(new PlayState());
				Cache.Clear();
			}
		}
		else
		{
			trace('WENT BACK TO FREEPLAY??');
			FlxG.switchState(new FreeplayState());
			Cache.Clear();
		}
	}

	var endingSong:Bool = false;

	private function popUpScore(noteDiff:Float,?gold=false):Void
	{
		var daRating = ScoreUtils.DetermineRating(noteDiff);
		totalNotes++;
		// boyfriend.playAnim('hey');
		vocals.volume = 1;

		var placement:String = Std.string(combo);

		var coolText:FlxText = new FlxText(0, 0, 0, placement, 32);
		coolText.screenCenter();
		coolText.x = FlxG.width * 0.55;
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

		hitNotes+=ScoreUtils.RatingToHit(daRating);
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
				numScore.y += 100;
				numScore.setGraphicSize(Std.int(numScore.width * 0.5));
			}
			else
			{
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
				if(i=='point'){
					if(!curStage.startsWith("school")){
						numScore.x += 25;
						numScore.y += 100;
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

		if((left || right || up || down) && generatedMusic ){
			var hitting=[];
			var beenHit=[];
			for(daNote in hittableNotes){
				if(daNote.isSustainNote && daNote.canBeHit && daNote.mustPress && holdArray[daNote.noteData] && !beenHit.contains(daNote.noteData)){
					noteHit(daNote);
				}
			};

		};

		if ((upP || rightP || downP || leftP) && generatedMusic)
			{
				var possibleNotes:Array<Note> = [];
				var ignoreList = [];
				var what = [];
				var checkDirAgain=[false,false,false,false];
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

			if (boyfriend.holdTimer > Conductor.stepCrochet * bfVar * 0.001 && !up && !down && !right && !left)
			{
				if (boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss'))
				{
					boyfriend.dance();
				}
			}


			if (omega.holdTimer >= Conductor.stepCrochet * bfVar * 0.001 && !up && !down && !right && !left)
			{
				if (omega.animation.curAnim.name.startsWith('sing') && !omega.animation.curAnim.name.endsWith('miss'))
				{
					omega.dance();
				}
			}


			playerStrums.forEach(function(spr:FlxSprite)
			{
				if(controlArray[spr.ID] && spr.animation.curAnim.name!="confirm")
					spr.animation.play("pressed");

				if(!holdArray[spr.ID]){
					spr.animation.play("static");
				}
				if (spr.animation.curAnim.name == 'confirm' && !curStage.startsWith('school'))
				{
					spr.centerOffsets();
					spr.offset.x -= 13;
					spr.offset.y -= 13;
				}
				else
					spr.centerOffsets();
			});
	}


	function noteMiss(direction:Int = 1,?note:Note):Void
	{
		if(note!=null) direction=note.noteData;

		boyfriend.holding=false;
		misses++;
		health -= 0.04;
		previousHealth=health;
		if(luaModchartExists && lua!=null)
			lua.setGlobalVar("health",health);
		if (combo > 5 && gf.animOffsets.exists('sad'))
		{
			gf.playAnim('sad');
		}
		combo = 0;

		songScore -= 10;

		FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.3, 0.6));

		if(note!=null){
			trace(note.whoSingsShit);
			note.whoSingsShit = note.whoSingsShit==null?"0":note.whoSingsShit;
			switch (note.noteData)
			{
				case 2:
					if(note.whoSingsShit=='0' || note.whoSingsShit=='2')
						boyfriend.playAnim('singUPmiss', true);

					if(note.whoSingsShit=='1' || note.whoSingsShit=='2')
						omega.playAnim('singUPmiss',true);

				case 3:
					if(note.whoSingsShit=='0' || note.whoSingsShit=='2')
						boyfriend.playAnim('singRIGHTmiss', true);

					if(note.whoSingsShit=='1' || note.whoSingsShit=='2')
						omega.playAnim('singRIGHTmiss',true);
				case 1:
					if(note.whoSingsShit=='0' || note.whoSingsShit=='2')
						boyfriend.playAnim('singDOWNmiss', true);

					if(note.whoSingsShit=='1' || note.whoSingsShit=='2')
						omega.playAnim('singDOWNmiss',true);
				case 0:
					if(note.whoSingsShit=='0' || note.whoSingsShit=='2')
						boyfriend.playAnim('singLEFTmiss', true);

					if(note.whoSingsShit=='1' || note.whoSingsShit=='2')
						omega.playAnim('singLEFTmiss',true);
			}
		}else{
			switch (direction)
			{
				case 0:
					boyfriend.playAnim('singLEFTmiss', true);
				case 1:
					boyfriend.playAnim('singDOWNmiss', true);
				case 2:
					boyfriend.playAnim('singUPmiss', true);
				case 3:
					boyfriend.playAnim('singRIGHTmiss', true);
			}
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
					health=-1;
				default:
					goodNoteHit(note);
			}
			note.wasGoodHit=true;
			playerStrums.forEach(function(spr:FlxSprite)
			{
				if (Math.abs(note.noteData) == spr.ID)
				{
					spr.animation.play('confirm', true);
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

	function hurtNoteHit(note:Note):Void
	{
		combo=0;
		totalNotes++;

		var strumLine = playerStrumLines.members[note.noteData%4];

		if(note.sustainLength==0 && !note.isSustainNote)
			health -= .5;
		else
			health -= .25;
		FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.3, 0.6));

		previousHealth=health;
		if(luaModchartExists && lua!=null)
			lua.setGlobalVar("health",health);

		//if(!note.isSustainNote){
		switch(boyfriend.curCharacter){
			case 'bf-christmas' | 'bf' | 'bf2':
				boyfriend.playAnim('ouch',true);
			default:
				var anim = "";
				switch (note.noteData)
				{
				case 0:
					anim='singLEFTmiss';
				case 1:
					anim='singDOWNmiss';
				case 2:
					anim='singUPmiss';
				case 3:
					anim='singRIGHTmiss';
				}


				var canHold = note.isSustainNote && boyfriend.animation.getByName(anim+"Hold")!=null;
				if(canHold && !boyfriend.animation.curAnim.name.startsWith(anim)){
					boyfriend.playAnim(anim,true);
				}else if(currentOptions.pauseHoldAnims && !canHold){
					boyfriend.playAnim(anim,true);
					if(note.holdParent)
						boyfriend.holding=true;
					else{
						boyfriend.holding=false;
					}


				}else if(!currentOptions.pauseHoldAnims && !canHold){
					boyfriend.playAnim(anim,true);
				}
		}

		//}
		updateAccuracy();
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

				if(SONG.player2 == 'angry-omega'){
					var damage = FlxMath.lerp(0,1.25,health/2);

					if(damage<.5)
						damage=.5;

					health-=damage;
				}else if(SONG.song.toLowerCase()=='curse-eternal'){
					health-=.05;
				}else{
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
			goldOverlayTween = FlxTween.tween(goldOverlay, {alpha: 0}, .25);
		}
		var strumLine = playerStrumLines.members[note.noteData%4];


		if(luaModchartExists && lua!=null){
			lua.call("goodNoteHit",[note.noteData,note.strumTime,Conductor.songPosition,note.isSustainNote]); // TODO: Note lua class???
		}


		if (note.noteData >= 0)
			health += 0.023;
		else
			health += 0.004;

		previousHealth=health;
		if(luaModchartExists && lua!=null)
			lua.setGlobalVar("health",health);

		//if(!note.isSustainNote){
		var anim = "";
		switch (note.noteData)
		{
		case 0:
			anim='singLEFT';
		case 1:
			anim='singDOWN';
		case 2:
			anim='singUP';
		case 3:
			anim='singRIGHT';
		}

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

	var fastCarCanDrive:Bool = true;

	function resetFastCar():Void
	{
		fastCar.x = -12600;
		fastCar.y = FlxG.random.int(140, 250);
		fastCar.velocity.x = 0;
		fastCarCanDrive = true;
	}

	function fastCarDrive()
	{
		FlxG.sound.play(Paths.soundRandom('carPass', 0, 1), 0.7);

		fastCar.velocity.x = (FlxG.random.int(170, 220) / FlxG.elapsed) * 3;
		fastCarCanDrive = false;
		new FlxTimer().start(2, function(tmr:FlxTimer)
		{
			resetFastCar();
		});
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
		FlxG.sound.play(Paths.soundRandom('thunder_', 1, 2));
		halloweenBG.animation.play('lightning');

		lightningStrikeBeat = curBeat;
		lightningOffset = FlxG.random.int(8, 24);

		boyfriend.playAnim('scared', true);
		gf.playAnim('scared', true);
	}

	override function stepHit()
	{
		super.stepHit();
		if(luaModchartExists && lua!=null){
			lua.setGlobalVar("curStep",curStep);
			lua.call("stepHit",[curStep]);
		}
		if (FlxG.sound.music.time-currentOptions.noteOffset > Conductor.songPosition-currentOptions.noteOffset + 20 || FlxG.sound.music.time-currentOptions.noteOffset < Conductor.songPosition-currentOptions.noteOffset - 20)
		{
			resyncVocals();
		}

		if (dad.curCharacter == 'spooky' && curStep % 4 == 2)
		{
			// dad.dance();
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
				if(luaModchartExists && lua!=null){
					lua.setGlobalVar("bpm",Conductor.bpm);
				}
			}
			// else
			// Conductor.changeBPM(SONG.bpm);

			// Dad doesnt interupt his own notes
			if (!dad.animation.curAnim.name.startsWith("sing")){
				if(dad.curCharacter=='noke' && curStage=='elevator')
					NokeReconnect();
				dad.dance();
			}

			if (!armyRight.animation.curAnim.name.startsWith("sing"))
			{
				armyRight.dance();
			}

		}
		// FlxG.log.add('change bpm' + SONG.notes[Std.int(curStep / 16)].changeBPM);
		wiggleShit.update(Conductor.crochet);

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
			boyfriend.playAnim('idle');
		}

		if (curBeat % 8 == 7 && curSong == 'Bopeebo')
		{
			boyfriend.playAnim('hey', true);
		}

		/*if (curBeat % 16 == 15 && SONG.song == 'Tutorial' && dad.curCharacter == 'gf' && curBeat > 16 && curBeat < 48)
		{
			boyfriend.playAnim('hey', true);
			dad.playAnim('cheer', true);
		}*/

		if(luaModchartExists && lua!=null){
			lua.setGlobalVar("curBeat",curBeat);
			lua.call("beatHit",[curBeat]);
		}

		switch (curStage)
		{

			case 'mall':
				upperBoppers.animation.play('bop', true);
				bottomBoppers.animation.play('bop', true);
				santa.animation.play('idle', true);

			case 'limo':
				grpLimoDancers.forEach(function(dancer:BackgroundDancer)
				{
					dancer.dance();
				});

				if (FlxG.random.bool(10) && fastCarCanDrive)
					fastCarDrive();
			case "philly":
				if (!trainMoving)
					trainCooldown += 1;

				if (curBeat % 4 == 0)
				{
					phillyCityLights.forEach(function(light:FlxSprite)
					{
						light.visible = false;
					});

					curLight = FlxG.random.int(0, phillyCityLights.length - 1);

					phillyCityLights.members[curLight].visible = true;
					phillyCityLights.members[curLight].alpha = 1;
					if(currentOptions.picoShaders && lightFadeShader!=null)
						lightFadeShader.setAlpha(0);
				}

				if (curBeat % 8 == 4 && FlxG.random.bool(30) && !trainMoving && trainCooldown > 8)
				{
					trainCooldown = FlxG.random.int(-4, 0);
					trainStart();
				}
		}

		if (isHalloween && FlxG.random.bool(10) && curBeat > lightningStrikeBeat + lightningOffset)
		{
			lightningStrikeShit();
		}
	}

	var curLight:Int = 0;
}
