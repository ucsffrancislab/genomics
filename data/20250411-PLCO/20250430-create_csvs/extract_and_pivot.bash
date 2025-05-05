#!/usr/bin/env bash



awk -F, '(NR>1){print $3","$1","$12}' batch1.csv | sort -k1,2 | sed '1isubject,protein,med40' > batch1.med40.csv
python3 -c "import pandas as pd;df=pd.read_csv('batch1.med40.csv',sep=',',low_memory=False);pd.pivot_table(df,values='med40',index='subject',columns='protein',aggfunc='min').to_csv('batch1.med40.min.csv')"
python3 -c "import pandas as pd;df=pd.read_csv('batch1.med40.csv',sep=',',low_memory=False);pd.pivot_table(df,values='med40',index='subject',columns='protein',aggfunc='max').to_csv('batch1.med40.max.csv')"
python3 -c "import pandas as pd;df=pd.read_csv('batch1.med40.csv',sep=',',low_memory=False);pd.pivot_table(df,values='med40',index='subject',columns='protein',aggfunc='median').to_csv('batch1.med40.median.csv')"

awk -F, '(NR>1){print $3","$1","$12}' batch234.csv | sort -k1,2 | sed '1isubject,protein,med40' > batch234.med40.csv
python3 -c "import pandas as pd;df=pd.read_csv('batch234.med40.csv',sep=',',low_memory=False);pd.pivot_table(df,values='med40',index='subject',columns='protein',aggfunc='min').to_csv('batch234.med40.min.csv')"
python3 -c "import pandas as pd;df=pd.read_csv('batch234.med40.csv',sep=',',low_memory=False);pd.pivot_table(df,values='med40',index='subject',columns='protein',aggfunc='max').to_csv('batch234.med40.max.csv')"
python3 -c "import pandas as pd;df=pd.read_csv('batch234.med40.csv',sep=',',low_memory=False);pd.pivot_table(df,values='med40',index='subject',columns='protein',aggfunc='median').to_csv('batch234.med40.median.csv')"


awk -F, '(/^VZV/){print $3","$1","$12}' batch1.csv | sort -k1,2 | sed '1isubject,protein,med40' > batch1.VZV.med40.csv
python3 -c "import pandas as pd;df=pd.read_csv('batch1.VZV.med40.csv',sep=',',low_memory=False);pd.pivot_table(df,values='med40',index='subject',columns='protein',aggfunc='min').to_csv('batch1.VZV.med40.min.csv')"
python3 -c "import pandas as pd;df=pd.read_csv('batch1.VZV.med40.csv',sep=',',low_memory=False);pd.pivot_table(df,values='med40',index='subject',columns='protein',aggfunc='max').to_csv('batch1.VZV.med40.max.csv')"
python3 -c "import pandas as pd;df=pd.read_csv('batch1.VZV.med40.csv',sep=',',low_memory=False);pd.pivot_table(df,values='med40',index='subject',columns='protein',aggfunc='median').to_csv('batch1.VZV.med40.median.csv')"

awk -F, '(/^VZV/){print $3","$1","$12}' batch234.csv | sort -k1,2 | sed '1isubject,protein,med40' > batch234.VZV.med40.csv
python3 -c "import pandas as pd;df=pd.read_csv('batch234.VZV.med40.csv',sep=',',low_memory=False);pd.pivot_table(df,values='med40',index='subject',columns='protein',aggfunc='min').to_csv('batch234.VZV.med40.min.csv')"
python3 -c "import pandas as pd;df=pd.read_csv('batch234.VZV.med40.csv',sep=',',low_memory=False);pd.pivot_table(df,values='med40',index='subject',columns='protein',aggfunc='max').to_csv('batch234.VZV.med40.max.csv')"
python3 -c "import pandas as pd;df=pd.read_csv('batch234.VZV.med40.csv',sep=',',low_memory=False);pd.pivot_table(df,values='med40',index='subject',columns='protein',aggfunc='median').to_csv('batch234.VZV.med40.median.csv')"


awk -F, '(/^HCMV/){print $3","$1","$12}' batch1.csv | sort -k1,2 | sed '1isubject,protein,med40' > batch1.HCMV.med40.csv
python3 -c "import pandas as pd;df=pd.read_csv('batch1.HCMV.med40.csv',sep=',',low_memory=False);pd.pivot_table(df,values='med40',index='subject',columns='protein',aggfunc='min').to_csv('batch1.HCMV.med40.min.csv')"
python3 -c "import pandas as pd;df=pd.read_csv('batch1.HCMV.med40.csv',sep=',',low_memory=False);pd.pivot_table(df,values='med40',index='subject',columns='protein',aggfunc='max').to_csv('batch1.HCMV.med40.max.csv')"
python3 -c "import pandas as pd;df=pd.read_csv('batch1.HCMV.med40.csv',sep=',',low_memory=False);pd.pivot_table(df,values='med40',index='subject',columns='protein',aggfunc='median').to_csv('batch1.HCMV.med40.median.csv')"

awk -F, '(/^HCMV/){print $3","$1","$12}' batch234.csv | sort -k1,2 | sed '1isubject,protein,med40' > batch234.HCMV.med40.csv
python3 -c "import pandas as pd;df=pd.read_csv('batch234.HCMV.med40.csv',sep=',',low_memory=False);pd.pivot_table(df,values='med40',index='subject',columns='protein',aggfunc='min').to_csv('batch234.HCMV.med40.min.csv')"
python3 -c "import pandas as pd;df=pd.read_csv('batch234.HCMV.med40.csv',sep=',',low_memory=False);pd.pivot_table(df,values='med40',index='subject',columns='protein',aggfunc='max').to_csv('batch234.HCMV.med40.max.csv')"
python3 -c "import pandas as pd;df=pd.read_csv('batch234.HCMV.med40.csv',sep=',',low_memory=False);pd.pivot_table(df,values='med40',index='subject',columns='protein',aggfunc='median').to_csv('batch234.HCMV.med40.median.csv')"


awk -F, '(!/^VZV/&&!/^HCMV/&&NR>1){print $3","$1","$12}' batch1.csv | sort -k1,2 | sed '1isubject,protein,med40' > batch1.Human.med40.csv
python3 -c "import pandas as pd;df=pd.read_csv('batch1.Human.med40.csv',sep=',',low_memory=False);pd.pivot_table(df,values='med40',index='subject',columns='protein',aggfunc='min').to_csv('batch1.Human.med40.min.csv')"
python3 -c "import pandas as pd;df=pd.read_csv('batch1.Human.med40.csv',sep=',',low_memory=False);pd.pivot_table(df,values='med40',index='subject',columns='protein',aggfunc='max').to_csv('batch1.Human.med40.max.csv')"
python3 -c "import pandas as pd;df=pd.read_csv('batch1.Human.med40.csv',sep=',',low_memory=False);pd.pivot_table(df,values='med40',index='subject',columns='protein',aggfunc='median').to_csv('batch1.Human.med40.median.csv')"

awk -F, '(!/^VZV/&&!/^HCMV/&&NR>1){print $3","$1","$12}' batch234.csv | sort -k1,2 | sed '1isubject,protein,med40' > batch234.Human.med40.csv
python3 -c "import pandas as pd;df=pd.read_csv('batch234.Human.med40.csv',sep=',',low_memory=False);pd.pivot_table(df,values='med40',index='subject',columns='protein',aggfunc='min').to_csv('batch234.Human.med40.min.csv')"
python3 -c "import pandas as pd;df=pd.read_csv('batch234.Human.med40.csv',sep=',',low_memory=False);pd.pivot_table(df,values='med40',index='subject',columns='protein',aggfunc='max').to_csv('batch234.Human.med40.max.csv')"
python3 -c "import pandas as pd;df=pd.read_csv('batch234.Human.med40.csv',sep=',',low_memory=False);pd.pivot_table(df,values='med40',index='subject',columns='protein',aggfunc='median').to_csv('batch234.Human.med40.median.csv')"
