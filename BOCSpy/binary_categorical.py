import numpy as np

import torch
from BOCSpy.experiment_configuration import sample_init_points, generate_function_on_highorderbinary


def high_interaction_function(x, interaction_coef):
	'''
	:param x: np.array 2 dimensional array
	:param interaction: list of tuple, tuple of interactions and coefficient
	:return:
	'''
	output = 0
	for interaction, coef in interaction_coef:
		output += np.any(x[:, interaction], axis=1, keepdims=True) * coef
	return output


class HighOrderBinary(object):
	def __init__(self, n_variables, highest_order, random_seed_pair=(None, None)):
		case_seed, init_seed = random_seed_pair
		self.suggested_init = torch.empty(0).long()
		self.suggested_init = torch.cat([self.suggested_init, sample_init_points([2] * n_variables, 20 - self.suggested_init.size(0), init_seed).long()], dim=0)
		self.n_variables = n_variables
		self.highest_order = highest_order
		self.interaction_coef = generate_function_on_highorderbinary(n_variables=n_variables, highest_order=highest_order, random_seed=case_seed)
		self.adjacency_mat = []
		self.fourier_coef = []
		self.fourier_basis = []
		self.random_seed_info = 'R'.join([str(random_seed_pair[i]).zfill(4) if random_seed_pair[i] is not None else 'None' for i in range(2)])
		for i in range(self.n_variables):
			adjmat = torch.diag(torch.ones(1), -1) + torch.diag(torch.ones(1), 1)
			self.adjacency_mat.append(adjmat)
			laplacian = torch.diag(torch.sum(adjmat, dim=0)) - adjmat
			eigval, eigvec = torch.symeig(laplacian, eigenvectors=True)
			self.fourier_coef.append(eigval)
			self.fourier_basis.append(eigvec)

	def evaluate(self, x):
		if x.ndim == 1:
			x = x.reshape(1, -1)
		evaluation = high_interaction_function(x, self.interaction_coef)
		return evaluation.flatten()


if __name__ == '__main__':
	pass
	import matplotlib.pyplot as plt
	import time

	n_variable = 20
	highest_order = 4
	test_function = HighOrderBinary(n_variables=n_variable, highest_order=highest_order, random_seed_pair=(758, 598))
	x = np.vstack([np.random.randint(0, 2, (1000, n_variable)), test_function.suggested_init.numpy()])
	start_time = time.time()
	y = high_interaction_function(x=x, interaction_coef=test_function.interaction_coef)
	print('Elapsed time : %6.4f' % (time.time() - start_time))
	print('Observed minimum %6.4f' % np.min(y))
	plt.hist(y)
	plt.show()