import algorithms.graph_utils as graph_utils


# Graph is dict of node_key --> node
# node has "op" (AND/OR), prereqs list, and dependents list
def sort(graph, blacklist=None):
    if blacklist is None:
        blacklist = {}


    open = []
    in_open = {}
    # Things immediately reachable from in_open, even allowing blacklisted edges
    reachable = {}
    # Keep track of AND nodes that have at least one blacklisted connection
    blacklisted_and_nodes = {}
    num_satisfiers = {}
    curr_ind = 0


    def add_node(node):
        node_key = graph_utils.make_key(node)
        open.append(node)
        in_open[node_key] = True


    # Add sources and populate blacklisted_and_nodes
    for node_key, node in graph.items():
        num_satisfiers[node_key] = 0

        if node["op"] == "and":
            if len(node["prereqs"]) == 0:
                add_node(node)

            for prereq in node["prereqs"]:
                if graph_utils.make_edge_key(prereq, node) in blacklist:
                    blacklisted_and_nodes[node_key] = True
                    break


    # Now, do updates
    while curr_ind < len(open):
        curr_node = open[curr_ind]
        
        for dependent in curr_node["dependents"]:
            dependent_key = graph_utils.make_key(dependent)
            dependent_node = graph[dependent_key]
            num_satisfiers[dependent_key] += 1


            if dependent_node["op"] == "and":
                if len(dependent_node["prereqs"]) == num_satisfiers[dependent_key]:
                    reachable[dependent_key] = True

                    # If this is not a blacklisted AND node, propagate
                    if not dependent_key in blacklisted_and_nodes:
                        add_node(dependent_node)
            elif dependent_node["op"] == "or":
                reachable[dependent_key] = True

                # If this wasn't already added to open and this edge is not blacklisted, propagate
                if not dependent_key in in_open and not graph_utils.make_edge_key(curr_node, dependent) in blacklist:
                    add_node(dependent_node)
        
        curr_ind += 1
    

    return {"sorted": open, "reachable": reachable}