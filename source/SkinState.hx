package;
#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import io.newgrounds.NG;
import lime.app.Application;
import haxe.Exception;
using StringTools;
import flixel.util.FlxTimer;
import Options;


class SkinState extends MusicBeatState {
  public static var selectedSkin = 'bf';
  public static var skins = ["bf","naikaze","mikeeey","tgr","erderi","babyvase","bfside","bf-neb"];
  public static var skinNames = ["Boyfriend.XML","Naikaze","Mikeeey","TheGhostReaper","Erderi the Fox","Fun-sized Vase","Fun-sized Brightside","Nebby"];
  public static var skinDescs = ["Funky lil' man","Literal god","Mikey with 3 e's","idk","furry","Don't you throw stones in glass houses","Brigthbsied my beloved","Stupid Cocksleeve Zorua"];
  public var unlockedSkins:Array<String> = [];
  public var unlockedNames:Array<String> = [];
  public var unlockedDescs:Array<String> = [];
  public var characters:Array<Character> = [];
  public var selectedIdx:Int = 0;

  var nameText:FlxText;
  var descText:FlxText;

  var leftArrow:FlxSprite;
  var rightArrow:FlxSprite;

  var selectedTimer:Float = 0;
  var lastAnimTimer:Float = 0;

  override function create(){
    selectedSkin = FlxG.save.data.selectedSkin;
    for(idx in 0...skins.length){
      unlockedSkins.push(skins[idx]);
      unlockedNames.push(skinNames[idx]);
      unlockedDescs.push(skinDescs[idx]);
    }
    selectedIdx = unlockedSkins.indexOf(selectedSkin);
    if(selectedIdx==-1){
      selectedIdx=0;
      selectedSkin='bf';
    }
    var bg = new FlxSprite().loadGraphic(Paths.image("equipBG"));
    bg.antialiasing=true;
    bg.updateHitbox();
    bg.screenCenter(XY);
    add(bg);
    for(skin in unlockedSkins){
      var char = new Character(0,300,skin,true);
      char.screenCenter(X);
      char.visible=false;
      add(char);
      switch(skin){
        case 'bf-neb':
          char.y -= 75;
        case 'naikaze':
          char.y -= 90;
        case 'bfside':
          char.y -= 120;
        case 'babyvase':
          char.y -= 110;
      }
      characters.push(char);
    }

    selectedIdx = unlockedSkins.indexOf(selectedSkin);
    var ui_tex = Paths.getSparrowAtlas('campaign_menu_UI_assets');

    nameText = new FlxText(10, 10, 0, "Boyfriend.XML", 32);
		nameText.setFormat("VCR OSD Mono", 36, FlxColor.WHITE, CENTER, SHADOW,FlxColor.BLACK);
		nameText.shadowOffset.set(2,2);
		nameText.screenCenter(XY);
		nameText.y -= 200;

    descText = new FlxText(10, 10, 0, "Funky lil' man", 32);
		descText.setFormat("VCR OSD Mono", 36, FlxColor.WHITE, CENTER, SHADOW,FlxColor.BLACK);
		descText.shadowOffset.set(2,2);
		descText.screenCenter(XY);
		descText.y -= 150;

    add(descText);
    add(nameText);
    leftArrow = new FlxSprite(0,300);
    leftArrow.screenCenter(X);
    leftArrow.x -= 350;
    leftArrow.y += 125;
    leftArrow.antialiasing=true;
    leftArrow.frames = ui_tex;
    leftArrow.animation.addByPrefix('idle', "arrow left");
    leftArrow.animation.addByPrefix('press', "arrow push left");
    leftArrow.animation.play('idle');
    leftArrow.scale.x = 1.2;
    leftArrow.scale.y = 1.2;
    add(leftArrow);

    rightArrow = new FlxSprite(0, leftArrow.y);
    rightArrow.screenCenter(X);
    rightArrow.x += 250;
    rightArrow.frames = ui_tex;
    rightArrow.antialiasing=true;
    rightArrow.animation.addByPrefix('idle', 'arrow right');
    rightArrow.animation.addByPrefix('press', "arrow push right", 24, false);
    rightArrow.animation.play('idle');
    rightArrow.scale.x = 1.2;
    rightArrow.scale.y = 1.2;
    add(rightArrow);

    Conductor.changeBPM(102);
    Conductor.songPosition = FlxG.sound.music.time;
    super.create();
  }

  override function beatHit(){
    for(char in characters){
      if(!char.animation.name.startsWith("sing") && char.animation.curAnim.name!="hey" || char.animation.curAnim.name=="hey" && char.animation.curAnim.finished ){
        char.dance();
      }
    }
  }

  var animIdx=0;
  var anims = ["singUP","singRIGHT","singDOWN","singLEFT"];

  public function changeSelection(change:Int){
    selectedIdx+=change;
    if(selectedIdx<0)
			selectedIdx=unlockedSkins.length-1;
		if(selectedIdx>=unlockedSkins.length)
			selectedIdx=0;

    selectedTimer=0;
  }


  override function update(elapsed:Float){
    FlxG.camera.zoom = .7;
    selectedTimer+=elapsed;
    if(selectedTimer>=3){
      lastAnimTimer+=elapsed;
      if(lastAnimTimer>=.5){
        lastAnimTimer=0;
        if(animIdx>=anims.length){
          animIdx=0;
          characters[selectedIdx].playAnim("idle",true);
          selectedTimer=0;
        }else{
          characters[selectedIdx].playAnim(anims[animIdx],true);
          animIdx++;
        }
      }
    }

    for(idx in 0...characters.length){
      var c = characters[idx];
      if(idx==selectedIdx)
        c.visible=true;
      else
        c.visible=false;
    }

    nameText.text = unlockedNames[selectedIdx];
    descText.text = unlockedDescs[selectedIdx];

    descText.screenCenter(XY);
		descText.y -= 300;
    nameText.screenCenter(XY);
		nameText.y -= 350;


    Conductor.songPosition = FlxG.sound.music.time;
    if (controls.BACK)
    {
      FlxG.sound.play(Paths.sound('cancelMenu'));
      FlxG.switchState(new MainMenuState());
    }

    if(controls.LEFT){
      leftArrow.animation.play("press");
    }else{
      leftArrow.animation.play("idle");
    }

    if(controls.RIGHT){
      rightArrow.animation.play("press");
    }else{
      rightArrow.animation.play("idle");
    }

    if(controls.ACCEPT && selectedSkin!=unlockedSkins[selectedIdx]){
      selectedTimer=0;
      selectedSkin = unlockedSkins[selectedIdx];
      FlxG.save.data.selectedSkin = selectedSkin;
      FlxG.sound.play(Paths.sound('confirmMenu'));
      characters[selectedIdx].playAnim("hey",true);
    }

    if (controls.RIGHT_P)
      changeSelection(1);
    if (controls.LEFT_P)
      changeSelection(-1);

    super.update(elapsed);
  }
}
