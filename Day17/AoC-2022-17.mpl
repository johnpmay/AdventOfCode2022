restart;
with(StringTools): with(FileTools):
inputt := 
">>><<><>><<<>><>>><<<>>><<<><<<>><>><<>>
";
input := Text:-ReadFile("AoC-2022-17-input.txt" ):
windpattern := TrimRight(inputt):
m := length(windpattern);
rocks := ["-", "+", "j", "l", "o"];
shape["-"] := Matrix(1..1,1..4,[1,1,1,1],datatype=integer[1]); 
shape["+"] := Matrix(1..3,1..3, [[0,1,0],[1,1,1],[0,1,0]],datatype=integer[1]);
shape["j"] := Matrix(1..3,1..3, [[0,0,1],[0,0,1],[1,1,1]],datatype=integer[1]);
shape["l"] := Matrix(1..4, 1..1, <1,1,1,1>,datatype=integer[1]);
shape["o"] := Matrix(1..2,1..2, [[1,1],[1,1]],datatype=integer[1]);
width := proc(s) (rhs-lhs)(rtable_dims(shape[s])[2])+1; end proc:
height := proc(s) (rhs-lhs)(rtable_dims(shape[s])[1])+1; end proc:
width("+"),height("+");
# bottom corner starts at [2, h+4]
# gap is 7 wide
kk := 1000;


blockedv := proc(pos, s, h, rows, $)
#option trace;
    if pos[2] = 1 then return true;
    elif pos[2]>h+1 then return false;
    end if;

    if add( shape[s][-1] *~ rows[(pos[2]-1-1 mod kk)+1, pos[1]..(pos[1]+width(s)-1)] ) = 0 then
# special case for +!
        if not s = "+" or
           add( shape[s][-2] *~ rows[(pos[2]-1 mod kk)+1, pos[1]..(pos[1]+width(s)-1)] ) = 0 
        then
             return false;
        else
             return true;
        end if;
    else
        return true;
    end if;
end proc:

blockedl := proc(pos, s, h, rows, $) #<
#option trace;
local i;
    if pos[1] <= 1 then return true;
    elif pos[2]>h then return false;
    end if;

    if add( shape[s][i,1]*rows[(pos[2]+height(s)-i-1 mod kk)+1,pos[1]-1], i=1..height(s) ) = 0 then
# special case for +
        if s <> "+" or
             add( shape[s][i,2]*rows[(pos[2]+height(s)-i-1 mod kk)+1,pos[1]], i=1..height(s) ) = 0
        then
            return false;
        else
            return true;
        end if;
    else
        return true;
    end if;
end proc:

blockedr := proc(pos, s, h, rows, $) #>
#option trace;
local i;
    if pos[1]+width(s)-1 >= 7 then return true;
    elif pos[2]>h then return false;
    end if;

# special case for +
    if add( shape[s][i,-1]*rows[(pos[2]+height(s)-i-1 mod kk)+1][pos[1]+width(s)-1+1], i=1..height(s) ) = 0 then
        if s <> "+" or
             add( shape[s][i,-2]*rows[(pos[2]+height(s)-i-1 mod kk)+1][pos[1]+width(s)-1], i=1..height(s) ) = 0
        then
            return false;
        else
            return true;
        end if;
    else
        return true;
    end if;
end proc:

windpos := proc(pos, s, w, h, rows, $)
local x := pos[1];
    
# first wind
    if windpattern[w] = "<" then
        if blockedl(pos, s, h, rows)=false then   
            x := pos[1]-1;  
        end if;
    else # ">" 
        if blockedr(pos, s, h, rows)=false then
            x := pos[1]+1;
        end if;
    end if;

    return [x, pos[2]];

end proc:

printchamber := proc(t,i,j)
local k,l;
    for k from j to i by signum(0,i-j,1) do
        printf(cat(seq(ifelse(t[(k-1 mod kk)+1,l]=0,".","#"), l=1..7),"\n")); 
    end do;
    printf("\n");
end proc:

simulate := proc(N)
local rows, currh, currock, windtick, pos, hc, wc, i, newrow, j, k,l, rsize;
#option trace;
global kk;
rows := Matrix(kk,7,0);
rsize := 0;
currh := 0;
windtick := 1;

to 4 do
     rsize := rsize+1;
     for k to 7 do
        rows[(rsize-1 mod kk)+1,k] :=0; 
     end do;
end do;
for k to N do 
   while rsize < currh+5 do
     rsize := rsize+1;
     for l to 7 do
        rows[(rsize-1 mod kk)+1,l] :=0; 
     end do;

#     rows[rsize] := Vector[row](1..7,[0$7]);
   end do;

pos := [3, currh+5];
currock := rocks[ (k-1 mod 5) +1 ];

# easy free fall for 4
to 4 do
   pos := [pos[1], pos[2]-1];
   windpattern[windtick];
   pos := windpos(pos, currock, windtick, currh, rows);
   windtick := (windtick mod m) + 1;   
end do;



to currh+1 do
#next move one if not blocked;

blockedv(pos, currock, currh, rows);
if blockedv(pos, currock, currh, rows) then # blocked
    hc := height(currock);
    wc := width(currock);
    for i from pos[2] to pos[2]+hc-1 do
       for j from pos[1] to pos[1]+wc-1 do
           rows[(i-1 mod kk) +1,j] := max(rows[(i-1 mod kk)+1,j],shape[currock][hc-i+pos[2],j-pos[1]+1]);
           
       end do;
    end do;
    currh := max(currh, pos[2]+hc-1);
    
    break # done with this block
end if;



pos := [pos[1], pos[2]-1];

# now wind
   pos := windpos(pos, currock, windtick, currh, rows);
   windtick := (windtick mod m) + 1;


end do;
if windtick = 1 and currock = rocks[-1] then
traperror( printchamber(rows, max(1,currh-5), currh+2) );
print(k, windtick, currock);
return k, currh;
end if;

#printchamber(rows, currh-5, currh+1);
end do;
( printchamber(rows, max(1,currh-5), currh+2) );
print(k-1, windtick, currock);
return currh;
end proc:

#trace(simulate);
res:=CodeTools:-Usage( simulate(10^6) );
#tracelast;

N := 2022; #1000000000000;
period := ilcm(m,nops(rocks));
count := CodeTools:-Usage(simulate(period));
rest := N mod period;
countr := simulate(period+rest) - count;
total := iquo(N,period)*count+countr; 


