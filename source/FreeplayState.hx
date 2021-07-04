package;

#if desktop
import Discord.DiscordClient;
#end
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;
import Options;
import flixel.util.FlxTimer;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
using StringTools;

class FreeplayState extends MusicBeatState
{
	var trackedAssets:Array<Dynamic> = [];
	public static var unlockables=['Last-Stand','Curse-Eternal','2v200','After-the-Ashes','Father-Time','Dishonor'];
	public static var unlockableChars = ['angry-omega','mika','army','omega','father','king'];
	var songs:Array<SongMetadata> = [];

	var selector:FlxText;
	var curSelected:Int = 0;
	var curDifficulty:Int = 1;

	var scoreText:FlxText;
	var diffText:FlxText;
	var lerpScore:Int = 0;
	var intendedScore:Int = 0;

	private var grpSongs:FlxTypedGroup<Alphabet>;
	private var curPlaying:Bool = false;

	private var iconArray:Array<HealthIcon> = [];

	override function create()
	{
		persistentDraw=true;
		persistentUpdate=true;
		controls.setKeyboardScheme(Solo,true);
		var initSonglist = CoolUtil.coolTextFile(Paths.txt('freeplaySonglist'));

		for (i in 0...initSonglist.length)
		{
			var data = initSonglist[i].split(" ");
			var icon = data.splice(0,1)[0];
			var week = data.splice(0,1)[0];
			songs.push(new SongMetadata(data.join(" "), Std.parseInt(week), icon));
		}


			if (FlxG.sound.music != null)
			{
				if (!FlxG.sound.music.playing)
					if(PlayState.SONG.song.toLowerCase()=='curse-eternal' && PlayState.isStoryMode){
						FlxG.sound.playMusic(Paths.inst('curse-eternal'));
					}else{
						FlxG.sound.playMusic(Paths.music('freakyMenu'));
					}
			}else{
				if(PlayState.SONG.song.toLowerCase()=='curse-eternal' && PlayState.isStoryMode){
					FlxG.sound.playMusic(Paths.inst('curse-eternal'));
				}else{
					FlxG.sound.playMusic(Paths.music('freakyMenu'));
				}
			}


		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("Freeplay", null);
		#end

		var isDebug:Bool = false;

		#if debug
		isDebug = true;
		#end

		if (StoryMenuState.weekUnlocked[2] || isDebug)
			addWeek(['Bopeebo', 'Fresh', 'Dadbattle'], 1, ['dad']);

		if (StoryMenuState.weekUnlocked[2] || isDebug)
			addWeek(['Spookeez', 'South', 'Salem'], 2, ['spooky','spooky','spooky']);

		if (StoryMenuState.weekUnlocked[3] || isDebug)
			addWeek(['Pico', 'Philly-Nice', 'Blammed'], 3, ['pico']);

		if (StoryMenuState.weekUnlocked[4] || isDebug)
			addWeek(['Satin-Panties', 'High', 'Milf'], 4, ['mom']);

		if (StoryMenuState.weekUnlocked[5] || isDebug)
			addWeek(['Cocoa', 'Eggnog', 'Winter-Horrorland', 'Monster'], 5, ['parents-christmas', 'parents-christmas', 'monster-christmas', 'monster-christmas']);

		if (StoryMenuState.weekUnlocked[6] || isDebug)
			addWeek(['Senpai', 'Roses', 'Thorns'], 6, ['senpai', 'senpai', 'spirit']);

		var omegaWeek=['Mercenary','Odd-Job','Guardian'];
		var omegaCharacters=['omega','omega','omega'];
		if(FlxG.save.data.unlockedOmegaSongs==null){
			FlxG.save.data.unlockedOmegaSongs=[];
		}
		if(FlxG.save.data.cameos==null){
			FlxG.save.data.cameos=[];
		}
		var encounteredCameos:Array<String> = FlxG.save.data.cameos;
		var unlockedSongs:Array<String> = FlxG.save.data.unlockedOmegaSongs;

		var cameos = StoryMenuState.cameos;
		var cameoChars = StoryMenuState.cameoCharacters;

		for(i in 0...unlockables.length){
			var song = unlockables[i];
			var char = unlockableChars[i];
			if(unlockedSongs.contains(song.toLowerCase())){
				omegaWeek.push(song);
				omegaCharacters.push(char);
			}
		}

		for(i in 0...cameos.length){
			var cameo = cameos[i];
			var char = cameoChars[i];
			if(encounteredCameos.contains(cameo)){
				omegaWeek.push(cameo);
				omegaCharacters.push(char);
			}
		}

		addWeek(omegaWeek,-1,omegaCharacters);


		// LOAD MUSIC

		// LOAD CHARACTERS

		var portal:FlxSprite = new FlxSprite(0,-80).loadGraphic(Paths.image("spaceshit"));
		portal.antialiasing=true;
		add(portal);

		grpSongs = new FlxTypedGroup<Alphabet>();
		add(grpSongs);

		for (i in 0...songs.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, songs[i].songName.split("-").join(" "), true, false);
			songText.alpha=0;
			songText.wantedA=0;
			songText.isMenuItem = true;
			songText.targetY = i;
			songText.gotoTargetPosition();
			songText.x = -125;
			songText.ID=i;
			grpSongs.add(songText);

			var icon:HealthIcon = new HealthIcon(songs[i].songCharacter);
			icon.sprTracker = songText;

			// using a FlxGroup is too much fuss!
			iconArray.push(icon);
			add(icon);

			// songText.x += 40;
			// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
			// songText.screenCenter(X);
		}
		new FlxTimer().start(.1, function(tmr:FlxTimer){

			grpSongs.forEach( function(song:Alphabet){
				song.isMenuItem = false;
				song.x = -(FlxG.width+song.width);
				song.calculateWantedXY();
				FlxTween.tween(song, {x:song.wantedX,alpha:1}, 0.5, {
					ease: FlxEase.backOut,
					startDelay: 0.05 + (0.05 * song.ID),
					onComplete:function(br){
						song.alpha=1;
						song.wantedA=1;
						song.isMenuItem = true;
					}
				});
			});
		});
		scoreText = new FlxText(FlxG.width * 0.7, 5, 0, "", 32);
		// scoreText.autoSize = false;
		scoreText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT);
		// scoreText.alignment = RIGHT;

		var scoreBG:FlxSprite = new FlxSprite(scoreText.x - 6, 0).makeGraphic(Std.int(FlxG.width * 0.35), 66, 0xFF000000);
		scoreBG.alpha = 0.6;
		add(scoreBG);

		diffText = new FlxText(scoreText.x, scoreText.y + 36, 0, "", 24);
		diffText.font = scoreText.font;
		add(diffText);

		add(scoreText);

		changeSelection();
		changeDiff();

		// FlxG.sound.playMusic(Paths.music('title'), 0);
		// FlxG.sound.music.fadeIn(2, 0, 0.8);
		selector = new FlxText();

		selector.size = 40;
		selector.text = ">";

		var swag:Alphabet = new Alphabet(1, 0, "swag");

		super.create();
	}

	public function addSong(songName:String, weekNum:Int, songCharacter:String)
	{
		songs.push(new SongMetadata(songName, weekNum, songCharacter));
	}

	public function addWeek(songs:Array<String>, weekNum:Int, ?songCharacters:Array<String>)
	{
		if (songCharacters == null)
			songCharacters = ['bf'];

		var num:Int = 0;
		for (song in songs)
		{
			addSong(song, weekNum, songCharacters[num]);

			if (songCharacters.length != 1)
				num++;
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.sound.music.volume < 0.7)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, 0.4));

		if (Math.abs(lerpScore - intendedScore) <= 10)
			lerpScore = intendedScore;

		scoreText.text = "PERSONAL BEST:" + lerpScore;

		var upP = controls.UP_P;
		var downP = controls.DOWN_P;
		var accepted = controls.ACCEPT;

		if (upP)
		{
			changeSelection(-1);
		}
		if (downP)
		{
			changeSelection(1);
		}

		if (controls.LEFT_P)
			changeDiff(-1);
		if (controls.RIGHT_P)
			changeDiff(1);

		if (controls.BACK)
		{
			FlxG.switchState(new MainMenuState());
		}

		if (accepted)
		{
			var poop:String = Highscore.formatSong(songs[curSelected].songName.toLowerCase(), curDifficulty);

			trace(poop);

			PlayState.SONG = Song.loadFromJson(poop, songs[curSelected].songName.toLowerCase());
			PlayState.isStoryMode = false;
			PlayState.storyDifficulty = curDifficulty;

			PlayState.storyWeek = songs[curSelected].week;
			trace('CUR WEEK' + PlayState.storyWeek);
			PlayState.blueballs=0;
			LoadingState.loadAndSwitchState(new PlayState());
		}
	}

	function changeDiff(change:Int = 0)
	{
		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = 3;
		if (curDifficulty > 3)
			curDifficulty = 0;

		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		#end

		switch (curDifficulty)
		{
			case 0:
				diffText.text = "EASY";
			case 1:
				diffText.text = 'NORMAL';
			case 2:
				diffText.text = "HARD";
			case 3:
				diffText.text = "GLITCH";
		}
	}

	function changeSelection(change:Int = 0)
	{
		#if !switch
		//NGio.logEvent('Fresh');
		#end

		// NGio.logEvent('Fresh');
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = songs.length - 1;
		if (curSelected >= songs.length)
			curSelected = 0;

		// selector.y = (70 * curSelected) + 30;

		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		// lerpScore = 0;
		#end

		if(OptionUtils.options.freeplayPreview){
			#if PRELOAD_ALL
			FlxG.sound.playMusic(Paths.inst(songs[curSelected].songName), 0);
			#end
		}

		var bullShit:Int = 0;

		for (i in 0...iconArray.length)
		{
			iconArray[i].alpha = 0.6;
		}

		iconArray[curSelected].alpha = 1;

		for (item in grpSongs.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			item.wantedA = .6;

			if (item.targetY == 0)
			{
				item.alpha = 1;
				item.wantedA = 1;
			}
		}
	}

	function unloadAssets():Void
	{

	}

}

class SongMetadata
{
	public var songName:String = "";
	public var week:Int = 0;
	public var songCharacter:String = "";

	public function new(song:String, week:Int, songCharacter:String)
	{
		this.songName = song;
		this.week = week;
		this.songCharacter = songCharacter;
	}
}
