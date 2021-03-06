package;

import Controls;
import Controls.Control;
import Controls.KeyboardScheme;
import flixel.input.keyboard.FlxKey;
import OptionCategory;
import Sys.sleep;
import flixel.FlxG;
import flash.events.KeyboardEvent;
import flixel.util.FlxSave;
import flixel.FlxState;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
class OptionUtils
{
	private static var saveFile:FlxSave = new FlxSave();

	public static var ratingWindowNames:Array<String>=[
		"Vanilla",
		"ITG",
		"Quaver",
		"Judge Four",
	];
	public static var ratingWindowTypes:Array<Array<Float>> = [ // TODO: make these all properly scale w/ the safeZoneOffset n shit
		[ // Vanilla
			18, // epic
			32, // sick
			123, // good
			148, // bad
			166, // shit
		],
		[ // ITG
			21.5, // epic
			43, // sick
			102, // good
			135, // bad
			180,
		],
		[ // Quaver
			18, // epic
			43, // sick
			76, // good
			127, // bad
			164,
		],
		[ // Judge 4
			22.5, // epic
			45, // sick
			90, // good
			135, // bad
			180, // shit
		]
	];
	public static var shit:Array<FlxKey> = [
		ALT,
		BACKSPACE,
		SHIFT,
		TAB,
		CAPSLOCK,
		CONTROL,
		ENTER
	];
	public static var options:Options = new Options();

	public static function bindSave(?saveName:String="nebbyEngineBeta"){
		saveFile.bind(saveName);
	};
	public static function saveOptions(options:Options){
		var fields = Reflect.fields(options);
		for(f in fields){
			var shit = Reflect.field(options,f);
			Reflect.setField(saveFile.data,f,shit);
		}
		saveFile.flush();
	};
	public static function loadOptions(options:Options){
		var fields = Reflect.fields(saveFile.data);
		for(f in fields){
			if(Reflect.getProperty(options,f)!=null)
				Reflect.setField(options,f,Reflect.field(saveFile.data,f));
		}
	}

	public static function get6KIdx(control:Control){
		var idx = 0;
		switch (control){
			case Control.LEFT:
				idx = 0;
			case Control.DOWN:
				idx = 1;
			case Control.RIGHT:
				idx = 2;
			case Control.LEFT2:
				idx = 3;
			case Control.UP:
				idx = 4;
			case Control.RIGHT2:
				idx = 5;
			case Control.RESET:
				idx = 6;
			default:
		}
		return idx;
	}

	public static function getKIdx(control:Control){
		var idx = 0;
		switch (control){
			case Control.LEFT:
				idx = 0;
			case Control.DOWN:
				idx = 1;
			case Control.UP:
				idx = 2;
			case Control.RIGHT:
				idx = 3;
			case Control.RESET:
				idx = 4;
			default:
		}
		return idx;
	}

	public static function getKey(control:Control){
		return options.controls[getKIdx(control)];
	}

	public static function getsixKey(control:Control){
		return options.controlsSixK[get6KIdx(control)];
	}
}

class Options
{
	public var dishonorShaders:Bool = true;
	public var controls:Array<FlxKey> = [FlxKey.A,FlxKey.S,FlxKey.K,FlxKey.L,FlxKey.R];
	public var controlsSixK:Array<FlxKey> = [FlxKey.A,FlxKey.S,FlxKey.D,FlxKey.J,FlxKey.K,FlxKey.L,FlxKey.R];
	public var ghosttapping:Bool = true;
	public var failForMissing:Bool = false;
	public var loadModcharts:Bool = true;
	public var pauseHoldAnims:Bool = true;
	public var botPlay:Bool = false;
	
	public var dummy:Bool = false;
	public var dummyInt:Int = 0;
	public var ratingWindow:Int = 0;
	public var showMS:Bool = false;
	public var ratingInHUD:Bool = false;
	public var noteOffset:Int = 0;
	public var downScroll:Bool = false;
	public var middleScroll:Bool = false;
	public var menuFlash:Bool = true;

	public var picoShaders:Bool = true;
	public var picoCamshake:Bool = true;
	public var senpaiShaders:Bool = true;

	public var freeplayPreview:Bool = true;
	public var hitSound:Bool = false;

	public function loadOptions(){

		OptionUtils.loadOptions(this);
	}

	public function clone(){
		var optionClone = new Options();
		for(f in Reflect.fields(this)){
			Reflect.setField(optionClone,f,Reflect.field(this,f));
		}
		return optionClone;
	}

	public function saveOptions(){
		OptionUtils.saveOptions(this);
	}

	public function new(){
	}
}

class CutsceneOption extends Option
{
	private var cutscenePath:String;
	public function new(name:String,path:String){
		super();
		cutscenePath=path;
		this.name=name;
	}
	public override function accept(){
		FlxG.sound.music.fadeOut(.25, 0);
		FlxG.switchState(new CutsceneState(CoolUtil.coolTextFile(Paths.txt(cutscenePath)),new OptionsMenu()));
		return false;
	}
}

class WipeOption extends Option
{
	private var areYOUSURE:Bool=false;

	public function new(){
		super();
		this.name="Wipe save data";
	}
	public override function accept(){
		if(areYOUSURE==false){
			areYOUSURE=true;
			name="Are you sure?";
		}else{
			FlxG.save.erase();

			FlxG.resetGame();
		}
		return true;
	}
}

class StateOption extends Option
{
	private var state:FlxState;
	public function new(name:String,state:FlxState){
		super();
		this.state=state;
		this.name=name;
	}
	public override function accept(){
		FlxG.switchState(state);
		return false;
	}
}

class OptionCheckbox extends FlxSprite
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
		offset.x = 0;
		offset.y = 0;
	}
}

class ToggleOption extends Option
{
	private var property = "dummy";
	private var checkbox:OptionCheckbox;
	public function new(property:String,?name:String){
		super();
		this.property = property;
		this.name = name;
		checkbox = new OptionCheckbox(Reflect.field(OptionUtils.options,property));
		add(checkbox);
	}

	public override function createOptionText(curSelected:Int,optionText:FlxTypedGroup<Option>):Dynamic{
    remove(text);
    text = new Alphabet(0, (70 * curSelected) + 30, name, true, false);
    text.movementType = "list";
    text.isMenuItem = true;
		text.offsetX = 165;
		text.gotoTargetPosition();
		checkbox.tracker = text;
    add(text);
    return text;
  }

	public override function accept():Bool{
		Reflect.setField(OptionUtils.options,property,!Reflect.field(OptionUtils.options,property));
		checkbox.changeState(Reflect.field(OptionUtils.options,property));

		return false;
	}
}

class ScrollOption extends Option
{
	private var names:Array<String>;
	private var property = "dummyInt";
	private var max:Int = -1;
	private var min:Int = 0;

	private var leftArrow:FlxSprite;
	private var rightArrow:FlxSprite;
	public function new(property:String,?min:Int=0,?max:Int=-1,?names:Array<String>){
		super();
		this.property=property;
		this.names=names;
		var value = Reflect.field(OptionUtils.options,property);
		leftArrow = new FlxSprite(0,0);
		leftArrow.frames = Paths.getSparrowAtlas("arrows");
		leftArrow.setGraphicSize(Std.int(leftArrow.width*.7));
		leftArrow.updateHitbox();
		leftArrow.animation.addByPrefix("pressed","arrow push left",24,false);
		leftArrow.animation.addByPrefix("static","arrow left",24,false);
		leftArrow.animation.play("static");

		rightArrow = new FlxSprite(0,0);
		rightArrow.frames = Paths.getSparrowAtlas("arrows");
		rightArrow.setGraphicSize(Std.int(rightArrow.width*.7));
		rightArrow.updateHitbox();
		rightArrow.animation.addByPrefix("pressed","arrow push right",24,false);
		rightArrow.animation.addByPrefix("static","arrow right",24,false);
		rightArrow.animation.play("static");

		add(rightArrow);
		add(leftArrow);
		this.max=max;
		this.min=min;
		if(names!=null){
			name = names[value];
		}else{
			name = Std.string(value);
		}
	};

	override function update(elapsed:Float){
		super.update(elapsed);
		//sprTracker.x + sprTracker.width + 10
		if(PlayerSettings.player1.controls.LEFT){
			leftArrow.animation.play("pressed");
			leftArrow.offset.x = 0;
			leftArrow.offset.y = -3;
		}else{
			leftArrow.animation.play("static");
			leftArrow.offset.x = 0;
			leftArrow.offset.y = 0;
		}

		if(PlayerSettings.player1.controls.RIGHT){
			rightArrow.animation.play("pressed");
			rightArrow.offset.x = 0;
			rightArrow.offset.y = -3;
		}else{
			rightArrow.animation.play("static");
			rightArrow.offset.x = 0;
			rightArrow.offset.y = 0;
		}
		rightArrow.x = text.x+text.width+10;
		leftArrow.x = text.x-60;
		leftArrow.y = text.y-10;
		rightArrow.y = text.y-10;
	}

	public override function createOptionText(curSelected:Int,optionText:FlxTypedGroup<Option>):Dynamic{
    remove(text);
    text = new Alphabet(0, (70 * curSelected) + 30, name, true, false);
    text.movementType = "list";
    text.isMenuItem = true;
		text.offsetX = 135;
		text.gotoTargetPosition();
    add(text);
    return text;
  }

	public override function left():Bool{
		var value:Int = Std.int(Reflect.field(OptionUtils.options,property)-1);

		if(value<min)
			value=max;

		if(value>max)
			value=min;

		Reflect.setField(OptionUtils.options,property,value);

		if(names!=null){
			name = names[value];
		}else{
			name = Std.string(value);
		}
		return true;
	};
	public override function right():Bool{
		var value:Int = Std.int(Reflect.field(OptionUtils.options,property)+1);

		if(value<min)
			value=max;
		if(value>max)
			value=min;

		Reflect.setField(OptionUtils.options,property,value);

		if(names!=null){
			name = names[value];
		}else{
			name = Std.string(value);
		}
		return true;
	};
}

class CountOption extends Option
{
	private var prefix:String='';
	private var suffix:String='';
	private var property = "dummyInt";
	private var max:Int = -1;
	private var min:Int = 0;
	public function new(property:String,?min:Int=0,?max:Int=-1,?prefix:String='',?suffix:String=''){
		super();
		this.property=property;
		this.min=min;
		this.max=max;
		var value = Reflect.field(OptionUtils.options,property);
		this.prefix=prefix;
		this.suffix=suffix;

		name = prefix + " " + Std.string(value) + " " + suffix;
	};

	public override function left():Bool{
		var value:Int = Std.int(Reflect.field(OptionUtils.options,property)-1);

		if(value<min)
			value=max;
		if(value>max)
			value=min;

		Reflect.setField(OptionUtils.options,property,value);
		name = prefix + " " + Std.string(value) + " " + suffix;
		return true;
	};
	public override function right():Bool{
		var value:Int = Std.int(Reflect.field(OptionUtils.options,property)+1);



		if(value<min)
			value=max;
		if(value>max)
			value=min;

		Reflect.setField(OptionUtils.options,property,value);

		name = prefix + " " + Std.string(value) + " " + suffix;
		return true;
	};
}

class ControlOption extends Option
{
	private var controlType:Control = Control.UP;
	private var controls:Controls;
	private var key:FlxKey;
	public var forceUpdate=false;
	public var sixK=false;
	public function new(controls:Controls,controlType:Control,sixK:Bool){
		super();
		this.controlType=controlType;
		this.controls=controls;
		this.sixK=sixK;

		if(sixK){
			key=OptionUtils.getsixKey(controlType);
			name='${controlType} : ${OptionUtils.getsixKey(controlType).toString()}';
		}else{
			key=OptionUtils.getKey(controlType);
			name='${controlType} : ${OptionUtils.getKey(controlType).toString()}';
		}

	};

	public override function keyPressed(pressed:FlxKey){
		//FlxKey.fromString(String.fromCharCode(event.charCode));
		for(k in OptionUtils.shit){
			if(pressed==k){
				pressed=-1;
				break;
			};
		};
		if(pressed!=ESCAPE){
			if(sixK)
				OptionUtils.options.controlsSixK[OptionUtils.get6KIdx(controlType)]=pressed;
			else
				OptionUtils.options.controls[OptionUtils.getKIdx(controlType)]=pressed;


			key=pressed;

		}
		if(sixK)
			name='${controlType} : ${OptionUtils.getsixKey(controlType).toString()}';
		else
			name='${controlType} : ${OptionUtils.getKey(controlType).toString()}';
		if(pressed!=-1){
			trace("epic style " + pressed.toString() );
			controls.setKeyboardScheme(Solo,true);
			allowMultiKeyInput=false;
			return true;
		}
		return true;
	}

	public override function createOptionText(curSelected:Int,optionText:FlxTypedGroup<Option>):Dynamic{
    remove(text);
    text = new Alphabet(0, (70 * curSelected) + 30, name, false, false);
    text.movementType = "list";
		text.offsetX = 70;
    text.isMenuItem = true;
		text.gotoTargetPosition();
    add(text);
    return text;
  }

	public override function accept():Bool{
		controls.setKeyboardScheme(None,true);
		allowMultiKeyInput=true;
		//FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		name = "<Press any key to rebind>";
		return true;
	};
}
