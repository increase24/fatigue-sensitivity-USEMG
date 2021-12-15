import os
os.sys.path.append('.')
import glob
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from sklearn import preprocessing
from utils.cm import confusionMatrix

NUM_CLASS = 8
start_repetition = 66
end_repetition = 99

def load_data(paths_emg, paths_aus, split_mode=1):
    dataset = [pd.DataFrame()]*8
    for index_motion in range(NUM_CLASS): # 8 motions
        df_emgFeature=pd.read_csv(paths_emg[index_motion],header = None)
        df_usFeature=pd.read_csv(paths_aus[index_motion],header = None)
        #exact 4800 valid samples from raw 10000 samples
        indexsList_NF=[]
        for i in range(10): # 10 repetitions
            indexs = [k for k in range(i*110+start_repetition,i*110+end_repetition)]
            indexsList_NF=indexsList_NF+indexs
        indexsList_F = [k + 2200 for k in indexsList_NF] # 2200:中间过程100s，1760 ：中间过程60s
        df_emgFeature_NF=df_emgFeature.iloc[indexsList_NF,:].reset_index(drop=True)
        df_emgFeature_F=df_emgFeature.iloc[indexsList_F,:].reset_index(drop=True)
        df_usFeature_NF=df_usFeature.iloc[indexsList_NF,:].reset_index(drop=True)
        df_usFeature_F=df_usFeature.iloc[indexsList_F,:].reset_index(drop=True)
        # split train and test data
        if(split_mode==0): #按顺序分割
            split_point = int(len(df_emgFeature_NF)*2/3)
            df_emgFeature_NF_train = df_emgFeature_NF.iloc[:split_point,:]
            df_emgFeature_NF_test = df_emgFeature_NF.iloc[split_point:len(df_emgFeature_NF),:]
            df_emgFeature_F_train = df_emgFeature_F.iloc[:split_point,:]
            df_emgFeature_F_test = df_emgFeature_F.iloc[split_point:len(df_emgFeature_NF),:]
            df_usFeature_NF_train = df_usFeature_NF.iloc[:split_point,:]
            df_usFeature_NF_test = df_usFeature_NF.iloc[split_point:len(df_emgFeature_NF),:]
            df_usFeature_F_train = df_usFeature_F.iloc[:split_point,:]
            df_usFeature_F_test = df_usFeature_F.iloc[split_point:len(df_emgFeature_NF),:]
        elif(split_mode==1): #随机分割
            index_all = np.arange(df_emgFeature_NF.shape[0])
            index_train=np.sort(np.random.choice(df_emgFeature_NF.shape[0],int(df_emgFeature_NF.shape[0]*3/5),replace=False))
            index_test = np.delete(index_all,index_train)
            df_emgFeature_NF_train = df_emgFeature_NF.iloc[index_train,:]
            df_emgFeature_NF_test = df_emgFeature_NF.iloc[index_test,:]
            df_emgFeature_F_train = df_emgFeature_F.iloc[index_train,:]
            df_emgFeature_F_test = df_emgFeature_F.iloc[index_test,:]
            df_usFeature_NF_train = df_usFeature_NF.iloc[index_train,:]
            df_usFeature_NF_test = df_usFeature_NF.iloc[index_test,:]
            df_usFeature_F_train = df_usFeature_F.iloc[index_train,:]
            df_usFeature_F_test = df_usFeature_F.iloc[index_test,:]
        # append
        dataset[0]=dataset[0].append(df_emgFeature_NF_train, ignore_index=True)
        dataset[1]=dataset[1].append(df_emgFeature_NF_test, ignore_index=True)
        dataset[2]=dataset[2].append(df_emgFeature_F_train, ignore_index=True)
        dataset[3]=dataset[3].append(df_emgFeature_F_test, ignore_index=True)
        dataset[4]=dataset[4].append(df_usFeature_NF_train, ignore_index=True)
        dataset[5]=dataset[5].append(df_usFeature_NF_test, ignore_index=True)
        dataset[6]=dataset[6].append(df_usFeature_F_train, ignore_index=True)
        dataset[7]=dataset[7].append(df_usFeature_F_test, ignore_index=True)
    return dataset

def evaluate_prediction(emgFeature_train, emgFeature_test, usFeature_train, usFeature_test, \
    labels_train,labels_test):        
    # =============================================================================
    # feature normalization
    # =============================================================================
    feature_scaler_emg = preprocessing.MinMaxScaler(feature_range=(0,1))
    emg_train_normalized = feature_scaler_emg.fit_transform(emgFeature_train)
    emg_test_normalized = feature_scaler_emg.transform(emgFeature_test)
    feature_scaler_us = preprocessing.MinMaxScaler(feature_range=(0,1))
    us_train_normalized = feature_scaler_us.fit_transform(usFeature_train)
    us_test_normalized = feature_scaler_us.transform(usFeature_test)
    # =============================================================================
    # PCA
    # =============================================================================
    from sklearn.decomposition import PCA
    pca_emg=PCA(n_components=40) 
    emg_train_pca=pca_emg.fit_transform(emg_train_normalized)
    emg_test_pca=pca_emg.transform(emg_test_normalized)
    pca_us=PCA(n_components=200) #optimal:240
    us_train_pca=pca_us.fit_transform(us_train_normalized)
    us_test_pca=pca_us.transform(us_test_normalized)
    # =============================================================================
    # model evaluation
    # =============================================================================       
    def evaluate(model,X_train, y_train,X_test,y_test):
        model.fit(X_train, y_train)
        y_predict = model.predict(X_test)
        prediction = sum(y_predict == y_test)/y_test.shape[0]         
        return y_predict, prediction
    from model.LDA_Bayesian import LDA_Bayesian
    model_lda = LDA_Bayesian(n_class = NUM_CLASS)
    y_predict1, prediction1 = evaluate(model_lda,emg_train_pca,labels_train,
                                    emg_test_pca,labels_test)
    print('precision of EMG:'+str(prediction1))
    y_predict2, prediction2 = evaluate(model_lda,us_train_pca,labels_train,
                                    us_test_pca,labels_test)
    print('precision of US:'+str(prediction2))
    return y_predict1, prediction1, y_predict2, prediction2

def generate_labels():
    n_class = NUM_CLASS
    labels = np.linspace(0, n_class-1, n_class, endpoint=True, dtype=int)
    labels_train = np.tile(labels, (int(3/5*(end_repetition-start_repetition)*10),1))
    labels_train= labels_train.reshape(-1,1,order = 'F')
    labels_test = np.tile(labels, (int(2/5*(end_repetition-start_repetition)*10),1))
    labels_test= labels_test.reshape(-1,1,order = 'F')
    return labels_train[:,0], labels_test[:,0]

if __name__ == "__main__":
    subjects = sorted(glob.glob('./featureset/*'))
    # subject-specific
    index_sub = 0
    dirs_emgFeats = sorted(glob.glob(os.path.join(subjects[index_sub], 'sEMG','*.txt')))
    dirs_ausFeats = sorted(glob.glob(os.path.join(subjects[index_sub], 'AUS','*.txt')))
    df_inputs = load_data(dirs_emgFeats, dirs_ausFeats, split_mode=1)
    labels_train, labels_test = generate_labels()
    accuracies = np.zeros((3,2))
    # NF-NF approach 
    preds_emg_nf_nf, accuracies[0,0], preds_us_nf_nf, accuracies[0,1] = evaluate_prediction(
        df_inputs[0], df_inputs[1], df_inputs[4], df_inputs[5], labels_train, labels_test)
    # F-F approach 
    preds_emg_f_f, accuracies[1,0], preds_us_f_f, accuracies[1,1] = evaluate_prediction(
        df_inputs[2], df_inputs[3], df_inputs[6], df_inputs[7], labels_train, labels_test)
    # NF-F approach 
    preds_emg_nf_f, accuracies[2,0], preds_us_nf_f, accuracies[2,1] = evaluate_prediction(
        df_inputs[0], df_inputs[3], df_inputs[4], df_inputs[7], labels_train, labels_test)
    # save accuracies
    if not os.path.exists(os.path.join('results', subjects[index_sub])):
        os.makedirs(os.path.join('results', subjects[index_sub]))
    np.savetxt(os.path.join('results', subjects[index_sub], 'accuracies.txt'), accuracies)

    # compute and save confusion matrix
    confusionMatrix(labels_test,preds_emg_nf_nf, os.path.join('results', subjects[index_sub],"cm_emg_nf_nf.png"))
    confusionMatrix(labels_test, preds_us_nf_nf, os.path.join('results', subjects[index_sub],"cm_us_nf_nf.png"))
    confusionMatrix(labels_test, preds_emg_f_f, os.path.join('results', subjects[index_sub],"cm_emg_f_f.png"))
    confusionMatrix(labels_test, preds_us_f_f, os.path.join('results', subjects[index_sub],"cm_us_f_f.png"))
    confusionMatrix(labels_test, preds_emg_nf_f, os.path.join('results', subjects[index_sub],"cm_emg_nf_f.png"))
    confusionMatrix(labels_test, preds_us_nf_f, os.path.join('results', subjects[index_sub],"cm_us_nf_f.png"))

