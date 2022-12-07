restart;
with(StringTools): with(FileTools):
input := Text:-ReadFile("AoC-2022-6-input.txt" ):

letters := TrimRight(input): length(letters);

for i from 4 to length(letters) do
    if nops({Explode(letters[i-3..i])[]}) = 4 then
         ans1 := i; break;
    end if;
end do:
ans1;

for i from 14 to length(letters) do
    if nops({Explode(letters[i-13..i])[]}) = 14 then
         ans2 := i; break;
    end if;
end do:
ans2;


