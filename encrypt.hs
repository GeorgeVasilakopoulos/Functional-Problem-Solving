import Data.Char (ord,chr)

--Mergesort algorithm

divide_list([],i,n)=([],[])
divide_list(x:list,i,n) = 
    if (i==n) then ([],x:list)
    else (x:fst w, snd w)
    where w = divide_list(list,i+1,n)

merge_lists([],l,comp) = l
merge_lists(l,[],comp) = l
merge_lists(x:l1,y:l2,comp) = 
    if(comp x y)then x:merge_lists(l1,y:l2,comp)
    else y:merge_lists(x:l1,l2,comp)

mergesort([],comp)=[]
mergesort(list,comp) = 
    let len = length list
        two_parts = divide_list(list,0,len `div` 2)
    in 
        if (len == 1) then list
        else merge_lists(mergesort(fst two_parts,comp), mergesort(snd two_parts,comp),comp)

-------------------------------------------

data Tree a = Empty | Node a (Tree a)(Tree a)

initial_node = (0,[])

inList([],x) = False
inList(y:l,x)=if(x == y) then True else inList(l,x)


remove_from_neighbor_list x (nn,[]) =(nn,[])
remove_from_neighbor_list x (nn,(y:l)) = if(x == y)then (nn,l) else let w = remove_from_neighbor_list x (nn,l) in (fst w,y:(snd w))

--Similar to problem 2
maketree(l,r) = 
    if (l>r) then Empty
    else let temp = (((ord l)+(ord r))`div` 2) in Node (chr temp,initial_node)(maketree(l,chr(temp - 1)))(maketree(chr(temp + 1),r))

traverse_tree(Empty, visit_fun)=[]
traverse_tree(Node (n,node)(left)(right), visit_fun)=
    traverse_tree(left, visit_fun) ++ [visit_fun (n,node)] ++ traverse_tree(right, visit_fun)


view_tree(Node (n,node)(left)(right), node_id, visit_fun) =
    if (n == node_id) then visit_fun node
    else if (node_id < n) then view_tree(left,node_id,visit_fun) else view_tree(right,node_id,visit_fun)

update_tree(Node (n,node)(left)(right), node_id, visit_fun) =
    if (n == node_id) then Node (n,visit_fun node)(left)(right)
    else if (node_id < n) then Node (n,node)(update_tree(left,node_id,visit_fun))(right) else Node (n,node)(left)(update_tree(right,node_id,visit_fun))

setNN val (nn,l) = (nn+val,l)
addNeighbor n (nn,l) = (nn,n:l)

getNeighborList (nn,l) = l
getNN(nn,l) = nn

iterate_neighbor_list(n,[],set,tree) = (set,tree)
iterate_neighbor_list(n, m:nlist,set,tree) = let w = update_tree(update_tree(tree,n,remove_from_neighbor_list m),m,setNN (-1)) in if(view_tree(w,m,getNN) == 0) then iterate_neighbor_list(n,nlist,m:set,w) else iterate_neighbor_list(n,nlist,set,w) 


topsort(list,[],tree) = list
topsort(list,(n:set),tree) = let w = iterate_neighbor_list(n,view_tree(tree,n,getNeighborList),set,tree) in topsort(n:list,fst w,snd w)


addEdge(x,y,tree) = if(inList(view_tree(tree,x,getNeighborList),y) == False) then update_tree(update_tree(tree,x, addNeighbor y),y,setNN 1) else tree

connect_lists([],[]) = []
connect_lists((x:l1),(y:l2)) = (x,y):(connect_lists(l1,l2))

add_indeces_fst([],i)=[]
add_indeces_fst((x:l),i) = (i,x):add_indeces_fst(l,i+1)
remove_indeces([]) = []
remove_indeces((a,b):l) =  a:remove_indeces(l)
transpose_permutation(l) =  remove_indeces(mergesort(add_indeces_fst(l,1),\x y -> (snd x) < (snd y)))


isemptytuple(([],[])) = True
isemptytuple((a,b)) = False

isemptylist([]) = True
isemptylist(l) = False

words_starting_with(c,[]) = ([],[])
words_starting_with(c,[]:word_list) = ([],[]:word_list)
words_starting_with(c,(x:string):word_list) = 
    if(c == x) then let w = words_starting_with(c,word_list) in (string:fst w,snd w)
    else ([],(x:string):word_list)

remove_empty_lists([]:l) = remove_empty_lists(l)
remove_empty_lists(l) = l

add_constraints(l,tree) = let w = remove_empty_lists(l) in
                              if (isemptylist(w)) then (tree,True) 
                              else let t = words_starting_with(head (head w),w) in
                                    if(isemptytuple(t)) then (tree,True)
                                    else if(isemptylist(snd t)) then add_constraints(fst t,tree)
                                    else if (isemptylist(head (snd t))) then (tree,False)
                                    else let t1 = add_constraints(fst t, tree)
                                             t2 = add_constraints(snd t, fst t1) in
                                                (addEdge(head (head w),head (head (snd t)),fst t2),(snd t2) && (snd t1))


removebrackets([])=[]
removebrackets([x]:l) = x:removebrackets(l)
removebrackets([]:l) = removebrackets(l)

getInitial(Node (n,node)(left)(right)) = removebrackets(traverse_tree(Node (n,node)(left)(right),\(x,y) -> if((\t->(t==0))(getNN y)) then [x] else []))

intlisttochar []=[]
intlisttochar (i:l)  = chr(i-1 + ord 'a'):intlisttochar(l)

encrypt strings perm  = let w = add_constraints(remove_indeces(mergesort(connect_lists(strings,transpose_permutation(perm)),\x y -> (snd x) < (snd y))),maketree('a','z')) in
    if(snd w == False) then ("no",[])
    else let d = reverse (topsort([],getInitial(fst w),fst w)) in if ((length d) < 26) then ("no",[]) else ("yes",intlisttochar (transpose_permutation(d)))



