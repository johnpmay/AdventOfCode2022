with(StringTools): with(FileTools):
input := Text:-ReadFile("AoC-2022-13-input.txt" ):
pairs := map(p->[parse(p[1]),parse(p[2])],
    map(Split,StringSplit(TrimRight(input), "\n\n"), "\n")):

checkpair := proc(l, r) # 1 correct, 0 tie, -1 wrong
local i, comp;
    if type(l,list) and type(r, list) then
         for i to min(nops(r),nops(l)) do
             comp := thisproc(l[i],r[i]);           
             if comp <> 0 then
                  return comp;
             end if;
         end do;
         if nops(r) > nops(l) then # l ran out first
             return 1;
         elif nops(r) = nops(l) then # same
             return 0;
         else # r ran out first
             return -1;
         end if;
    elif type(l, integer) and type(r, integer) then
         return signum(r-l);
    else
         return thisproc(ifelse(l::list,l,[l]), ifelse(r::list,r,[r]));
    end if;    
end proc:

# Part 1
corrpairs := NULL:
for i to  nops(pairs) do
    i;
    comp := checkpair(pairs[i][1],pairs[i][2]);
    if comp = 0 then error "not comparable";
    elif comp = 1 then corrpairs := corrpairs,i;
    else next; end if; 
end do: corrpairs;
ans1 := `+`(corrpairs);

# Part 2
signals := [ [[2]], [[6]], map(op,pairs)[] ]:
predicate := (a,b) -> ifelse(checkpair(a,b)=-1, false, true);
sorted := sort(signals, predicate):
member([[6]], sorted, 'l1');l1;
member([[2]], sorted, 'l2');l2;
ans2 := l1*l2;


