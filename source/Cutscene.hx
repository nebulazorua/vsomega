package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.addons.text.FlxTypeText;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxSpriteGroup;
import flixel.input.FlxKeyManager;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.math.FlxMath;
import flixel.addons.transition.FlxTransitionableState;
using StringTools;

typedef CutsceneData =
{
    var fadeInto:Bool;
    var text:String;
    var image:String;
    var actions:Array<String>;
}

class Cutscene extends FlxSpriteGroup {
  var image:FlxSprite;
  var cutscene:Array<CutsceneData>=[];
  var currentCutscene:CutsceneData;
  var rawData:Array<String> = [];
  var fader:FlxSprite;
  var canSkip:Bool=true;
  var cutsceneCamera:FlxCamera;
  var ereg = new EReg("\\[(.*?)\\]","ig");
  var dialogueBox:CutsceneDialogueBox;
  var currentLeft = '';
  var skipLeft=false;
  var currentRight = '';

  public var finishThing:Void->Void;
  public function new (data:Array<String>){
    super();
    cutsceneCamera = new FlxCamera();
    FlxG.cameras.reset(cutsceneCamera);
    cameras=[cutsceneCamera];

    image = new FlxSprite();
    image.antialiasing=true;
    add(image);

    dialogueBox = new CutsceneDialogueBox();
    dialogueBox.cameras=[cutsceneCamera];
    add(dialogueBox);

    fader = new FlxSprite(0, 0).makeGraphic(Std.int(FlxG.width * 3), Std.int(FlxG.height * 3), 0xFF000000);
    fader.scrollFactor.set();
    fader.alpha = 0;
    fader.setGraphicSize(Std.int(fader.width*(1+(1-FlxG.camera.zoom))));
    add(fader);

    dialogueBox.leftCallback = function() {
      dialogueBox.unsetDecision();
      resetCutscene(CoolUtil.coolTextFile(Paths.txt(currentLeft)));
    }

    dialogueBox.rightCallback = function() {
      dialogueBox.unsetDecision();
      resetCutscene(CoolUtil.coolTextFile(Paths.txt(currentRight)));
    }

    resetCutscene(data);
  }

  public function resetCutscene(data:Array<String>){
    cutscene=[];
    rawData = data;

    parseData();
    currentCutscene=cutscene[0];
    canSkip=false;
    nextCutscene(true);
  }

  override function update(elapsed:Float){
    var gotoNext = FlxG.keys.justPressed.ENTER;
    if(gotoNext){
      if(dialogueBox.finishedTyping){
        if(canSkip && !dialogueBox.inDecision){
          nextCutscene();
        }else if(canSkip && skipLeft){
          dialogueBox.leftCallback();
        }
      }else
        dialogueBox.skipDialogue();
    }
    super.update(elapsed);
  }

  function endCutscene(?fade:Bool){
    canSkip=false;
    if(fade){
      if(FlxG.sound.music.playing)
        FlxG.sound.music.fadeOut(.25, 0);
      FlxTween.tween(fader, {alpha: 1}, .5, {
        ease: FlxEase.quadInOut,
        onComplete: function(twn:FlxTween)
        {
          finishThing();
        }
      });
    }else{
      if(finishThing!=null) finishThing();
    }
  }

  function nextCutscene(?dontUpdateCurrent=false){
    if(dontUpdateCurrent==false){
      cutscene.shift();
    }
    if(cutscene.length==0){
      endCutscene(true);
    }else{
      if(dontUpdateCurrent==false){
        currentCutscene=cutscene[0];
      }
      var newCutsceneData:Null<Array<String>>=null;
      for(action in currentCutscene.actions){
        if(action.startsWith("gotoscene:")){
          var name = action.replace("gotoscene:","");
          newCutsceneData = CoolUtil.coolTextFile(Paths.txt(name));
          break;
        }
      }
      if(newCutsceneData!=null){
        resetCutscene(newCutsceneData);
        return;
      }

      if(currentCutscene.image!='' && currentCutscene.image!=null){
        if(currentCutscene.fadeInto){
          canSkip=false;
          fader.alpha=0;
          FlxTween.tween(fader, {alpha: 1}, .5, {
            ease: FlxEase.quadInOut,
            onComplete: function(twn:FlxTween)
            {
              updateGraphic();
              FlxTween.tween(fader, {alpha: 0}, .5, {ease: FlxEase.quadInOut,onComplete: function(twn:FlxTween){canSkip=true;} });
            }
          });
        }else{
          updateGraphic();
          canSkip=true;
        }
      }else if(currentCutscene.actions.contains("end")){
        endCutscene(currentCutscene.fadeInto);
      }else{
        updateGraphic();
        canSkip=true;
      }
    }
  }

  function updateGraphic(){
    var dialogueSpeed = .04;
    var hasDecision=false;
    for(action in currentCutscene.actions){
      if(action.startsWith("shake:")){
        var data = action.replace("shake:","").split(",");
        var intensity = Std.parseFloat(data[0])/100;
        var duration = Std.parseFloat(data[1]);
        cutsceneCamera.shake(intensity,duration);
      }else if(action.startsWith("sound:")){
        var name = action.replace("sound:","");
        FlxG.sound.play(Paths.sound(name), 0.6);
      }else if(action.startsWith("dialoguespeed:")){
        dialogueSpeed = Std.parseFloat(action.replace("dialoguespeed:",""));
      }else if(action.startsWith('dialogueshadow:')){
        dialogueBox.setDropTextColor(FlxColor.fromString(action.replace("dialogueshadow:","")));
      }else if(action.startsWith('dialoguesound:')){
        var name = action.replace("dialoguesound:","");
        dialogueBox.setTypeSound(name);
      }else if(action.startsWith('decision:') && !hasDecision){
        hasDecision=true;
        var shit = action.replace("decision:","");
        var decisions = shit.split(",");
        var leftshit = decisions[0].split("|");
        var left = leftshit[0];
        var leftCutscene = leftshit[1];

        var rightshit = decisions[1].split("|");
        var right = rightshit[0];
        var rightCutscene = rightshit[1];

        currentLeft=leftCutscene;
        currentRight=rightCutscene;
        dialogueBox.setDecision(left,right);
      }else if(action.startsWith('changesong:')){
        var data = action.replace("changesong:","").split(",");
        var name = data[0];
        var diff = Std.parseInt(data[1]);
        var week = Std.parseInt(data[2]);

        var poop:String = Highscore.formatSong(name, diff);
  			PlayState.SONG = Song.loadFromJson(poop, name);
        PlayState.storyDifficulty=diff;
  			PlayState.isStoryMode = false;
  			PlayState.storyWeek = week;
      }else if(action.startsWith('setstory:')){
        var names = action.replace("setstory:","").split(",");
        //PlayState.storyPlaylist.push(name);
        var name = names[0];
        var difficulty:String = "";

				if (PlayState.storyDifficulty == 0)
					difficulty = '-easy';

				if (PlayState.storyDifficulty == 2)
					difficulty = '-hard';

        PlayState.SONG = Song.loadFromJson(name + difficulty, name);
        FlxG.sound.music.stop();
        PlayState.storyPlaylist=names;
      }else if(action.startsWith('rightpos:')){
        var data = action.replace("rightpos:","").split(",");
        dialogueBox.rightDecision.x = Std.parseFloat(data[0]);
        dialogueBox.rightDecision.y = Std.parseFloat(data[1]);
      }else if(action.startsWith('leftpos:')){
        var data = action.replace("leftpos:","").split(",");
        dialogueBox.leftDecision.x = Std.parseFloat(data[0]);
        dialogueBox.leftDecision.y = Std.parseFloat(data[1]);
      }else if(action.startsWith('rightbgalpha:')){
        var a = action.replace("rightbgalpha:","");
        dialogueBox.rightDecision.alpha = Std.parseFloat(a);
      }else if(action.startsWith('righttxtalpha:')){
        var a = action.replace("righttxtalpha:","");
        dialogueBox.rightDecisionTxt.alpha = Std.parseFloat(a);
      }else if(action.startsWith('righttxtcolor:')){
        var c = action.replace("righttxtcolor:","");
        dialogueBox.rightDecisionTxt.color = FlxColor.fromString(c);
      }else if(action.startsWith("music:")){
        var name = action.replace("music:","");
        if(FlxG.sound.music!=null && FlxG.sound.music.playing)
          FlxG.sound.music.fadeOut(.25, 0);
        new FlxTimer().start(.25, function(tmr:FlxTimer){
          FlxG.sound.playMusic(Paths.music(name),0);
          FlxG.sound.music.fadeIn(.25, 0, .7);
        });
      }
    }

    skipLeft = currentCutscene.actions.contains("skipleft");

    if(currentCutscene.actions.contains("leftinvis") && dialogueBox.leftDecision.visible)
      dialogueBox.leftDecision.visible=false;

    if(currentCutscene.actions.contains("rightinvis") && dialogueBox.rightDecision.visible)
      dialogueBox.rightDecision.visible=false;

    if(currentCutscene.image!='' && currentCutscene.image!=null){
      image.loadGraphic(Paths.image("cutscenes/" + currentCutscene.image) );
      image.updateHitbox();
      image.setGraphicSize(FlxG.width,FlxG.height);
      image.updateHitbox();
      image.screenCenter(XY);
    }
    if(currentCutscene.text.replace(' ','')==''){
      dialogueBox.visible=false;
      dialogueBox.setText("",dialogueSpeed);
    }else{
      dialogueBox.visible=true;
      dialogueBox.setText(currentCutscene.text,dialogueSpeed);
    }

    if(hasDecision==false)
      dialogueBox.unsetDecision();
    else
      dialogueBox.visible=true;
  }

  function parseData(){
    for(i in 0...rawData.length){
      var dat = rawData[i];
      var actions:Array<String>=[];
      var text:String='';
      if(ereg.match(dat)){
        var input = dat;
        while (ereg.match(input)) {
          var act = ereg.matched(1);
          actions.push(act);
          input = ereg.matchedRight();
        }
        text=input;
      }else{
        text=dat;
      }
      var gotoImage='';
      var fade=true;
      var toRemove=[];
      for(action in actions){
        if(action.startsWith("goto:")){
          gotoImage=action.replace("goto:","");
          toRemove.push(action);
        }else{
          switch(action){
            case 'nofade':
              toRemove.push(action);
              fade=false;
          }
        }
      }
      for(i in toRemove) actions.remove(i);

      var cutsceneData:CutsceneData = {
        fadeInto: fade,
        text: text,
        image: gotoImage,
        actions: actions,
      }
      cutscene.push(cutsceneData);
    }
  }
}
