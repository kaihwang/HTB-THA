#!/bin/sh

# run 3dDeconvolve

#041 044 048 054 062 067 070 077 080 084 042 045 049 057 063 068 071 078 082 043 046 053 059 064 069 076 079 083

for s in 041 044 048 054 062 067 070 077 080 084 042 045 049 057 063 068 071 078 082 043 046 053 059 064 069 076 079 083; do 

	for task in HTB; do

		Raw="/data/backed_up/kahwang/HTB/fMRIprep/data/fmriprep/fmriprep/sub-${s}"
		Output='/data/backed_up/kahwang/HTB/fMRIprep/Results'

		for run in 1 2 3 4 5 6 7 8; do

			if [ ! -e ${Raw}/func/sub-${s}_task-${task}run${run}_bold_space-MNI152NLin2009cAsym_preproc_smoothed_scaled.nii.gz ]; then
				
				3dmerge -1blur_fwhm 4.5 -doall -prefix ${Raw}/func/sub-${s}_task-${task}run${run}_bold_space-MNI152NLin2009cAsym_smoothed.nii.gz \
				${Raw}/func/sub-${s}_task-${task}run${run}_bold_space-MNI152NLin2009cAsym_preproc.nii.gz
				#3dBlurToFWHM -input ${Raw}/func/sub-${s}_task-${task}_run-${run}_bold_space-MNI152NLin2009cAsym_preproc.nii.gz \
				#-prefix ${Raw}/func/sub-${s}_task-${task}_run-${run}_bold_space-MNI152NLin2009cAsym_smoothed_preproc.nii.gz \
				#-FWHM 6		

				#scaling
				3dTstat -mean -prefix ${Raw}/func/sub-${s}_task-${task}run${run}_bold_space-MNI152NLin2009cAsym_preproc_mean.nii.gz \
				${Raw}/func/sub-${s}_task-${task}run${run}_bold_space-MNI152NLin2009cAsym_smoothed.nii.gz

				3dcalc \
				-a ${Raw}/func/sub-${s}_task-${task}run${run}_bold_space-MNI152NLin2009cAsym_smoothed.nii.gz \
				-b ${Raw}/func/sub-${s}_task-${task}run${run}_bold_space-MNI152NLin2009cAsym_preproc_mean.nii.gz  \
				-c ${Raw}/func/sub-${s}_task-${task}run${run}_bold_space-MNI152NLin2009cAsym_brainmask.nii.gz \
				-expr "(a/b * 100) * c" \
				-prefix ${Raw}/func/sub-${s}_task-${task}run${run}_bold_space-MNI152NLin2009cAsym_preproc_smoothed_scaled.nii.gz

				#remove not needed files
				rm ${Raw}/func/sub-${s}_task-${task}run${run}_bold_space-MNI152NLin2009cAsym_preproc_mean.nii.gz
				rm ${Raw}/func/sub-${s}_task-${task}run${run}_bold_space-MNI152NLin2009cAsym_smoothed.nii.gz
			fi
		done	

		if [ -d ${Output}/sub-${s}/ ]; then
			rm -rf ${Output}/sub-${s}/
		fi

		if [ ! -d ${Output}/sub-${s}/ ]; then
			mkdir ${Output}/sub-${s}/
		fi

		# if [ -e ${Output}/sub-${s}/confounds.tsv ]; then
		# 	rm ${Output}/sub-${s}/confounds.tsv
		# fi

		# if [ -e rm ${Output}/sub-${s}/motion.tsv ]; then
		# 	rm ${Output}/sub-${s}/motion.tsv
		# fi

		# touch ${Output}/sub-${s}/confounds.tsv
		# touch ${Output}/sub-${s}/motion.tsv

		# compile nuisance regressors
		for f in $(ls ${Raw}/func/sub-${s}_task-${task}run*confounds.tsv | sort -V); do
			cat ${f} | tail -n+2 | cut -f1-3,14-19 >> ${Output}/sub-${s}/confounds.1D
			cat ${f} | tail -n+2 | cut -f22-27 >> ${Output}/sub-${s}/motion.1D
		done

		#1d_tool.py -infile ${Output}/sub-${s}/motion.tsv -set_nruns 8 -show_censor_count -censor_motion 0.2 ${Output}/sub-${s}/FD0.2 -censor_prev_TR -overwrite
		1d_tool.py -infile ${Output}/sub-${s}/motion.1D -set_nruns 8 -derivative -censor_prev_TR -collapse_cols euclidean_norm \
        -moderate_mask -1.2 1.2            \
        -show_censor_count                 \
        -write_censor ${Output}/sub-${s}/censor.1D
		
		1d_tool.py -infile ${Output}/sub-${s}/motion.1D -set_nruns 8 -overwrite -derivative -write ${Output}/sub-${s}/motion.deriv.1D 

		rm ${Output}/sub-${s}/union_mask.nii.gz
		3dMean -count -prefix ${Output}/sub-${s}/union_mask.nii.gz $(ls ${Raw}/func/sub-${s}_task-${task}run*_bold_space-MNI152NLin2009cAsym_brainmask.nii.gz)

		if [ -e ${Output}/sub-${s}/censor.1D ]; then

			/home/kahwang/bin/linux_centos_7_64/3dDeconvolve -input $(ls ${Raw}/func/sub-${s}_task-${task}run*_bold_space-MNI152NLin2009cAsym_preproc_scaled.nii.gz | sort -V) \
			-mask ${Output}/sub-${s}/union_mask.nii.gz \
			-polort A \
			-num_stimts 4 \
			-censor ${Output}/sub-${s}/censor.1D \
			-ortvec ${Output}/sub-${s}/confounds.1D confounds \
			-ortvec ${Output}/sub-${s}/motion.1D motion \
			-ortvec ${Output}/sub-${s}/motion.deriv.1D motion_deriv \
			-stim_times 1 /data/backed_up/kahwang/HTB/fMRIprep/DesignMatrices/sub-${s}_R4.1D 'CSPLIN(0, 12, 9)' -stim_label 1 R4 \
			-stim_times 2 /data/backed_up/kahwang/HTB/fMRIprep/DesignMatrices/sub-${s}_R8.1D 'CSPLIN(0, 12, 9)' -stim_label 2 R8 \
			-stim_times 3 /data/backed_up/kahwang/HTB/fMRIprep/DesignMatrices/sub-${s}_D1.1D 'CSPLIN(0, 12, 9)' -stim_label 3 D1 \
			-stim_times 4 /data/backed_up/kahwang/HTB/fMRIprep/DesignMatrices/sub-${s}_D2.1D 'CSPLIN(0, 12, 9)' -stim_label 4 D2 \
			-iresp 1 ${Output}/sub-${s}/R4_FIR_MNI.nii.gz \
			-iresp 2 ${Output}/sub-${s}/R8_FIR_MNI.nii.gz \
			-iresp 3 ${Output}/sub-${s}/D1_FIR_MNI.nii.gz \
			-iresp 4 ${Output}/sub-${s}/D2_FIR_MNI.nii.gz \
			-num_glt 16 \
			-gltsym 'SYM: +1*D1 +1*D2 -1*R4 -1*R8 ' -glt_label 1 Dimension \
			-gltsym 'SYM: +1*D2 +1*R8 -1*D1 -1*R4 ' -glt_label 2 Load \
			-gltsym 'SYM: +1*D2 -1*D1 -1*R8 +1*R4 ' -glt_label 3 Interaction \
			-gltsym 'SYM: +1*R8 -1*R4 ' -glt_label 4 R8-R4 \
			-gltsym 'SYM: +1*D2 -1*D1 ' -glt_label 5 D2-D1 \
			-gltsym 'SYM: +1*D2 -1*R8 ' -glt_label 6 D2-R8 \
			-gltsym 'SYM: +1*D1 -1*R4 ' -glt_label 7 D1-R4 \
			-gltsym 'SYM: +1*D2 -1*R4 ' -glt_label 8 D2-R4 \
			-gltsym 'SYM: +1*R8 -1*D1 ' -glt_label 9 R8-D1 \
			-gltsym 'SYM: +0.5*R4 +0.5*R8 ' -glt_label 10 R4+R8 \
			-gltsym 'SYM: +0.5*D1 +0.5*D2 ' -glt_label 11 D1+D2 \
			-gltsym 'SYM: +1*D1 ' -glt_label 12 D1 \
			-gltsym 'SYM: +1*D2 ' -glt_label 13 D2 \
			-gltsym 'SYM: +1*R4 ' -glt_label 14 R4 \
			-gltsym 'SYM: +1*R8 ' -glt_label 15 R8 \
			-gltsym 'SYM: +1*D1 +1*D2 +1*R4 +1*R8 ' -glt_label 16 alltask \
			-rout \
			-tout \
			-bucket ${Output}/sub-${s}/FIRmodel_task-${task}_MNI_stats \
			-errts ${Output}/sub-${s}/FIRmodel_task-${task}_errts.nii.gz \
			-noFDR \
			-nocout \
			-jobs 24 \
			-allzero_OK


			. /data/backed_up/kahwang/HTB/fMRIprep/Results/sub-${s}/FIRmodel_task-HTB_MNI_stats.REML_cmd

		fi

		ln -s /data/backed_up/shared/standard/mni_icbm152_nlin_asym_09c/mni_icbm152_t1_tal_nlin_asym_09c.nii ${Output}/sub-${s}/mni.nii

	done

	cd /data/backed_up/kahwang/HTB/fMRIprep/Results/sub-${s}/
done


