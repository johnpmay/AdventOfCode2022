restart;
with(StringTools): with(FileTools):
input := Text:-ReadFile("AoC-2022-4-input.txt" ):
# parse input to pairs of pairs of integers
pairs := subsindets( map(Split,Split(Trim(input)),","),
    string, s->parse~(Split(s,"-"))): nops(pairs);

contQ := proc(a,b)
    if      b[1] >= a[1] and b[1] <= a[2]
        and b[2] >= a[1] and b[2] <= a[2]
    then
       return true;
    elif    a[1] >= b[1] and a[1] <= b[2]
        and a[2] >= b[1] and a[2] <= b[2]
    then
       return true;
    else
       return false;
    end if;
end proc:
contQ([1,1],[1,1]), contQ([1,3], [2,2]), contQ([2,2],[1,3]), contQ([2,3],[1,2]);       
part1 := nops( select(p->contQ(p[]), pairs) );

ovlpQ := proc(a,b)
    if     b[1] >= a[1] and b[1] <= a[2] 
        or b[2] >= a[1] and b[2] <= a[2]
    then
       return true;
    elif   a[1] >= b[1] and a[1] <= b[2]
        or a[2] >= b[1] and a[2] <= b[2]
    then
       return true;
    else
       return false;
    end if;
end proc:
part2 := nops( select(p->ovlpQ(p[]), pairs) );
