
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


------------------------------------------------------------------------

-- Get records that refer to player with id 'player_id'
getplayerlist ([], player_id)=[]
getplayerlist ((t,p,q):list, player_id) = 
    if (player_id == p) then (t,p,q):getplayerlist(list,player_id)
    else getplayerlist(list,player_id)


--Given a sorted list of shootings done by the same player, count the player's points
countpoints([],last_time) = 0
countpoints((t,p,q):list,last_time) = 
    if ((p-1) `div` 4 == (q-1) `div` 4 ) then countpoints(list,last_time)     --Friendly fire/self shooting does not count
    else countpoints(list,t) + if(t-last_time<=10) then 150 else 100          



team_points(list,player_id,first_player) = 
    if(player_id<first_player || player_id>first_player+3) then 0
    else
        countpoints(mergesort(getplayerlist(list,player_id),\(t1,p1,q1) (t2,p2,q2) -> t1<t2),-11) + team_points(list,player_id+1,first_player)

mpougela(list) = (team_points(list,1,1),team_points(list,5,5))








