restart;
with(StringTools): with(FileTools):
inputt :=
"Blueprint 1: Each ore robot costs 4 ore. Each clay robot costs 2 ore. Each obsidian robot costs 3 ore and 14 clay. Each geode robot costs 2 ore and 7 obsidian.
Blueprint 2: Each ore robot costs 2 ore. Each clay robot costs 3 ore. Each obsidian robot costs 3 ore and 8 clay. Each geode robot costs 3 ore and 12 obsidian.
":
input := Text:-ReadFile("AoC-2022-19-input.txt" ):
inputc := Split(TrimRight(input),"\n"): nops(inputc);

blueprints := map(s->sscanf(s, "Blueprint %d: Each ore robot costs %d ore. Each clay robot costs %d ore. Each obsidian robot costs %d ore and %d clay. Each geode robot costs %d ore and %d obsidian."), inputc)[1..3];
# start state
start := [1,0,0,0,0,0,0,0]; # rcbg robots, rcbg quanity, time

nbs := proc(state, bpn)
option cache;
local bp := blueprints[bpn];
local i, newores := seq(state[i]+state[i+4], i=1..4); # all nb increase ore
local out;

    out := NULL;

    if (state[5]>=bp[6] and state[7]>=bp[7]) then # build geode bot
        out := [state[1], state[2], state[3], state[4]+1, newores[1]-bp[6], newores[2], newores[3]-bp[7], newores[4]];
    elif (state[5]>=bp[4] and state[6]>=bp[5] and state[3] < bp[7]) then # build obsian bot
        out := [state[1..4][], newores], [state[1], state[2], state[3]+1, state[4], newores[1]-bp[4], newores[2]-bp[5],newores[3..-1]];
    else
        out :=  [state[1..4][], newores], # don't build
        ifelse(state[5]>=bp[2] and state[1]<max(bp[2],bp[3],bp[4],bp[6]), # build ore
               [state[1]+1, state[2..4][], newores[1]-bp[2], newores[2..-1]], NULL),
        ifelse(state[5]>=bp[3] and state[2] < bp[5], # build clay
               [state[1], state[2]+1, state[3..4][], newores[1]-bp[3], newores[2..-1]], NULL);

    end if;

    return [out];

end proc:
nbs([1,0,0,0,2,0,0,0],2);
# recursive BFS - too slow

geodecount := proc(state, bp, timeleft, $)
local nxt, pstate;
option cache;
#option trace;

    if timeleft = 0 then
        return state[8];
    end if;
    local orecap := max(blueprints[bp][2], blueprints[bp][3], blueprints[bp][4], blueprints[bp][6]);
    pstate := [ state[1..4][],
        ifelse( state[5] > orecap*timeleft - state[1]*(timeleft-1),
            orecap*timeleft - state[1]*(timeleft-1), state[5]),
        ifelse( state[6] > blueprints[bp][5]*timeleft - state[1]*(timeleft-1),
            blueprints[bp][5]*timeleft - state[1]*(timeleft-1), state[6]),
        ifelse( state[7] > blueprints[bp][7]*timeleft - state[3]*(timeleft-1),
            blueprints[bp][7]*timeleft - state[3]*(timeleft-1), state[7]),
        state[8] ];

local nbhd := nbs(pstate, bp);
local outs := map(thisproc, nbhd, bp, timeleft-1);

    return max(0,outs[]);

end proc:
#geodecount(start, 2, 16);
quality := proc(state, bpn)
option cache;
    return 10^8*state[8] + 10^6*state[4] + (blueprints[bpn][4]+blueprints[bpn][6])*(state[5]+state[1]) + blueprints[bpn][5]*(state[2]+state[6]) + 10^3*blueprints[bpn][7]*(state[3]+state[7]);
end proc;
quality(s, 2);


gsearch := proc(start, bp)
option cache;
local pq, timesofar, curr, nb, newcost, pt, dim;
uses priqueue;

    timesofar := table(sparse=infinity):

    initialize(pq):
    insert([quality(start, bp),start], pq):
    timesofar[start] := 0:
local bestsofar := 32;

local best := NULL;
    while pq[0] <> 0 do
        curr := extract(pq);

        curr := curr[2];
        if timesofar[curr] <> infinity and timesofar[curr] > bestsofar then
            next;
        end if;

        if curr[4] >= 1 then
            if timesofar[curr] < bestsofar then
                bestsofar := timesofar[curr];
                best := curr;
            elif timesofar[curr] = bestsofar then
                best := best, curr;
            end if;
            next; # don't explore all the way
        end if;

        nb := nbs(curr,bp);
        for pt in nb do
            newcost := timesofar[curr] + 1;
            if newcost < timesofar[pt] and newcost < bestsofar then
                timesofar[pt] := newcost;
                insert([-newcost,pt], pq);
            end if;
        end do;


    end do:

    return bestsofar, { best };
end proc:
# trace(gsearch);
# gsearch(start,2);
fastgeocount2 := proc(bpn)
local i, res := gsearch(start, bpn);
    if res[2] = [] then return 0;
    end if;
    return max(0, seq( geodecount( res[2][i], bpn, 32-res[1]), i=1..nops(res[2])) );
end proc;

fastgeocount := proc(bpn)
local i, res := gsearch(start, bpn);
    if res[2] = [] then return 0;
    end if;
local mres := max(map2(op,7,res[2]));
local res2 := select(i->i[7]=mres, res[2]);
    return max( 0, seq( geodecount( res2[i], bpn, 32-res[1]), i=1..nops(res2)) );
end proc;


#trace(gsearch);
#res := CodeTools:-Usage(fastgeocount(1));

ans2 := CodeTools:-Usage( seq([i,fastgeocount(i)], i = 1..nops(blueprints)));
ans2 := ans2[1][2]*ans2[2][2]*ans2[3][2];

# a little slower - same answer
#alt2 := CodeTools:-Usage( seq([i,fastgeocount2(i)], i = 1..nops(blueprints)) );
#alt2 := alt2[1][2]*alt2[2][2]*alt2[3][2];

