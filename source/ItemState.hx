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

class Checkbox extends FlxSprite
{
	public var state:Bool=false;
	public var tracker:FlxSprite;
	public function new(state:Bool){
		super();
		this.state=state;
		frames = Paths.getSparrowAtlas("checkbox");
		updateHitbox();
		animation.addByIndices("unselected","confirm",[0],"",36,false);
		animation.addByPrefix("selecting","confirm",36,false);
		var reversedindices = [];
		var max = animation.getByName("selecting").frames.copy();
		max.reverse();
		for(i in max){
			reversedindices.push(i-2);
		}
		animation.addByIndices("unselecting","confirm",reversedindices,"",36,false);
		animation.addByIndices("selected","confirm",[animation.getByName("selecting").frames.length-2],"",36,false);
		antialiasing=true;
		setGraphicSize(Std.int(width*.6) );
		updateHitbox();
		if(state)
			animation.play("selected");
		else
			animation.play("unselected");

	}

	public function changeState(state:Bool){
		this.state=state;
		if(state){
			animation.play("selecting",true,false,animation.curAnim.name=='unselecting'?animation.curAnim.frames.length-animation.curAnim.curFrame:0);
		}else{
			animation.play("unselecting",true,false,animation.curAnim.name=='selecting'?animation.curAnim.frames.length-animation.curAnim.curFrame:0);
		}
	}

	override function update(elapsed:Float){
		super.update(elapsed);
		if(tracker!=null){
			x = tracker.x - 140;
			y = tracker.y - 45;
		}
		if(animation.curAnim!=null){

			if(animation.curAnim.finished && (animation.curAnim.name=="selecting" || animation.curAnim.name=="unselecting")){
				if(state){
					trace("SELECTED");
					animation.play("selected",true);
				}else{
					trace("UNSELECTED");
					animation.play("unselected",true);
				}
			}
		}
	}
}

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

  override function update(elapsed:Float){
    super.update(elapsed);

  }
}

class ItemState extends MusicBeatState
{
  public static var items = ["sword","arrow","twat","depressed","drunk","flippy"];
  public static var itemNames = ["Omega's Sword","Resistance","Flashy","Cold Heart","Drunk Notes","Flippy Mode"];
	public static var itemFlavour:Map<String,String> = [
		"sword" =>  "You're pretty sure it's a replica, but it's close enough.",
		"arrow" => "You're taking 'what doesn't kill you makes you stronger' way too literally.",
		"twat" => "Your strive for perfection has left you unable to accept anything else. Don't slip up.",
		"depressed" => "You monster.",
		"flippy" => "Feelin' lucky, are ya? ESPECIALLY Don't slip up.",
		"drunk" => "I'm nto drnuk, you a-are!"
	];
	public static var itemDescs:Map<String,String> = [
		"sword" =>  "You gain 50% more health when hitting notes.",
		"arrow" => "You get revived with 50% HP the first time you die, and you take 50% less \"physical\" damage",
		"twat" => "When you get below 90% accuracy, you die.",
		"depressed" => "Missing deals 50% less damage.",
		"flippy" => "You take damage when getting goods, and die on a bad, shit or miss.",
		"drunk" => "Every song has a modchart akin to You Are a Fool's"
	];

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

		"" => "Naked",
  ];
  public static var comboDescs:Map<String,String> = [
    "sword" =>  "You're pretty sure it's a replica, but it's close enough.",
    "arrow" => "You're taking 'what doesn't kill you makes you stronger' way too literally.",
    "twat" => "Your strive for perfection has left you unable to accept anything else. Don't slip up.",
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

		"" => "No items!",
  ];

  public var unlockedItems = [];
  public var unlockedItemNames = [];

	var comboNameTxt:FlxText;
	var comboDescTxt:FlxText;
	var itemDescTxt:FlxText;
	var itemFlavTxt:FlxText;
  public static var equipped = [];
  var void1:FlxSprite;
  var void2:FlxSprite;
  var bfRock:FlxSprite;
  var texts:FlxTypedGroup<ItemChoice>;
  var selectionArrow:FlxSprite;
  var selectedIdx:Int = 0;
  var layerBullshit:FlxTypedGroup<Character>;
  var bf:Character;
  override function create(){
		equipped = FlxG.save.data.equipped;
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

    bfRock = new FlxSprite(350, 400).loadGraphic(Paths.image('smallrockItemStage'));
    bfRock.setGraphicSize(Std.int(bfRock.width*.6));
    bfRock.updateHitbox();
    bfRock.antialiasing = true;
    bfRock.scrollFactor.set(1, 1);
    bfRock.active = false;
    add(bfRock);

    var box = new FlxSprite().loadGraphic(Paths.image("WOODEN_BOX"));
    box.antialiasing=true;
    box.updateHitbox();
    box.screenCenter(XY);
    add(box);

    texts = new FlxTypedGroup<ItemChoice>();
    add(texts);

    layerBullshit = new FlxTypedGroup<Character>();
    add(layerBullshit);

		comboNameTxt = new FlxText(650, 50, 600, "Naked", 32);
		comboNameTxt.setFormat("VCR OSD Mono", 36, FlxColor.WHITE, CENTER, SHADOW,FlxColor.BLACK);
		comboNameTxt.shadowOffset.set(2,2);

		comboDescTxt = new FlxText(650, 85, 600, "No items!", 32);
		comboDescTxt.setFormat("VCR OSD Mono", 28, FlxColor.WHITE, CENTER, SHADOW,FlxColor.BLACK);
		comboDescTxt.shadowOffset.set(2,2);

		itemDescTxt = new FlxText(650, 600, 725, "Omega's Sword", 32);
		itemDescTxt.setFormat("VCR OSD Mono", 22, FlxColor.WHITE, CENTER, SHADOW,FlxColor.BLACK);
		itemDescTxt.shadowOffset.set(2,2);

		itemFlavTxt = new FlxText(650, 650, 725, "Cum", 32);
		itemFlavTxt.setFormat("VCR OSD Mono", 26, FlxColor.WHITE, CENTER, SHADOW,FlxColor.BLACK);
		itemFlavTxt.shadowOffset.set(2,2);

		add(comboNameTxt);
		add(comboDescTxt);
		add(itemFlavTxt);
		add(itemDescTxt);

		var conditions = [
      FlxG.save.data.omegaGoodEnding,
      FlxG.save.data.getResistance,
      FlxG.save.data.beATwat,
      FlxG.save.data.omegaBadEnding,
      FlxG.save.data.drunk,
			true
    ];

    for(cum in 0...items.length){
      var name = itemNames[cum];
      var fard:ItemChoice;
      if(conditions[cum]==true){
        fard = new ItemChoice(items[cum],name,equipped.contains(items[cum]));
      }else{
        fard = new ItemChoice("none","???",false);
      }
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

    displayCharacter();

    super.create();
  }

  function displayCharacter(){
		var frame = 0;
		if(bf!=null){
			if(bf.animation.curAnim!=null)
				frame = bf.animation.curAnim.curFrame;
		}

    if(bf!=null){
      layerBullshit.remove(bf);
			bf.destroy();
		}

    var name = '';
    if(equipped.length>0){
      var shit = ["sword","arrow","twat","depressed"];
      for(cum in shit){
        if(equipped.contains(cum)){
          name+=cum;
        }
      }
    }

		comboNameTxt.text = comboNames.get(name);
		comboDescTxt.text = comboDescs.get(name);

    if(name=='')name='bf';

    bf = new Character(750,200,name);
    bf.flipX=!bf.flipX;

    layerBullshit.add(bf);
  }



  public function changeSelection(change:Int){
    selectedIdx+=change;
    if(selectedIdx<0)
			selectedIdx=items.length-1;
		if(selectedIdx>=items.length)
			selectedIdx=0;
    }

  override function beatHit(){
    bf.dance();
    super.beatHit();
  }

  var timer:Float = 0;

  override function update(elapsed:Float){
    timer += elapsed;
    bfRock.y = 0-25*Math.cos(timer*1.25);
    bf.y = 200-25*Math.cos(timer*1.25);

    Conductor.songPosition = FlxG.sound.music.time;

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
        displayCharacter();
				FlxG.save.data.equipped=equipped;
      }
    }
		comboNameTxt.x = 650;
		comboNameTxt.y = 50;

		comboDescTxt.x = 650;
		comboDescTxt.y = 80;
		var item = texts.members[selectedIdx];
		if(item.name!='none'){
			itemDescTxt.visible=true;
			itemFlavTxt.visible=true;

			itemDescTxt.text=itemDescs.get(item.name);
			itemFlavTxt.text='"${itemFlavour.get(item.name)}"';
		}else{
			itemDescTxt.visible=false;
			itemFlavTxt.visible=false;
		}
		itemDescTxt.x = 475;
		itemDescTxt.y = 650;

		itemFlavTxt.x = 475;
		itemFlavTxt.y = 600;

    selectionArrow.y = FlxMath.lerp(selectionArrow.y,texts.members[selectedIdx].y - 32,.2);

    super.update(elapsed);
  }
}
