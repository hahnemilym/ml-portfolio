# MSIT task fMRI — AFNI preprocessing and Beta Series Method (BSM)

Analysis pipeline for the **Multi-Source Interference Task (MSIT)** using **AFNI** for task fMRI preprocessing and **Beta Series Method (BSM)** modeling (`3dDeconvolve` / `3dLSS`). Supporting steps use **SPM** (slice timing, motion derivatives) and **FSL** (tissue segmentation), with anatomical prep that assumes **FreeSurfer → SUMA** outputs.

## Quickstart: what to install first

Install and wire up the stack **before** editing paths inside the `.csh` scripts. Suggested order (each step depends on the previous being on your `PATH` or sourced in the shell you use to launch the pipeline):

1. **[FreeSurfer](https://surfer.nmr.mgh.harvard.edu/fswiki/DownloadAndInstall)** — Download, accept the license, run `SetUpFreeSurfer.sh` (or your site’s module). You need **`recon-all`** output (or equivalent) for SUMA/AFNI anatomical prep.
2. **[FSL](https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/FslInstallation)** — Install and source **`$FSLDIR/etc/fslconf/fsl.sh`** in `~/.bashrc` or equivalent so **`fast`**, **`bet`**, and related tools work from non-interactive shells if your site requires it.
3. **[AFNI](https://afni.nimh.nih.gov/pub/dist/doc/htmldata/background_install/main_toc.html)** — Full install with binaries on **`PATH`**. Confirm **`3dDeconvolve`**, **`3dLSS`**, **`@auto_tlrc`**, and **`maskSVD`** (or your AFNI version’s equivalent) are available. SUMA/Surface tools used in step 0 are typically satisfied once **AFNI + FreeSurfer** are installed correctly.
4. **MATLAB** — A recent release is usually fine; the `.csh` drivers call **`matlab -nodesktop -nosplash -r "..."`** for slice timing and motion regressors.
5. **[SPM8](https://www.fil.ion.ucl.ac.uk/spm/software/spm8/)** — Install under MATLAB and point the `.m` files at your copy: change **`addpath '/spm/spm8'`** in `general_multiband_slice_timing.m` (and any other hard-coded SPM paths) to match your machine.
6. **C shell** — Scripts use **`#!/bin/csh`**. **macOS** includes **`tcsh`**. On **Linux**, install **`tcsh`** if needed, then run drivers with **`tcsh script.csh`** or **`csh script.csh`**.

**Sanity checks** (from a terminal):

```bash
which tcsh csh 2>/dev/null; recon-all -help 2>&1 | head -1
echo $FREESURFER_HOME $FSLDIR; which fast 2>/dev/null
which 3dDeconvolve 3dLSS suma 2>/dev/null
matlab -batch "ver" 2>/dev/null | head -3
```

**Then** open `AFNI_anat_preproc_step0.csh`, `AFNI_BSM_Analysis.csh`, etc., and replace **`/projects/msit`** (and subject lists) with your project layout. See **`requirements.txt`** in this folder for the same checklist with doc links.

## Contents


| File                                   | Role                                                                                                                                               |
| -------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Orchestration**                      |                                                                                                                                                    |
| `AFNI_anat_func_MASTER_SCRIPT.csh`     | Sources BSM analysis and result-transfer scripts (commented block shows full anat + func + BSM order).                                             |
| `AFNI_anat_func_MASTER_BSM_SCRIPT.csh` | Intended to source `AFNI_BSM_Analysis.csh` and `AFNI_BSM_ROI_BetaExtraction.csh` (only the former is present in this folder).                      |
| **Anatomical preprocessing**           |                                                                                                                                                    |
| `AFNI_anat_preproc_step0.csh`          | SUMA: FreeSurfer → AFNI conversion; copy into BSM directory layout.                                                                                |
| `AFNI_anat_preproc_step1.csh`          | AFNI/FSL: NIfTI → AFNI, GM/WM/CSF segmentation, Talairach (`@auto_tlrc`) for anat and segmentations.                                               |
| **Functional preprocessing**           |                                                                                                                                                    |
| `AFNI_func_preproc_step0.csh`          | Calls MATLAB: `general_multiband_slice_timing` (SPM8) for multiband slice-timing correction.                                                       |
| `AFNI_func_preproc_step1.csh`          | Part 1: despiking, deobliquing, motion correction (expects SPM MBST / slice timing already run).                                                   |
| `AFNI_func_preproc_step2.csh`          | Part 2: resample anat to EPI grid, warp structural to functional space, EPI masking.                                                               |
| `AFNI_func_preproc_step2.5.csh`        | Calls MATLAB: `make_motion_regressors` (motion + temporal derivatives for nuisance regression).                                                    |
| `AFNI_func_preproc_step3.csh`          | Part 3: nuisance masks (WM/CSF), `maskSVD` regressors, regress out WM/CSF/motion, retain residuals.                                                |
| `AFNI_func_preproc_step4.csh`          | Part 4: polynomial detrending, high-pass filter (128 s), spatial smoothing.                                                                        |
| **BSM**                                |                                                                                                                                                    |
| `AFNI_BSM_Analysis.csh`                | Per-subject BSM: ROI masks in TLRC, `3dDeconvolve` design, `3dLSS`, clustering / extrema, ROI spheres, beta extraction (`3dbucket` / `3dmaskave`). |
| **MATLAB**                             |                                                                                                                                                    |
| `general_multiband_slice_timing.m`     | SPM8 wrapper for multiband interleaved slice timing (63 slices, odds-first pattern).                                                               |
| `make_motion_regressors.m`             | Builds motion regressors (and derivatives) from per-run `.motion.1D` files.                                                                        |
| `spm_mbst.m`                           | SPM slice-timing routine (used in the slice-timing path).                                                                                          |
| **Utilities / optional**               |                                                                                                                                                    |
| `AFNI_RAI2TLRC.csh`                    | Optional coordinate / `whereami` helper for RAI ↔ TLRC (marked as needing updates for broader use).                                                |
| `transfer_results.csh`                 | Copies anat, func (e.g. smoothed residuals, motion), and BSM volumes into per-subject `results`.                                                   |
| `transfer_bsm_results.csh`             | Aggregates BSM 1D outputs into a project-level `beta_extract_output` directory.                                                                    |


## Typical pipeline order

1. Anat: `AFNI_anat_preproc_step0.csh` → `AFNI_anat_preproc_step1.csh`
2. Func: `AFNI_func_preproc_step0.csh` → `AFNI_func_preproc_step1.csh` → `AFNI_func_preproc_step2.5.csh` → `AFNI_func_preproc_step2.csh` → `AFNI_func_preproc_step3.csh` → `AFNI_func_preproc_step4.csh`
3. BSM: `AFNI_BSM_Analysis.csh`
4. Collect outputs: `transfer_results.csh`, `transfer_bsm_results.csh`

## Configuration

Scripts assume a project root such as `/projects/msit`, with `subjs`, `bsm_params`, and task-specific folders (e.g. `msit_bsm`). **Edit `setenv` paths, subject lists, TR (1.75 s in BSM script), and ROI definitions** before running on a new machine or dataset.

## Dependencies

See **`requirements.txt`** in this directory for a printable checklist and install links.

- [AFNI](https://afni.nimh.nih.gov/)  
- [FSL](https://fsl.fmrib.ox.ac.uk/) (segmentation in anat step)  
- **SPM8** (paths in `.m` files reference `/spm/spm8`; update `addpath` as needed)  
- **FreeSurfer / SUMA** (anatomical step 0)  
- **MATLAB** (batch calls from `.csh` drivers)  
- **C shell** (`csh`/`tcsh`) for `.csh` drivers

