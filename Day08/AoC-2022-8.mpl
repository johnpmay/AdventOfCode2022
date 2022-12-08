with(StringTools): with(FileTools):
input := Text:-ReadFile("AoC-2022-8-input.txt" ):

grid := Matrix( map(r->parse~(r), Explode~(Split(TrimRight(input)))));
(r,c) := op(rhs~([rtable_dims(grid)]));

vis := Matrix(r, c, (i,j)->ifelse(i=1 or j=1 or i=r or j=c, 1, 0));

# sweep left
for i from 2 to r-1 do
    maxh := grid[i,1];
    for j from 2 to c-1 do
        if grid[i,j] > maxh then
            vis[i,j] := 1;
            maxh := grid[i,j];
        end if;
    end do;
end do:

# sweep right
for i from 2 to r-1 do
    maxh := grid[i,c];
    for j from c-1 to 2 by -1 do
        if grid[i,j] > maxh then
            vis[i,j] := 1;
            maxh := grid[i,j];
        end if;
    end do;
end do:

# sweep down
for i from 2 to c-1 do
    maxh := grid[1,i];
    for j from 2 to r-1 do
        if grid[j,i] > maxh then
            vis[j,i] := 1;
            maxh := grid[j,i];
        end if;
    end do;
end do:

# sweep up
for i from 2 to c-1 do
    maxh := grid[r,i];
    for j from r-1 to 2 by -1 do
        if grid[j,i] > maxh then
            vis[j,i] := 1;
            maxh := grid[j,i];
        end if;
    end do;
end do:

ans1 := add(vis);

calcscore := proc(a,b)
global r,c,grid;
local ls, rs, us, ds, i;
local h := grid[a,b];

# sweep down
ds := 0;
for i from a+1 to c do
    ds := ds + 1;
    if grid[i,b] >= h then
         break;
    end if;
end do;

# sweep up
us := 0;
for i from a-1 to 1 by -1 do   
    us := us + 1;
    if grid[i,b] >= h then
         break;
    end if;
end do;

# sweep right
rs := 0;
for i from b+1 to r do  
    rs := rs + 1;
    if grid[a,i] >= h then
         break;
    end if;
end do;

# sweep left
ls := 0;
for i from b-1 to 1 by -1 do
    ls := ls + 1;
    if grid[a,i] >= h then
         break;
    end if;
end do;

return `*`(us, ls, ds, rs);

end proc:

score := Matrix(r, c, calcscore);
ans2 := max(score);


