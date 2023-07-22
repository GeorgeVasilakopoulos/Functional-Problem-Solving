# Tasks:

1. [μπουγέλα](#1-μπουγέλα-)
2. [forest](#2-forest-)
3. [pebbles](#3-pebbles---)
4. [lexword](#4-lexword-)
5. [encrypt](#5-encrypt-)

This set of problems was given as an assignment in course ```ΘΠ01 Principles of Programming Languages```. \
This submission was the *only* one that received a perfect score, passing even the most obscure corner cases.


## 1. *μπουγέλα* 🔫
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

---



## 2. *forest* 🌲🌲
Given two trees, it is possible to connect them into a single tree by adding an edge in between *any* two nodes of the two trees. Given n trees, what is the maximum path that can be produced in the final tree, by making n-1 sequential connections between the trees? Define a function that takes as input a list of edges between the nodes and returns the length of the maximum path. For example:

```forest [(1,2)(1,3),(1,4),(5,6),(5,7),(5,8)] = 5```

Assume that the node indexes range from 1, up to some maximum index.

Also assume that the input is a valid representation of a forest.

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

---


## 3. *pebbles* 🪨🪨  🪨

Mitsos and Kitsos play the following game: 

 - They have placed n pebbles side by side and each pebble is either *black* or *white*. 

 - Mitsos plays first and he must choose to take a pebble from either side of the line of pebbles. 

 - Then, it's Kitsos' turn to pick a pebble from either side. 

 - The game stops when one of the players has collected a total of K *black* pebbles, in which case he loses and the other player wins.  

 - There are **at least** 2K-1 black pebbles in the line.


Mitsos wonders whether he can beat Kitsos regardless of how well he plays.

Define a function `pebbles` that takes as input a string representing the pebble order and a number K < n and returns 'yes' if Mitsos can win regardless of how Kitsos plays and 'no' otherwise.

For example:

```
pebbles "bbbw" 1 = "yes"  //Mitsos takes w and Kitsos is forced to take a b and loses
pebbles "wwbwbwwb" 1 = "no"
```


### Solution


First, let's consider a simpler version of this game, in which there are **exactly** 2K-1 black pebbles in the list. In this version of the game, the last person to take a black pebble loses.

In this version, the following property holds:

```
The objective of minimizing the gained black pebbles is equivalent to the objective of not getting the last black pebble
```


This problem can be solved with dynamic programming:

- Each subproblem is a substring of the given string. This means that there are n(n+1)/2 subproblems

- For each subproblem we will calculate the *minimum number of pebbles* that each player will get if both of them play optimally. 

- **Base Cases**: 
	
	```
	dp("b") = (1,0)  		//In the end of this game, Mitsos will have 1 black pebble and Kitsos 0
	
	dp("w") = (0,0) 		//Mitsos 0 Kitsos 0	
	```

- **Dynamic Formula**:

	Assume that we want to find ```dp(lSr)```, where ```l,r``` are either 'b' or 'w' and S is a subproblem (i.e. a substring of b's and w's)

	Also, assume that ```dp(lS) = (ml,kl)``` and ```dp(Sr) = (mr,kr)``` have already been computed (hypothesis of recursion).


	- If Mitsos, who plays first, chooses ```l```, then if ```l``` is 'b', then he will get one black and ***as many blacks as Kitsos would get*** in the subproblem ```Sr``` Otherwise, if ```l``` is 'w', then Mitsos would get *only* as many as Kitsos in ```Sr```

	- Symmetrically, if Mitsos chooses ```r```, then he will get as many as Kitsos would in ```lS``` plus one, if ```r``` is black.

	- Since Mitsos plays optimally, he will pick `l` or `r` based on the number of black pebbles that he will have at the end of the game:

	```
	If Mitsos chooses l
		If l is 'b', (kr+1,mr)		//Mitsos gets kr+1 Kitsos gets mr
		If l is 'w', (kr,mr)
	If Mitsos chooses r
		If r is 'b', (kl+1,ml)
		If r is 'w', (kl,ml)
	```

	Therefore, the number of black pebbles that each player will get if they play optimally, can be computed through `dp`, by the following recursive algorithm:

	```
	most_favourable((m1,k1),(m2,k2)):
		if(m1<m2) then 
			return (m1,k1)
		else 
			return (m2,k2)


	//Argument Pattern Matching
	dp('b'):
		return (1,0)
	dp('w'):
		returns (0,0)
	dp(lSr):
		
		(ml,kl) := dp(lS)
		(mr,kr) := dp(Sr)

		return most_favourable(
			(kl + (r=='b') , ml),			//r==b returns 1 if condition true, 0 otherwise
			(kr + (l=='b') , mr)
			)
	```


	Notice that the computation of ```dp(lSr)``` requires the result of two subproblems of size one less than ```lSr```. Therefore, dp can be computed dynamically as follows:

	```
	Calculate dp for all subproblems of size 1 (n in total)
	Calculate dp for all subproblems of size 2 (n-1 in total)
	... 
	Calculate dp for all subproblems of size n (1 in total)
	```

A typical implementation of this in an imperative language would utilize a 2D array ```dp[i][j]``` to store the subproblem results. In the first iteration, the diagonal ```dp[1][1], dp[2][2] ... dp[n][n]``` of the array would be computed. Then, the adjacent diagonal ```dp[1][2], dp[2][3],...dp[n-1][n]```, and so on...up until the corner ```dp[n][n]```.  



It turns out that this solution can be *slightly modified* to be **applicable to the original problem**:

```
Consider an instance of the original problem: "wbwbbwbwbbwbwwb" with K = 3

The algorithm that we presented can be used to solve instances with 2K-1 = 5 black pebbles

In this problem we have B=8 black pebbles. 

Assume that the two players, after some moves, have reached this state of the game "bbwbwb"  (wbw 'bbwbwb' bwbwwb)
This means that they both have 2 black pebbles each and the next person to choose a black loses.
Since the first player is forced to take b, he loses. 

This would be true for any interval that starts and ends with b's and contains exactly (B - 2K + 2) many b's, namely: 

- Subproblem 1-6 : "bwbbwb"
-            3-8 : "bbwbwb"
-            4-9 : "bwbwbb"
-            6-11: "bwbbwb"
-            8-14: "bbwbwwb"
```

The idea is that if we 'replaced' such intervals with single b's, then the problem would contain exactly 2K-1 black pebbles.

In other words, **in the context of recursion, these intervals behave just like base cases of single black pebbles**.

Therefore, if we modify our algorithm so that ```dp(any such interval) = dp("b") = (1,0)```, it will produce correct results for the original problem.



As if all of this wasn't enough, now we have to write this in Haskell, which means no dp arrays and no assignment operators. Fortunately, the dynamic formula can be easily converted into a stateless function and the computation of the dp array can be done as follows:


```
Input some problem S = "bwb...wwbw"
Create intervals of size 1 and put them in a list. (layer 1)
Combine adjacent intervals from the list according to the dynamic formula (layer 2)
Combine adjacent intervals again (layer 3)
.
.
.
Combine last two intervals into one, containing the final answer (mitsos,kitsos) (layer n)

if mitsos < kitsos return "yes"
otherwise return "no"
```

(This is equivalent to computing the diagonals of the dp array)

Both the imperative and the functional implementations of this algorithm have a complexity of O(n^2), as the number of subproblems suggests.

In the final implementation I also applied an optimization of removing adjacent pairs of white pebbles.

---

## 4. *lexword* 🔤

Mitsos and Kitsos now play with words: Initially, Kitsos writes N letters where each of them is either 'a', 'b' or 'c'. Mitsos also writes a word of his own of size N, using letters 'a','b','c'.


Kitsos now must write a new word, using the N letters from the word that he initially wrote, such that:

- Each character of the new word is different from the corresponding character of the word that Mitsos wrote.

- The new word is the *lexicographically smallest* word that has the previous property.


Help Kitsos by defining a function `lexword` that returns the word with the previous property, given the initial words that Kitsos and Mitsos wrote. For example:


```
lexword "aaabc" "abcba" = "baaac"

/*
"baaac" is the lexicographically smallest permutation of "aaabc" 
such that all corresponding letters are different from "abcba"
*/
```

Assume that in the test cases it will always be possible to construct such a word.


### Solution

This problem can be solved with a greedy approach:

- We will count the occurances of each character in K and, separately, in M.

- Then, we will create the output word by examining sequentially each character of M and selecting the smallest letter that satisfies some constraints:


```
check_constraints((A1,B1,C1), (A2,B2,C2)):
	return 		B1 + C1 >= A2	//There are enough remaining Bs and Cs to replace the rest of As
		    &&  A1 + C1 >= B2 //There are enough remaining As and Cs to replace the rest of Bs
		    &&  A1 + B1 >= C2	//...
		    &&  A1>=0 && B1 >=0 && C1 >=0

lexword(K,M):
	(Ak,Bk,Ck) = Count number of occurances of each character in K 
	(Am,Bm,Cm) = Count number of occurances of each character in M 

	output_word = ""

	for each character c in M:
		if c is 'a':
			if check_constraints((Ak,Bk-1,Ck), (Am-1,Bm,Cm)) //Selecting a b does not violate the constraints
				output_word += 'b'
				Bk -= 1 		//One less b available
			else 
				output_word += 'c'
				Ck -= 1  		//One less c available
			Am -= 1 			//One less a left

		else if c is 'b':
			if check_constraints((Ak-1,Bk,Ck), (Am,Bm-1,Cm)) //Selecting an a does not violate the constraints
				output_word += 'a'
				Ak -= 1 		//One less a available
			else 
				output_word += 'c'
				Ck -= 1  		//One less c available
			Bm -= 1 			//One less b left

		else if c is 'c'
			if check_constraints((Ak-1,Bk,Ck), (Am,Bm,Cm-1)) 
				output_word += 'a'
				Ak -= 1 		//One less a available
			else 
				output_word += 'b'
				Bk -= 1  		//One less b available
			Cm -= 1 			//One less c left
	return output_word
```

We can prove using induction that we can always choose a letter that does not violate the constraints. I'll leave this as an exercise to the reader ;)


Implementing this algorithm in Haskell is not difficult, as the for loop can be easily replaced with a tail recursion.


The complexity is, of course, O(n), as we only traverse the N lettered strings twice.

---


## 5. *encrypt* 🔐

Mitsos has an array of N distinct words that he wants to encrypt in order to send a secret message to his classmates. The words may have different lengths.

The encryption is done using a *key*, which is a permutation of the english alphabet: Replace all occurances of 'a' in the initial text with the *first* letter of the key. Replace all occurances of 'b' in the initial text with the *second* letter of the key, and so on.

Mitsos also has an array `A` which contains a permutation of numbers 1 to N. He wants to find a *key* such that:

- If he encodes the array and sorts it lexicographically, the word which was initially in position `A[i]`, is now (encrypted) in position `i`, after the encryption and the sorting.


Define a function `encrypt` which takes as input the word array and the permutation `A` and returns "yes" and the *key* that has this property (if there exists one). Otherwise, it returns "no" and an empty string. For example:

```
encrypt ["ab","bc"] [2,1] = ("yes","bacdefghijklmnopqrstuvwxyz")

encrypt ["abc","bcd","add"] [1,2,3] = ("no",[])
``` 


If there are multiple keys that satisfy this condition, return any one of them.



### Solution

The first thing that we can do, is to sort the initial array of words according to the given permutation of numbers from 1 to n. After we do that, our goal will be to find a key such that when these words are encrypted, they will be in lexicographical order.


We want the word in position `A[i]` to be replaced in position `i`. It would be much more convenient to know *the final position of each word in the initial order* instead of *the original position of each word in the final order*. 

We can obtain the *final positions of each word* by 'transposing' the array A: If `A[i]` is the ith element of A, then, in the transposed array, `i` will be the element of the `A[i]`th position of the array.


**Interestingly enough**, calculating the transposed array can be done in *linear* time in an imperative language with random access, by using an array `A'` and assigning `A'[A[i]] := i` for each `i`. 

However, in a functional language, this is (probably) impossible to do. A naive approach would be to simulate `A'[A[i]] := i` by iterating all the way to the `A[i]` th element of a list and assigning `i`. Such an approach would be of O(n^2) complexity.

A better approach would be:

```
Create a list B[i] = [(i,A[i]) for i in range (1,N)]
Sort list B according to the second part of each tuple
Get A' by adding into a list the first part of each tuple in B, in order
```

This approach requires O(nlogn) steps, as the dominating factor nlogn originates from the sorting process. 


Now that he have the transposed array, we can follow the same process to obtain the final permutation of the words:

```
//W[i] is the ith word in the initial order
Create B[i] = [(W[i],A'[i]) for i in range(1,N)]
Sort list B according to the second part of each tuple
Get W' by adding into a list the first part of each tuple in B, in order
```


At this point, all we need to do is find a valid *key* so that if we encrypt each word in W' with it, the resulting array will be lexicographically sorted. 


**Let's ask a simpler question**: if this sequence of words is considered 'sorted', then what would be a valid alphabetic order so that the words are indeed sorted under that order?

For example, assume that these words are sorted under some alphabetic order:

```
1. cluster
2. bridge
3. break
4. black
5. ashtray
6. abnormal
```

The constraints that emerge from this sequence of words are:
- `c < b` and `b < a`, due to the first letters of the words
- `r < l`,  due to the second letters of words 2,3,4
- `i < e`, due to the third letters of words 2,3
- `s < b`, due to the second letters of 5,6

Since no constraints are contradictory to each other, any alphabet that satisfies them would be a valid alphabet.


The constraints can be found recursively as follows
```
Find constraints from the first letters of the words.
For each independent subsequence of words that start with the same letter:
	Find constraints recursively by removing the first letters of words
```


In the previous example:

```
1. cluster
2. bridge
3. break
4. black
5. ashtray
6. abnormal
```

- From the first letters we obtain `c < b` and `b < a`
- By recursively calling the algorithm on:
		
	```
	ridge
	reak
	lack
	```

	We get `r < l` and then after one further recursive call on 'idge', 'eak' we get `i < e` 

- By recursively calling the algorithm on:

	```
	ashtray
	abnormal
	```
	We get `s < b`


- Therefore, the algorithm returns \{`c < b`, `b < a`, `r < l`, `i < e`, `s < b`\}

- This is relatively easy to implement in Haskell and requires no major modifications in order to work.
...

So, how can we model this problem and find such an ordering efficiently?


**Surprisingly enough**, this can be viewed as a **graph** problem:

- Each letter of the english alphabet is a node in the graph

- Each constraint is a directed edge in the graph: if `r < l` is a constraint, then we have an edge from `r` to `l`.

- The problem of finding a valid alphabet is equivalent to the problem of finding a **topological ordering** of the nodes in the graph. If no such ordering exists (i.e. if the graph contains a cycle) then no valid alphabet exists.

The algorithm for finding a topological ordering is very similar to the one that we presented in problem 2. The Haskell implementation is also identical...


OK, so now we can find a valid ordering. But how is the *key* related to the ordering?

Remember, the key tells us how to change the original letters, while the ordering tells us **in which original letter each final letter could correspond to**. Therefore, all we need to do in order to obtain the key from the ordering, is **apply the transposition algorithm** that we presented earlier, on the ordering.

To sum up:

```
Transpose A
Sort the words according to transposed A
Find constraints with recursive algorithm
Create graph and add constraints as edges
Find topological ordering of nodes-letters
If no ordering exists return ("no",[])
Else, return ("yes", transposed ordering)
```



The Haskell implementation of this algorithm has a complexity of O(nlogn) due to the sortings.











