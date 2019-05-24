# Overview of Function Arguments for Simulation.R

## Arguments for Groups and Norms

**majority** This parameter takes an arbitrary text string as input to identify the majority group by attaching the string as a property to each node assigned to the majority, for example "male" or "female".

**minority** This parameter takes an arbitrary text string as input to identify the minority group by attaching the string as a property to each node assigned to the minority, for example "male" or "female".

**majnorm** This parameter takes an arbitrary text string as input to identify the group of nodes that hold the attribute that is predominant in the majority. For example "pro-abortion" or "contra-abortion".

**minnorm** This parameter takes an arbitrary text string as input to identify the group of nodes that hold the attribute that is predominant in the minority. For example "pro-abortion" or "contra-abortion".

## Arguments for Simulation Size and Parameter Space

**r** Takes a single numeric value as input to specify how many networks of each parameter configuration should be generated.

**nodes** Takes a single numeric value as input to specify how many nodes each network should contain. Every simulated network will contain the same amount of total nodes.

**iter** Takes a single numeric value as input to specify how many iterations of the norm updating process should be simulated.

**norm_end_maj** Takes a sequence of numeric values between 0 and 1 as input and specifies the proportion of nodes in the majority group that is attributed to the majnorm. The attribution co-occurs probabilistically with the sample() function in R, thus, exact values are not guaranteed.

**norm_end_min** Takes a sequence of numeric values between 0 and 1 as input and specifies the proportion of nodes in the minority group that is attributed to the majnorm. The attribution happens probabilistically with the sample() function in R, thus, exact values are not guaranteed.

**m** Takes a single integer value as input and specifies the minimum number of edges that each node in the network forms.

**g** Takes a sequence of numeric values between 0 and 1  as input and specifies the proportion of nodes that are assigned to the minority.

**h** Takes a sequence of numeric values between 0 and 1 as input and specifies the degree to which nodes preferentially form edges with similar or dissimilar (majority or minority group) others.

## Arguments for Threshold Distribution and Updating Process

**t** Takes either a single numeric value between 0 and 1 as input, or the text strings "uniform" or "normal". The parameter specifies the necessary percentage of neighboring nodes for a node to switch from their current attribute to the different one (e.g. if t = 0.6, at least 60\% of neighboring nodes have to display a different attribute for a node to change its attribute). For a single numeric value, all nodes are assigned the same value for t, for t = "uniform", values are drawn from a random uniform distribution between 0 and 1, and for t = "normal", values for t are drawn from a normal distribution with specified mean and standard deviation (see below) and truncated to values between 0 and 1.

**tmean** Only meaningful for t = "normal". Takes a single numeric value as input and specifies the mean of the normal distribution from which values for the parameter t are sampled.

**tsd** Only meaningful for t = "normal". Takes a single numeric value as input and specifies the standard deviation of the normal distribution from which values for the parameter t are sampled.

**UpdateProcess** Takes either the text string "synchronous" or "asynchronous" as input and determines how the update process is executed. For synchronous updating, all nodes in a network update their attributes at the same time, for asynchronous updating, nodes update their attributes in a random order on each iteration, taking into account previous changes.

## Arguments for Graphics

**majnormcolor** This parameter takes any valid color name in R as an input and visually identifies the group of nodes with the majnorm attribute.

**minnormcolor** This parameter takes any valid color name in R as an input and visually identifies the group of nodes with the minnorm attribute.

**majshape** This parameter specifies the shape of the nodes that are assigned to the majority group. Valid inputs are all shapes recognized by the vertex.shapes attribute in the plot() function of the igraph R package.

**minshape** This parameter specifies the shape of the nodes that are assigned to the minority group. Valid inputs are all shapes recognized by the vertex.shapes attribute in the plot() function of the igraph R package.

**CreatePlots** Takes TRUE or FALSE as input and specifies whether jpeg plots are created for each iteration of every network (not recommended for larger networks or large parameter spaces).

**AnimatePlots** Takes "HTML" or "GIF" as input and specifies whether created jpeg plots should be combined into a GIF/HTML animation (see example - not recommended for larger networks or large parameter spaces).


## Arguments for Technical Settings

**cores** Specifies the number of cores that should be used in parallel for the simulation. On windows machines, only one core is supported. For simulation on across multiple machines, see our script for MPI clusters in the Serverfiles Folder.

 **SimplifyCombinations** Takes TRUE or FALSE as input and specifies whether combinations of norm_end_maj and norm_end_min should be reduced to the combinations 0.5;0.5, 0.6;0.4 and 0.8;0.2. This argument was only included to reduce computation time by only simulating the specified combinations. For a full test of all possible combinations of norm_end_maj and norm_end_min, the argument should be set to FALSE (default setting).
