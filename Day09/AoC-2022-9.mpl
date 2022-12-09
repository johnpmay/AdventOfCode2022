restart;
with(StringTools): with(FileTools):
input := Text:-ReadFile("AoC-2022-9-input.txt" ):

steps := map(s->[s[1], parse(s[2..-1])], Split(TrimRight(input),"\n")):
dirt := table(["L"=[-1,0], "R"=[1,0], "D"=[0,-1], "U"=[0,1]]);

neworr := proc(orr, dir, $)
# T is orr relative to H - [0,0] OK
# H moves in dir - diagonal OK
    local newor := orr -~ dir;
    if max(newor) < 2 and min(newor) > -2 then
        return newor;
    elif max(newor) = 2 then
        if signum(newor[1])=signum(newor[2]) then
            return newor -~ [1,1];
        else # [{0,-1}, 2] e.g.
            return newor -~ floor~(1/2 * newor);
        end if;
    elif min(newor) = -2 then
        if signum(newor[1])=signum(newor[2]) then
            return newor -~ [-1,-1];
        else # [-2, {0,1}] e.g.
            return newor -~ ceil~(1/2 * newor);
        end if;
    else 
        error "illegal move or relative position"; 
    end if;
end proc:

# Part 1 loop
start := [0,0];
visit := table(sparse=0);
visit[start[]] := 1;
Hpos := start; # coord
Torr := [0,0]; # relative
for s in steps do
    to s[2] do 
        Hpos := Hpos +~ dirt[s[1]];
        Torr := neworr(Torr, dirt[s[1]]);
        vpos := Hpos +~ Torr;
        visit[vpos[]] := 1;
    end do;
end do:
ans1 := nops({indices(visit)});

# Part 2 loop
start := [0,0];
visit := table(sparse=0);
visit[start[]] := 1;
Hpos :=  [0,0]; # coord
Torr := Array(1..9, ()->start);; # relative
for s in steps do
    to s[2] do
        oldpos := Hpos;
        Hpos := Hpos +~ dirt[s[1]];
        tmppos := Hpos;
        tmpmov := dirt[s[1]];
        for i to 9 do
            oldpos := oldpos +~ Torr[i];
            Torr[i] := neworr(Torr[i], tmpmov);            
            vpos := tmppos +~ Torr[i];
            tmpmov := vpos -~ oldpos;
            tmppos := vpos;            
        end do;
        visit[vpos[]] := 1; #9 position
    end do;
end do:

ans2 := nops({indices(visit)});


