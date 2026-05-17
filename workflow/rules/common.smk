from pathlib import Path
import os
from collections import defaultdict
import numpy as np
import glob
import pathlib
import scanpy as sc
import math



class PrepConfig:
    def __init__(self,config):
        self.DATASETS=config["DATASETS"]
        self.GRAPH_GENERATION=config["GRAPH_GENERATION"]
        self.CLUSTERING=config["CLUSTERING"]

  
    def get_dataset_info(self,data):
        return self.DATASETS[data].keys()

    def get_datasets(self):
        return list(self.DATASETS.keys())
    
    def get_from_dataset(self,data,key):
        return self.DATASETS[data.split("-")[0]][key]
    
    def get_subdata_names(self):
        subdata = []

        for dataset in self.get_datasets():

            sub_files = self.get_from_dataset(dataset, 'subdatasets')

            if not sub_files:
                subdata.append(dataset)
            else:
                subdata.extend(f"{dataset}-{sub}" for sub in sub_files)

        return subdata  
    
    def get_silver_standard(self):
        return [dataset for dataset in self.get_subdata_names() 
                if self.get_from_dataset(dataset.split("-")[0], 'standard') == 'silver']
    
    def get_gold_standard(self):
        return [dataset for dataset in self.get_subdata_names() 
                if self.get_from_dataset(dataset.split("-")[0], 'standard') == 'gold']
    
    def get_tissues_silver(self):
        return set([self.get_from_dataset(dataset.split("-")[0], 'tissue')
                for dataset in self.get_silver_standard()])

    def get_organisms_silver(self):
        return set([self.get_from_dataset(dataset.split("-")[0], 'organism')
                for dataset in self.get_silver_standard()])
    

    def get_valid_organism_tissue_pairs(self):
        return {
            (self.get_from_dataset(dataset.split("-")[0], "organism"),
            self.get_from_dataset(dataset.split("-")[0], "tissue"))
            for dataset in self.get_silver_standard()
        }
    
    def get_data_ids_cellxgene(self):
        return {dataset:self.get_from_dataset(dataset,'dataset_id') for dataset in self.get_subdata_names() 
                if 'dataset_id' in self.get_dataset_info(dataset.split("-")[0])}


    
    #def get_from_dataset(self, data, key):
    #    if key=='path':
    #        return glob.glob(self.DATASETS[data][key]+'*.h5ad')
    #    else:
    #        return self.DATASETS[data][key]
        
    #def get_files(self,data):
    #    return glob.glob(os.path.join(self.DATASETS[data]['path']+'/*.h5ad'))
    # def get_from_dir(self,data):
    #     files = os.listdir(self.get_from_dataset(data,'path'))
    #     print(files)
    #     return [f for f in files if os.path.isfile(self.DATASETS[data]['path']+'/'+f)]
    
    def get_graph_parameters(self,key):
        return self.GRAPH_GENERATION[key]

    # def consider_neighbors(self):
    #     return str(self.GRAPH_GENERATION['nns'])
    

    def check_clusters_number(self,dataset):
        adata = os.path.join("/work/Master_Project/Snakemake/benchmark_analysis/normalized_adata", dataset + ".h5ad")
        return sc.read_h5ad(adata).obs[self.get_from_dataset(dataset,'cell_labels')]


    def check_knn_size(self,dataset):
        adata = os.path.join("results/benchmark_analysis/processed_normalized_data", dataset + ".h5ad")
        if (len(sc.read_h5ad(adata).obs)<self.get_graph_parameters("neighbors")["end"] + 1): 
            sample_size = len(sc.read_h5ad(adata).obs)
            return True, sample_size
        return False, None
   
    
    def get_possible_output(self,dataset):              # since its not possible to restric value of wildcard based on another wildcard, special function is needed
        wildcards = defaultdict(list)
        #data=self.get_datasets()
        #nns=self.get_graph_parameters("nns")
        #neighbors=list(range(self.get_graph_parameters("neighbors")["start"], self.get_graph_parameters("neighbors")["end"] + 1, self.get_graph_parameters("neighbors")["step"]))
        #graph_method=self.get_graph_parameters("graph_method")
        # if self.get_from_dataset(dataset, "subdatasets") is not None:
        #     wildcards['dataset'] = list(f"{dataset}_{sub}" for sub in self.get_from_dataset(dataset, "subdatasets"))
        # else:
        wildcards['dataset']=dataset
        wildcards['graph_method']=self.get_graph_parameters("graph_method")
            #wildcards['dataset']=self.get_datasets()
        is_too_small, size = self.check_knn_size(dataset)
        if is_too_small:
            wildcards['neighbors']=list(range(self.get_graph_parameters("neighbors")["start"], math.ceil(size - 0.1*size) + 1, self.get_graph_parameters("neighbors")["step"]))
        else:
            wildcards['neighbors']=list(range(self.get_graph_parameters("neighbors")["start"], self.get_graph_parameters("neighbors")["end"] + 1, self.get_graph_parameters("neighbors")["step"]))
        wildcards['clust_method']=self.get_clustering_methods()
        wildcards['sim_measure']=self.get_graph_parameters("sim_measure")
            #for dataset in wildcards['dataset']:
            #wildcards['data']=rules.generate_graph.input
            #function_expand=itertools.product
        return wildcards
    def get_clustering_methods(self):
        return self.CLUSTERING.keys()
    def get_clustering_params(self,method,key):
        if key=='res':
            start=int((self.CLUSTERING[method][key]['start'])*1000)
            step=int((self.CLUSTERING[method][key]['step'])*1000 )
            stop=int((self.CLUSTERING[method][key]['stop'])*1000 + step)

            return [x / 1000 for x in range(start, stop,step)]
        else:
            return self.CLUSTERING[method][key]

    





            
        

        
    
  