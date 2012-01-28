component
{

	base36 function init(){

		// Plugin Properties
		setPluginName("base32");
		setPluginVersion("1.0");
		setPluginDescription("A conversion plugin to Encode or Decode Base36");
		setPluginAuthor("Jeremy R DeYoung");
		setPluginAuthorURL("http://www.lunarfly.com");

		return this;
	}


	public string function encode(required string value){
		var arrCharacters = ListToArray("0 1 2 3 4 5 6 7 8 9 A B C D E F G H I J K L M N O P Q R S T U V W X Y Z"," ");

		return FormatBaseNData(arguments.value,arrCharacters);
	}

	public string function decode(required string value){
		var arrCharacters = ListToArray("0 1 2 3 4 5 6 7 8 9 A B C D E F G H I J K L M N O P Q R S T U V W X Y Z"," ");

		return InputBaseNData(arguments.value,arrCharacters);
	}



	//////////////////////
	/// PRIVATE FUNCTIONS
	//////////////////////
	private string function FormatBaseNData(required numeric value,required array CharacterSet){
		var LOCAL = {};
		LOCAL.EncodedValue = "";
		LOCAL.Radix = ArrayLen( ARGUMENTS.CharacterSet );
		LOCAL.Value = ARGUMENTS.Value;

		do{
			LOCAL.Result = Fix( LOCAL.Value / LOCAL.Radix );
			LOCAL.Remainder = (LOCAL.Value MOD LOCAL.Radix);

			LOCAL.EncodedValue = (
			ARGUMENTS.CharacterSet[ LOCAL.Remainder + 1 ] &
			LOCAL.EncodedValue
			);

			LOCAL.Value = LOCAL.Result;

			if(!LOCAL.Value){
				break;
			}

		}while(1 eq 1);

		return LOCAL.EncodedValue;
	}



	private string function InputBaseNData(required string Value,required array CharacterSet){
		var LOCAL = {};
		LOCAL.DecodedValue = 0;

		LOCAL.Radix = ArrayLen( ARGUMENTS.CharacterSet );
		LOCAL.CharacterList = ArrayToList( ARGUMENTS.CharacterSet );
		LOCAL.Value = Reverse( ARGUMENTS.Value );

		LOCAL.ValueArray = ListToArray(
		REReplace(
			LOCAL.Value,
			"(.)",
			"\1,",
			"all"
			)
		);

		for(LOCAL.Index=1;LOCAL.Index<=ArrayLen( LOCAL.ValueArray );LOCAL.Index++)
		{
			LOCAL.DecodedValue += (
			(ListFind( LOCAL.CharacterList, LOCAL.ValueArray[ LOCAL.Index ] ) - 1) *
			(LOCAL.Radix ^ (LOCAL.Index - 1))
			);
		}

		return LOCAL.DecodedValue;
	}

}