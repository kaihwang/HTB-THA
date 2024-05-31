#!/bin/bash
# do group analysis


data='/data/backed_up/kahwang/HTB/fMRIprep/Results'

rm -rf /data/backed_up/kahwang/HTB/fMRIprep/Group/
mkdir /data/backed_up/kahwang/HTB/fMRIprep/Group/

for contrast in alltask Dimension Load D2-R8 Abstraction Response; do 

	echo "cd /data/backed_up/kahwang/HTB/fMRIprep/Group 
	3dMEMA -prefix /data/backed_up/kahwang/HTB/fMRIprep/Group/${contrast}_groupMEMA \\
	-set ${contrast} \\" > /data/backed_up/kahwang/HTB/fMRIprep/Group/groupstat_${contrast}.sh

	cd ${data}
	
	# MTD_BC_stats_w20_MNI_V2v_REML+tlrc
	for s in 041 044 048 054 062 067 070 077 080 084 042 045 049 057 063 068 071 078 082 043 046 053 059 064 069 076 079 083; do 

		if [ -e ${data}/sub-${s}/FIRmodel_task-HTB_MNI_stats_REML+tlrc.HEAD ]; then
			cbrik=$(3dinfo -verb ${data}/sub-${s}/FIRmodel_task-HTB_MNI_stats_REML+tlrc | grep "${contrast}#0_Coef" | grep -o ' #[0-9]\{1,3\}' | grep -o '[0-9]\{1,3\}')
			tbrik=$(3dinfo -verb ${data}/sub-${s}/FIRmodel_task-HTB_MNI_stats_REML+tlrc | grep "${contrast}#0_Tstat" | grep -o ' #[0-9]\{1,3\}' | grep -o '[0-9]\{1,3\}')

			echo "${s} ${data}/sub-${s}/FIRmodel_task-HTB_MNI_stats_REML+tlrc[${cbrik}] ${data}/sub-${s}/FIRmodel_task-HTB_MNI_stats_REML+tlrc[${tbrik}] \\" >> /data/backed_up/kahwang/HTB/fMRIprep/Group/groupstat_${contrast}.sh
		fi
	done

	echo "-max_zeros 0 -cio " >> /data/backed_up/kahwang/HTB/fMRIprep/Group/groupstat_${contrast}.sh

	. /data/backed_up/kahwang/HTB/fMRIprep/Group/groupstat_${contrast}.sh

done
3dMean -prefix /data/backed_up/kahwang/HTB/fMRIprep/Group/FIR_R4.nii.gz ${data}/sub-*/R4_FIR_MNI.nii.gz
3dMean -prefix /data/backed_up/kahwang/HTB/fMRIprep/Group/FIR_R8.nii.gz ${data}/sub-*/R8_FIR_MNI.nii.gz
3dMean -prefix /data/backed_up/kahwang/HTB/fMRIprep/Group/FIR_D1.nii.gz ${data}/sub-*/D1_FIR_MNI.nii.gz
3dMean -prefix /data/backed_up/kahwang/HTB/fMRIprep/Group/FIR_D2.nii.gz ${data}/sub-*/D2_FIR_MNI.nii.gz

ln -s /data/backed_up/shared/standard/mni_icbm152_nlin_asym_09c/mni_icbm152_t1_tal_nlin_asym_09c.nii /data/backed_up/kahwang/HTB/fMRIprep/Group/mni.nii
cd /data/backed_up/kahwang/HTB/fMRIprep/Group