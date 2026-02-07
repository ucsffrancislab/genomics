#!/usr/bin/env python3

import pandas as pd


df = pd.read_csv('id,entry_version,sequence_version,species,organism,protein,oligo,peptide,start,end.csv')
print(df.head())

#	Version. Take the highest entry version for the highest sequence version for each id ...
df = (df
    .sort_values(['id', 'entry_version', 'sequence_version'], ascending=[True, False, False])
    .drop_duplicates(subset='id', keep='first')
    .drop(columns=['entry_version', 'sequence_version'])
)
#df.to_csv('id,species,organism,protein,oligo,peptide,start,end-clean.csv',index=False)
print(df.head())

df = df.drop(columns=['oligo','peptide','start','end'])
print(df.shape)
print(df.head())

species = df[['species']]
print(species.shape)
print(species.head())
species = species.drop_duplicates().sort_values(by='species')
#species['species_canonical']=species['species']
species.loc[:, 'species_canonical'] = species['species']
print(species['species_canonical'].nunique())
species['species_canonical'] = species['species_canonical'].str.replace(r'\s*\(.*?\)', '', regex=True).str.strip()
print(species['species_canonical'].nunique())
species.loc[species['species'] == 'Human cytomegalovirus (HHV-5) (Human herpesvirus 5)', 'species_canonical'] = 'Human herpesvirus 5'
print(species['species_canonical'].nunique())
print(species.shape)
print(species.head())
species.to_csv('species_translation_table.csv',index=False)

organism = df[['organism']]
print(organism.shape)
print(organism.head())
organism = organism.drop_duplicates().sort_values(by='organism')
#organism['organism_canonical']=organism['organism']
organism.loc[:, 'organism_canonical'] = organism['organism']
print(organism['organism_canonical'].nunique())
organism['organism_canonical'] = organism['organism_canonical'].str.replace(r'\s*\(.*?\)', '', regex=True).str.strip()
print(organism['organism_canonical'].nunique())
organism['organism_canonical'] = organism['organism_canonical'].str.replace(r'\s*\[.*?\]', '', regex=True).str.strip()
print(organism['organism_canonical'].nunique())
#organism.loc[organism['organism'] == 'Human cytomegalovirus (HHV-5) (Human herpesvirus 5)', 'organism_canonical'] = 'Human herpesvirus 5'
print(organism['organism_canonical'].nunique())
print(organism.shape)
print(organism.head())
organism.to_csv('organism_translation_table.csv',index=False)


protein = df[['protein']]
print(protein.shape)
print(protein.head())
protein = protein.drop_duplicates().sort_values(by='protein')
#protein['protein_canonical']=protein['protein']
protein.loc[:, 'protein_canonical'] = protein['protein']
print(protein['protein_canonical'].nunique())
protein['protein_canonical'] = protein['protein_canonical'].str.replace(r'\s*\[.*?\]', '', regex=True).str.strip()
print(protein['protein_canonical'].nunique())
protein['protein_canonical'] = protein['protein_canonical'].str.replace(r'\s*\(.*?\)', '', regex=True).str.strip()
print(protein['protein_canonical'].nunique())
protein['protein_canonical'] = protein['protein_canonical'].str.replace(r',', ' ', regex=True).str.strip()
print(protein['protein_canonical'].nunique())
protein['protein_canonical'] = protein['protein_canonical'].str.replace(r'\s+', ' ', regex=True).str.strip()
#protein.loc[protein['protein'] == 'Human cytomegalovirus (HHV-5) (Human herpesvirus 5)', 'protein_canonical'] = 'Human herpesvirus 5'
print(protein['protein_canonical'].nunique())
print(protein.shape)
print(protein.head())
protein.to_csv('protein_translation_table.csv',index=False)

