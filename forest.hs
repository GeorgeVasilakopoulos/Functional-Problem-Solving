data Tree a = Empty | Node a (Tree a)(Tree a)


--Node format:
--(n. of neighbors, neighbors list, is visited,(a,b,c))
-- where:
-- a -> size of longest path that includes the node
-- b -> size of longest path that starts at node
-- c -> size of second longest path that starts at node
-- (a,b,c) is referred as 'info'

--a = b + c

initial_node = (0,[],False,(0,0,0)) 


-- Tree Node functions
isvisited (nn,nlist,visited,info) = visited
getNeighbors (nn,nlist,visited,info) = nlist
getNN (nn,nlist,visited,info) = nn
getinfo (nn,nlist,visited,info) = info
getmaxpath(nn,nlist,visited,(a,b,c)) = a


--Visit Node
visit (nn,nlist,visited,info) = (nn,nlist,True,info) 

--Add val to neighbor count of node
addToNeighborCount val (nn,nlist,visited,info) = (nn+val,nlist,visited,info)

-- Add neighbor to neighbor list. Add 1 to n of neighbors
addNeighbor neighbor (nn,nlist,visited,info) = (nn+1,neighbor:nlist,visited,info)

-- Update info of node 1, when it gets connected with a node 2 that has info (maxpath2,first2,second2)
nodeupdate (maxpath2,first2,second2) (nn,nlist,visited,(maxpath1,first1,second1)) = 
    let first3 = max first1 (first2 + 1)
        second3 = max (min first1 (first2 + 1)) second1
    in 
        (nn,nlist,visited,(max (first3 + second3) (max maxpath1 maxpath2),first3,second3))




-- Visit node in tree
-- Output is the result of visit_fun on desired node
view_tree(Node (n,node)(left)(right), node_id, visit_fun) =
    if (n == node_id) then visit_fun node       
    else if (node_id < n) then view_tree(left,node_id,visit_fun) else view_tree(right,node_id,visit_fun)


-- Update node in tree
-- Output is the new tree
update_tree(Node (n,node)(left)(right), node_id, visit_fun) =
    if (n == node_id) then Node (n,visit_fun node)(left)(right) --Replace node with visit_fun node
    else if (node_id < n) then Node (n,node)(update_tree(left,node_id,visit_fun))(right) else Node (n,node)(left)(update_tree(right,node_id,visit_fun))



-- traverse_tree :: Ord a => (Tree (a, b), a, b -> b) -> [a]
traverse_tree(tree,visit_fun) = nodes_inorder(tree,visit_fun,[])


-- Visits nodes in-order through visit_fun
-- Output is the inorder concatenation of visit_fun outputs on each node 
nodes_inorder(Empty, visit_fun,list)=list
nodes_inorder(Node (n,node)(left)(right), visit_fun,list)=
    let right_result = nodes_inorder(right, visit_fun,list) in
    nodes_inorder(left, visit_fun,(visit_fun (n,node)):right_result)

-- Create Tree with indices, ranging from l to r (can be of any ordinal type)
-- All nodes are initialized with initial_node
maketree(l,r) = 
    if (l>r) then Empty
    else Node ((l+r)`div` 2,initial_node)(maketree(l,(l+r)`div` 2 - 1))(maketree((l+r)`div` 2 + 1,r))


-- Add list of edges to tree
addEdges([],tree)=tree
addEdges(((x,y):l),tree) = addEdges(l,update_tree(update_tree(tree,x,addNeighbor y),y,addNeighbor x))  


--Given a list of single-itemed lists, return a list of the items
removebrackets([])=[]
removebrackets([x]:l) = x:removebrackets(l)
removebrackets([]:l) = removebrackets(l)

-- Initial are nodes that have at most 1 neighbor
-- Traverse tree with this visit function \(x,y) -> if((\t->(t==0)||(t==1)) (getNN y)) then [x] else [])
-- x is the id of the node and y is the node itself
-- returns list of the initial node ids
getInitial(Node (n,node)(left)(right)) = removebrackets(traverse_tree(Node (n,node)(left)(right),\(x,y) -> if((getNN y)==0||(getNN y)==1) then [x] else []))



-- Find max node in list of edges
find_max_node [] = 0
find_max_node ((x,y):l) = max x (max (find_max_node l) y) 


-- 'tree' is the node tree. 'list' is an accumulator 
-- given a list (x:l) of neighbors of some node with 'info'
-- Go through the neighbor list and for each unvisited node, decrement its neighbor count
--      if the neighbor count becomes 1, add node to the accumulator list 
iterate_neighbor_list(info,[],tree,list) = (tree,list)
iterate_neighbor_list(info,(x:l),tree,list)=if(view_tree(tree,x,isvisited) == False) then
                                                let w = iterate_neighbor_list(info,l,update_tree(update_tree(tree,x,nodeupdate info),x,addToNeighborCount (-1)),list)                                             
                                                in  if(view_tree(fst w,x,getNN) == 1) then (fst w, x:(snd w))
                                                    else w
                                            else
                                                iterate_neighbor_list(info,l,tree,list)


-- Go through l. Each node that has 0 neighbors now represents a tree. Therefore maxpath is the maximum path of the tree
--                      This means that the nodes maxpath + 1 + iteratelist on the rest of the list will give us the max path
-- For any other node n, we call iterate_neighbor_list on its neighbors, effectively pruning the node from its
--      remaining neighbors and adding into l any other nodes - neighbors of n that now have a degree of 1
iteratelist(tree,[]) = 0
iteratelist(tree,x:l) = if(view_tree(tree,x,getNN) == 0) then view_tree(tree,x,getmaxpath) + 1 + iteratelist(update_tree(tree,x,visit),l)
                        else iteratelist (iterate_neighbor_list(view_tree(tree,x,getinfo),view_tree(tree,x,getNeighbors),tree,l))




-- iterate_list adds +1 to the result for each tree (representing the edges that connect the trees)
-- We must subtract 1 to get the result
forest [] = 0
forest l = let w = addEdges(l,maketree(1,find_max_node(l))) 
            in 
                iteratelist(w,getInitial(w)) - 1
