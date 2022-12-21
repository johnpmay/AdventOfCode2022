with(StringTools): with(FileTools):
input := Text:-ReadFile("../../AdventOfCode_inputs/AoC-2022-21-input.txt" ):

monk := map(s->`=`(parse~(Split(s, ":"))[]), Split(TrimRight( input ),"\n")): N := nops(monk);
monk := table(monk):

expr := monk[root];
while not type(expr, constant) do
    terms := indets(expr, name);
    for e in terms do        
        expr := subs(e=monk[e], expr);
    end do;
end do:
ans1 := expr;

monk[root] := `=`(op(monk[root]));
monk[humn] := humn;
expr := monk[root];
terms := [root,humn];
while nops(terms) > 1 do
	terms := indets(expr, name);
    for e in terms do        
        expr := subs(e=monk[e], expr);
    end do;
end do:
tosolve := expr;
ans2 := solve(tosolve);