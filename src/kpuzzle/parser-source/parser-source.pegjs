start = DEFINITION_FILE

IDENTIFIER = characters:([A-Za-z0-9<>]+) { return characters.join(""); }
// IDENTIFIER = characters:(([1-9][0-9]*)(([1-9][0-9]*)*)?)*(([A-Za-z]+)|(\<[A-Za-z]+(_[A-Za-z]+)*\>)) { return characters.join(); }
SET_IDENTIFIER = first:[A-Za-z] rest:[A-Za-z0-9]* { return [first].concat(rest).join(""); }
NUMBER = characters:[0-9]+ { return parseInt(characters.join(""), 10); }
SPACE = " "

NAME = "Name" SPACE identifier:IDENTIFIER { return identifier; }

ORBIT= "Set" SPACE set_identifier:SET_IDENTIFIER SPACE num_pieces:NUMBER SPACE num_orientations:NUMBER {
        return [set_identifier, {numPieces: num_pieces, orientations: num_orientations}];
       }

ORBITS
  = orbit:ORBIT { const orbits = {}; orbits[orbit[0]] = orbit[1]; return orbits;  }
  // TODO: Can we make sure orbits are added in order? (Most JS engines preserve map order.)
  / orbit:ORBIT NEWLINE orbits:ORBITS { orbits[orbit[0]] = orbit[1]; return orbits; }

NEWLINE = "\n"
NEWLINES = "\n"+
OPTIONAL_NEWLINES = "\n"*

NUMBERS = num:NUMBER SPACE nums:NUMBERS { return [num].concat(nums); }
        / num:NUMBER { return [parseInt(num, 10)]; }

PERMUTATION = nums:NUMBERS { return nums.map(x => x - 1); }

DEFINITION  = set_identifier:SET_IDENTIFIER NEWLINE permutation:PERMUTATION NEWLINE nums:NUMBERS {
                return [set_identifier, {permutation: permutation, orientation: nums}];
              }
              / set_identifier:SET_IDENTIFIER NEWLINE permutation:PERMUTATION   {
                return [set_identifier, {permutation: permutation, orientation: new Array(permutation.length).fill(0)}];
              }

DEFINITIONS
  = definition:DEFINITION NEWLINE definitions:DEFINITIONS { definitions[definition[0]] = definition[1]; return definitions; }
  / definition:DEFINITION { const definitions = {}; definitions[definition[0]] = definition[1]; return definitions; }

START_PIECES = "Solved" NEWLINE definitions:DEFINITIONS NEWLINE "End" { return definitions; }

MOVE = "Move" SPACE identifier:IDENTIFIER NEWLINE definitions:DEFINITIONS NEWLINE "End" { return [identifier, definitions]; }

MOVES = move:MOVE NEWLINES moves:MOVES { moves[move[0]] = move[1]; return moves; }
      / move:MOVE { const moves = {}; moves[move[0]] = move[1]; return moves; }

DEFINITION_FILE = name:NAME NEWLINES orbits:ORBITS NEWLINES start_pieces:START_PIECES NEWLINES moves:MOVES OPTIONAL_NEWLINES {
                    return {name: name, orbits: orbits, moves: moves, startPieces: start_pieces};
                  }
