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
The Haskell implementation also has the same complexity. The main difference is that loops and iterations must be replaced with tail recursions.

