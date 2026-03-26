
setenv out_dir /projects/msit
setenv subs_dir /projects/msit/subjs
setenv params_dir /projects/msit/bsm_params

set subjects_list = ()
foreach subjs ($subjects_list)
	echo $subjs
	cd $subs_dir/${subjs}/msit_bsm/anat;
	cp *.anat.mask+tlrc.* ../results;
	cp *.anat.2x2x2+tlrc.* ../results;
	echo "-------T1s COPIED for " $subjs "----------"
	cd $subs_dir/${subjs}/msit_bsm/func;
	cp *.smooth.resid+tlrc.* ../results;
	echo "-------smooth.resid+tlrc. COPIED for " $subjs "----------"
	cp *.motion.py.strp+tlrc.* ../results;
	echo "-------.motion.py.strp+tlrc. COPIED for " $subjs "----------"
	echo "-------EPIs COPIED for " $subjs "----------"
	cd $subs_dir/${subjs}/msit_bsm/bsm;
	cp *LSS* ../results;
	echo "-------BSM COPIED for " $subjs "----------"
end

cd $out_dir
