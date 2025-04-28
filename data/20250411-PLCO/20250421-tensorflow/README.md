
#	20250411-PLCO/20250421-tensorflow



```
ftp.box.com/Signal_stats_updated_2016/signal_cmv_plco.csv
ftp.box.com/Signal_stats_updated_2016/signal_human_plco.csv
ftp.box.com/Signal_stats_updated_2016/signal_vzv_plco.csv

ftp.box.com/Ring_stats_updated_2017/new_cmv_ring_2017.csv
ftp.box.com/Ring_stats_updated_2017/new_vzv_ring_2017.csv
ftp.box.com/Ring_stats_updated_2017/new_vzv_ring_2017.idno-barcode.csv

head -2 ftp.box.com/Signal_stats_updated_2016/signal_vzv_plco.csv 
IDNO,Batch,TGF_beta,IL13,TNF_a,Total_IgE,Total_IgE_cutoff,Phadiatop,Phadiatop_cutoff,lnphadiatop,lnil13,lntgf_beta,lntnf_a,lnige_quart,lnphadiatop_quart,lnil13_quart,lntgf_beta_quart,lntnf_a_quart,match_gender,match_agelevel,match_race7,is_case,match_draw_yr,match_draw_month,glio_icdtop,glio_icdmor_beh,glio_icdmor,glio_icdbeh,glio_icdgrd,glio_is_first_dx,glio_cstatus_cat,glio_type,glio_cancer,glio_candxdays,glio_exitstat,glio_exitage,glio_exitdays,educat,marital,bq_age,hispanic_f,cig_stat,cig_stop,cig_years,pack_years,bmi_20,bmi_50,bmi_curr,bmi_curc,glio_fh,glio_fh_cnt,glio_fh_age,is_dead,dth_cat,dth_days,bq_cohort_entryage,sex,age,agelevel,draw_to_dx_days,PLCO_master_barcode,Backtrack_barcode,_NAME_,Orf_S_L,Orf0,Orf1,Orf1_N,Orf11,Orf12,Orf12_C,Orf12_N,Orf13,Orf14,Orf14_N,Orf15_F,Orf15_N,Orf16,Orf17,Orf18,Orf18_C,Orf19,Orf2,Orf20,Orf21,Orf22_1,Orf22_2,Orf23,Orf24,Orf24_N,Orf25,Orf26,Orf27,Orf28,Orf3,Orf30,Orf31_C,Orf31_F,Orf31_M,Orf32,Orf33,Orf33_N,Orf33_5,Orf35,Orf36,Orf37,Orf38,Orf39,Orf39_N,Orf4,Orf40,Orf41,Orf42,Orf43,Orf43_C,Orf44,Orf45,Orf46,Orf47,Orf48,Orf49,Orf5,Orf5_F,Orf50,Orf50_C,Orf51,Orf52,Orf53,Orf55,Orf56,Orf56_C,Orf57,Orf58,Orf59,Orf6,Orf60,Orf60_C,Orf61,Orf62,Orf63,Orf64,Orf65,Orf65_N,Orf66,Orf67,Orf67_C,Orf67_N,Orf68,Orf68_C,Orf68_F,Orf7,Orf8,Orf9,Orf9a,Orf9a_N,case_AZ
A_000023,2.0,1672.18,637.94,27.98,141.1849952,Elevated,6.10689925242042,Positive,1.809419157039326,6.458244235035239,7.421883443352602,3.331489969237335,4.0,4.0,4.0,4.0,4.0,M,3.0,1.0,0.0,0.0,3.0,,,,,,0.0,0.0,,0.0,,14.0,84.0,4748.0,7.0,1.0,71.0,0.0,0.0,,0.0,0.0,19.977699347046745,27.37684725336035,28.856676834623073,3.0,0.0,0.0,,0.0,0.0,,71.0,1.0,71.0,3.0,5579.0,,,Cont_IX3436,1.372,1.306,1.306,0.945,1.801,1.499,1.081,1.292,1.356,1.566,1.36,1.256,1.266,1.433,1.287,1.424,1.881,0.893,2.019,1.473,1.099,2.139,1.519,1.409,1.159,1.299,1.17,1.804,1.831,1.179,1.85,1.042,0.953,0.977,1.45,0.905,1.121,0.821,1.112,1.051,1.269,1.473,1.867,0.487,1.46,1.654,0.815,1.484,1.249,1.634,1.234,1.659,0.807,1.169,1.722,1.236,1.166,1.151,1.116,1.386,1.264,1.518,1.837,1.567,2.949,1.712,2.167,1.476,1.967,1.66,2.4,1.084,1.893,1.992,1.97,1.655,1.201,1.712,1.709,1.716,1.787,2.263,2.24,0.934,2.437,1.27,1.707,1.655,1.013,1.457,1.493,0.0

wc -l ftp.box.com/Signal_stats_updated_2016/signal_vzv_plco.csv
659
```


drop most of the above except the protein signal, case, idno, gender, ...


```
./20250421-predict.bash > commands
commands_array_wrapper.bash --array_file commands --time 1-0 --threads 2 --mem 15G 
```


