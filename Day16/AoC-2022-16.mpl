restart;
with(StringTools): with(FileTools):
inputt :=
"Valve AA has flow rate=0; tunnels lead to valves DD, II, BB
Valve BB has flow rate=13; tunnels lead to valves CC, AA
Valve CC has flow rate=2; tunnels lead to valves DD, BB
Valve DD has flow rate=20; tunnels lead to valves CC, AA, EE
Valve EE has flow rate=3; tunnels lead to valves FF, DD
Valve FF has flow rate=0; tunnels lead to valves EE, GG
Valve GG has flow rate=0; tunnels lead to valves FF, HH
Valve HH has flow rate=22; tunnel leads to valve GG
Valve II has flow rate=0; tunnels lead to valves AA, JJ
Valve JJ has flow rate=21; tunnel leads to valve II
":

input := Text:-ReadFile("AoC-2022-16-input.txt" ):
valvs :=  map(s->Split(s,";"), Split(TrimRight(input),"\n"));
data := [seq]([convert(v[1][7..8],'name'),parse(Split(v[1], "=")[2]), [parse](v[2][24..-1])], v in valvs);
n := map2(op,1,data); member('AA', n, 'start');
data:=subs(seq(n[i]=i, i=1..nops(n)), data);
a := Matrix(nops(n),nops(n), (i,j)->ifelse(j in data[i][3], 1, 0)):
g:=GraphTheory:-Graph(a);
#GraphTheory:-DrawGraph(g,style=spring,redraw,size=[800,800]);
start;

SP := proc() option remember; GraphTheory:-ShortestPath(_passed); end proc:

tmp:=select(t->t[2]<>0, data): goodvalves := map2(op,1,tmp):
sortPaths := proc(p, gv)
global g, data;
option remember;
#option trace;
local wt := map(i->-1.*data[i][2]/sqrt(1.*nops(SP(g,p,i))), gv);
    wt := sort(wt, output=permutation);
    return gv[wt];
end proc:
seq(sortPaths(i, goodvalves), i=1..nops(data)):

 PRUNEWT := .85; # works for part 2
# PRUNEWT := .80;

walk := proc(p, timeleft, flow, released, path, goodvalves)
global g, data, bestsofar, counter, PRUNEWT;
local status, tmp, best, newflow, ve, vh, paths, gv, i,j, gv2;
option cache(40000000);

    status := [27-timeleft, flow];

    if timeleft = "start" then
        counter := 0;
        bestsofar := table(sparse=-infinity);
        gv := sortPaths(1, goodvalves);


        best := (0,[]);
# first step symmetry in e and h
        for i to nops(gv) do
            for j from i+1 to nops(gv) do
                vh := gv[j]; ve := gv[i];
                paths := [SP(g, p[1], vh), SP(g, p[2], ve)];
                tmp := thisproc([paths[1][2], paths[2][2]],
                                26,
                                flow, released,
                                [[paths[1][3..-1][],paths[1][-1]], [paths[2][3..-1][], paths[2][-1]]],
                                subs(ve=NULL, vh=NULL, goodvalves));
                if tmp[1]>best[1] then
                    best := tmp;
                end if;
            end do;
        end do;
        printf("\n\n");
        return best[1], [[0,0]=p, best[2][]];
    end if;

    counter := counter+1;

    if counter mod 500000 = 0 then printf("%d ",counter); end if;

    # PRUNE
    if bestsofar[timeleft] < released+flow then
        bestsofar[timeleft] := released+flow;
    elif bestsofar[timeleft]<>-infinity and bestsofar[timeleft]*PRUNEWT > released+flow then
        return -infinity, [p];
    end if;



    if timeleft = 1 then
        return released+flow, [status=p];
    end if;

# cases
# h+e moving
# h+e opening
# h open, e moving
# h moving, e open

# where to go next
    if path[1]<>[] and path[2]<>[] then # h+e moving
        # released increases, flow stays
        tmp := thisproc([path[1][1], path[2][1]], timeleft-1, flow, released+flow, [path[1][2..-1], path[2][2..-1]], goodvalves);

        return tmp[1], [status=p, tmp[2][]];


    elif path[1] = [] and path[2] = [] then
        # h+e ready to open
        newflow := flow + data[p[1]][2] + data[p[2]][2];

# search for best paths

        if nops(goodvalves) >= 2 then
            best := (-infinity,[p]);
            gv := sortPaths(p[1], goodvalves);
            for vh in gv do
                gv2 := sortPaths(p[2], goodvalves);
                for ve in gv2 do
                    if ve = vh then next; end if;
                    paths := [SP(g, p[1], vh), SP(g, p[2], ve)];
                    tmp := thisproc([paths[1][2], paths[2][2]],
                                    timeleft-1,
                                    newflow, released+flow,
                                    [[paths[1][3..-1][],paths[1][-1]], [paths[2][3..-1][], paths[2][-1]]],
                                    subs(ve=NULL, vh=NULL, goodvalves));
                    if tmp[1]>best[1] then
                        best := tmp;
                    end if;
                end do;
            end do;
            return best[1], [status="both open", best[2][]];


        elif nops(goodvalves) =1 then
            # e idle, search h

            vh := goodvalves[1];
            paths := [SP(g, p[1], vh)];
            tmp := thisproc([paths[1][2], p[2]], timeleft-1, newflow, released+flow, [[paths[1][3..-1][],paths[1][-1]], p[2]$timeleft], subs(vh=NULL, goodvalves));


            return tmp[1], [status=["h open","e done"], tmp[2][]];


        else
            # both idle
            tmp := thisproc([p[1],  p[2]], timeleft-1, newflow, released+flow, [[p[1]$timeleft], [p[2]$timeleft]], []);
            return tmp[1], [status="both done", tmp[2][]];
        end if;
    elif path[1] = [] then # h at end
        newflow := flow + data[p[1]][2];

        if nops(goodvalves) >= 1 then
            best := (-infinity,[p]);
            gv := sortPaths(p[1], goodvalves);
            for vh in gv do

                paths := [SP(g, p[1], vh)];
                tmp := thisproc([paths[1][2], path[2][1]], timeleft-1, newflow, released+flow, [[paths[1][3..-1][],paths[1][-1]], path[2][2..-1]], subs(vh=NULL, goodvalves));
                if tmp[1]>best[1] then
                    best := tmp;
                end if;

            end do;
            return best[1], [status=["h open",p[2]], best[2][]];
        else # h idles
            tmp := thisproc([p[1],  path[2][1]], timeleft-1, newflow, released+flow, [[p[1]$timeleft], path[2][2..-1]], []);
            return tmp[1], [status=["h open", p[2]], tmp[2][]];
        end if;
    elif path[2] = [] then # e at end
        newflow := flow + data[p[2]][2];

        if nops(goodvalves) >= 1 then
            best := (-infinity,[p]);
            gv := sortPaths(p[2], goodvalves);
            for ve in gv do

                paths := [[],SP(g, p[2], ve)];
                tmp := thisproc([path[1][1], paths[2][2]], timeleft-1, newflow, released+flow, [path[1][2..-1], [paths[2][3..-1][],paths[2][-1]]], subs(ve=NULL, goodvalves));
                if tmp[1]>best[1] then
                    best := tmp;
                end if;

            end do;
            return best[1], [status=[p[1],"e open"], best[2][]];

        else # e idles
            tmp := thisproc([path[1][1],p[2]], timeleft-1, newflow, released+flow, [path[1][2..-1], [p[2]$timeleft]], []);
            return tmp[1], [status=[p[1],"e open"], tmp[2][]];

        end if;



    else
        error "NYI";
    end if;

end proc:

tmp:=select(t->t[2]<>0, data): goodvalves := map2(op,1,tmp): counter := 0:
walk([start,start], "start", 0, 0, [[],[]], goodvalves);
#nops(%[2]); counter; eval(bestsofar);
ans2 := %[1];


