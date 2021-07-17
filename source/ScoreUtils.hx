package;
import flixel.math.FlxMath;
import Options;
class ScoreUtils
{
	public static var gradeArray:Array<String> = ["☆☆☆☆","☆☆☆","☆☆","☆","S+","S","S-","A+","A","A-","B+","B","B-","C+","C","C-","D"];
	public static var ghostTapping:Bool=false;
	public static var botPlay:Bool=false;
	public static var ratingStrings = [
		"epic",
		"sick",
		"good",
		"bad",
		"shit",
	];
	public static var ratingWindows = OptionUtils.ratingWindowTypes[OptionUtils.options.ratingWindow];
	public static function GetAccuracyConditions(): Array<Float>{
		return [
      1.0, // Quad star
      .99, // Trip star
      .98, // Doub star
      .96, // Single star
      .94, // S+
      .92, // S
      .89, // S-
      .86, // A+
      .83, // A
      .8, // A-
      .76, // B+
      .72, // B
      .68, // B-
      .64, // C+
      .6, // C
      .55, // C-
    ];
	}
	public static function AccuracyToGrade(accuracy:Float):String {
    var grade = gradeArray[gradeArray.length-1];
    var accuracyConditions:Array<Float>=GetAccuracyConditions();
    for(i in 0...accuracyConditions.length){
      if(accuracy >= accuracyConditions[i]){
        grade = gradeArray[i];
        break;
      }
    }

    return grade;
  }
	public static function DetermineRating(noteDiff:Float){
		var noteDiff = Math.abs(noteDiff);
		for(idx in 0...ratingWindows.length){
			var timing = ratingWindows[idx];
			var string = ratingStrings[idx];
			if(noteDiff<=timing){
				return string;
			}
		}
		return "shit";
	}

	public static function RatingToHit(rating:String):Float{ // TODO: toggleable ms-based system
		var hit:Float = 0;
		switch (rating){
			case 'shit':
				hit = .1;
			case 'bad':
				hit = .5;
			case 'good':
				hit = .8;
			case 'sick':
				hit = .95;
			case 'epic':
				hit = 1;
		}
		return hit;
	}
	public static function RatingToScore(rating:String):Int{
		var score = 0;
		switch (rating){
			case 'shit':
				score = 0;
			case 'bad':
				score = 20;
			case 'good':
				score = 100;
			case 'sick':
				score = 350;
			case 'epic':
				score = 500;
		}
		if(!ghostTapping)
			score=Std.int(score*1.05);

		if(ItemState.equipped.contains("flippy"))
			score=Std.int(score*1.1);

		return score;
	}
}
