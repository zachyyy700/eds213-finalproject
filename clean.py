import pandas as pd
import numpy as np
import ast

# load data
horse_profiles = pd.read_csv("data/raw/horse_profiles.csv")
results = pd.read_csv("data/raw/results.csv")
races = pd.read_csv("data/raw/races.csv")

# scrape script doesn't extract gender, extract gender & horse_id here
horse_gender = pd.DataFrame(
    [(h['horse_id'], h['gender']) for x in races['raw_json'] for h in ast.literal_eval(x)[1]],
    columns=['horse_id', 'gender']
).drop_duplicates('horse_id')


# data is suspected to have horse_ids in results that are not in lineage. likely due to scraping errors
## count missing horse ids in lineage
missing_horse_count = results['horse_id'].nunique() - horse_profiles['horse_id'].nunique()

# Set A difference Set B: find values in Set A that don't exist in Set B
## use to find horse ids in results that are not in lineage
results_set = set(results['horse_id'].unique())
lineage_set = set(horse_profiles['horse_id'].unique())
missing_ids = results_set.difference(lineage_set)

# create new dataset with only horse_ids in common between lineages and results
results_common = results.loc[results['horse_id'].isin(horse_profiles['horse_id'])].copy()

# create new column with 'horse_entry_num' with int
results_common['horse_entry_num'] = results_common.groupby('race_id').cumcount() + 1

# add gender
results_common['horse_id'] = results_common['horse_id'].astype(str)
results_common = results_common.merge(horse_gender, on='horse_id')

# reorder columns & rename id column
results_common = results_common[['id', 'race_id', 'finish_pos', 'horse_entry_num', 'horse_id', 'horse_name', 'gender', 'weight', 'odds', 'time_sec', 'margin']].rename(columns={'id':'result_id'})

# edit results_id column in results, needs to be `race_id` + `horse_entry_id`
results_common['result_id'] = results_common['race_id'].astype(str) + results_common['horse_entry_num'].astype(int).astype(str).str.zfill(2)

results_common.to_csv('data/processed/results_processed_gender.csv', index=False)