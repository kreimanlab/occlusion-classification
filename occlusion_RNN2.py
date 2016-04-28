import theano
import pdb, sys, traceback, os, pickle, time

import numpy as np
import scipy.ndimage
import matplotlib.pyplot as plt
import hickle as hkl
import scipy as sp
import scipy.io as spio
import pickle as pkl
from scipy.misc import imread, imresize
import pandas as pd
import shutil

from occluded_images_classification_FFmodels import load_KLAB325_features, KLAB325_orig_classes, load_KLAB16_features


def_dir = os.path.expanduser('~/default_dir')
sys.path.insert(0,def_dir)
from basic_fxns import *

cname = get_computer_name()

sys.path.append(get_scripts_dir() +'General_Scripts/')
from general_python_functions import libsvm_classify, compute_kernel_mat, load_features

import general_python_functions as gp
sys.path.append('/home/bill/Libraries/keras/')
from keras.datasets import mnist
from keras.utils import np_utils
from keras.models import standardize_X, slice_X
from keras.optimizers import *
from keras.models import *
from keras.layers.core import *
from keras.layers.convolutional import *
from keras.layers.recurrent import *

sys.path.append('/home/bill/Dropbox/Cox_Lab/Predictive_Networks/scripts/')
from prednet2 import plot_error_log


base_save_dir = '/home/bill/Projects/Occlusion_RNN/runs/'

def get_occlusion_params(param_overrides=None):

    #base_save_dir = '/home/bill/Projects/Occlusion_RNN/runs/'

    P = {}
    P['n_orig_replicas'] = 1
    P['nt'] = 5
    P['batch_size'] = 512
    P['t_val'] = range(-1,P['nt']+2)
    P['C_list'] = [1e-4, 1e-3, 1e-2, 0.1, 1, 10, 100, 1e3, 1e4]
    P['n_epochs'] = 10
    P['fixed_W'] = True
    P['input_once'] = False

    P['train_for_KLAB16'] = False
    P['train_for_PHYS'] = True
    P['split_num'] = 0
    P['do_svm_test'] = False
    P['input_layer'] = 'fc7_noRelu' #'fc7_noRelu' #'pool5'

    #P['run_num'] = gp.get_next_run_num(base_save_dir)
    #P['save_dir'] = base_save_dir + 'run_' + str(P['run_num']) + '/'

    if param_overrides is not None:
        for d in param_overrides:
            P[d] = param_overrides[d]

    if P['train_for_KLAB16']:
        P['run_num'] = P['input_layer']+'_KLAB16'
        P['save_dir'] = base_save_dir + P['input_layer']+'_KLAB16/'
    elif P['train_for_PHYS']:
        P['run_num'] = P['input_layer']+'_PHYS'
        P['save_dir'] = base_save_dir + P['input_layer']+'_PHYS/'
    else:
        P['run_num'] = P['input_layer']+'_split'+str(P['split_num'])
        P['save_dir'] = base_save_dir + P['input_layer']+'_split'+str(P['split_num'])+'/'

    return P


def create_model(P):

    model = Graph()
    model.add_input(name='input', ndim=3)

    f = P['input_layer'].replace('_norelu', '').replace('_noRelu', '')
    feature_size = {'fc7': 4096, 'pool5': 9216, 'conv5': 43264}

    model.add_node(SimpleRNN(feature_size[f], feature_size[f], fixed_W=P['fixed_W'], activation='relu', return_sequences=False), name='RNN', input='input')
    model.add_output(name='output', input='RNN')

    return model


def run_RNN(param_overrides=None):

    P = get_occlusion_params(param_overrides)

    model, log = train_RNN(P)

    if not os.path.exists(P['save_dir']):
        os.mkdir(P['save_dir'])

    f = open(P['save_dir'] + 'params.pkl', 'w')
    pickle.dump(P, f)
    f.close()

    f = open(P['save_dir'] + 'log.pkl', 'w')
    pickle.dump(log, f)
    f.close()

    model.save_weights(P['save_dir']+'model_weights.hdf5', overwrite=True)

    plot_error_log(P, log)

    if P['do_svm_test']:

        if P['train_for_KLAB16']:
            for t in [False, True]:
                print 'Train occl='+str(t)
                pred_features, pred_classes = evaluate_RNN_KLAB16(P, model, train_occl=t)

                if t:
                    s = 'trainoccl'
                else:
                    s = 'trainorig'

                f = open(P['save_dir'] + 'features_over_time_test_'+s+'.hkl', 'w')
                hkl.dump(pred_features, f)
                f.close()

                f = open(P['save_dir'] + 'pred_classes_test_'+s+'.hkl', 'w')
                hkl.dump(pred_classes, f)
                f.close()
        else:
            for t in [True, False]:
                print 'Train occl='+str(t)
                print ' Doing validation'
                best_C = evaluate_RNN(P, model, is_test=False, train_occl=t)

                print ' Doing Testing'
                pred_features, scores, pred_classes = evaluate_RNN(P, model, is_test=True, C_to_use=best_C, train_occl=t)

                if t:
                    s = 'trainoccl'
                else:
                    s = 'trainorig'

                f = open(P['save_dir'] + 'features_over_time_test_'+s+'.hkl', 'w')
                hkl.dump(pred_features, f)
                f.close()

                f = open(P['save_dir'] + 'pred_classes_test_'+s+'.hkl', 'w')
                hkl.dump(pred_classes, f)
                f.close()

                f = open(P['save_dir'] + 'svm_scores_test_'+s+'.txt', 'w')
                for t in scores:
                    f.write(str(t)+": "+str(scores[t]))
                    f.write("\n")
                f.close()



def train_RNN(P):

    model = create_model(P)
    model.compile('rmsprop', {'output': 'mse'})

    if P['train_for_KLAB16']:
        train_idx = get_KLAB16_train_idx()
        val_idx = np.random.permutation(train_idx)[:300]  #it doesnt matter, wont be used
    elif P['train_for_PHYS']:
        train_idx = get_PHYS_train_idx()
        val_idx = np.random.permutation(train_idx)[:300]  #it doesnt matter, wont be used
    else:
        train_idx, val_idx, test_idx = load_idxs_by_split(P['split_num'])
    X = load_KLAB325_features('caffenet_'+P['input_layer'])
    if '_noRelu' in P['input_layer']:
        X_target = load_KLAB325_features('caffenet_'+P['input_layer'].replace('_noRelu',''))
    else:
        X_target = X

    is_orig, im_labels, _ = load_extra_data()

    orig_features = X_target[:325]

    idx = [i for i in train_idx if not is_orig[i]]
    X_train_occl = X[idx]
    im_labels_occl = im_labels[idx]
    idx = [i for i in train_idx if is_orig[i]]
    X_train_orig = X[idx]
    im_labels_orig = im_labels[idx]
    X_train_orig = np.tile(X_train_orig, (P['n_orig_replicas'],1))
    im_labels_orig = np.tile(im_labels_orig, P['n_orig_replicas'])
    X_train = np.vstack((X_train_orig, X_train_occl)).astype(np.float32)
    im_labels_train = np.concatenate((im_labels_orig, im_labels_occl))

    X_train_all_t = np.zeros((X_train.shape[0], P['nt'], X_train.shape[1])).astype(np.float32)
    for i in range(X_train.shape[0]):
        if P['input_once']:
            X_train_all_t[i,0] = X_train[i]
        else:
            X_train_all_t[i,:] = X_train[i]

    Y_train = np.zeros_like(X_train).astype(np.float32)
    for i in range(len(im_labels_train)):
        Y_train[i] = orig_features[im_labels_train[i]]

    X_val = X[val_idx].astype(np.float32)
    im_labels_val = im_labels[val_idx]

    X_val_all_t = np.zeros((X_val.shape[0], P['nt'], X_val.shape[1])).astype(np.float32)
    for i in range(X_val.shape[0]):
        if P['input_once']:
            X_val_all_t[i,0] = X_val[i]
        else:
            X_val_all_t[i,:] = X_val[i]

    Y_val = np.zeros_like(X_val).astype(np.float32)
    for i in range(len(im_labels_val)):
        Y_val[i] = orig_features[im_labels_val[i]]

    train_data = {'input': X_train_all_t, 'output': Y_train}
    val_data = {'input': X_val_all_t, 'output': Y_val}

    log = {}
    log['train_error'] = np.zeros(P['n_epochs'])
    log['val_error'] = np.zeros(P['n_epochs'])
    best_error = np.inf
    best_weights = None
    for epoch in range(P['n_epochs']):
        print "Epoch "+str(epoch)
        model.fit(train_data, batch_size=P['batch_size'], nb_epoch=1, verbose=1)
        log['val_error'][epoch] = model.evaluate(val_data, batch_size=P['batch_size'])
        log['train_error'][epoch] = model.evaluate(train_data, batch_size=P['batch_size'])
        print 'train error: '+str(log['train_error'][epoch])
        print 'val error: '+str(log['val_error'][epoch])
        if log['val_error'][epoch]<best_error:
            best_error = log['val_error'][epoch]
            best_weights = model.get_weights()

    return model, log


def evaluate_RNN_KLAB16(P, model, train_occl):

    train_idx = get_KLAB16_train_idx()
    X = load_KLAB325_features('caffenet_'+P['input_layer'])
    if '_noRelu' in P['input_layer']:
        X_target = load_KLAB325_features('caffenet_'+P['input_layer'].replace('_noRelu',''))
    else:
        X_target = X

    is_orig, im_labels, y = load_extra_data()
    y[y==4] = 3

    idx = [i for i in train_idx if is_orig[i]]
    X_train_orig = X_target[idx]

    if train_occl:
        train_ims = np.unique(im_labels[train_idx])
        occl_idx = []
        for t in train_ims:
            p_idx = [i for i in train_idx if (not is_orig[i] and im_labels[i]==t)]
            p_idx = np.random.permutation(p_idx)
            occl_idx.append(p_idx[0])
        y_train_orig = y[occl_idx]
        X_train_real = X_target[occl_idx]
        X_train_occl = X[occl_idx]
    else:
        y_train_orig = y[idx]

    _, X_val = load_KLAB16_features('caffenet_'+P['input_layer'].replace('_noRelu',''))
    data = spio.loadmat('/home/bill/Data/Occluded_Datasets/data_occlusion_main/files/labels_sorted.mat')
    y_val = data['cat_labels'].reshape((len(data['cat_labels'],)))

    X_val_real = X_val
    y = np.concatenate((y_train_orig.flatten(), y_val))

    if train_occl:
        pred_features_train = {}
        for t in P['t_val']:
            if t==-1:
                pred_features_train[t] = X_train_real
            else:
                X_train_all_t = np.zeros((X_train_occl.shape[0], t+1, X_train_occl.shape[1])).astype(np.float32)
                for i in range(X_train_occl.shape[0]):
                    if P['input_once']:
                        X_train_all_t[i,0] = X_train_occl[i]
                    else:
                        X_train_all_t[i,:] = X_train_occl[i]

                pred_features_train[t] = model.predict({'input': X_train_all_t})['output']

    val_and_test_idx = np.array(range(len(y_train_orig), len(y)))
    val_and_test_idx = np.random.permutation(val_and_test_idx)
    n = len(val_and_test_idx)/2
    test_idxs = [val_and_test_idx[:n], val_and_test_idx[n:]]
    train_idx = np.array(range(len(y_train_orig)))

    pred_features = {}
    pred_classes = {}
    for t in P['t_val']:
        print ' t='+str(t)
        if t==-1:
            pred_features[t] = X_val_real
        else:
            X_val_all_t = np.zeros((X_val.shape[0], t+1, X_val.shape[1])).astype(np.float32)
            for i in range(X_val.shape[0]):
                if P['input_once']:
                    X_val_all_t[i,0] = X_val[i]
                else:
                    X_val_all_t[i,:] = X_val[i]

            pred_features[t] = model.predict({'input': X_val_all_t})['output']

        if train_occl:
            X = np.vstack((pred_features_train[t], pred_features[t]))
        else:
            X = np.vstack((X_train_orig, pred_features[t]))

        pred_classes[t] = -1*np.ones(pred_features[t].shape[0])

        X = compute_kernel_mat(X, 'linear')
        for j in range(2):
            C_scores = np.zeros(len(P['C_list']))

            if j==0:
                v_idx = test_idxs[0]
                t_idx = test_idxs[1]
            else:
                v_idx = test_idxs[1]
                t_idx = test_idxs[0]

            print ' validating C'
            for i,C in enumerate(P['C_list']):
                res = libsvm_classify(X, y.flatten(), train_idx, v_idx, is_kernel_mat = True, C = C)
                C_scores[i] = res[0]

            idx = np.nonzero(C_scores==np.max(C_scores))[0][-1]
            best_C = P['C_list'][idx]

            print ' testing'
            res = libsvm_classify(X, y.flatten(), train_idx, t_idx, is_kernel_mat = True, C = best_C)
            pred_classes[t][t_idx - len(y_train_orig)] = res[1]

        if np.sum(pred_classes==-1)>0:
            print 'Somethings messed up'
            pdb.set_trace()

    return pred_features, pred_classes



def predict_features_for_model():

    f_name = base_save_dir + 'fc7_noRelu_PHYS/params.pkl'

    P = pkl.load(open(f_name, 'r'))
    model = create_model(P)
    model.compile('rmsprop', {'output': 'mse'})

    model.load_weights(base_save_dir + 'fc7_noRelu_PHYS/model_weights.hdf5')

    tags, feats = load_features('/home/bill/Data/Occluded_Datasets/data_occlusion_PHYS/features/caffenet_fc7_noRelu_ims_1-632.txt')

    for t in range(7):
        print t
        X_all = np.zeros((feats.shape[0], t+1, feats.shape[1])).astype(np.float32)
        for i in range(feats.shape[0]):
            if P['input_once']:
                X_all[i,0] = feats[i]
            else:
                X_all[i,:] = feats[i]
        rnn_features = model.predict({'input': X_all})['output']

        spio.savemat('/home/bill/Data/Occluded_Datasets/data_occlusion_PHYS/features/RNN_features_t'+str(t)+'.mat', {'features': rnn_features})








def evaluate_RNN(P, model, is_test=False, C_to_use=None, train_occl=False, mask_start=None, mask_type='strong'):

    train_idx, val_idx, test_idx = load_idxs_by_split(P['split_num'])

    X = load_KLAB325_features('caffenet_'+P['input_layer'])
    if '_noRelu' in P['input_layer']:
        X_target = load_KLAB325_features('caffenet_'+P['input_layer'].replace('_noRelu',''))
    else:
        X_target = X

    if mask_start is not None:
        if mask_type=='blank':
            X_mask = np.zeros(X.shape)
            f_name = '/home/bill/Data/Occluded_Datasets/gray_screen/caffenet_'+P['input_layer']+'.hkl'
            feats = hkl.load(open(f_name,'r'))
            X_mask[:] = feats
        else:
            f_dir = '/home/bill/Data/Occluded_Datasets/data_occlusion_klab325v2_masks_' + mask_type + '/features/caffenet_'
            for i in range(13):
                im_start = 1000*i+1
                im_end = (i+1)*1000
                tags, feats = load_features(f_dir+P['input_layer']+'_ims_'+str(im_start)+'-'+str(im_end)+'.txt')
                if i==0:
                    X_mask = feats
                else:
                    X_mask = np.vstack((X_mask, feats))
            X_mask = np.vstack((X_mask[:325], X_mask)) # just to get masks for orig images (this wont matter)

    is_orig, im_labels, y = load_extra_data()

    idx = [i for i in train_idx if is_orig[i]]
    X_train_orig = X_target[idx]

    if train_occl:
        train_ims = np.unique(im_labels[train_idx])
        occl_idx = []
        for t in train_ims:
            p_idx = [i for i in train_idx if (not is_orig[i] and im_labels[i]==t)]
            p_idx = np.random.permutation(p_idx)
            occl_idx.append(p_idx[0])
        y_train_orig = y[occl_idx]
        X_train_real = X_target[occl_idx]
        X_train_occl = X[occl_idx]
    else:
        y_train_orig = y[idx]

    if is_test:
        tmp_idx = test_idx
    else:
        tmp_idx = val_idx
    X_val = X[tmp_idx]
    X_val_mask = X_mask[tmp_idx]
    y_val = y[tmp_idx]

    X_val_real = X_target[tmp_idx]

    #X = np.vertstack((X_train_orig, X_val))
    y = np.concatenate((y_train_orig, y_val))

    train_idx = np.array([i for i in range(X_train_orig.shape[0])])

    test_idx = np.array([i for i in range(X_train_orig.shape[0], X_train_orig.shape[0]+X_val.shape[0])])


    if train_occl:
        pred_features_train = {}
        for t in P['t_val']:
            if t==-1:
                pred_features_train[t] = X_train_real
            else:
                X_train_all_t = np.zeros((X_train_occl.shape[0], t+1, X_train_occl.shape[1])).astype(np.float32)
                for i in range(X_train_occl.shape[0]):
                    if P['input_once']:
                        X_train_all_t[i,0] = X_train_occl[i]
                    else:
                        X_train_all_t[i,:] = X_train_occl[i]

                pred_features_train[t] = model.predict({'input': X_train_all_t})['output']


    pred_features = {}
    scores = {}
    best_C = {}
    pred_classes = {}
    for t in P['t_val']:
        print 'Calculating t='+str(t)
        if t==-1:
            pred_features[t] = X_val_real
        else:
            X_val_all_t = np.zeros((X_val.shape[0], t+1, X_val.shape[1])).astype(np.float32)
            for i in range(X_val.shape[0]):
                if P['input_once']:
                    X_val_all_t[i,0] = X_val[i]
                else:
                    X_val_all_t[i,:] = X_val[i]
                    if mask_start is not None:
                        X_val_all_t[i,mask_start:] = X_val_mask[i]


            pred_features[t] = model.predict({'input': X_val_all_t})['output']

        if train_occl:
            if train_occl==2:
                X = np.vstack((pred_features_train[t], pred_features[-1]))
            else:
                X = np.vstack((pred_features_train[t], pred_features[t]))
        else:
            X = np.vstack((X_train_orig, pred_features[t]))


        if not is_test:
            C_scores = np.zeros(len(P['C_list']))

            for i,C in enumerate(P['C_list']):
                res = libsvm_classify(X, y.flatten(), train_idx, test_idx, is_kernel_mat = False, C = C, kernel_name = 'linear')
                C_scores[i] = res[0]

            idx = np.nonzero(C_scores==np.max(C_scores))[0][-1]
            best_C[t] = P['C_list'][idx]
        else:
            if isinstance(C_to_use,dict):
                best_C[t] = C_to_use[t]
            else:
                best_C[t] = C_to_use

            res = libsvm_classify(X, y.flatten(), train_idx, test_idx, is_kernel_mat = False, C = best_C[t], kernel_name = 'linear')
            scores[t] = res[0]
            pred_classes[t] = res[1]

    if is_test:
        return pred_features, scores, pred_classes
    else:
        return best_C


def create_cv_idxs():

    n_splits = 5
    n_per_class = 325/5
    n_test_per_split = n_per_class/n_splits

    data = spio.loadmat('/home/bill/Data/Occluded_Datasets/data_occlusion_klab325v2/files/labels.mat')
    occl_classes = data['cat_labels']-1
    orig_classes = KLAB325_orig_classes()
    classes = np.concatenate( (orig_classes, occl_classes) )
    orig_labels = np.array(range(325)).reshape((325,1))
    occl_labels = data['im_labels'] -1
    im_labels = np.vstack( (orig_labels, occl_labels) )

    test_and_val_ims = [[] for _ in range(n_splits)]

    for i in range(5):
        these_im_nums = [j for j in range(len(orig_labels)) if orig_classes[j]==i]
        these_im_nums = np.random.permutation(these_im_nums).tolist()
        for k in range(n_splits):
            test_and_val_ims[k].extend(these_im_nums[k*n_test_per_split:(k+1)*n_test_per_split])

    train_idxs = []
    test_idxs = []
    val_idxs = []

    for split in range(n_splits):
        train_ims = [j for j in range(325) if j not in test_and_val_ims[split]]
        test_ims = test_and_val_ims[split][:len(test_and_val_ims[split])/2]
        val_ims = test_and_val_ims[split][len(test_and_val_ims[split])/2:]
        tr_idx = [i for i in range(len(im_labels)) if im_labels[i] in train_ims]
        t_idx = [i for i in range(len(im_labels)) if im_labels[i] in test_ims]
        v_idx = [i for i in range(len(im_labels)) if im_labels[i] in val_ims]
        train_idxs.append(tr_idx)
        test_idxs.append(t_idx)
        val_idxs.append(v_idx)
        train_idxs.append(tr_idx)
        test_idxs.append(v_idx)
        val_idxs.append(t_idx)

    f_name = '/home/bill/Projects/Occlusion_RNN/files/KLAB325_cv_idxs.pkl'
    f = open(f_name, 'w')
    pkl.dump({'train_idxs': train_idxs, 'test_idxs': test_idxs, 'val_idxs': val_idxs}, f)
    f.close()


def load_idxs_by_split(split_num):

    f_name = '/home/bill/Projects/Occlusion_RNN/files/KLAB325_cv_idxs.pkl'
    f = open(f_name, 'r')
    d = pkl.load(f)
    f.close()

    train_idx = d['train_idxs'][split_num]
    val_idx = d['val_idxs'][split_num]
    test_idx = d['test_idxs'][split_num]

    return train_idx, val_idx, test_idx


def create_extra_data():

    is_orig = np.concatenate((np.ones(325),np.zeros(13000)))

    data = spio.loadmat('/home/bill/Data/Occluded_Datasets/data_occlusion_klab325v2/files/labels.mat')
    orig_labels = np.array(range(325)).reshape((325,1))
    occl_labels = data['im_labels'] -1
    im_labels = np.vstack( (orig_labels, occl_labels) )

    occl_classes = data['cat_labels']-1
    orig_classes = KLAB325_orig_classes()
    classes = np.concatenate( (orig_classes, occl_classes) )

    f_name = '/home/bill/Projects/Occlusion_RNN/files/KLAB325_extra_data.pkl'
    f = open(f_name, 'w')
    pkl.dump({'is_orig': is_orig, 'im_labels': im_labels, 'y': classes}, f)
    f.close()


def load_extra_data():

    f_name = '/home/bill/Projects/Occlusion_RNN/files/KLAB325_extra_data.pkl'
    f = open(f_name, 'r')
    d = pkl.load(f)
    f.close()

    return d['is_orig'], d['im_labels'], d['y']


def create_aggregate_predicted_classes():

    feature_tag = 'fc7_noRelu'
    for t in ['occltestt0']:#['orig', 'occl']:
        for j in range(-1, 7):
            pred_classes = -1*np.ones(13325)
            for split in range(10):
                _,_, test_idx = load_idxs_by_split(split)
                run_dir = base_save_dir + feature_tag+'_split'+str(split)+'/'
                f = open(run_dir + 'pred_classes_test_train'+t+'.hkl', 'r')
                these_preds = hkl.load(f)
                f.close()
                pred_classes[test_idx] = these_preds[str(j)]
            if np.sum(pred_classes==-1)>0:
                print 'THERE ARE SOME NONpredictions'
                pdb.set_trace()
            else:
                save_file = '/home/bill/Projects/Occlusion_RNN/files/pred_classes_'+feature_tag+'_train'+t+'_t'+str(j)+'.mat'
                # f = open(save_file, 'w')
                # hkl.dump(pred_classes, f)
                # f.close()
                spio.savemat(save_file, {'pred_classes': pred_classes})

def create_aggregate_predicted_classes_mask():

    feature_tag = 'fc7_noRelu'
    t = 'orig'
    mask_type = 'blank'
    time_step = 4
    for mt in [1,2,3,4]:
        pred_classes = -1*np.ones(13325)
        for split in range(10):
            _,_, test_idx = load_idxs_by_split(split)
            run_dir = base_save_dir + feature_tag+'_split'+str(split)+'_masked_'+mask_type+'_start'+str(mt)+'/'
            f = open(run_dir + 'pred_classes_test_train'+t+'.hkl', 'r')
            these_preds = hkl.load(f)
            f.close()
            pred_classes[test_idx] = these_preds[str(time_step)]
        if np.sum(pred_classes==-1)>0:
            print 'THERE ARE SOME NONpredictions'
            pdb.set_trace()
        else:
            save_file = '/home/bill/Projects/Occlusion_RNN/files/pred_classes_'+feature_tag+'_train'+t+'_t'+str(time_step)+'_masked_'+mask_type+'_start'+str(mt)+'.mat'
            spio.savemat(save_file, {'pred_classes': pred_classes})



def create_aggregate_features():

    feature_tag = 'fc7_noRelu'
    for j in [-1]:#range(0, 5):
        pred_classes = -1*np.ones(13325)
        for split in range(10):
            _,_, test_idx = load_idxs_by_split(split)
            run_dir = base_save_dir + feature_tag+'_split'+str(split)+'/'
            f = open(run_dir + 'features_over_time_test_trainorig.hkl', 'r')
            these_feats = hkl.load(f)[str(j)]
            f.close()
            if split==0:
                features = np.zeros((13325, these_feats.shape[1]))
            features[test_idx] = these_feats

        if j==-1:
            save_file = '/home/bill/Projects/Occlusion_RNN/files/RNN_features_'+feature_tag+'_tm1.mat'
        else:
            save_file = '/home/bill/Projects/Occlusion_RNN/files/RNN_features_'+feature_tag+'_t'+str(j)+'.mat'
        spio.savemat(save_file, {'features': features})




def create_KLAB16_predicted_classes():

    feature_tag = 'fc7_noRelu'
    for t in ['orig', 'occl']:
        f_name = '/home/bill/Projects/Occlusion_RNN/runs/'+feature_tag+'_KLAB16/pred_classes_test_train'+t+'.hkl'
        f = open(f_name, 'r')
        pred_classes = hkl.load(f)
        f.close()
        for j in range(-1, 7):
            if np.sum(pred_classes[str(j)]==-1)>0:
                print 'THERE ARE SOME NONpredictions'
                pdb.set_trace()
            else:
                save_file = '/home/bill/Projects/Occlusion_RNN/files/pred_classes_'+feature_tag+'_train'+t+'_t'+str(j)+'_KLAB16.mat'
                spio.savemat(save_file, {'pred_classes': pred_classes[str(j)]})




def get_KLAB16_train_idx():

    good_ims = list(set(range(300)) - set(range(180,240)))
    _, im_labels, _ = load_extra_data()
    train_idx = [i for i in range(len(im_labels)) if im_labels[i] in good_ims]

    return train_idx

def get_PHYS_train_idx():

    good_ims = range(300)
    _, im_labels, _ = load_extra_data()
    train_idx = [i for i in range(len(im_labels)) if im_labels[i] in good_ims]

    return train_idx


def quick_test():

    _,_, y = load_extra_data()
    _,_, test_idx = load_idxs_by_split(0)
    y = y[test_idx]

    for o in ['occl', 'orig']:
        f_name = '/home/bill/Projects/Occlusion_RNN/runs/pool5_split0/pred_classes_test_train'+o+'.hkl'
        f = open(f_name, 'r')
        pred_classes = hkl.load(f)
        f.close()

        for t in range(-1, 7):
            score = np.mean(pred_classes[str(t)]==y)
            print 'For train '+o+' t='+str(t)+': '+str(score)


def calculate_feature_change():

    t0 = 0
    t1 = 4

    feature_tag = 'fc7_noRelu'
    feature_change = -1*np.ones(13325)
    for split in range(10):
        print split
        _,_, test_idx = load_idxs_by_split(split)
        run_dir = base_save_dir + feature_tag+'_split'+str(split)+'/'

        f = open(run_dir + 'features_over_time_test_trainorig.hkl', 'r')
        features = hkl.load(f)
        f.close()

        these_change = np.zeros(len(test_idx))
        for i in range(len(test_idx)):
            delta_f = features[str(t1)][i] - features[str(t0)][i]
            these_change[i] = np.linalg.norm(delta_f)

        feature_change[test_idx] = these_change

    if np.sum(feature_change<0)>0:
        print 'THERE ARE SOME NONpredictions'
        pdb.set_trace()
    else:
        save_file = '/home/bill/Projects/Occlusion_RNN/files/feature_change_norm_'+feature_tag+'.mat'
        spio.savemat(save_file, {'feature_change': feature_change})


def make_deconv_plots():

    import matplotlib.image as mpimg

    sys.path.insert(0, '/home/bill/Libraries/caffe_invert_alexnet/python/')
    import caffe

    n_plot = 100
    out_dir = '/home/bill/Dropbox/Occlusion_Modeling/deconv_plots/'
    if not os.path.exists(out_dir):
        os.mkdir(out_dir)

    is_orig, im_labels,_ = load_extra_data()

    features = load_KLAB325_RNN_features()

    plot_idx = np.random.permutation(features[0].shape[0])[:n_plot]

    PRETRAINED = '/home/bill/Libraries/caffe_invert_alexnet/fc7/invert_alexnet_fc7.caffemodel'
    MODEL_FILE = '/home/bill/Libraries/caffe_invert_alexnet/fc7/invert_alexnet_fc7_deploy_from_features2.prototxt'
    net = caffe.Classifier(MODEL_FILE, PRETRAINED)

    for idx in plot_idx:

        if is_orig:
            occl_im = mpimg.imread('/home/bill/Data/Occluded_Datasets/KLAB325v2/images/im_'+str(im_labels[idx]+1)+'.tif')
        else:
            occl_im = mpimg.imread('/home/bill/Data/Occluded_Datasets/data_occlusion_klab325v2/images/im_'+str(idx+1)+'.tif')

        orig_im = mpimg.imread('/home/bill/Data/Occluded_Datasets/KLAB325v2/images/im_'+str(im_labels[idx]+1)+'.tif')

        for t in range(5):
            out = net.predict(features[t][idx].reshape((1,4096,1,1)), is_features=True)
            deconv_im = out[0].transpose((1,2,0))
            deconv_im = np.dot(deconv_im[...,:3], [0.299, 0.587, 0.144])

            plt.subplot(5,4,t*4+1)
            plt.imshow(deconv_im, cmap='Greys_r')
            if t==0:
                plt.title('Im#'+str(idx)+' t='+str(t))
            plt.gca().axes.get_xaxis().set_ticks([])
            plt.gca().axes.get_yaxis().set_ticks([])


def analyze_weights(split_num):

    input_layer = 'fc7_noRelu'
    save_dir = base_save_dir + input_layer + '_split' +str(split_num)+'/'

    out_dir = '/home/bill/Dropbox/OcclusionModeling/RNN_weights_analysis/'

    f_name = save_dir + 'params.pkl'
    P = pkl.load(open(f_name, 'r'))
    model = create_model(P)
    model.load_weights(save_dir + 'model_weights.hdf5')
    weights = model.get_weights()[0]

    d_idx = np.diag_indices(weights.shape[0])
    diag_weights = weights[d_idx]
    weights[d_idx] = 999
    non_d_idx = np.nonzero(weights!=999)
    non_diag_weights = weights[non_d_idx]


    plt.clf()
    plt.hist(diag_weights)
    plt.title('Hist of DIAG weights split'+str(split_num) +'\n'+'mean: '+"%.3f" % np.mean(diag_weights)+' std: '+'%.3f'%np.std(diag_weights))
    plt.savefig(out_dir+'Weights_Hist_DIAG_split'+str(split_num)+'.jpg')

    plt.clf()
    plt.hist(non_diag_weights)
    plt.title('Hist of OFFDIAG weights split'+str(split_num) +'\n'+'mean: '+"%.3f" % np.mean(non_diag_weights)+' std: '+'%.3f'%np.std(non_diag_weights))
    plt.savefig(out_dir+'Weights_Hist_OFFDIAG_split'+str(split_num)+'.jpg')



def run_train_occl_test_t0():

    input_layer = 'fc7_noRelu'
    train_occl = 2

    for split_num in range(10):
        print split_num

        save_dir = base_save_dir + input_layer + '_split' +str(split_num)+'/'
        f_name = save_dir + 'params.pkl'
        P = pkl.load(open(f_name, 'r'))
        model = create_model(P)
        model.compile('rmsprop', {'output': 'mse'})
        model.load_weights(save_dir + 'model_weights.hdf5')

        best_C = evaluate_RNN(P, model, is_test=False, train_occl=train_occl)

        print ' Doing Testing'
        _, _, pred_classes = evaluate_RNN(P, model, is_test=True, C_to_use=best_C, train_occl=train_occl)

        s = 'trainoccltestt0'

        f = open(P['save_dir'] + 'pred_classes_test_'+s+'.hkl', 'w')
        hkl.dump(pred_classes, f)
        f.close()


def get_masked_results(mask_type, split_num, mask_start):

    P = {}
    P['split_num'] = split_num

    P['input_layer'] = 'fc7_noRelu'
    P['t_val'] = [4]
    P['input_once'] = False
    P['C_list'] = [1e-4, 1e-3, 1e-2, 0.1, 1, 10, 100, 1e3, 1e4]
    orig_dir = base_save_dir + P['input_layer']+'_split'+str(P['split_num'])+'/'
    save_dir = base_save_dir + P['input_layer']+'_split'+str(P['split_num'])+'_masked_' + mask_type + '_start' +str(mask_start)+ '/'

    P_orig = pkl.load(open(orig_dir+'params.pkl', 'r'))
    model = create_model(P_orig)
    model.load_weights(orig_dir+'model_weights.hdf5')
    model.compile('rmsprop', {'output': 'mse'})

    best_C = evaluate_RNN(P, model, is_test=False, train_occl=False, mask_start=mask_start, mask_type=mask_type)
    pred_features, scores, pred_classes = evaluate_RNN(P, model, is_test=True, C_to_use=best_C, train_occl=False, mask_start=mask_start, mask_type=mask_type)

    if not os.path.exists(save_dir):
        os.mkdir(save_dir)
    f = open(save_dir + 'pred_classes_test_trainorig.hkl', 'w')
    hkl.dump(pred_classes, f)
    f.close()



if __name__=='__main__':
    try:
        #create_cv_idxs()
        #create_extra_data()
        #run_RNN()
        # for i in range(10):
        #    run_RNN({'split_num': i})
        #create_aggregate_predicted_classes()
        #quick_test()
        #create_KLAB16_predicted_classes()
        #create_aggregate_features()
        #calculate_feature_change()
        #make_deconv_features()
        #predict_features_for_model()
        #for i in range(10):
        #    analyze_weights(i)
        #run_train_occl_test_t0()
        #create_aggregate_predicted_classes()
        # for s in range(10):
        #     get_masked_results('blank', s, 4)
        create_aggregate_predicted_classes_mask()
    except:
        ty, value, tb = sys.exc_info()
        traceback.print_exc()
        pdb.post_mortem(tb)
