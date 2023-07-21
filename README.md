# Tasks:


## 1. *Μπουγέλα*
Little Mitsos and 7 of his friends bought new waterguns and got split into two teams, A and B. The game is played as follows: Each time a player from one team splashes a player from the other team, the first player's team gains 100 points. If, within 10 seconds, the same player splashes another player of the opposite team, then their team gains 100 points, plus a bonus of 50 points (*διπλοκατάβρεγμα*). Given a list of tuples ```(t_i,p_i,q_i)```, ```0<=t_i<=1000```, ```1<=p_i,q_i<=8``` which mean that player ```p_i``` splashed player ```q_i``` at time point ```t_i```, create a function ```mpougela``` that calculates the scores of the two teams. For example:

```mpougela [(10,2,5),(15,2,6),(25,2,5)] = (400,0)```

Players of team A are indexed with 1 to 4 and players of team B are indexed with 5 to 8

### Solution

```
For each player, find the time points in which they splashed someone from the opposite team
Sort these lists for each player individually
For each player:
  Go through the sorted list. For each splash that happened in 10 seconds or less from a previous one, add 150 points.
                              For any other splash, add 100 points
For each team, sum up the points of the team's players.
```


In simple imperative programming, this algorithm has a complexity of O(nlogn), due to the sorting process (mergesort).
The Haskell implementation also has the same complexity. The main difference is that loops and iterations must be replaced with tail recursion.


## 2. *forest*
Given two trees, it is possible to connect them into a single tree by adding an edge in between *any* two nodes of the two trees. Given n trees, what is the maximum path that can be produced in the final tree, by making n-1 sequential connections between the trees? Create a function that takes as input a list of edges between the nodes and returns the length of the maximum path. For example:

```forest [(1,2)(1,3),(1,4),(5,6),(5,7),(5,8)] = 5```

Assume that the node indexes range from 1, up to some maximum index.
Also assume that the input is a valid representation of a forest

### Solution

It is fairly easy to see that this problem requires the calculation of the maximum path in each individual tree.
If we connect the endpoints of the longest paths of the trees, we will obtain a tree whose longest path will be maximum, and equal to the sum of the individual paths + n - 1



Another key observation to make is the following:

```
Assume a tree T that is (arbitrarily) rooted at some node v.
Also assume that v has exactly two neighbors, i.e. is connected to two subtrees T1 and T2

The maximum path of T:
	- Will either be contained entirely inside T1 OR T2
	- Or, will contain v

In the second case L(T) = height(T1) + height(T2) + 2

Based on this, the length of the maximum path of T can be computed by:

L(T) = max(L(T1),L(T2),height(T1)+height(T2)+2)


This can be naturally generalized for any number of neighboring subtrees.
In the second case, we will have to consider the two largest heights of subtrees, though


```
Based on this idea, we can visit the nodes of the forest in topological order and compute the length of the maximum path dynamically:

```
For each node, initialize:
	node.maximum_path = 0
	node.largest_branch = 0
	node.second_largest = 0


Insert nodes with degree of 0 or 1 into a list
sum = 0
While list is not empty:
	Select a node from the list
	if degree(node) == 0:
		sum += node.max_path + 1 //Plus one for the connecting edge
	else:
		Use the dynamic formula on the neighbors of node
		Prune node from the forest
		Insert into list any neighboring node that now has a degree of 0 or 1

answer = sum - 1 	//minus one for one extra connecting edge
```

Notice that if the forest is consisted of only one tree, this algorithm will iteratively prune leaves of the tree, updating neighboring nodes at each step, until a single node is left, that contains the length of the longest path. It is worth noting that this node, initially had a maximal degree in the tree.

If there are more trees in the forest, this process will happen individually to all trees 'in parallel', until every tree is pruned down to a single node. 

In an imperative programming language, this algorithm can be implemented in O(n) time, by using an adjacency matrix.

In a functional language, like Haskell, however, an 'adjacency structure' with constant-time operations seems impossible, due to the absense of random access.

For that reason, since we don't have arrays, we will use the next best thing: a **balanced tree structure**


By using such a structure in order to store information about the nodes, we can execute node queries and updates in logarithmic time, instead of constant time.


As a result, the previous imperative program can be transformed into a functional one that runs in O(nlogn)

