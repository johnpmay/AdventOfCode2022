with(StringTools): with(FileTools):
input := Text:-ReadFile("AoC-2022-21-input.txt" ):
monk := map(s->parse~(Split(s, ":")), Split(TrimRight( input ),"\n")):
N := nops(monk);
monk[1];
findkey := proc(key)
local i;
   for i to N do
       if monk[i][1]=key then
          return i;
       end if;
   end do;
    return FAIL:
end proc:

loc := findkey(root);
expr := monk[loc][2];
while not type(expr, constant) do
	terms := indets(expr, name);
	for e in terms do
	    loc := findkey(e);
	    expr := subs(e=monk[loc][2], expr);
	end do;
end do:
ans1 := expr;
loc := findkey(root);
monk2 := subsop(loc=[root,`=`(op(monk[loc][2]))], monk):
loc := findkey(humn);
monk2 := subsop(loc=[humn,humn], monk2):

loc := findkey(root);
expr := monk2[loc][2];
terms := indets(monk2):
while nops(terms) > 1 do
	terms := indets(expr, name);
	for e in terms do
	    loc := findkey(e);
	    expr := subs(e=monk2[loc][2], expr);
	end do;
end do:
tosolve := expr;
ans2 := solve(tosolve);

