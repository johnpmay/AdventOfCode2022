with(StringTools): with(FileTools):
input := Text:-ReadFile("AoC-2022-3-input.txt" ):

priority := proc(c,$)
local p := convert(c, ByteArray)[1];
    if p <= 90 then p - 38; # upper case
    else p - 96; end if;    # lower case
end proc:

elves := Split(Trim(input),"\n");
rucks := map(s->[ s[1..length(s)/2], s[length(s)/2+1..-1] ], elves);

part1 := add( priority(op({Explode(r[1])[]}
		intersect {Explode(r[2])[]})), r in rucks);

# part 2
badges := [seq(op( {Explode(elves[i+1])[]}
	 intersect {Explode(elves[i+2])[]}
	 intersect {Explode(elves[i+3])[]}),
		 i=0..nops(elves)-1,3)];
part2 := add(priority(b), b in badges);


