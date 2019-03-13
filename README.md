# SimulatingTheEvolutionOfNorms
Collaboration on simulating the evolution of norms between two groups in social networks with different groups sizes and varying levels of homophily using Agent-based modelling.

![](Network8.gif)

# To do:
- ~~The plotting function assigns the wrong names to the network plots (network and iteration number are switched)~~
- ~~we should implement a proper progress bar instead of printing sth. on each iteration~~
- ~~We should be able to switch off the plotting function in the funcion call if we want to save time/resources~~
- ~~We should include the animator function in the Simulation function but hide it in an if-statement that is switched off by default~~
- ~~The animator function is naming the network animations incorrectly~~
- ~~Would be nice to have a method for nice interactive 3D plotting in HTML instead of using static 2D GIFS~~
- ~~We still need to make the parameter for m take other values besides 2 by tweaking the generator function~~
- We still need to implement changes so that we can input sequences for m, rather than only a single value
- Round and square shapes in the Plot legend are static and do not change according to other user-defined changes.
- For some cases, nodes that are only connected to one other node with a different norm switch their norm. This is debateable: Currently, each node *only* polls their neighbors and checks if 50% or more of them have
a different norm. This results in disconnect parts of the graph with only two nodes to confer (randomly because of the random             order of updateing nodes) to one of the two norms. This is not necesarily unrealistic for dyadic interactions but we might want           to change this so that each node also counts itself with a certain weight so that it takes more than 1 neighboring node to               change their opinion
-~~We want the Simulation to stop if no nodes change their norms anymore as to not waste resources~~
- ~~Instead of having a parameter p and using (1-p) as the probability of the two demographic groups to endorse a certain norm, we should have two parameters p1 and p2 that operate independently of each other.~~
-~~Currently, every node has the same threshold t. It would be more realistic if we could use different distributions of t (uniform,normal).~~

# Far future:
- Currently, all edges carry the same weight. It would be more realistic if we could specify a distribution of edgeweights, possibly with a vector of different parameters (e.g. slightly different powerlaw for each node).
- Generalizing the algorithm so we can have as many interacting groups as we want, not only two.
- Instead of modelling norms in a binary fashion, we could represent them as a spectrum (e.g. 0 - 100) with different hues of color
- Would be nice if we had an online tool (maybe R-shiny server) that we could use to showcase the functionality of the simulation. Users could play around with a limited range of parameters and see live how networks form and
