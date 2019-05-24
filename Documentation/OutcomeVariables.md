# Overview of Outcome Varaibles
In this file, we are explaining the meaning of all column names for the NormResultsDF.Rdata dataframe.

## Identifying Networks

**NetworkNumber** ID of generated Network

**IterationNumber** Number of Iteration of the Granovetter Treshold Model for updating norms of agents. Iteration 0 is the network before the first iteration of norm updating took place

## Initial Parameters

**nodes** Total number of agents that was specified for this network

**iter** Number of total iterations of the Granovetter Treshold Model that were specified for this network

**norm_end_maj** Probability of each majority group agent to be assigned to the majority norm that was specified for this network

**norm_end_min** Probability of each minority group agent to be assigned to the majority norm that was specified for this network

**t** Type of treshold distribution that was specified for this network

**m** Minimum node degree that was specified for this network

**g** Probability of each agent to be assigned to the minority group

**h** Degree of homophily/heterophily that was specified for this network

## Extracted Parameters

**NoOfMajorityNodes** The number of agents actually assigned to the majority group in the network. Note: This value will approximate `g-1` for networks with many agents but is not an exact value because agents are assigned to groups probabilistically. To compute the number of minority group agents, simply substract this value from the total number of agents.

**NumberOfEdgesInGraph** The total amount of ties between agents in the iteration

**TotalEdgesAmongMaj** The total amount of ties between majority group agents in the iteration

**TotalEdgesAmongMin** The total amount of ties between minority group agents in the iteration

**TotalEdgesBetweenGroups** The total amount of ties between agents from different groups

**MajorityNormPercentageOverall** The total amount of agents holding the majority norm in the iteration. To compute the total amount of agents holding the minority norm, simply substract this value from the total amount of agents

**MajorityNormPercentageInMajority** The total amount of majority group agents holding the majority norm in the iteration. To compute the total amount of majority agents holding the minority norm, simply substract this value from the total amount of agents

**MajorityNormPercentageInMinority** The total amount of minority group agents holding the majority norm in the iteration. To compute the total amount of minority agents holding the minority norm, simply substract this value from the total amount of agents

**PercSameGroupEdges** Percentage of ties that connect agents from different groups

**PercMajMajEdgesInMaj** Percentage of majority group ties that connect agents holding the majority norm

**PercMinMinEdgesInMaj** Percentage of majority group ties that connect agents holding the minority norm

**PercMajMajEdgesInMin** Percentage of minority group ties that connect agents holding the majority norm

**PercMinMinEdgesInMin**  Percentage of minority group ties that connect agents holding the minority norm

**PercMajMajEdgesBetween** Percentage of between-group ties that connect agents holding the majority norm

**PercMinMinEdgesBetween** Percentage of between-group ties that connect agents holding the minority norm

**PercMajMinEdgesBetween** Percentage of between-group ties that connect an agents holding a different norm (held norm corresponds with group membership)

**PercMinMajEdgesBetween** Percentage of between-group ties that connect an agents holding a different norm (held norm does not correspond to group membership)

