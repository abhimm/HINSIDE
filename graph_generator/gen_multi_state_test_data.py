#!/usr/bin/python2.7

import networkx
import csv
from geopy.distance import great_circle
import pickle
import random
import numpy as np, scipy.io as sio

nppes_dict = dict()
tax_code_dict = dict()

available_state = ['NY', 'NJ', 'PA', 'OH', 'VA', 'IL', 'WI', 'NC', 'MA', 'MI']
available_type = ['Internal Medicine', 'Family Medicine', 'Nurse Practitioner', 'Physician Assistant',
                  'Emergency Medicine', 'Anesthesiology', 'Radiology']
node_longitude = dict()
node_latitude = dict()
node_type = dict()
node_state = dict()


def gen_multi_state_test_data():
    global nppes_dict, tax_code_dict, available_state, available_type, node_longitude, node_latitude, node_type, node_state
    chosen_state = list()
    state_node_count = dict()
    select_state = True
    index = int(raw_input('Enter test case index: '))
    print '****State Selection****'

    while select_state:
        print 'Available states: ', available_state
        state = raw_input('Enter a state from available state or enter Stop to quit selection: ')
        if state == 'Stop':
            break
        chosen_state.append(state)
        available_state.remove(state)

    for state in chosen_state:
        state_node_count[state] = int(raw_input('Enter no of nodes in ' + state + ': '))

    no_of_types = int(raw_input('Enter no of types (Total type: 7): '))
    selected_type = list()
    for i in range(len(available_type)):
        selected_type.append(available_type[i])

    nppes_dict = pickle.load(open("npi_dict.p", "rb"))
    tax_code_dict = pickle.load(
        open("tax_code_dict.p", "rb"))

    state_wise_node_list = pickle.load(open('state_wise_node_distribution.p', 'rb'))

    graph = networkx.DiGraph()
    graph = pickle.load(open('biggest_connected_component.p', 'rb'))

    node_longitude = networkx.get_node_attributes(graph, 'longitude')
    node_latitude = networkx.get_node_attributes(graph, 'latitude')
    node_type = networkx.get_node_attributes(graph, 'node_type')
    node_state = networkx.get_node_attributes(graph, 'state')

    # create an array containing counts based on state and node type
    state_type_node_count = np.zeros((len(chosen_state), no_of_types), dtype=int)

    for state, node_count in state_node_count.items():
        type_wise_node_count = divide_nodes_per_type(no_of_types, node_count, state)
        state_index = chosen_state.index(state)
        for i in range(no_of_types):
            state_type_node_count[state_index, i] = type_wise_node_count[i]
            print state, str(state_type_node_count[state_index, i])
    test_graph = networkx.DiGraph()
    node_mapping = dict()
    test_graph_node_state_assgn = list()
    test_graph, node_mapping, test_graph_node_state_assgn = generate_test_graph(graph, state_type_node_count, chosen_state, state_wise_node_list, no_of_types)

    # generate distance and referral matrix
    distance_matrix, referral_matrix = generate_distance_and_referral_matrix(test_graph, node_mapping)
    print "**************Referral Matrix & Distance Matrix Created**************"

    # generate authority propagation matrix
    authority_propagation_matrix = generate_authority_propagation_matrix(no_of_types)
    print "**************Authority Propagation Matrix Created**************"

    # generate type matrix and type column matrix
    type_matrix, type_column_matrix = generate_type_matrix(no_of_types, node_mapping, selected_type)
    print "**************Type Matrix Created**************"

    writer = csv.writer(open('test_graph_node_state_assgn_' + str(index) + '.csv', 'wb'))
    for i in range(len(test_graph_node_state_assgn)):
        writer.writerow((i, test_graph_node_state_assgn[i]))

    # save generated data to mat file
    sio.savemat('./TEST_DATA/type_matrix_' + str(index) + '.mat', {'node_type': np.matrix(type_matrix)})
    sio.savemat('./TEST_DATA/distance_matrix_' + str(index) + '.mat', {'distance': np.matrix(distance_matrix)})
    sio.savemat('./TEST_DATA/referral_matrix_' + str(index) + '.mat', {'referral': np.matrix(referral_matrix)})
    sio.savemat('./TEST_DATA/authority_propagation_matrix_' + str(index) + '.mat',
                {'propagation': np.matrix(authority_propagation_matrix)})
    sio.savemat('./TEST_DATA/type_column_matrix_' + str(index) + '.mat', {'type_column': np.matrix(type_column_matrix)})


def divide_nodes_per_type(no_of_types, no_of_nodes, state):
    state_type_dist = dict()
    state_type_dist = pickle.load(open('state_type_dist.p', 'rb'))

    per_type_node_count = list()
    total_nodes = 0
    for ntype in available_type[:no_of_types]:
        total_nodes += state_type_dist[(state, ntype)]

    for ntype in available_type[:no_of_types]:
        per_type_node_count.append(no_of_nodes*float(state_type_dist[(state, ntype)])/float(total_nodes) )
    return per_type_node_count


def generate_test_graph(original_graph, state_type_node_count, chosen_state, state_wise_node_list,
                        no_of_types):
    global available_type, node_latitude, node_longitude, node_state, node_type
    test_graph_nodes = list()
    node_queue = list()
    print state_type_node_count
    for i in range(len(chosen_state)):
        for j in range(no_of_types):
            print 'Running for state', chosen_state[i]
            print state_type_node_count[i, j]
            while not state_type_node_count[i, j] == 0:
                node_index = random.randint(1, len(state_wise_node_list[chosen_state[i]]))
                node = state_wise_node_list[chosen_state[i]][node_index-1]
                state_wise_node_list[chosen_state[i]].remove(node)
                if not node_type[node] in available_type[:no_of_types] or node in node_queue or node in test_graph_nodes:
                    continue
                node_queue.append(node)
                state_type_node_count[i, j] -= 1

                expand_graph(node_queue, test_graph_nodes, original_graph, chosen_state, no_of_types, state_type_node_count)

    test_graph = networkx.DiGraph()
    test_graph = original_graph.subgraph(test_graph_nodes)


    components = networkx.weakly_connected_component_subgraphs(test_graph)
    i = 1
    print 'Components Before:'
    print '******************'
    for component in components:
        print 'Component: ' + str(i) + '- ' + str(networkx.number_of_nodes(component))
        i += 1


    # Check connectivity
    if i > 1:
        resolve_connectivity_issue(test_graph)
        components = networkx.weakly_connected_component_subgraphs(test_graph)
        i = 1
        print 'Components After:'
        print '******************'
        for component in components:
            print 'Component: ' + str(i) + '- ' + str(networkx.number_of_nodes(component))
            i += 1


    node_mapping = dict()
    test_graph_node_state_assgn = list()
    for i in range(len(test_graph_nodes)):
        node_mapping[i] = test_graph_nodes[i]
        test_graph_node_state_assgn.append(node_state[test_graph_nodes[i]])
    print 'No of nodes: ', len(test_graph_nodes)

    return test_graph, node_mapping, test_graph_node_state_assgn


def expand_graph(node_queue, test_graph_nodes, original_graph, chosen_state, no_of_types, state_type_node_count):
    while len(node_queue) != 0:
        node = node_queue.pop(0)
        test_graph_nodes.append(node)
        neighbor_iter = networkx.all_neighbors(original_graph, node)

        for neighbor in neighbor_iter:
            if neighbor in node_queue or \
                neighbor in test_graph_nodes or\
                    node_state[neighbor] not in chosen_state or \
                    node_type[neighbor] not in available_type[:no_of_types] or \
                    state_type_node_count[chosen_state.index(node_state[neighbor]), available_type.index(node_type[neighbor])] == 0:

                continue
            node_queue.append(neighbor)
            state_type_node_count[chosen_state.index(node_state[neighbor]), available_type.index(node_type[neighbor])] -= 1

    return test_graph_nodes


def resolve_connectivity_issue(test_graph):
    weakly_connected_components = networkx.weakly_connected_components(test_graph)
    wcc_list = list()

    # get components sorted  based on the length
    for component in weakly_connected_components:
        index = 0
        for wcc in wcc_list:
            if len(component) < len(wcc):
                break
            index += 1
        wcc_list.insert(index, component)

    print "sorted list"
    for wcc in wcc_list:
        print 'component length' + str(len(wcc))

    for i in range(len(wcc_list)-1):
        for j in range(i+1, len(wcc_list)):
            connect_weakly_connected_component(wcc_list[i], wcc_list[j], test_graph)


def connect_weakly_connected_component(wcc_1, wcc_2, test_graph):
    no_of_nodes = int(len(wcc_1)*0.15)
    for i in range(no_of_nodes):
        node_index = random.randint(1, len(wcc_1)) - 1

        node = wcc_1[node_index]
        wcc_1.remove(node)

        out_edges = test_graph.out_edges([node], data=True)
        out_edge_no = int(len(out_edges)*0.10)

        in_edges = test_graph.in_edges([node], data=True)
        in_edge_no = int(len(in_edges)*0.10)

        max_out_edge_weight = 1
        min_out_edge_weight = 1
        for edge in out_edges:
            if int(edge[2]['weight']) > max_out_edge_weight:
                max_out_edge_weight = int(edge[2]['weight'])
            if int(edge[2]['weight']) < min_out_edge_weight:
                min_out_edge_weight = int(edge[2]['weight'])

        max_in_edge_weight = 1
        min_in_edge_weight = 1
        for edge in in_edges:
            if int(edge[2]['weight']) > max_in_edge_weight:
                max_in_edge_weight = int(edge[2]['weight'])
            if int(edge[2]['weight']) < min_in_edge_weight:
                min_in_edge_weight = int(edge[2]['weight'])


        # create out edges
        for j in range(out_edge_no):
            edge_weight = random.randint(min_out_edge_weight, max_out_edge_weight)
            other_node_index = random.randint(1, len(wcc_2)) - 1
            other_node = wcc_2[other_node_index]
            test_graph.add_edge(node, other_node, weight=edge_weight)

        # create in edges
        for j in range(in_edge_no):
            edge_weight = random.randint(min_in_edge_weight, max_in_edge_weight)
            other_node_index = random.randint(1, len(wcc_2)) - 1
            other_node = wcc_2[other_node_index]
            test_graph.add_edge(other_node, node, weight=edge_weight)


def generate_type_matrix(no_of_types, node_mapping, selected_type):
    type_matrix = np.zeros((len(node_mapping), no_of_types), dtype=float)
    type_column_matrix = np.zeros(len(node_mapping), dtype=float)

    for i in range(len(node_mapping)):
        for j in range(no_of_types):
            if node_type[node_mapping[i]] == selected_type[j]:
                type_matrix[i, j] = 1
                type_column_matrix[i] = j
    return type_matrix, type_column_matrix


def generate_authority_propagation_matrix(no_of_types):
    authority_propagation_matrix = np.zeros((no_of_types, no_of_types), dtype=float)
    for i in range(no_of_types):
        for j in range(no_of_types):
            authority_propagation_matrix[i, j] = random.random()

    row_sums = authority_propagation_matrix.sum(axis=1)
    norm_authority_propg_matrix = authority_propagation_matrix / row_sums[:, np.newaxis]
    return norm_authority_propg_matrix


def generate_distance_and_referral_matrix(graph, node_mapping):
    no_of_nodes = graph.number_of_nodes()
    distance_matrix = np.zeros((no_of_nodes, no_of_nodes), dtype=float)
    referral_matrix = np.zeros((no_of_nodes, no_of_nodes), dtype=float)

    for i in range(no_of_nodes):
        for j in range(no_of_nodes):
            node_1_loc = (node_latitude[node_mapping[i]], node_longitude[node_mapping[i]])
            node_2_loc = (node_latitude[node_mapping[j]], node_longitude[node_mapping[j]])
            distance_matrix[i, j] = great_circle(node_1_loc, node_2_loc).miles

            if graph.has_edge(node_mapping[i], node_mapping[j]):
                edge_weight = graph.get_edge_data(node_mapping[i], node_mapping[j])
                referral_matrix[i, j] = edge_weight['weight']
    return distance_matrix, referral_matrix


def main():
    gen_multi_state_test_data()


if __name__ == '__main__':
    main()
