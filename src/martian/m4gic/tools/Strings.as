/*
Copyright (c) 2010 julien barbay <barbay.julien@gmail.com>

Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without
restriction, including without limitation the rights to use,
copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following
conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.
*/

package martian.m4gic.tools
{
	public class Strings
	{
		static public const FIRST:String = "first";
		static public const LAST:String = "last";
		static public const BEFORE:String = "before";
		static public const AFTER:String = "after";
		
		static public const LEFT:int = 0x01;
		static public const RIGHT:int = 0x10;
		
		static public const EXCEPT:String = "except";
		static public const ONLY:String = "only";
		static public const ALL:String = "all";

		
		
		
		/**
		 * Strips tags of a markup
		 * @param string : the markup string
		 * @param policy : can be EXCEPT, ONLY, or ALL
		 * @param tags : an array of markup tags that will be used in conjonction with the policy (ignored if policy == ALL)
		 * @return : a clean string
		 */
		
		static public function strip(string:String, policy:String = ALL, tags:Array = null):String
		{
			if (string == "") { return ""; }
			if (policy != ALL && (tags == null || tags.length == 0)) { policy = ALL; }
			
			switch(policy)
			{
				case EXCEPT:
					return string.replace(new RegExp("<(?!\/?(" + tags.join("|") + ")(?=>|\s?.*>))\/?.*?>", "gi"), "");
					break;
							
				case ONLY:
					return string.replace(new RegExp("<\/?[" + tags.join("|") + "][^>]*>", "gi"), "");
					break;
				
				default:
				case ALL:
					return string.replace(new RegExp("<.*?>", "gi"), "");
					break;
			}
		}
		
		
		
		
		/**
		 * insert replacements where tags are inserted (%1, %2, %3, %4, %5...)
		 * @param string : the string to replace
		 * @param replacements : the dynamic parts of the string
		 * @return a clean string
		 */
		
		static public function put(string:String, ...replacements):String
		{
			var result:String = string;
			for (var i:int = 0; i < replacements.length; i++) { result = result.replace("%" + (i + 1), replacements[i]); }
			
			return result;
		}	
		
		
		
		
		/**
		 * trims empty spaces at the left or right or both of a string
		 * @param string : the string to trim
		 * @param policy : can be LEFT, RIGHT, or LEFT | RIGHT
		 * @return a clean string
		 */
		
		static public function trim(string:String, policy:int = LEFT):String
		{
			if (!(policy && 0x11)) { policy = LEFT; }
			
			var result:String = string;
			
			if (policy & Strings.LEFT) { result = result.replace(new RegExp("^\s+"), ''); }
			if (policy & Strings.RIGHT) { result = result.replace(new RegExp("\s+$"), ''); }
			
			return result;
		}
		
		
		
		
		/**
		 * add some chars to the left or right of a string
		 * @param string : the string to decorate
		 * @param char : the decoration char
		 * @param policy : can be LEFT or RIGHT
		 * @return a deco string
		 */
		
		static public function pad(string:String, char:String, length:int, policy:int = LEFT):String
		{
			var result:String = string;
			
			if (policy & LEFT) { while (result.length < length) { result = char + result; } }
			else if (policy & RIGHT) { while (result.length < length) { result += char; } }
			
			return result;
		}
		
		
		
		
		/**
		 * a trim test to know if a string is empty
		 * @param string : the string to test
		 * @return true if string length is 0 after a trim
		 */
		
		static public function empty(string:String):Boolean { return trim(string, LEFT | RIGHT).length == 0; }
		
		
		
		
		/**
		 * test if a string is numeric
		 * @param string : the string to test
		 * @return true if string can be numeric
		 */
		
		static public function numeric(string:String):Boolean { return !isNaN(parseFloat(string)); }
		
		
		
		
		/**
		 * test if a char is a vowel
		 * @param string : the char to test
		 * @return true if the char is a vowel
		 */
		
		static public function vowel(char:String):Boolean { return char.match(new RegExp("[AEIOUY]", "gi")).length > 0; }
		
		
		
		
		/**
		 * test if a string begins by a specific string
		 * @param string : the big string
		 * @param pattern : the beginning pattern string
		 * @return true the pattern is found at index 0
		 */
		
		static public function begins(string:String, pattern:String):Boolean { return (string != "") ? string.indexOf(pattern) == 0 : false; }
		
		
		
		
		/**
		 * test if a string ends by a specific string
		 * @param string : the big string
		 * @param pattern : the ending pattern string
		 * @return true the pattern is found at the end of the string
		 */
		
		static public function ends(string:String, pattern:String):Boolean { return string.lastIndexOf(pattern) == string.length - pattern.length; }		
		
		
		
		
		/**
		 * test if a string contains by a specific string
		 * @param string : the big string
		 * @param pattern : the pattern string
		 * @return true the pattern is found in the string
		 */
		
		static public function contains(string:String, pattern:String):Boolean { return (string != "") ? string.indexOf(pattern) != -1 : false; }
		
		
		
		
		/**
		 * finds how many times the pattern is found in a string
		 * @param string : the big string
		 * @param pattern : the pattern string
		 * @param sensitive : tells the script to be case sensitive
		 * @return an int of how many times the pattern has been found
		 */
		
		static public function count(string:String, pattern:String, sensitive:Boolean = true):int { return (string != "") ? string.match(new RegExp(patternable(pattern), (!sensitive ? 'ig' : 'g'))).length : 0; }
		
		
		
		
		/**
		 * count number of words in a string
		 * @param string : the string to test
		 * @return the number of words in the testing string
		 */
		
		static public function words(string:String):int { return (string != "") ? string.match(/\b\w+\b/g).length : 0; }		
		
		
		
		
		/**
		 * reverse a string
		 * @param string : the string to reverse
		 * @return the reversed string
		 */
		
		static public function reverse(string:String):String { return string != "" ? string.split('').reverse().join('') : ''; }
		
		
		
		
		/**
		 * shuffles a string
		 * @param string : the string to shuffles
		 * @return the shuffled string
		 */
		
		static public function shuffle(string:String):String { return string != "" ? Arrays.shuffle(string.split('')).join('') : ''; }
		
		
		
		
		/**
		 * remove all pattern's occurences found in a string
		 * @param string : the string to operate on
		 * @param pattern : the pattern string to remove
		 * @param sensitive : tells the script to be case sensitive
		 * @return a clean string
		 */
		
		static public function remove(string:String, pattern:String, sensitive:Boolean = true):String { return string != "" ? string.replace(new RegExp(patternable(pattern), (!sensitive ? 'ig' : 'g')), '') : ''; }		
		
		
		
		
		/**
		 * cuts a string after given number of chars then add a suffix
		 * @param string : the string to operate on
		 * @param length : the maximum length of the string
		 * @param string : the suffix to add if the string is longer than the given length
		 * @return a truncated string
		 */
		
		static public function truncate(string:String, length:uint, suffix:String = "..."):String
		{
			if (string == '') { return ''; }
			
			var result:String = trim(result, RIGHT);
			
			if (result.length > length) { result = result.substr(0, length); }
			else { result = result.substr(0, length - suffix.length) + suffix; }
			
			return result;
		}		
		
		
		
		
		/**
		 * find how many transformations are necessary to make source equals to target
		 * @param source : a A state string
		 * @param target : a B state string
		 * @return the number of transformation necessary to get A == B
		 */
		
		static public function levenshtein(source:String, target:String):int
		{
			if (source == null) { source = ''; }
			if (target == null) { target = ''; }
			if (source == target) { return 0; }
			
			var d:Array = new Array(),
				i:int, j:int, cost:int;
			
			var n:int = source.length,
				m:int = target.length;
			
			var a:String, b:String;
			
			if (n == 0) { return m; }
			if (m == 0) { return n; }
			
			for (i = 0; i <= n; i++) { d[i] = new Array(); }
			for (i = 0; i <= n; i++) { d[i][0] = i; }
			for (j = 0; j <= m; j++) { d[0][j] = j; }
			
			for (i = 1; i <= n; i++)
			{
				a = source.charAt(i - 1);
				
				for (j = 1; j <= m; j++)
				{
					b = target.charAt(j - 1);
					
					cost = (a == b) ? 0 : 1;
					
					d[i][j] = Math.min(d[i - 1][j] + 1, d[i][j - 1] + 1, d[i - 1][j - 1] + cost);
				}
			}
			
			return d[n][m];
		}		
		
		
		
		
		/**
		 * levenshtein as a percentage
		 * @param source : a A state string
		 * @param target : a B state string
		 * @return the percent of similarity of those strings
		 */
		
		static public function similar(source:String, target:String):Number
		{
			var lv:int = levenshtein(source, target);
			var max:int = source.length < target.length ? target.length : source.length;
			
			return max != 0 ? (1 - (lv / max)) : 1;
		}		
		
		
		
		
		/**
		 * make a string clean for regex use
		 * @param pattern : the pattern to clean
		 * @return a clean string
		 */
		
		static public function patternable(pattern:String):String { return pattern.replace(/(\]|\[|\{|\}|\(|\)|\*|\+|\?|\.|\\)/g, '\\$1'); }		
		
		
		
		
		/**
		 * cuts a string with a pattern and returns the rest
		 * @param string : the string to cut
		 * @param pattern : the matching pattern
		 * @param from : defines from where the cut begins. possible values are FIRST or LAST
		 * @param give : defines which part of the cut string is returned. possible values are BEFORE or AFTER
		 * @return a clean string
		 */
		
		static public function cut(string:String, pattern:String, from:String = FIRST, give:String = AFTER):String
		{
			if (string == '') { return ''; }
			if (from != FIRST && from != LAST) { from = FIRST; }
			
			var index:int = (from == FIRST) ? string.indexOf(pattern) : string.lastIndexOf(pattern);
				if (index == -1) { return ''; }
			
			return (give == BEFORE) ? string.substr(0, index) : string.substr(index + pattern.length);
		}		
		
		
		
		
		/**
		 * cuts a string with a maximum length and a delimiter
		 * @param string : the string to cut
		 * @param length : the maximum length of a block
		 * @param delimiter : a char that will be used to cut the block
		 * @return an array of blocks string
		 */
		
		static public function block(string:String, length:int, delimiter:String = "."):Array
		{
			if (string == "" || !contains(string, delimiter)) { return null; }
			
			var array:Array = new Array(),
				regexp:RegExp = new RegExp("[^" + patternable(delimiter) + "]+$"),
				substring:String;
			
			var i:int = 0,
				l:int = string.length;
			
			while (i < l)
			{
				substring = string.substr(i, l);
				
				if (!contains(substring, delimiter))
				{
					array.push(truncate(substring, substring.length));
					i += substring.length;
				}
				
				substring = substring.replace(regexp, '');
				array.push(substring);
				
				i += substring.length;
			}
			
			return array;
		}
		
		
		
		
		/**
		 * a double metaphone implementation
		 * @param string : the string to analyse
		 * @return an array of the 2 results from the metaphone
		 */
		
		static public function metaphone(str:String):Array
		{
			str = String(str + "     ").toUpperCase();
			
			var p:String = "",
				s:String = "",
				i:int = 0;
						
			if (Arrays.contains(["GN", "KN", "PN", "WR", "PS"], str.substr(0, 2))) { i++; }
			else if (str.charAt(0) == "X")
			{
				p += "S";
				s += "S";
				i++;
			}

			while (p.length < 4 || s.length < 4)
			{
				if (i >= str.length) { break; }

				switch (str.charAt(i))
				{
					case "A": case "E": case "I":
					case "O": case "U": case "Y":
						if (i == 0)
						{
							p += "A";
							s += "A";
						}
						
						i++;
						break;

					case "B":
						p += "P";
						s += "P";
						i += (str.charAt(i + 1) == "B") ? 2 : 1;
						break;
					
					case 'Ç':
						p += 'S';
						s += 'S';
						i++;
						break;

					
					case "C":
						if ((i > 1) && !vowel(str.charAt(i - 2))
							&& str.substr(i - 1, 3) == "ACH"
							&& str.charAt(i + 2) != 'I'
							&& str.charAt(i + 2) != 'E'
							|| Arrays.contains(["BACHER", "MACHER"], str.substr(i - 2, 6)))
							{
								p += 'K';
								s += 'K';
								i += 2;
								break;
							}
							
						if (i == 0 && str.substr(i, 6) == "CAESAR")
						{
							p += 'S';
							s += 'S';
							i += 2;
							break;
						}
						
						if (str.substr(i, 4) == "CHIA")
						{
							p += 'K';
							s += 'K';
							i += 2;
							break;
						}
						
						if (str.substr(i, 2) == "CH")
						{
							if (i > 0 && str.substr(i, 4) == "CHAE")
							{
								p += 'K';
								s += 'X';
								i += 2;
								break;
							}
							
							if (i == 0 && str.substr(0, 5) != "CHORE" && (Arrays.contains(["HARAC", "HARIS"], str.substr(i + 1, 5)) || Arrays.contains(["HOR", "HYM", "HIA", "HEM"], str.substr(i + 1, 3))))
							{
								p += 'K';
								s += 'K';
								i += 2;
								break;
							}
								
							if (Arrays.contains(["VAN ", "VON "], str.substr(0, 4))
								|| Arrays.contains(["ORCHES", "ARCHIT", "ORCHID"], str.substr(i - 2, 6))
								|| Arrays.contains(["T", "S"], str.charAt(i + 2))
								|| str.substr(0, 3) == "SCH"
								|| ((Arrays.contains(["A","O","U","E"], str.charAt(i - 1)) || i == 0)
									&& Arrays.contains(["L","R","N","M","B","H","F","V","W"," "], str.charAt(i + 2))
								)
							)
							{
								p += 'K';
								s += 'K';
							}
							else
							{
								if (i > 0)
								{
									p += (str.substr(0, 2) == "MC") ? "K" : "X";
									s += "K";
								}
								else
								{
									p += "X";
									s += "X";
								}
							}
							
							i += 2;
							break;
						}
						
						if (str.substr(i, 2) == "CZ" && str.substr(i - 2, 4) != "WICZ")
						{
							p += 'S';
							s += 'X';
							i += 2;
							break;
						}
						
						if (str.substr(i + 1, 3) == "CIA")
						{
							p += 'X';
							s += 'X';
							i += 3;
							break;
						}
						
						if (str.substr(i, 2) == "CC" && !(i == 1 && str.charAt(0) == 'M'))
						{
							if (Arrays.contains(["I","E","H"], str.charAt(i + 2)) && !str.substr(i + 2, 2) == "HU")
							{
								if ((i == 1 && str.charAt(i - 1) == 'A') || Arrays.contains(["UCCEE", "UCCES"], str.substr(i - 1, 5)))
								{
									p += "KS";
									s += "KS";
								}
								else
								{
									p += "X";
									s += "X";
								}
								
								i += 3;
								break;
							}
							else
							{
								p += "K";
								s += "K";
								i += 2;
								break;
							}
						}
						
						if (Arrays.contains(["CK","CG","CQ"], str.substr(i, 2)))
						{
							p += "K";
							s += "K";
							i += 2;
							break;
						}
						
						if (Arrays.contains(["CI","CE","CY"], str.substr(i, 2)))
						{
							if (Arrays.contains(["A","E","0"], str.charAt(i + 2)))
							{
								p += "S";
								s += "X";
							}
							else
							{
								p += "S";
								s += "S";
							}
							
							i += 2;
							break;
						}
						
						p += "K";
						s += "K";
						
						if (Arrays.contains([" C"," Q"," G"], str.substr(i + 1, 2)))
						{
							i += 3;
						}
						else
						{
							if (Arrays.contains(["C","K","Q"], str.charAt(i + 1)) && !Arrays.contains(["CE","CI"], str.substr(i + 1, 2)))
							{
								i += 2;
							}
							else { i += 1; }
						}
						
						break;
					
					case "D":	
						if (str.substr(i, 2) == "DG")
						{
							if (Arrays.contains(["I","E","Y"], str.charAt(i + 2)))
							{
								p += "J";
								s += "J";
								i += 3;
								break;
							}
							else
							{
								p += "TK";
								s += "TK";
								i += 2;
								break;
							}
						}
						
						if (Arrays.contains(["DT","DD"], str.substr(i, 2)))
						{
							p += "T";
							s += "T";
							i += 2;
							break;
						}
						
						p += "T";
						s += "T";
						i++;
						
						break;
					
					case 'F':
						p += "F";
						s += "F";
						i += (str.charAt(i + 1) == "F") ? 2 : 1;
						break;
							
					case 'G':
						if (str.substr(i + 1, 1) == 'H')
						{
							if (i > 0 && !vowel(str.charAt(i - 1)))
							{
								p += "K";
								s += "K";
								i += 2;
								break;
							}
							
							if (i < 3)
							{
								if (i == 0)
								{
									if (str.charAt(i + 2) == 'I')
									{
										p += "J";
										s += "J";
									}
									else
									{
										p += "K";
										s += "K";
									}
									
									i += 2;
									break;
								}
							}
							
							if ((i > 1 && Arrays.contains(["B","H","D"], str.charAt(i - 2)))
								|| (i > 2 && Arrays.contains(["B","H","D"], str.charAt(i - 3)))
								|| (i > 3 && Arrays.contains(["B","H"], str.charAt(i - 4))))
							{
								i += 2;
								break;
							}
							else
							{
								if (i > 2 && str.charAt(i - 1) == "U" && Arrays.contains(["C","G","L","R","T"], str.charAt(i - 3)))
								{
									p += "F";
									s += "F";
								}
								else if (i > 0 && str.charAt(i - 1) != 'I')
								{
									p += "K";
									s += "K";
								}
								
								i += 2;
								break;
								
							}
						}
						
						if (str.charAt(i + 1) == 'N')
						{
							if ((i == 1) && vowel(str.charAt(0)) && str.match(new RegExp("W|K|CZ|WITZ", "g")).length == 0)
							{
								p += "KN";
								s += "N";
							}
							else
							{
								if (str.substr(i + 2, 2) != "EY" && str.charAt(i + 1) != "Y" && str.match(new RegExp("W|K|CZ|WITZ", "g")).length == 0)
								{
									p += "N";
									s += "KN";
								}
								else
								{
									p += "KN";
									s += "KN";
								}
							}
							
							i += 2;
							break;
						}
						
						if (str.substr(i + 1, 2) == "LI" && str.match(new RegExp("W|K|CZ|WITZ", "g")).length == 0)
						{
							p += "KL";
							s += "L";
							i += 2;
							break;
						}
						
						
						if (i == 0 && ((str.charAt(i + 1) == 'Y') || Arrays.contains(["ES","EP","EB","EL","EY","IB","IL","IN","IE","EI","ER"], str.substr(i + 1, 2))))
						{
							p += "K";
							s += "J";
							i += 2;
							break;
						}
						
						if ((str.substr(i + 1, 2) == "ER" || str.charAt(i + 1) == 'Y')
							&& !Arrays.contains(["DANGER","RANGER","MANGER"], str.substr(0, 6))
							&& !Arrays.contains(["E", "I"], str.charAt(i -1))
							&& !Arrays.contains(["RGY","OGY"], str.substr(i -1, 3)))
						{
							p += "K";
							s += "J";
							i += 2;
							break;
						}
						
						if (Arrays.contains(["E","I","Y"], str.charAt(i + 1)) || Arrays.contains(["AGGI","OGGI"], str.substr(i - 1, 4)))
						{
							if (Arrays.contains(["VAN ", "VON "], str.substr(0, 4)) || str.substr(0, 3) == "SCH" || str.substr(i + 1, 2) == "ET")
							{
								p += "K";
								s += "K";
							}
							else
							{
								if (str.substr(i + 1, 4) == "IER ")
								{
									p += "J";
									s += "J";
								}
								else
								{
									p += "J";
									s += "K";
								}
							}
							
							i += 2;
							break;   
						}
						
						i += (str.charAt(i + 1) == "G") ? 2 : 1;
						p += 'K';
						s += 'K';
						break;	
							
					case "H":	
						if ((i == 0 || vowel(str.charAt(i - 1)) && vowel(str.charAt(i + 1))))
						{
							p += "H";
							s += "H";
							i += 2;
						}
						else { i++; }
						break;		
							
					case "J":
						if (str.substr(i, 4) == "JOSE" || str.substr(0, 4) == "SAN ")
						{
							if ((i == 0 && str.charAt(i + 4) == ' ') || str.substr(0, 4) == "SAN ")
							{
								p += "H";
								s += "H";
							}
							else
							{
								p += "J";
								s += "H";
							}
							
							i += 1;
							break;
						}
						
						if (i == 0  && str.substr(i, 4) != "JOSE")
						{
							p += "J";
							s += "A";
						}
						else
						{
							if (vowel(str.charAt(i - 1)) && !str.match(new RegExp("W|K|CZ|WITZ", "g")).length == 0 && (str.charAt(i + 1) == 'A' || str.charAt(i + 1) == 'O'))
							{
								p += "J";
								s += "H";
							}
							else
							{
								if (i == str.length - 1)
								{
									p += "J";
									s += "";
								}
								else
								{
									if (!Arrays.contains(["L","T","K","S","N","M","B","Z"], str.charAt(i + 1)) && !Arrays.contains(["S","K","L"], str.substr(i - 1)))
									{
										p += "J";
										s += "J";
									}
								}
							}
						}
						
						i += str.charAt(i + 1) == "J" ? 2 : 1;
						break;
						
					case 'K':
						p += "K";
						s += "K";
						i += str.charAt(i + 1) == "K" ? 2 : 1;
						break;		
							
					case "L":
						if (str.charAt(i + 1) == "L")
						{
							if ((i == (str.length - 3) && Arrays.contains(["ILLO","ILLA","ALLE"], str.substr(i - 1, 4)))
								|| ((Arrays.contains(["AS","OS"], str.substr(str.length - 2, 2))) || Arrays.contains(["A","O"], str.charAt(str.length - 1)))
								&& str.substr(i - 1, 4) == "ALLE")
							{
								p += "L";
								s += "";
								i += 2;
								break;
							}
						}
						
						p += "L";
						s += "L";
						i += (str.charAt(i + 1) == "L") ? 2 : 1;
						break;		
						
						
					case "M":
						p += "M";
						s += "M";
						
						if (str.substr(i - 1, 3) == "UMB" && (i + 1 == str.length - 1 || str.substr(i + 2, 2) == "ER") || str.charAt(i + 1) == "M")
						{   
							i += 2;
						}
						else { i ++; }
						break;
						
						case "N":
						p += "N";
						s += "N";
						i += str.charAt(i + 1) == "N" ? 2 : 1;
						break;
						
						case "Ñ":
						p += "N";
						s += "N";
						i++;
						break;
						
					case "P":	
						if (str.charAt(i + 1) == 'H')
						{
							p += "F";
							s += "F";
							i += 2;
							break;
						}
						
						p += "P";
						s += "P";
						i += Arrays.contains(["P", "B"], str.charAt(i + 1)) ? 2 : 1;
						break;
						
					case 'Q':
						p += "K";
						s += "K";
						i += str.charAt(i + 1) == "Q" ? 2 : 1;
						break;
						
					case 'R':
						if (i == str.length - 1 && str.match(new RegExp("W|K|CZ|WITZ", "g")).length == 0 && str.substr(i - 2, 2) == "IE" && Arrays.contains(["MA", "ME"], str.substr(i - 4, 2)))
						{
							p += "";
							s += "R";	
						}
						else
						{
							p += "R";
							s += "R";			
						}
						
						i += str.charAt(i + 1) == "R" ? 2 : 1;
						break;
						
					case 'S':
						if (Arrays.contains(["ISL", "YSL"], str.substr(i - 1, 3)))
						{
							i ++;
							break;
						}
						
						if (i == 0 && str.substr(i, 5) == "SUGAR")
						{
							p += "X";
							s += "S";
							i ++;
							break;
						}
						
						if (str.substr(i, 2) == "SH")
						{
							if (Arrays.contains(["HEIM","HOEK","HOLM","HOLZ"], str.substr(i + 1, 4)))
							{
								p += "S";
								s += "S";
							}
							else
							{
								p += "X";
								s += "X";
							}
							
							i += 2;
							break;
						}
						
						if (Arrays.contains(["SIA", "SIO"], str.substr(i, 3)) || str.substr(i, 4) == "SIAN")
						{
							if (str.match(new RegExp("W|K|CZ|WITZ", "g")).length == 0)
							{
								p += "S";
								s += "X";
							}
							else
							{
								p += "S";
								s += "S";
							}
							
							i += 3;
							break;
						}
						
						if ((i == 0 && Arrays.contains(["M","N","L","W"], str.charAt(i + 1))) || str.charAt(i + 1) == "Z")
						{
							p += "S";
							s += "X";
							i += str.charAt(i + 1) == "Z" ? 2 : 1;
							break;
						}
						
						if (str.substr(i, 2) == "SC")
						{
							if (str.charAt(i + 2) == "H")
							{
								if (Arrays.contains(["OO","ER","EN","UY","ED","EM"], str.substr(i + 3, 2)))
								{
									if (Arrays.contains(["ER", "EN"], str.substr(i + 3, 2)))
									{
										p += "X";
										s += "SK";
									}
									else
									{
										p += "SK";
										s += "SK";
									}
										
									i += 3;
									break;
								}
								else
								{
									if (i == 0 && !vowel(str.charAt(3)) && str.charAt(i + 3) != "W")
									{
										p += "X";
										s += "S";
									}
									else
									{
										p += "X";
										s += "X";
									}
									
									i += 3;
									break;
								}	
							
								if (Arrays.contains(["E", "I", "Y"], str.charAt(i + 2)))
								{
									p += "S";
									s += "S";
									i += 3;
								}
									
								p += "SK";
								s += "SK";
								i += 3;
								break;
							}	
						}
				
						if (i == str.length - 1 && Arrays.contains(["AI", "OI"], str.substr(i - 2, 2)))
						{
							p += "";
							s += "S";
						}
						else
						{
							p += "S";
							s += "S";
						}
						
						i += Arrays.contains(["S", "Z"], str.charAt(i + 1)) ? 2 : 1;
						break;
				
				
				
					case "T":
						if (str.substr(i, 4) == "TION" || Arrays.contains(["TIA", "TCH"], str.substr(i, 3)))
						{
							p += "X";
							s += "X";
							i += 3;
							break;
						}
						
						if (str.substr(i, 2) == "TH" || str.substr(i, 3) == "TTH")
						{
							if (Arrays.contains(["AM", "OM"], str.substr(i + 2, 2)) || Arrays.contains(["VAN ", "VON "], str.substr(0, 4)) || str.substr(0, 3) == "SCH")
							{
								p += "T";
								s += "T";
							}
							else
							{
								p += "0";
								s += "T";	
							}
							
							i += 2;
							break;
							
						}
						
						p += "T";
						s += "T";
						i += Arrays.contains(["D", "T"], str.charAt(i + 1)) ? 2 : 1;
						break;
				
					case "V":
						p += "F";
						s += "F";
						i += str.charAt(i + 1) == "V" ? 2 : 1;
						break;	
				
				
					case "W":
						if (str.substr(i, 2) == "WR")
						{
							p += "R";
							s += "R";
							i += 2;
							break;
						}
				
						if (i == 0 && (vowel(str.charAt(i + 1)) || str.substr(i, 2) == "WH"))
						{
							if (vowel(str.charAt(i + 1)))
							{
								p += "A";
								s += "F";
							}
							else
							{
								p += "A";
								s += "A";
							}
						}
						
						if ((i == str.length - 1 && vowel(str.charAt(i - 1))) || Arrays.contains(["EWSKI","EWSKY","OWSKI","OWSKY"], str.substr(i - 1, 5)) || str.substr(0, 3) == "SCH")
						{
							p += "";
							s += "F";
							i ++;
							break;
						}
						
						if (Arrays.contains(["WICZ","WITZ"], str.substr(i, 4)))
						{
							p += "TS";
							s += "FX";
							i += 4;
							break;
						}
						
						i += 1;
						break;
				
					case "X":
						if (!(i == str.length - 1 && Arrays.contains(["IAU", "EAU"], str.substr(i - 3, 3)) || Arrays.contains(["AU", "OU"], str.substr(i - 2, 2))))
						{
							p += "KS";
							s += "KS";
						}
						
						i += Arrays.contains(["C","X"], str.substr(i + 1, 1)) ? 2 : 1;
						break;
				
					case "Z":
						if (str.charAt(i + 1) == "H")
						{
							p += "J";
							s += "J";
							i += 2;
							break;
						}
						else if (Arrays.contains(["ZO", "ZI", "ZA"], str.substr(i + 1, 2)) || (str.match(new RegExp("W|K|CZ|WITZ", "g")).length > 0 && (i > 0 && str.charAt(i - 1) != "T")))
						{
							p += "S";
							s += "TS";
						}
						else
						{
							p += "S";
							s += "S";
						}
						
						i += str.charAt(i + 1) == "Z" ? 2 : 1;
						break;
				
					default:
						i++;
						break;
				}
			}	
		
			return new Array(p.substr(0, 4), s.substr(0, 4));
		}
	}
}