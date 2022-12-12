restart;
with(StringTools): with(FileTools):
input := Text:-ReadFile("AoC-2022-12-input.txt" ):

grid := Array(Explode~(Split(TrimRight(input),"\n")));
dim:=rhs~([rtable_dims(grid)]);
member("S", grid, 'startl'): startl;
member("E", grid, 'endl'): endl;

grid[startl] := "a";
grid[endl] := "z";
grid := map(c->ToByteArray(c)[1]-96, grid);

nbs := proc(i,j,dim)
local out := NULL;
    if i < dim[1] then
       out := out, [i+1, j];
    end if;
    if j < dim[2] then
       out := out, [i, j+1];
    end if;

    if i > 1 then
      out := out, [i-1,j];
    end if;
    if j > 1 then
       out := out, [i, j-1];
    end if;

    return [out];
end proc:

Dijkstra := proc(start, theend, grid)
local pq, costsofar, curr, nb, newcost, pt, dim; 
uses priqueue;

dim:=rhs~([rtable_dims(grid)]);
costsofar := table(sparse=infinity):

    initialize(pq):
    insert([0,start], pq):
    costsofar[start] := 0:

    while pq[0] <> 0 do
        curr := extract(pq)[2];
        if curr = theend then
            return costsofar[theend];
        end if;
        # climb at most one
        nb := select(n->grid[n[]]<=grid(curr[])+1, nbs(curr[], dim));
        for pt in nb do
            newcost := costsofar[curr] + 1;
            if newcost < costsofar[pt] then
                costsofar[pt] := newcost;
                insert([-newcost,pt], pq);
            end if;
        end do;
    end do:
end proc:
ans1 := Dijkstra([startl], [endl], grid);

(*ans2 := ans1:
for i from 1 to dim[1] do
    for j from 1 to dim[2] do
        if grid[i,j] = 1 then
            tmp := Dijkstra([i,j], [endl], grid);
            #print([i,j],tmp);
            ans2 := min(tmp, ans2);
        end if;
    end do;
end do;
ans2;*)

DijkstraAll := proc(theend, start, grid)
local pq, costsofar, curr, nb, newcost, pt, dim; 
uses priqueue;

    dim:=rhs~([rtable_dims(grid)]);
    costsofar := table(sparse=infinity):

    initialize(pq):
    insert([0,start], pq):
    costsofar[start] := 0:

    while pq[0] <> 0 do
    curr := extract(pq)[2];
        if curr = theend then
            return min( seq(seq(ifelse(grid[i,j]=1,costsofar[[i,j]],NULL),
                i=1..dim[1]), j=1..dim[2]) );
        end if;
        nb := select(n->grid[curr[]]<=grid[n[]]+1, nbs(curr[], dim));
        for pt in nb do
            newcost := costsofar[curr] + 1;
            if newcost < costsofar[pt] then
                costsofar[pt] := newcost;
                insert([-newcost,pt], pq);
            end if;
        end do;
    end do:

end proc:
ans2 := DijkstraAll([startl], [endl], grid);

