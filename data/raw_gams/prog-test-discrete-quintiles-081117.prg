'scc program for generating quantiles
 smpl @all
smpl 1 10000000
'Set random variables
!sample=10000000
'Normal dist for pop and tfp
!mean_tfp=.076
!sd_tfp=.056
!mean_pop=.01
!sd_pop=0.002372231
series randtfp=nrnd*!sd_tfp+!mean_tfp
series randpop=nrnd*!sd_pop+!mean_pop

' set lognormal for ets
!medln_ets=   1.106
!sdln_ets=   0.2646
series randets=@rlognorm(!medln_ets,!sdln_ets)

' For damage coef
!mean_damcoef=   .00227 
!sd_damcoef=   !mean_damcoef/2
series randdamcoef=nrnd*!sd_damcoef+!mean_damcoef

' lognormal for carbon coef
!medln_carb=   5.851
!sdln_carb=   0.2649
series randcarb=@rlognorm(!medln_carb,!sdln_carb)

' For sigma
!mean_sig=-.0152
!sd_sig=.0032
series randsig=nrnd*!sd_sig+!mean_sig
 
stats randdamcoef randets randsig randtfp  randcarb

'calculate means of tertiles

matrix(5,5) coefquint

'ETS
!row=1
sort randdamcoef
smpl 1 2000000
coefquint(!row,1)=@mean(randdamcoef)
smpl 2000001 4000000
coefquint(!row,2)=@mean(randdamcoef)
smpl 4000001 6000000
coefquint(!row,3)=@mean(randdamcoef)
smpl 6000001 8000000
coefquint(!row,4)=@mean(randdamcoef)
smpl 8000001 10000000
coefquint(!row,5)=@mean(randdamcoef)

'TFP
!row=!row+1
sort randtfp
smpl 1 2000000
coefquint(!row,1)=@mean(randtfp)
smpl 2000001 4000000
coefquint(!row,2)=@mean(randtfp)
smpl 4000001 6000000
coefquint(!row,3)=@mean(randtfp)
smpl 6000001 8000000
coefquint(!row,4)=@mean(randtfp)
smpl 8000001 10000000
coefquint(!row,5)=@mean(randtfp)

 

!row=!row+1
sort randets
smpl 1 2000000
coefquint(!row,1)=@mean(randets)
smpl 2000001 4000000
coefquint(!row,2)=@mean(randets)
smpl 4000001 6000000
coefquint(!row,3)=@mean(randets)
smpl 6000001 8000000
coefquint(!row,4)=@mean(randets)
smpl 8000001 10000000
coefquint(!row,5)=@mean(randets)

!row=!row+1
sort randsig
smpl 1 2000000
coefquint(!row,1)=@mean(randsig)
smpl 2000001 4000000
coefquint(!row,2)=@mean(randsig)
smpl 4000001 6000000
coefquint(!row,3)=@mean(randsig)
smpl 6000001 8000000
coefquint(!row,4)=@mean(randsig)
smpl 8000001 10000000
coefquint(!row,5)=@mean(randsig)

!row=!row+1
sort randcarb
smpl 1 2000000
coefquint(!row,1)=@mean(randcarb)
smpl 2000001 4000000
coefquint(!row,2)=@mean(randcarb)
smpl 4000001 6000000
coefquint(!row,3)=@mean(randcarb)
smpl 6000001 8000000
coefquint(!row,4)=@mean(randcarb)
smpl 8000001 10000000
coefquint(!row,5)=@mean(randcarb)

show coefquint

