# EEG Motor Execution Preprocessing Pipeline
MATLAB-based preprocessing and feature extraction pipeline for EEG signals acquired during unilateral motor execution tasks (Relax and Left Fist).
This repository supports the methodological workflow described in the associated research project and focuses on signal preparation prior to training machine learning models.

## 1. Data Extraction
EEG data were obtained from a curated version of the Physionet EEG Motor Imagery/Execution dataset.
The dataset includes recordings from 103 subjects, sampled at 160 Hz accross 64 EEG channels. Each subject performed 12 task-related runs.

This stage:
- Loads the curated EEG dataset.
- Extracts the runs of interest (Run 1: Relax, Run 2: Left Fist Motor Execution), both belonging to Task 1 (Motor Execution, unilateral).
- Organizes data progressively, until a three-dimensional matrix of size [subjects x samples x channles] is achieved.

Scripts involved: 
- Data_extraction.m
- ThreeDimensional_matrix.m

## 2. Filtering
EEG signals were decomposed into five frequency bands using a Chebyshev Type II bandpass IIR filter: **delta** (0.5-4 Hz); **theta** (4-7 Hz); **alpha** (8-12 Hz); **beta** (13-30 Hz); **gamma** (>30 Hz)

Scripts involved:
- Filtering/filter_one_signal.m
- Filtering/filter_threeDMatrixRunOne.m

## 3. Feature Extraction
From each band-limited signal obtained after filtering, a total of eight features were extracted per subject and channel:
**Time-domain-features** included mean, variance, power and maximum amplitude.
**Frequency-domain features computed using the Fourier Transform** included mean spectrum, variance spectrum, maximum amplitude spectrum and dominant frequency (Hz).

Scripts involved:
- Filtering/filter_threeDMatrixRunOne.m
- Filtering/export_features_toCSV.m

## NOTES
Raw EEG data and derived feature files are **not included** in this repository.
