# Our first goal is to generate the polytope in Sage 
# For example, the input for the Todd Polytope is the following:
# A = [[-7,-4,-1,0], [-4,-7,0,-1],[-43,-53,-2,-5],[-53,-43,-5,-2],[1,0,0,0],[0,1,0,0],[0,0,1,0],[0,0,0,1]]
# b = [1,1,8,8,0,0,0,0]


# For this, we take as input a constraint matrix A for inequalities of the form Ax + b \geq 0
A = [[-7,-4,-1,0], [-4,-7,0,-1],[-43,-53,-2,-5],[-53,-43,-5,-2],[1,0,0,0],[0,1,0,0],[0,0,1,0],[0,0,0,1]]

# Right-hand side of inequality system defining the polytope
b = [1,1,8,8,0,0,0,0]

# Put the inequality system into the form of a matrix [b, A]
ineq_system = []
for i in range(len(A)):
    ineq_system.append([b[i]] + A[i])

# From the inequality system we obtain the corresponding polytope
P = Polyhedron(ieqs = ineq_system)

# Our next goal is to generate the hyper-plane arrangement with hyper-planes orthogonal to each edge of the polytope
# We will call this the edge_arrangement

# First we generate a list of vertices of the polytope
Pverts = P.vertices()

# Using these vertices, we can find a list of edge_directions
edge_dirs = {}
for u in P.vertices():
    for v in u.neighbors():
        # To ensure we don't overcount parallelism classes of edges, we obtain their direction by normalizing with respect to the 1-norm
        edge_dir = (vector(u)-vector(v))/sum([abs(x) for x in list(vector(u)-vector(v))])
        if tuple(edge_dir) not in edge_dirs and tuple(-edge_dir) not in edge_dirs:
            edge_dirs[tuple(edge_dir)] = True
            
# We append 0 to the end of each edge_direction as the input for the hyper-plane arrangement generator is is [(u-v), 0]
edge_dirs = [ [tuple(edge_dir),0] for edge_dir in edge_dirs.keys()]

# We let n denote the number of variables defining the polytope
n = len(A[0])

# This brute force algorithm will only be able to be run in super low dimensions as it scales terribly
# Here is a hacky way to generate the indices:
indices = tuple(['A'*(i+1) for i in range(n)])


# We initialize the hyper-plane arrangment
H = HyperplaneArrangements(QQ, indices)

# Then we add the hyper-planes for each edge direction
edge_arrangement = H(edge_dirs)


# The regions of the hyperplane arrangements correspond to the set of all orientations of the directed graph
# We extract for each region a vector on its interior as a representative for the orientation

regions = edge_arrangement.regions()
print(len(regions))
orientation_vecs = []
for region in regions:
    interior_point = sum([vector(ray) for ray in region.rays()])
    orientation_vecs.append(interior_point)
    
# Now what remains is for each orientation vector to compute the worst-case distance to the unique sink and then take the minimum

# We initialize the monotone diameter at 0 as a trivial lower bound
monodiam = 0

# We iterate over all orientations
for orientation_vec in orientation_vecs:
    
    # First we compute the unique sink
    currmax = vector(Pverts[0])
    currmaxval = orientation_vec.dot_product(currmax)
    for vert in Pverts:
        if orientation_vec.dot_product(vector(vert)) > orientation_vec.dot_product(currmax):
            currmax = vector(vert)
            currmaxval = orientation_vec.dot_product(currmax)
    sink = currmax
    
    
    # It remains to find the worst case distance to the unique sink
    # For this, we use a Bellman-Ford type approach to shortest paths in a directed graph
    # Namely, we store the distances and update them
    
    # generate the distances from each vertex to the unique sink
    distances = {}
    
    # We need to construct the directed graph. We do this using a dictionary
    dir_neighbors = {}
    
    # Throughout we will use num_verts as a naive upper bound on the initial distance to the unique sink
    num_verts = len(Pverts)
    for u in Pverts:
        distances[tuple(u)] = num_verts
        dir_neighbors[tuple(u)] = []
        for v in u.neighbors():
            # This is the only place where we ever use the orientation vector
            # Namely, our algorithm is combinatorial from this point onward and only requires the directed graph
            if orientation_vec.dot_product(vector(v) - vector(u)) > 0:
                dir_neighbors[tuple(u)].append(v)
    
    # Note that we must separately initialize the distance to the unique sink from itself to be 0
    distances[tuple(sink)] = 0
    
    # To be efficient, we will check at each step whether the algorithm made a change to the list of distances 
    no_change = False 
    
    # We iterate at most the number of vertices many times and update the distances of each vertex to the unique sink
    for i in range(len(Pverts)):
        if no_change:
            break
        no_change = True
        for u in Pverts:
            dir_neighborhood = dir_neighbors[tuple(u)]
            if dir_neighborhood != []:
                comp = min([distances[tuple(v)] for v in dir_neighborhood])
                if distances[tuple(u)] > comp + 1:
                    distances[tuple(u)] = comp + 1
                    no_change = False
    
    # The maximum distance is the oriented diameter of the graph
    oridiam = max([distances[tuple(v)] for v in Pverts]) 
    
    # The monotone diameter is the worst case oriented diameter
    if oridiam > monodiam:
        monodiam = oridiam

print(monodiam)