getA((a,b,c)) = a
getB((a,b,c)) = b
getC((a,b,c)) = c

count_characters([]) = (0,0,0)
count_characters (x:s) = let w = count_characters(s) in
    if(x == 'a') then (getA(w)+1,getB(w),getC(w)) 
    else if (x=='b') then (getA(w),getB(w)+1,getC(w))
    else (getA(w),getB(w),getC(w)+1)

check_constraints(k,m) = 
    if(getA(k)>=0 && getB(k)>=0 && getC(k)>=0 && getA(m) <= getB(k) + getC(k) && getB(m) <= getA(k) + getC(k) && getC(m) <= getA(k) + getB(k)) then True
    else False 

-- Replace a with b if the constraints allow it, otherwise c
-- Replace b with a if the constraints allow it, otherwise c
-- Replace c with a if the constraints allow it, otherwise b    
solve([],(ka,kb,kc),(ma,mb,mc)) = []
solve(x:s,(ka,kb,kc),(ma,mb,mc)) = 
    if(x == 'a') then if(check_constraints((ka,kb-1,kc),(ma-1,mb,mc))) then 'b':solve(s,(ka,kb-1,kc),(ma-1,mb,mc)) else 'c':solve(s,(ka,kb,kc-1),(ma-1,mb,mc)) 
    else if(x == 'b') then if(check_constraints((ka-1,kb,kc),(ma,mb-1,mc))) then 'a':solve(s,(ka-1,kb,kc),(ma,mb-1,mc)) else 'c':solve(s,(ka,kb,kc-1),(ma,mb-1,mc))
    else if (check_constraints((ka-1,kb,kc),(ma,mb,mc-1)))then 'a':solve(s,(ka-1,kb,kc),(ma,mb,mc-1)) else 'b':solve(s,(ka,kb-1,kc),(ma,mb,mc-1))


lexword k m = solve(m,count_characters(k),count_characters(m))


