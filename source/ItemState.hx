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
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;

class ItemChoice extends FlxSpriteGroup
{
  public var name:String = '';
  public var itemText:FlxText;
  public var checkbox:Checkbox;
  public var toggled:Bool = false;

  public function new(internalName:String,display:String,state:Bool){
    super();
    toggled=state;
    name=internalName;

    itemText = new FlxText(150, 0, 430, display, 32);
    itemText.setFormat("VCR OSD Mono", 36, FlxColor.WHITE, LEFT, SHADOW,FlxColor.BLACK);
    itemText.shadowOffset.set(2,2);
    add(itemText);


    checkbox = new Checkbox(state);
    checkbox.offset.x -= 30;
    checkbox.offset.y -= 14;
    checkbox.tracker = itemText;
    checkbox.scale.x = .6;
    checkbox.scale.y = .6;
    if(internalName!='none')
		  add(checkbox);
  }
}

class ItemState extends MusicBeatState
{
  public static var items = ["sword","arrow","twat","depressed"];
  public static var itemNames = ["Omega's Sword","Cold Heart","Resistance","Flashy"];
  public static var comboNames:Map<String,String> = [
    "sword" => "Omega's Sword",
    "arrow" => "Resistance",
    "twat" => "Flashy",
    "depressed" => "Cold Heart",

    "swordarrow" => "Overconfident",
    "swordtwat" => "Novice Swordsman",
    "sworddepressed" => "Denial",

    "swordarrowtwat" => "Battle Scarred",
    "swordarrowdepressed" => "Fakin' it",
    "swordtwatdepressed" => "Lying Through Your Teeth",

    "arrowtwat" => "Dying While Dripping",
    "arrowdepressed" => "Horrible Luck",

    "twatdepressed" => "Depressed But Well Dressed",
    "arrowtwatdepressed" => "Work Through the Pain",

    "swordarrowtwatdepressed" => "Clusterfuck",
  ];
  public static var comboDescs:Map<String,String> = [
    "sword" =>  "Not the real thing, but it's close enough.",
    "arrow" => "You're taking 'what doesn't kill you makes you stronger' way too literally.",
    "twat" => "Looks like someone's feeling lucky. Don't slip up.",
    "depressed" => "You monster.",

    "swordarrow" => "Having that sword must make you feel like a total pimp. Don't slip up.",
    "swordtwat" => "I mean, you've certainly got guts for all that bravado of yours. Make sure you aren't in over your head though.",
    "sworddepressed" => "Using his sword won't undo what you did.",

    "swordarrowtwat"  => "Looks like you might be overdoing it, but that smile on your face tells me you got this.",
    "swordarrowdepressed"  => "Even with all that sword bravado, you're hurting, no doubt.",
    "swordtwatdepressed"  => "You can act like you're okay, you can even use his sword, but it won't bring them back.",

    "arrowtwat"  => "You might be injured, but at least you're stylin'.",
    "arrowdepressed" => "Looks like your physical pain matches your emotional pain.",

    "twatdepressed" => "Hey, at least you're trying to act happy about what you did.",
    "arrowtwatdepressed" => "Smile all you want, you still did what you did, and now you got an arrow through your head.",

    "swordarrowtwatdepressed" => "You just like checking all the boxes, huh?",
  ];

  public var unlockedItems = [];
  public var unlockedItemNames = [];

  public static var equipped = [];
  var void1:FlxSprite;
  var void2:FlxSprite;
  var texts:FlxTypedGroup<ItemChoice>;
  var selectionArrow:FlxSprite;
  var selectedIdx:Int = 0;

  override function create(){


    void1 = new FlxSprite(-600, -500).loadGraphic(Paths.image('BGvoid'));
    void1.antialiasing = true;
    void1.setGraphicSize(Std.int(void1.width*2));
    void1.updateHitbox();
    void1.x = -600;
    void1.scrollFactor.set(0, 0);
    void1.active = false;
    add(void1);

    void2 = new FlxSprite(-600, -500).loadGraphic(Paths.image('BGvoid'));
    void2.antialiasing = true;
    void2.setGraphicSize(Std.int(void2.width*2));
    void2.updateHitbox();
    void2.scrollFactor.set(0, 0);
    void2.active = false;
    void2.x = -(void1.width)-600;
    add(void2);

    var box = new FlxSprite().loadGraphic(Paths.image("WOODEN_BOX"));
    box.antialiasing=true;
    box.updateHitbox();
    box.screenCenter(XY);
    add(box);

    texts = new FlxTypedGroup<ItemChoice>();
    add(texts);

    var conditions = [
      FlxG.save.data.omegaGoodEnding,
      FlxG.save.data.omegaBadEnding,
      FlxG.save.data.getResistance,
      FlxG.save.data.becomeATwat
    ];

    for(cum in 0...items.length){
      var name = itemNames[cum];
      var fard:ItemChoice;
      if(conditions[cum]==true){
        fard = new ItemChoice(items[cum],name,equipped.contains(items[cum]));
      }else{
        fard = new ItemChoice("none","???",false);
      }
      trace("cummmieeess");
      fard.y = 100 + (100*texts.members.length);
      texts.add(fard);
    }

    var ui_tex = Paths.getSparrowAtlas('campaign_menu_UI_assets');
    selectionArrow = new FlxSprite(10, 100);
    selectionArrow.frames = ui_tex;
    selectionArrow.animation.addByPrefix('idle', 'arrow right');
    selectionArrow.animation.play('idle');
    selectionArrow.antialiasing=true;
    selectionArrow.scale.x = .8;
    selectionArrow.scale.y = .8;
    add(selectionArrow);

    super.create();
  }

  public function changeSelection(change:Int){
    selectedIdx+=change;
    if(selectedIdx<0)
			selectedIdx=items.length-1;
		if(selectedIdx>=items.length)
			selectedIdx=0;

  }

  override function update(elapsed:Float){
    var nextXBG = void1.x+(elapsed*64);
    var nextXBG2 = void2.x+(elapsed*64);

    void1.x = nextXBG;
    void2.x = nextXBG2;


    if(nextXBG>=3000){
      void1.x = void2.x-void2.width;
    }

    if(nextXBG2>=3000){
      void2.x = void1.x-void1.width;
    }

    if (controls.BACK)
    {
      FlxG.sound.play(Paths.sound('cancelMenu'));
      FlxG.switchState(new MainMenuState());
    }

    if (controls.UP_P)
      changeSelection(-1);
    if (controls.DOWN_P)
      changeSelection(1);

    if (controls.ACCEPT){
      var item = texts.members[selectedIdx];
      if(item.name!='none'){
        item.toggled = !item.toggled;
        item.checkbox.changeState(item.toggled);
        if(item.toggled && !equipped.contains(item.name)){
          equipped.push(item.name);
        }else if(!item.toggled && equipped.contains(item.name)){
          equipped.remove(item.name);
        }
      }
    }


    selectionArrow.y = FlxMath.lerp(selectionArrow.y,texts.members[selectedIdx].y - 32,.1);

    super.update(elapsed);
  }
}
