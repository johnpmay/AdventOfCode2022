with(StringTools): with(FileTools):
input := Text:-ReadFile("AoC-2022-7-input.txt" ):

listing := Split(TrimRight(input),"\n"):
dirtable := table();
currdir := "";
dirstack := DEQueue();

for l in listing do
    if l[1] = "$" then
        if l = "$ ls" then
            next;
        elif l = "$ cd .." then
            currdir := pop_back(dirstack);
        else
            push_back(dirstack, currdir);
            currdir := Split(l," ")[-1];
        end if;
        if currdir <> "/" then
            fulldir := cat("/",Join([convert(dirstack,list)[3..-1][],currdir],"/"));
        else
            fulldir:="/";
        end if;
        if not type(dirtable[fulldir],set) then
            dirtable[fulldir] := {};
        end if;
    else 
       tmp := Split(l, " ");
       if tmp[1] <> "dir" then
           tmp := [parse(tmp[1]), tmp[2]];
       end if;
       dirtable[fulldir] := dirtable[fulldir] union {tmp};
    end if;
end do:

directories := {indices(dirtable,'nolist')} minus {"/"};
dirsize := proc(d)
local lsf, lsd, f;
    (lsd, lsf) := selectremove(e->e[1]="dir", dirtable[d]);
    add(f[1], f in lsf)
        + add( thisproc(cat(ifelse(d="/","",d),"/",f[2])), f in lsd );
end proc:

ans1 := add(rhs~(select(d->rhs(d)<100000, [seq(e=dirsize(e), e in directories)])));

# part 2
tot := 70000000; goal := tot - dirsize("/");
need := 30000000; target := need - goal;
bigdirs := select( d->dirsize(d) > target, directories);
dirsizes := map(dirsize, bigdirs);
ans2 := min(dirsizes);


