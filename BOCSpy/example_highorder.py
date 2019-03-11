#
# Bayesian Optimization of Combinatorial Structures
#
# Copyright (C) 2018 R. Baptista & M. Poloczek
# 
# BOCS is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# BOCS is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License 
# along with BOCS.  If not, see <http://www.gnu.org/licenses/>.
#
# Copyright (C) 2018 MIT & University of Arizona
# Authors: Ricardo Baptista & Matthias Poloczek
# E-mails: rsb@mit.edu & poloczek@email.arizona.edu
#

import numpy as np
import matplotlib.pyplot as plt
from BOCSpy.BOCS import BOCS
from BOCSpy.binary_categorical import HighOrderBinary
from BOCSpy.experiment_configuration import generate_random_seed_pair_highorderbinary

n_variables = 20
order = 3
random_seed_config = 1
n_eval = 2


random_seed_pair = generate_random_seed_pair_highorderbinary()
assert 1 <= random_seed_config <= 25
case_seed = sorted(list(random_seed_pair.keys()))[(random_seed_config - 1) // 5]
init_seed = sorted(random_seed_pair[case_seed])[(random_seed_config - 1) % 5]
print(case_seed, init_seed)

# Save inputs in dictionary
inputs = {}
inputs['n_vars']     = n_variables
inputs['lambda']     = 0

# Save objective function and regularization term
objective = HighOrderBinary(n_variables=inputs['n_vars'], highest_order=order, random_seed_pair=(case_seed, init_seed))
inputs['n_init']     = objective.suggested_init.size(0)
inputs['evalBudget'] = inputs['n_init'] + n_eval
inputs['model']      = lambda x: objective.evaluate(x)
inputs['penalty']    = lambda x: 0

# Generate initial samples for statistical models
inputs['x_vals']   = objective.suggested_init.numpy()
inputs['y_vals']   = inputs['model'](inputs['x_vals']) + inputs['penalty'](inputs['x_vals']) * inputs['lambda']

# Run BOCS-SA
BOCS_SA_model, BOCS_SA_obj, BOCS_SA_time = BOCS(inputs.copy(), order, 'SA')


# Compute optimal value found by BOCS
iter_t = np.arange(BOCS_SA_obj.size)
BOCS_SA_opt  = np.minimum.accumulate(BOCS_SA_obj)


print(BOCS_SA_model)
print(BOCS_SA_obj)
print(BOCS_SA_opt)


# Plot results
fig = plt.figure()
ax  = fig.add_subplot(1,1,1)
ax.plot(iter_t, BOCS_SA_opt, color='r', label='BOCS-SA')
ax.set_xlabel('$t$')
ax.set_ylabel('Best $f(x)$')
ax.legend()
plt.show()

# -- END OF FILE --