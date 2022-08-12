# Import all packages

import MetaTrader5 as mt5
import pandas as pd
import numpy as np
from datetime import datetime
import random
import matplotlib.pyplot as plt
from catboost import CatBoostClassifier
from sklearn.model_selection import train_test_split
from sklearn.linear_model import LinearRegression
from sklearn import mixture

mt5.initialize()

# Setting up global variables

MA_PERIODS = [5, 25, 55, 75, 100,
              125, 150, 200, 250, 300, 350, 400, 450, 500]
              
GRID_SIZE = 10
GRID_DISTANCES = np.linspace(0.003, 0.008, num= GRID_SIZE)
# GRID_DISTANCES = np.full(GRID_SIZE, 0.00200)
GRID_COEFFICIENTS = np.linspace(1, 5, num= GRID_SIZE)
# GRID_COEFFICIENTS = np.full(GRID_SIZE, 1)

SYMBOL = 'EURUSD'
MARKUP = 0.00010
TIMEFRAME = mt5.TIMEFRAME_H1
START_DATE = datetime(2020, 5, 1)
TSTART_DATE = datetime(2019, 1, 1)
FULL_DATE = datetime(2018, 1, 1)
END_DATE = datetime(2022, 1, 1)

N_COMPONENTS = 75

# Miscellaneous functions

def get_prices(start_date, end_date):
    prices = pd.DataFrame(mt5.copy_rates_range(SYMBOL, TIMEFRAME, start_date, end_date),
                          columns=['time', 'close']).set_index('time')
    prices.index = pd.to_datetime(prices.index, unit='s')
    prices = prices.dropna()
    pr = prices.copy()

    count = 0
    for i in MA_PERIODS:
        prices[str(count)] = pr - pr.rolling(i).mean()
        count += 1

    return prices.dropna()

def add_labels(dataset, min, max, distances, coefficients):
    labels = []
    for i in range(dataset.shape[0]-max):
        rand = random.randint(min, max)
        all_pr = dataset['close'][i:i + rand + 1]

        grid_stats = {'up_range': all_pr[0] - all_pr.min(),
                      'dwn_range': all_pr.max() - all_pr[0],
                      'up_state': 0,
                      'dwn_state': 0,
                      'up_orders': 0,
                      'dwn_orders': 0,
                      'up_profit': all_pr[-1] - all_pr[0] - MARKUP,
                      'dwn_profit': all_pr[0] - all_pr[-1] - MARKUP
                      }

        for i in np.nditer(distances):
            if grid_stats['up_state'] + i <= grid_stats['up_range']:
                grid_stats['up_state'] += i
                grid_stats['up_orders'] += 1
                grid_stats['up_profit'] += (all_pr[-1] - all_pr[0] + grid_stats['up_state']) \
                * coefficients[int(grid_stats['up_orders']-1)]
                grid_stats['up_profit'] -= MARKUP * coefficients[int(grid_stats['up_orders']-1)]

            if grid_stats['dwn_state'] + i <= grid_stats['dwn_range']:
                grid_stats['dwn_state'] += i
                grid_stats['dwn_orders'] += 1
                grid_stats['dwn_profit'] += (all_pr[0] - all_pr[-1] + grid_stats['dwn_state']) \
                * coefficients[int(grid_stats['dwn_orders']-1)]
                grid_stats['dwn_profit'] -= MARKUP * coefficients[int(grid_stats['dwn_orders']-1)]
        
        if grid_stats['up_profit'] > grid_stats['dwn_profit'] and grid_stats['up_profit'] > 0:
            labels.append(0.0)
            continue
        elif grid_stats['dwn_profit'] > 0:
            labels.append(1.0)
            continue
        
        labels.append(2.0)

    dataset = dataset.iloc[:len(labels)].copy()
    dataset['labels'] = labels
    dataset = dataset.dropna()
    dataset = dataset.drop(
        dataset[dataset.labels == 2].index).reset_index(drop=True)
    return dataset

def tester(dataset, markup, distances, coefficients, plot=False):
    last_deal = int(2)
    all_pr = np.array([])
    report = [0.0]
    for i in range(dataset.shape[0]):
        pred = dataset['labels'][i]
        all_pr = np.append(all_pr, dataset['close'][i])

        if last_deal == 2:
            last_deal = 0 if pred <= 0.5 else 1
            continue

        if last_deal == 0 and pred > 0.5:
            last_deal = 1
            up_range = all_pr[0] - all_pr.min()
            up_state = 0
            up_orders = 0
            up_profit = (all_pr[-1] - all_pr[0]) - markup
            report.append(report[-1] + up_profit)
            up_profit = 0
            for d in np.nditer(distances):
                if up_state + d <= up_range:
                    up_state += d
                    up_orders += 1
                    up_profit += (all_pr[-1] - all_pr[0] + up_state) \
                    * coefficients[int(up_orders-1)]
                    up_profit -= markup * coefficients[int(up_orders-1)]    
                    report.append(report[-1] + up_profit)
                    up_profit = 0
            all_pr = np.array([dataset['close'][i]])
            continue

        if last_deal == 1 and pred < 0.5:
            last_deal = 0
            dwn_range = all_pr.max() - all_pr[0]
            dwn_state = 0
            dwn_orders = 0
            dwn_profit = (all_pr[0] - all_pr[-1]) - markup
            report.append(report[-1] + dwn_profit)
            dwn_profit = 0
            for d in np.nditer(distances):
                if dwn_state + d <= dwn_range:
                    dwn_state += d
                    dwn_orders += 1
                    dwn_profit += (all_pr[0] + dwn_state - all_pr[-1]) \
                    * coefficients[int(dwn_orders-1)]
                    dwn_profit -= markup * coefficients[int(dwn_orders-1)] 
                    report.append(report[-1] + dwn_profit)
                    dwn_profit = 0
            all_pr = np.array([dataset['close'][i]])   
            continue

    y = np.array(report).reshape(-1, 1)
    X = np.arange(len(report)).reshape(-1, 1)
    lr = LinearRegression()
    lr.fit(X, y)

    l = lr.coef_
    if l >= 0:
        l = 1
    else:
        l = -1

    if(plot):
        plt.figure(figsize=(12,7))
        plt.plot(report)
        plt.plot(lr.predict(X))
        plt.title("Strategy performance")
        plt.xlabel("the number of trades")
        plt.ylabel("cumulative profit in pips")
        plt.show()

    return lr.score(X, y) * l

def brute_force(samples=5000):
    # sample new dataset
    generated = gmm.sample(samples)
    # make labels
    gen = pd.DataFrame(generated[0])
    gen.rename(columns={gen.columns[-1]: "labels"}, inplace=True)
    gen.loc[gen['labels'] >= 0.5, 'labels'] = 1
    gen.loc[gen['labels'] < 0.5, 'labels'] = 0

    X = gen[gen.columns[:-1]]
    y = gen[gen.columns[-1]]

    # train\test split
    train_X, test_X, train_y, test_y = train_test_split(
        X, y, train_size=0.5, test_size=0.5, shuffle=True)
    # learn with train and validation subsets
    model = CatBoostClassifier(iterations=500,
                               depth=6,
                               learning_rate=0.01,
                               custom_loss=['Accuracy'],
                               eval_metric='Accuracy',
                               verbose=False,
                               use_best_model=True,
                               task_type='CPU')
    model.fit(train_X, train_y, eval_set=(test_X, test_y),
              early_stopping_rounds=25, plot=False)
    # test on new data
    pr_tst = get_prices(TSTART_DATE, END_DATE)
    X = pr_tst[pr_tst.columns[1:]]
    X.columns = [''] * len(X.columns)

    # test the learned model
    p = model.predict_proba(X)
    p2 = [x[0] < 0.5 for x in p]
    pr2 = pr_tst.iloc[:len(p2)].copy()
    pr2['labels'] = p2
    R2 = tester(pr2, MARKUP, GRID_DISTANCES, GRID_COEFFICIENTS, plot=False)

    return [R2, model]

def test_model(result):
    pr_tst = get_prices(FULL_DATE, END_DATE)
    X = pr_tst[pr_tst.columns[1:]]
    X.columns = [''] * len(X.columns)

    # test the learned model
    p = result[1].predict_proba(X)
    p2 = [x[0] < 0.5 for x in p]
    pr2 = pr_tst.iloc[:len(p2)].copy()
    pr2['labels'] = p2
    R2 = tester(pr2, MARKUP, GRID_DISTANCES, GRID_COEFFICIENTS, plot=True)

def export_model_to_MQL_code(model):
    model.save_model('catmodel.h',
                     format="cpp",
                     export_parameters=None,
                     pool=None)

    # add variables
    code = '#include <Math\Stat\Math.mqh>'
    code += '\n'
    code += 'int MAs[' + str(len(MA_PERIODS)) + \
        '] = {' + ','.join(map(str, MA_PERIODS)) + '};'
    code += '\n'
    code += 'int grid_size = ' + str(GRID_SIZE) + ';'
    code += '\n'
    code += 'double grid_distances[' + str(len(GRID_DISTANCES)) + \
        '] = {' + ','.join(map(str, GRID_DISTANCES)) + '};'
    code += '\n'
    code += 'double grid_coefficients[' + str(len(GRID_COEFFICIENTS)) + \
        '] = {' + ','.join(map(str, GRID_COEFFICIENTS)) + '};'
    code += '\n'

    # get features
    code += 'void fill_arays( double &features[]) {\n'
    code += '   double pr[], ret[];\n'
    code += '   ArrayResize(ret, 1);\n'
    code += '   for(int i=ArraySize(MAs)-1; i>=0; i--) {\n'
    code += '       CopyClose(NULL,PERIOD_CURRENT,1,MAs[i],pr);\n'
    code += '       double mean = MathMean(pr);\n'
    code += '       ret[0] = pr[MAs[i]-1] - mean;\n'
    code += '       ArrayInsert(features, ret, ArraySize(features), 0, WHOLE_ARRAY); }\n'
    code += '   ArraySetAsSeries(features, true);\n'
    code += '}\n\n'

    # add CatBosst
    code += 'double catboost_model' + '(const double &features[]) { \n'
    code += '    '
    with open('catmodel.h', 'r') as file:
        data = file.read()
        code += data[data.find("unsigned int TreeDepth")
                               :data.find("double Scale = 1;")]
    code += '\n\n'
    code += 'return ' + \
        'ApplyCatboostModel(features, TreeDepth, TreeSplits , BorderCounts, Borders, LeafValues); } \n\n'

    code += 'double ApplyCatboostModel(const double &features[],uint &TreeDepth_[],uint &TreeSplits_[],uint &BorderCounts_[],float &Borders_[],double &LeafValues_[]) {\n\
    uint FloatFeatureCount=ArrayRange(BorderCounts_,0);\n\
    uint BinaryFeatureCount=ArrayRange(Borders_,0);\n\
    uint TreeCount=ArrayRange(TreeDepth_,0);\n\
    bool     binaryFeatures[];\n\
    ArrayResize(binaryFeatures,BinaryFeatureCount);\n\
    uint binFeatureIndex=0;\n\
    for(uint i=0; i<FloatFeatureCount; i++) {\n\
       for(uint j=0; j<BorderCounts_[i]; j++) {\n\
          binaryFeatures[binFeatureIndex]=features[i]>Borders_[binFeatureIndex];\n\
          binFeatureIndex++;\n\
       }\n\
    }\n\
    double result=0.0;\n\
    uint treeSplitsPtr=0;\n\
    uint leafValuesForCurrentTreePtr=0;\n\
    for(uint treeId=0; treeId<TreeCount; treeId++) {\n\
       uint currentTreeDepth=TreeDepth_[treeId];\n\
       uint index=0;\n\
       for(uint depth=0; depth<currentTreeDepth; depth++) {\n\
          index|=(binaryFeatures[TreeSplits_[treeSplitsPtr+depth]]<<depth);\n\
       }\n\
       result+=LeafValues_[leafValuesForCurrentTreePtr+index];\n\
       treeSplitsPtr+=currentTreeDepth;\n\
       leafValuesForCurrentTreePtr+=(1<<currentTreeDepth);\n\
    }\n\
    return 1.0/(1.0+MathPow(M_E,-result));\n\
    }'

    file = open('C:/Users/dmitrievsky/AppData/Roaming/MetaQuotes/Terminal/D0E8209F77C8CF37AD8BF550E51FF075/MQL5/Include/' +
                str(SYMBOL) + '_cat_model_martin' + '.mqh', "w")
    file.write(code)
    file.close()
    print('The file ' + 'cat_model' + '.mqh ' + 'has been written to disc')

# Get prices and labels and test it

pr = get_prices(START_DATE, END_DATE)
pr = add_labels(pr, 15, 15, GRID_DISTANCES, GRID_COEFFICIENTS)
tester(pr, MARKUP, GRID_DISTANCES, GRID_COEFFICIENTS, plot=True)

# Learn and test CatBoost model

gmm = mixture.GaussianMixture(
    n_components=N_COMPONENTS, covariance_type='full', n_init=1).fit(pr[pr.columns[1:]])
res = []
for i in range(10):
    res.append(brute_force(10000))
    print('Iteration: ', i, 'R^2: ', res[-1][0])
res.sort()
test_model(res[-1])

export_model_to_MQL_code(res[-1][1])