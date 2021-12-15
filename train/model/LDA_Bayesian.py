import numpy as np

class LDA_Bayesian():
    def __init__(self, n_class):
        self.__n_class=n_class
    
    #feature:np.array(n_samples,n_features), labels:np.array(n_samples,)
    def fit(self, feature, labels):
        n_class = self.__n_class
        #number of feats(samples) and dimension of features
        num_samples = feature.shape[0]
        feat_dim = feature.shape[1]
        MeanMat = np.zeros([n_class, feat_dim],dtype=np.float64)
        CovMat = np.zeros([feat_dim * n_class, feat_dim],dtype=np.float64)
        PoolCovMat = np.zeros([feat_dim, feat_dim],dtype=np.float64)
        index_sort=np.argsort(labels)
        labels_sorted=labels[index_sort]
        feature=feature[index_sort]
        from collections import  Counter
        counter_class=Counter(labels_sorted)
        #return a numpy array:[[label1,counter1],[label2,counter2],...,[labelN,counterN]]
        counter_class=np.array(counter_class.most_common(len(counter_class)))
        #compute the mean vector of each class, stored into mean matrix
        for i in range(self.__n_class):
            start = sum(counter_class[:i,1])
            end = start + counter_class[i,1]
            MeanMat[i,:]=np.mean(feature[start:end,:],axis=0)
        #compute the covariance matrix for each class and pool covariance matrix
#        #method one
#        for i in range(self.__n_class):
#            m_cov = np.zeros([feat_dim, feat_dim],dtype=np.float32)
#            for j in range(i * samples_per_class,(i+1) * samples_per_class,1):
#                #(featmat.Row(i) - MeanMat.Row(j)T*(featmat.Row(i) - MeanMat.Row(j)
#                m_cov+=np.matmul((feature[j,:] - MeanMat[i,:]).transpose(),feature[j,:] - MeanMat[i,:])
#            CovMat[i * feat_dim:(i+1)* feat_dim,:] = m_cov
        #method two       
        for i in range(self.__n_class):
            ones = np.ones([counter_class[i,1],1])
            start = sum(counter_class[:i,1])
            end = start + counter_class[i,1]
            m_cov = feature[start:end,:]-np.matmul(ones,MeanMat[i,:].reshape([1,-1]))
            CovMat[i * feat_dim:(i+1)* feat_dim,:]=np.matmul(m_cov.transpose(),m_cov)
            PoolCovMat += CovMat[i * feat_dim:(i+1)* feat_dim,:]
        PoolCovMat /= (num_samples - n_class) # 1/((sample_per_class-1)*n_class)
        self.__ModelCov = np.linalg.inv(PoolCovMat)
        self.__ModelMean = MeanMat
        
    #feature_vectors:np.array(n_samples,n_features)
    def predict(self,feature_vectors):
        feat_dim = self.__ModelCov.shape[1] #m_ModelCov:(feat_dim, feat_dim)
        n_class = self.__ModelMean.shape[0] #m_ModelMean:(n_class, feat_dim)
        if(feature_vectors.shape[1] != feat_dim):
            print("the dimension of features is not equal to the dimension of Gaussian Model")
            return -1
        n_samples = feature_vectors.shape[0]
        d_maha = np.zeros([n_samples,n_class],dtype=np.float32)
        for i in range(n_samples):
            for j in range(self.__n_class):
                #(x-u_k)*((Σ^(-1)))*(x-u_k)T
                d_maha[i,j] = (feature_vectors[i,:] -self.__ModelMean[j,:]).dot(self.__ModelCov) \
                .dot((feature_vectors[i,:] - self.__ModelMean[j,:]).transpose())
        label_predict = np.argmin(d_maha,axis=1)
        return label_predict
    
def main():
    from sklearn import datasets
    from sklearn.model_selection import train_test_split   
    iris=datasets.load_iris()
    X=iris.data
    y=iris.target
    X_train,X_test,y_train,y_test=train_test_split(X,y,test_size=0.2,shuffle=True)
    lda = LDA_Bayesian(n_class=3)
    lda.fit(X_train,y_train)
    y_predict=lda.predict(X_test)
    print('predict:{:.4f}'.format(sum(y_predict == y_test)/y_test.shape[0]))
    
if __name__ == '__main__' : #__name__ 是当前模块名,当模块被直接运行时模块名为 __main__ 
    main()
        
    

