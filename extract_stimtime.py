import scipy.io as spio
import os.path
import numpy as np
import fileinput
import sys


def write_stimtime(filepath, inputvec):
	''' short hand function to write AFNI style stimtime'''
	if os.path.isfile(filepath) is False:
			f = open(filepath, 'w')
			for val in inputvec[0]:
				if val =='*':
					f.write(val + '\n')
				else:
					# this is to dealt with some weird formating issue
					f.write(np.array2string(np.around(val,2)).replace('\n','')[4:-1] + '\n') 
			f.close()


mat_path = '/data/backed_up/kahwang/HTB/fMRIprep/DesignMatrices/'
subjects = [41, 48, 54, 62, 67, 70, 77, 80, 84, 42, 45, 49, 57, 63, 68, 71, 78, 82, 43, 46, 53, 59, 64, 69, 76, 79]
num_runs=int(8) 
R4_stimtime = [['*']*num_runs]
R8_stimtime = [['*']*num_runs]
D1_stimtime = [['*']*num_runs]
D2_stimtime = [['*']*num_runs]


for s in subjects:
	for r in np.arange(num_runs): 
		fn = mat_path + 'sub%s/sub%s_designMatrix_run%s.mat' %(s, s, r+1)
		mat = spio.loadmat(fn)

		name = mat['names'][0][0][0]
		onsets = mat['onsets'][0][0][0]			
		
		if name == 'R4':
			R4_stimtime[0][r] = onsets
		if name == 'D1':
			D1_stimtime[0][r] = onsets
		if name == 'D2':
			D2_stimtime[0][r] = onsets
		if name == 'R8':
			R8_stimtime[0][r] = onsets				

	fn = mat_path + 'sub-0%s_D1.1D' %s
	write_stimtime(fn, D1_stimtime)	

	fn = mat_path + 'sub-0%s_D2.1D' %s
	write_stimtime(fn, D2_stimtime)	

	fn = mat_path + 'sub-0%s_R4.1D' %s
	write_stimtime(fn, R4_stimtime)	

	fn = mat_path + 'sub-0%s_R8.1D' %s
	write_stimtime(fn, R8_stimtime)	
