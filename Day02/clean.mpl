with(StringTools): with(FileTools):
input := Text:-ReadFile("AoC-2022-2-input.txt" ):

#rock=0, paper=1, scissors=2
rounds := eval( map(Split,Split(Trim(input),"\n")),
    ["A"=0, "B"=1, "C"=2, "X"=0, "Y"=1, "Z"=2] ):
score := s->s+1;
outcome := (t,m)->(m-t+1 mod 3)*3;
ans1 := add(score(p[2])+outcome(p[]), p in rounds);

# solve for m: o = 3*outcome(t,m) = m-t+1 mod 3
mychoice := (t,o) -> (o+t-1) mod 3;
ans2 := add(p[2]*3+score(mychoice(p[])), p in rounds);



