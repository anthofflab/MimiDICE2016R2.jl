
subroutine renamerv
' Rename r.v.
smpl @all
' START TEXTON
smpl 1000001 1003125
series carb=carbcoef
series dam=damcoef
series ets=etscoef
series prod=prodcoef2100
series sig=sigcoef
endsub

'table(1000,10) resmonte
!row=1

subroutine drawrandom
'DRAW RANDOM VARIABLES FOR RSF
smpl 1 1000000
series randcarb=@rlognorm(5.852,0.2644)
series randdamcoef=nrnd*0.00134+0.00226
series randets=@rlognorm(1.0959,0.267)
series randsig=nrnd*0.003185+-0.0152
series randtfp=5*(nrnd*0.009265+.0152)
stats  randdamcoef randtfp  randets randsig randcarb
 
endsub 

subroutine redefinervrsf
'define rv over grid
smpl 1 1000000
carb=randcarb
prod=randtfp
dam=randdamcoef
ets=randets
sig=randsig
endsub

subroutine statsrv
!nrow=2
for !n = 1 to 1
'!row=1
table(200,8) rvstats

rvstats(1,2)="Mean, RSF"
rvstats(1,3)="St Dev ,RSF"
rvstats(1,4)="Mean, Grid"
rvstats(1,5)="St Dev, Grid"
rvstats(1,6)="Ratio, Mean (RSF/Grid)"
rvstats(1,7)="Ratio, St Dev (RSF/Grid)"

rvstats(2,1)="Carb"
rvstats(3,1)="Prod"
rvstats(4,1)="Dam"
rvstats(5,1)="ETS"
rvstats(6,1)="Sigma"


for %rv carb prod dam ets sig  
smpl 1 1000000

rvstats(!nrow,2)=@mean({%rv})
rvstats(!nrow,3)=@stdev({%rv})
!rv2=@mean({%rv})
!rv3=@stdev({%rv})
smpl  1000001 10003125
rvstats(!nrow,4)=@mean({%rv})
rvstats(!nrow,5)=@stdev({%rv})
!rv4=@mean({%rv})
!rv5=@stdev({%rv})

rvstats(!nrow,6)=!rv2/!rv4
rvstats(!nrow,7)= !rv3/!rv5
!nrow=!nrow+1
next 

next
'show rvstats

endsub
call renamerv
call drawrandom
call redefinervrsf
call statsrv
show rvstats
 

'show  rvstats
 

 table(1000,9) resmonteNEW
'Now do MUP method
resmonteNEW(1,2)="Mean, RSF"
resmonteNEW(1,3)="St dev, RSF" 
resmonteNEW(1,4)="Mean, grid" 
resmonteNEW(1,5)="St dev, grid" 
resmonteNEW(1,6)="CV, RSF" 
resmonteNEW(1,7)="CV, grid" 
resmonteNEW(1,8)="Ratio, means" 
resmonteNEW(1,9)="Ratio, st dev" 
resmonteNEW(1,10)="R2bar" 
resmonteNEW(1,11)="Stand error, regr" 

!row=2

resmonteNEW(!row,1)="SCC,2015" 
resmonteNEW(!row+1,1)="Temp, 2100" 
resmonteNEW(!row+2,1)="CO2, 2100 (ppm)"
resmonteNEW(!row+3,1)="Output, 2100" 
resmonteNEW(!row+4,1)="Emissions, 2100" 
resmonteNEW(!row+5,1)="Damage fraction, 2100"
resmonteNEW(!row+6,1)="Interest rate, 2100" 
resmonteNEW(!row+7,1)="Objective function"




!row=2
smpl 1000001 10003125
for %v scc2015 TEMP2100 co2100ppm output2100    EMIS2100 damfrac2100 r2100 objective
ls {%v} c prod prod^2 dam dam^2 ets ets^2  sig sig^2 carb carb^2 dam*prod  dam*ets  dam*carb  dam*sig  prod*carb  prod*sig prod*ets ets*carb ets*sig carb*sig
 
resmontenew(!row,10)=@rbar2
resmontenew(!row,11)=@se

smpl 1 1000000
forecast {%v}f
 
resmonteNEW(!row,2)=@mean({%v}f)
resmonteNEW(!row,3)=@stdev({%v}f)
!n2=@mean({%v}f)
!n3=@stdev({%v}f)

smpl 1000001 1003125
resmonteNEW(!row,4)=@mean({%v}f)
resmonteNEW(!row,5)=@stdev({%v}f)
!n4=@mean({%v}f)
!n5=@stdev({%v}f)


resmonteNEW(!row,6)= !n3/!n2
resmonteNEW(!row,7)= !n5/!n4

resmonteNEW(!row,8)= !n2/!n4
resmonteNEW(!row,9)= !n3/!n5


!row=!row+1
next
 
show resmonteNEW


