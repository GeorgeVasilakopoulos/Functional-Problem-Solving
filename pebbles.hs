
-- Compare two subproblems
-- Return subproblem that is the most favourable to the first player.
compare_intervals(((lchar1,rchar1),(m1,k1),bcounter1) , ((lchar2,rchar2),(m2,k2),bcounter2)) =
     if(m1<=m2) then ((lchar1,rchar1),(m1,k1),bcounter1)
     else ((lchar2,rchar2),(m2,k2),bcounter2)


-- In c[subproblem], where c=b/w
-- What is the entire subproblem if the first player chooses c in their first move 
apply_char ('l', c, ((lchar,rchar),(m,k),bcounter)) =
     if c == 'b' then (('b',rchar),(k+2,m-1),bcounter+1) 
     else (('w',rchar),(k+1,m-1),bcounter)


-- Similarly if c is on the right [subproblem]c
apply_char ('r', c, ((lchar,rchar),(m,k),bcounter)) = 
     if c == 'b' then ((lchar,'b'),(k+2,m-1),bcounter+1) 
     else ((lchar,'w'),(k+1,m-1),bcounter)

-- with the help of apply_char, when we want to evaluate a state c1[subproblem]c2,
-- we can compare the subproblems c1[subproblem] and [subproblem]c2 and choose the most favourable move 

isblack = (\x->if (x=='b') then 1 else 0)


--Combining two partially overlapping intervals I1, I2 INTO lchar1[subproblem]rchar2,
-- I1 = lchar1[subproblem], I2 = [subproblem]rchar2

-- If lchar1=rchar2='b' and the new subproblem contains 'param' b's, fall back to base case
-- Else, apply characters and select the most favourable subproblem
combine_intervals (param,((lchar1,rchar1),(m1,k1),bcounter1),((lchar2,rchar2),(m2,k2),bcounter2)) =
     let newbcounter = (bcounter1 + bcounter2 - (isblack lchar1) - (isblack rchar2))/2 +  (isblack lchar1) + (isblack rchar2) 
     in 
          if(newbcounter == param && lchar1 == 'b' && rchar2 == 'b') then ((lchar1,rchar2),(2,0),newbcounter)
          else let leftint = apply_char('l' , lchar1,((lchar2,rchar2),(m2,k2),bcounter2))
                   rightint = apply_char('r',rchar2,((lchar1,rchar1),(m1,k1),bcounter1))
               in compare_intervals(leftint,rightint)


-- in [int] we have a list of adjacent intervals of size n
-- combine them by adjacent pairs and return adjacent intervals of size n+1
produce_next_layer(param,[int]) = []
produce_next_layer(param,int1:(int2:l)) = (combine_intervals(param,int1,int2)):(produce_next_layer(param,int2:l))

--According to the dp formula, if m<=k then the first player (m) wins
iterate_layers(param,[((l,r),(m,k),bcounter)]) = if (m<=k) then "yes" else "no"
iterate_layers(param,l) = iterate_layers(param,produce_next_layer(param,l))

--Get left character of interval
getcharacter((lchar1,rchar1),(m,k),bcounter) = lchar1

isemptylist([]) = True
isemptylist(l) = False

--base cases
make_first_layer(['b'])=[(('b','b'),(2,0),1)]     
make_first_layer(['w'])=[(('w','w'),(1,0),0)]


make_first_layer(c:l) = let w = make_first_layer(l) 
                              in 
                                   if (isemptylist(w)) then if (c == 'w') then [(('w','w'),(1,0),0)] else [(('b','b'),(2,0),1)] 
                                   else if (getcharacter(head w) == 'w' && c == 'w') then tail w --Remove pairs of adjacent white pebbles
                                   else if (c == 'w') then (('w','w'),(1,0),0):w
                                   else (('b','b'),(2,0),1):w

count_black ([]) = 0
count_black (c:l) = if c == 'b' then count_black(l) + 1 else count_black(l) 


pebbles l k = iterate_layers(count_black(l)-2*k +2,make_first_layer(l))