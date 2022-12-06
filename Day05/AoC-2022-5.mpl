with(StringTools): with(FileTools):
input := Text:-ReadFile("AoC-2022-5-input.txt" ):

temp1 := StringSplit(TrimRight(input),"\n\n");
init := Split(temp1[1],"\n");
nstacks := nops(subs(""=NULL, Split(init[-1]," ")));
theStack := [seq(DEQueue(), i=1..nstacks)];
for i to 1 from nops(init)-1 by -1 do
    for j from 1 to nstacks do
        crate := init[i][(j-1)*4+2];
        if crate <> " " then
            push_front(theStack[j], crate);
        end if;
    end do;
end do:

moves := map(s->sscanf(s, "move %d from %d to %d"), Split(temp1[2], "\n"));
(* # destroys initial state - comment out for part2
for m in moves do
    to m[1] do
        out := pop_front(theStack[m[2]]);
        push_front(theStack[m[3]],out);
    end do;
end do;
ans1 := cat(seq(convert(theStack[i],list)[1],i=1..nstacks));
*)
for m in moves do
    out := NULL;
    to m[1] do
        out := pop_front(theStack[m[2]]), out;
    end do;
    for o in out do
        push_front(theStack[m[3]],o);
    end do;
end do:
ans2 := cat(seq(convert(theStack[i],list)[1],i=1..nstacks));
