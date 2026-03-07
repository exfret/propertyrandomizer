def make_key(node):
    return (node["type"], node["name"])


def make_edge_key(start, end):
    return (make_key(start), make_key(end))