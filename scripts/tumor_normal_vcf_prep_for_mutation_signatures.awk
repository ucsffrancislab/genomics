BEGIN{
	FS=OFS="\t"
}
{
	split($10,normal,":")		#	base counts
	split(normal[5],na,",")
	split(normal[6],nc,",")
	split(normal[7],ng,",")
	split(normal[8],nt,",")
	split($11,tumor,":")		#	base counts
	split(tumor[5],ta,",")
	split(tumor[6],tc,",")
	split(tumor[7],tg,",")
	split(tumor[8],tt,",")
	if(normal[1] > 5 && tumor[1] > 5 ){
		n["A"]=na[1];n["C"]=nc[1];n["G"]=ng[1];n["T"]=nt[1]
		t["A"]=ta[1];t["C"]=tc[1];t["G"]=tg[1];t["T"]=tt[1]
		maxin=0
		for(i in n){
			maxin=(n[i]>n[maxin] ? i : maxin)
		}
		delete t[maxin]
		maxit=0
		for(i in t){
			maxit=(t[i]>t[maxit] ? i : maxit)
		}
		print $1,$2,maxin,maxit,sample >> "mut.txt"
		print $1,$2,maxin,maxit,"+",sample >> "count_trinuc_input.csv"
	}else{#DP TOO LOW (<=5) FOR EITHER TUMOR OR NORMAL
		print sample,$0 >> "TooLowDP"
	}
}
