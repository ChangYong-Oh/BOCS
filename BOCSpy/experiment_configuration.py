import itertools
import numpy as np

import torch


SEED_STR_LIST = ['2019ICML_HIGHORDERBINARY']


def generate_random_seed_pair_highorderbinary():
    return _generate_random_seed_pair('2019ICML_HIGHORDERBINARY', n_test_case_seed=5, n_init_point_seed=5)


def _generate_random_seed_pair(seed_str, n_test_case_seed=5, n_init_point_seed=5):
    assert seed_str in SEED_STR_LIST
    rng_state = np.random.RandomState(seed=sum([ord(ch) for ch in seed_str]))
    result = {}
    for _ in range(n_test_case_seed):
        result[rng_state.randint(0, 10000)] = list(rng_state.randint(0, 10000, (n_init_point_seed, )))
    return result


def sample_init_points(n_vertices, n_points, random_seed=None):
    if random_seed is not None:
        rng_state = torch.get_rng_state()
        torch.manual_seed(random_seed)
    init_points = torch.empty(0).long()
    for _ in range(n_points):
        init_points = torch.cat([init_points, torch.cat([torch.randint(0, elm, (1, 1)) for elm in n_vertices], dim=1)], dim=0)
    if random_seed is not None:
        torch.set_rng_state(rng_state)
    return init_points


def generate_function_on_highorderbinary(n_variables, highest_order, random_seed=None):
    init_seeds = np.random.RandomState(random_seed).randint(100, 100000, 4)
    choice_ratio = (np.random.RandomState(init_seeds[0]).rand(highest_order) + np.random.RandomState(init_seeds[1]).rand(highest_order)) / 2.0 * 0.3
    choice_shuffle = np.random.RandomState(init_seeds[2]).randint(100, 10000, highest_order)
    coef_seed = np.random.RandomState(init_seeds[3]).randint(100, 10000, highest_order)
    interaction_coef = []
    for o in range(1, highest_order + 1):
        combinations = list(itertools.combinations(range(n_variables), o))
        n_choices = len(combinations)
        n_chosen = int(n_choices * choice_ratio[o - 1])
        choice_inds = list(range(n_choices))
        np.random.RandomState(choice_shuffle[o - 1]).shuffle(choice_inds)
        chosen_interaction = [combinations[i] for i in choice_inds[:n_chosen]]
        chosen_coefficient = list(np.random.RandomState(coef_seed[o - 1]).uniform(-1.0, 1.0, n_chosen))
        interaction_coef.extend(zip(chosen_interaction, chosen_coefficient))
    return interaction_coef


def matlab_interaction_coef(interaction_coef):
    matrix_form_dict = {}
    for interaction, coef in interaction_coef:
        order = len(interaction)
        interaction_key = 'interaction' + str(order)
        coef_key = 'coef' + str(order)
        if interaction_key in matrix_form_dict.keys():
            matrix_form_dict[interaction_key] = np.vstack([matrix_form_dict[interaction_key], interaction])
            matrix_form_dict[coef_key] = np.append(matrix_form_dict[coef_key], coef)
        else:
            matrix_form_dict[interaction_key] = np.array([list(interaction)])
            matrix_form_dict[coef_key] = np.array([coef])
    return matrix_form_dict