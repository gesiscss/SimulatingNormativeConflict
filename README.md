![10.5281/zenodo.3183121](https://zenodo.org/badge/DOI/10.5281/zenodo.3183121.svg)

# Simulating Normative Conflict

This repository is complementing our chapter "The Role of Network Structure and Initial Group Norm Distribution in Norm Conflict" in [...add edited volume full title + editors]. In this chapter, we aim to study the impact of network structure and initial distribution of norms (group norm difference) on the process of arriving at a normative consensus between groups and the potential for intragroup and intergroup conflict that might emerge under different conditions. To this end, we developed an agent-based model that simulates a social network of agents from two different social groups where each agent holds one of two social norms. In an adapted version of the Granovetter Threshold Model, each agent updates its social norm by comparing the proportion of norms held by its immediate neighbors to an internal threshold drawn from a uniform distribution. Agents can thus be said to be "observing" the openly displayed behavior of their neighbors and adapt their own behavior accordingly if enough of their neighbors display a different norm. Importantly, we will test this mechanism for norm adaptation in different network structures, determined by relative group sizes and homophily/heterophily between agents from different groups. This will allow us to assess the impact of these structural network properties on the process of norm convergence and associated conflict potential. In addition, we run our model for different levels of group norm differences as initial conditions, so that we can also assess the influence of the degree to which norms are aligned with (or independent from) social group membership. Relevant outcome variables are the proportion of norms in the networks over time (or rather, iterations of our model) as well as the amount of ties in the network between agents with different norms within the groups and between the groups, as an operationalization for conflict potential. For a more detailed insight, you can check the full chapter, which is available at [add Open Access Link].

# Instructions for Usage:
To use the files in this repository, you can download it and extract it's contents to a folder of your choice. You then need to source the file Simulation.R to load the wrapper function that contains all subfuntions and will allow you to run a simulation with just one command. When chosing parameters for your simulation, we strongly recommand you to test the simulation with few parameters and small networks with to get a feeling for computation times on your machines. Importantly, the simulation can run substantially faster on Mac and Linux than on windows, because it is using forking to use multiple cores on unix-based systems (see for more information). A function call to simulate a small network 10 times could look like this:

`
    TEST  <br\>
    TEST  
`

# Output

# Example Network:

![](ExampleNetwork.gif)

# Documentation

For an overview of arguments to the simulation function, check the Documentation.md file in this repository.

