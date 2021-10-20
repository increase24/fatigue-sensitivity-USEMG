# Fatigue-sensitivity Comparison of sEMG and A-mode Ultrasound based Hand Gesture Recognition

This is an official pytorch implementation of [Fatigue-sensitivity Comparison of sEMG and A-mode Ultrasound based Hand Gesture Recognition (to be published)]()

## Environment
The code is developed using python 3.7 on Ubuntu 20.04. NVIDIA GPU is needed.

## Data preparing
The complete hybrid sEMG/AUS dataset is not released now. We apply collected sEMG/AUS data of one subject for code testing, which can be downloaded from: 
* [Baidu Disk](https://pan.baidu.com/s/1Tc9Y6TTDm7xjjOsoLFioqA#list/path=%2F)
(code: pyc4).
* [Google Drive]()

Create a folder named by "dataset". Download the dataset from the links and place it in this folder. Then following the instruction from the repo [USEMG-feature-extraction](https://github.com/increase24/USEMG-feature-extraction) to extract the features of sEMG and AUS signal. The extracted features will be saved to a folder named `"featureset"` (automatically create if not exits).

Your directory tree should look like this: 
```
${ROOT}/dataset
├── S1
|   ├── sEMG
|   |   |—— s1_*datetime1*_EMG.txt
|   |   |—— s1_*datetime2*_EMG.txt
|   |   |   ...
|   |   └── s1_*datetime8*_EMG.txt
|   └── AUS
|       |—— s1_*datetime1*_US.txt
|       |—— s1_*datetime2*_US.txt
|       |   ...
|       └── s1_*datetime8*_US.txt
├── S2
├── S3
├── S4
├── S5
├── S6
├── S7
└── S8

${ROOT}/featureset
├── S1
|   ├── sEMG
|   |   |—— FEATURE_s1_*datetime1*_EMG.txt
|   |   |—— FEATURE_s1_*datetime2*_EMG.txt
|   |   |   ...
|   |   └── FEATURE_s1_*datetime8*_EMG.txt
|   └── AUS
|       |—— FEATURE_s1_*datetime1*_US.txt
|       |—— FEATURE_s1_*datetime2*_US.txt
|       |   ...
|       └── FEATURE_s1_*datetime8*_US.txt
├── S2
├── S3
├── S4
├── S5
├── S6
├── S7
└── S8
```

## Usage
### Installation
1. Clone this repo
2. Install dependencies:
   ```
   pip install -r requirements.txt
   ```
### Training

## Results

## Citation
If you find this repository useful for your research, please cite with:
```
```

## Contact
If you have any questions, feel free to contact me through jia.zeng@sjtu.edu.cn or Github issues.