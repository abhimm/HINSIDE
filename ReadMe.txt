* model_implementation_and_experiments folder contains complete implementation of HINSIDE. 6 Algorithms have been implemented,
    - RankSVM Non-negativity constraint
    - RankSVM NoConstratint 
    - Gradient Descent-1-Non-negativity Constraint
    - Gradient Descent-1-No Constratint
    - Gradient Descent-2-Non-negativity Constraint
    - Gradient Descent-2-No Constratint


    
* How to run a new simulation experiment:
==========================================
All simluation of HINSIDE are done on a subgraph genereated by snowball sampling on the subgraph of DocGraph where only individual medical providers
are considered. This subgraph of DocGraph contains the medical providers from top 7 types and top 10 states based on the count.

    - Generate simulation data:
    ---------------------------
    1. Run gen_multi_state_test_data python script in graph_generator folder. On execution the script request for no. of types out of 7 types and states 
        out of 10 states. On completion the script generates referral, distance, type_column and node_type matrix. completely_pruned_subgraph.p  and npi_dict.p 
        has a large size and seperate link would be provided to download the data.
    2. Rename type_column matrix to Type and node_type matrix to T.
   
   - Execute HINSIDE:
   ------------------
   To execute HINSIDE the data generated in last step have to be used to create experiment set. As for a generated graph, mutilple experiments are performed with different ground truth authority transfer rates. Each experiment corresponds to a ground truth authority transfer rate.
   1. Execute experimentSetUp.m . This will generate an experiment set which will have experiment groups and each experiment group has to be executed separately.
   2. To execute the desired algorithm for simulation, run runExperiment.m. This will generate results for each experiment group in it's respective folder.
   Results will include training and test accuracy for all the experiments within that experiment group using accuracy measure as NDCG, AP@20, AP@33% and AP@N
   
   
* Simulation have been performed for two dataset with no. of nodes 3979 - 7 Types and 446 - 3  Types. Results for those simulation can be found in respective folders.experimentSetData.mat for graph 3979 is not uploaded yet, a link would be provided soon. 

* DBLP experiments
=====================
For DBLP, we have constructed a co-authorship network which consists of 6619 nodes from 4 different area DB,DM, ML and IR. We have executed HINSIDE to 
estimate the ATR for this information network. Execution of experiments for DBLP is similar to the steps mentioned previously. The dataset is not uploaded yet to due to large size of matrices generated after first step in execution of HINSIDE. It will be uploaded soon.

* How to run baseline algorithms:
==================================
    - PageRank and In-weight 
    1. Execute experimentSetUp.m . This will generate an experiment set which will have experiment groups and each experiment group has to be executed separately.
    2. Run runTrivialBaselineExperiments.m.
    
    - Random Guessing and Random Ordering
    1. Execute experimentSetUp.m . This will generate an experiment set which will have experiment groups and each experiment group has to be executed separately.
    2. Run runBaselinesExperiments.m .
    
