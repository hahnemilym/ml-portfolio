#! /bin/csh

setenv out_dir /projects/msit
setenv subs_dir /projects/msit/subjs
setenv params_dir /projects/msit/bsm_params

set subjects_list = ()

foreach subjs (`cat $subjects_list`)
	cd $subs_dir/${subjs}/msit_bsm/results;
	cp *_LSS_avg_file.1D* $out_dir/beta_extract_output;
	cp *R.LSS.1D* $out_dir/beta_extract_output;
	echo "-------BSM extractions COPIED for " $subjs "----------"

end

cd $out_dir
