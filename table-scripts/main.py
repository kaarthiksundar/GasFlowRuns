import pandas as pd 
import csv 
import math

eos = ['ideal', 'cnga']
instances = ['GasLib-11', 'GasLib-24', 'GasLib-40', 'GasLib-134']
output_path = '../output/'

get_feasible_count = lambda file: pd.read_csv(file)['feasibility'].sum()
get_pressure_correction_count = lambda file: pd.read_csv(file)['pressure_correction'].sum()
get_success_count = lambda file: (pd.read_csv(file)['solver_status'] == 0).sum()
get_mean_iter = lambda file: pd.read_csv(file)['num_iterations'].mean() 

def create_tables(instances, output_path):
    # create_pressure_correction_table(instances, output_path)
    create_dimensional_table(instances, output_path)
    create_iter_table(instances, output_path)
    return 

def create_pressure_correction_table(instances, output_path):
    header = ['instance', 'feas_count', 'correction_count']
    with open('pressure-correction.csv', 'w', encoding='UTF8') as f:
        writer = csv.writer(f)
        writer.writerow(header)
        for instance in instances: 
            file = output_path + instance + '-cnga.csv'
            data = [instance, get_feasible_count(file), get_pressure_correction_count(file)]
            writer.writerow(data)
    return 

def create_dimensional_table(instances, output_path):
    table_header = ['instance', 'ideal_d', 'ideal_nd', 'nonideal_d', 'nonideal_nd']
    with open('d-vs-nd-counts.csv', 'w', encoding='UTF8') as f: 
        writer = csv.writer(f)
        writer.writerow(table_header)
        for instance in instances: 
            file_ideal_d = output_path + instance + '-ideal-d.csv'
            file_ideal_nd = output_path + instance + '-ideal.csv'
            file_cnga_d = output_path + instance + '-cnga-d.csv'
            file_cnga_nd = output_path + instance + '-cnga.csv'
            success_ideal_d = get_success_count(file_ideal_d)
            success_ideal_nd = get_success_count(file_ideal_nd)
            success_cnga_d = get_success_count(file_cnga_d)
            success_cnga_nd = get_success_count(file_cnga_nd)
            data = [instance, success_ideal_d, success_ideal_nd, success_cnga_d, success_cnga_nd]
            writer.writerow(data)
    return 

def create_iter_table(instances, output_path):
    table_header = ['instance', 'ideal', 'nonideal']
    with open('iterations.csv', 'w', encoding='UTF8') as f: 
        writer = csv.writer(f)
        writer.writerow(table_header)
        for instance in instances: 
            file_ideal = output_path + instance + '-ideal.csv'
            file_cnga = output_path + instance + '-cnga.csv'
            data = [instance, math.ceil(get_mean_iter(file_ideal)), math.ceil(get_mean_iter(file_cnga))]
            writer.writerow(data)
    return 

create_tables(instances, output_path)