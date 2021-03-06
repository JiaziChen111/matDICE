function [c1,c3,c4,totForcing,Tatm,Tocean,GISS_temp,rss,GISS_years]=TuneDICEClimateModel(climsens,aerosol_k,c1,c3,c4,FCO22x,dt,focean,z_mixed,Cp_mixed,z_deep,sbconst,ocean_diffusivity,Tocean0);

%
%
% Last updated by Robert Kopp, robert-dot-kopp-at-rutgers-dot-edu, Fri Jul 31 16:23:01 EDT 2015

defval('climsens',3);
defval('aerosol_k',1);
defval('FCO22x',3.7127);
defval('dt',10);

defval('focean',0.7);
defval('z_mixed',100);
defval('Cp_mixed',focean * 3985 * 1030 * z_mixed);
defval('z_deep',3790-z_mixed);
defval('sbconst',5.7e-8 * (pi*1e7)*dt);
defval('ocean_diffusivity',1e-3 * (pi*1e7));

lam=FCO22x./climsens;
defval('c1',(1-.70^dt)/lam);
%defval('c3',ocean_diffusivity./(.5*(z_deep+z_mixed)*z_mixed.*c1));
%defval('c4',z_deep./z_mixed.*c1.*c3);
defp=DICEParameters;
defval('c3',defp.c3);
defval('c4',defp.c4);
defval('Tocean0',0);
calcnexttemperature = @(Atm,Ocean,Forcing,c1,c3,c4) [Atm+c1*(Forcing-lam.*Atm-c3*(Atm-Ocean)) Ocean+c4*(Atm-Ocean)];
        
[GISS_years,GISS_LLGHG,GISS_Aerosols,GISS_OtherRF,GISS_temp]=GetGISS(dt);
totForcing = GISS_LLGHG+GISS_Aerosols*aerosol_k+GISS_OtherRF;

keyboard

fitoptions=optimset('Display','iter','algorithm','sqp','TolX',1e-10,'TolFun',1e-10);


	x = fmincon(@tunefunc,[c3 c4],[],[],[],[],[0 0],[1 1],[],fitoptions);
	
	if nargout>2
		[rss,Tatm,Tocean]=tunefunc(x);
	end	
	c3=x(1);
%c4=x(1)*5/31;
c4=x(2);

	
	function [rss,Tatm,Tocean]=tunefunc(x)
		Tatm(1) = 0; Tocean(1) = 0;
		for i=2:length(GISS_years)
			temps = calcnexttemperature(Tatm(i-1),Tocean(i-1),totForcing(i-1),c1,x(1),x(2));
			Tatm(i) = temps(1); Tocean(i) = temps(2);
		end
		y=Tatm.*(abs(Tatm)<=50)+(abs(Tatm)>50)*50;
		resid=(y-GISS_temp').^2;
		rss=sum(resid);
	end
	
end


function [GISS_years,GISS_LLGHG,GISS_Aerosols,GISS_OtherRF,GISS_temp]=GetGISS(dt)

GISS_years0=[1880:2010]';
GISS_LLGHG0 = [
         0
    0.0149
    0.0298
    0.0427
    0.0535
    0.0634
    0.0762
    0.0832
    0.0874
    0.0920
    0.0988
    0.1053
    0.1130
    0.1137
    0.1179
    0.1206
    0.1258
    0.1283
    0.1309
    0.1420
    0.1527
    0.1670
    0.1793
    0.1916
    0.2066
    0.2208
    0.2336
    0.2459
    0.2611
    0.2741
    0.2873
    0.3021
    0.3159
    0.3277
    0.3358
    0.3458
    0.3602
    0.3739
    0.3888
    0.3993
    0.4137
    0.4258
    0.4403
    0.4545
    0.4690
    0.4832
    0.4995
    0.5142
    0.5281
    0.5442
    0.5583
    0.5744
    0.5868
    0.6054
    0.6197
    0.6335
    0.6476
    0.6639
    0.6777
    0.6899
    0.6957
    0.6974
    0.6986
    0.7015
    0.7024
    0.7106
    0.7190
    0.7299
    0.7400
    0.7567
    0.7728
    0.7948
    0.8156
    0.8371
    0.8620
    0.8863
    0.9109
    0.9382
    0.9631
    0.9965
    1.0306
    1.0599
    1.0920
    1.1247
    1.1550
    1.1890
    1.2392
    1.2774
    1.3167
    1.3672
    1.4203
    1.4671
    1.5199
    1.5892
    1.6383
    1.6925
    1.7344
    1.8016
    1.8633
    1.9269
    1.9860
    2.0439
    2.0970
    2.1433
    2.2026
    2.2551
    2.3132
    2.3700
    2.4445
    2.5045
    2.5493
    2.5975
    2.6291
    2.6509
    2.6862
    2.7329
    2.7705
    2.7917
    2.8484
    2.8916
    2.9168
    2.9440
    2.9801
    3.0258
    3.0368
    3.0705
    3.1096
    3.1470
    3.1887
    3.2204
    3.2642]; 

GISS_Aerosols0 = [         0
   -0.0065
   -0.0130
   -0.0195
   -0.0260
   -0.0325
   -0.0390
   -0.0454
   -0.0520
   -0.0585
   -0.0649
   -0.0714
   -0.0780
   -0.0845
   -0.0909
   -0.0975
   -0.1039
   -0.1105
   -0.1169
   -0.1234
   -0.1299
   -0.1373
   -0.1448
   -0.1522
   -0.1595
   -0.1671
   -0.1744
   -0.1820
   -0.1893
   -0.1967
   -0.2043
   -0.2116
   -0.2191
   -0.2265
   -0.2339
   -0.2413
   -0.2488
   -0.2562
   -0.2637
   -0.2710
   -0.2785
   -0.2859
   -0.2934
   -0.3008
   -0.3082
   -0.3157
   -0.3237
   -0.3317
   -0.3397
   -0.3477
   -0.3558
   -0.3639
   -0.3720
   -0.3799
   -0.3879
   -0.3960
   -0.4041
   -0.4121
   -0.4201
   -0.4280
   -0.4362
   -0.4443
   -0.4522
   -0.4603
   -0.4683
   -0.4764
   -0.4844
   -0.4924
   -0.5005
   -0.5085
   -0.5166
   -0.5347
   -0.5526
   -0.5708
   -0.5888
   -0.6068
   -0.6250
   -0.6430
   -0.6611
   -0.6792
   -0.6972
   -0.7135
   -0.7297
   -0.7458
   -0.7619
   -0.7782
   -0.7944
   -0.8105
   -0.8267
   -0.8429
   -0.8591
   -0.8811
   -0.9029
   -0.9250
   -0.9470
   -0.9689
   -0.9908
   -1.0129
   -1.0348
   -1.0568
   -1.0787
   -1.0908
   -1.1028
   -1.1148
   -1.1270
   -1.1390
   -1.1510
   -1.1631
   -1.1752
   -1.1872
   -1.1993
   -1.2271
   -1.2527
   -1.2785
   -1.3031
   -1.3265
   -1.3538
   -1.3815
   -1.4074
   -1.4319
   -1.4582
   -1.4758
   -1.4904
   -1.5058
   -1.5223
   -1.5391
   -1.5552
   -1.5735
   -1.5930
   -1.6123
   -1.6321];
GISS_OtherRF0 = [         0
    0.0290
    0.0472
   -1.0583
   -3.3226
   -1.4839
   -0.8753
   -0.9153
   -0.5604
   -0.7195
   -0.9607
   -0.7133
   -0.4893
   -0.1814
   -0.0228
    0.0072
   -0.4192
   -0.4114
   -0.3067
   -0.1411
   -0.0798
   -0.0678
   -0.5131
   -1.6806
   -0.7032
   -0.2812
   -0.1240
   -0.1950
   -0.2158
   -0.0930
   -0.0952
   -0.0687
   -0.4896
   -0.5904
   -0.2465
   -0.0597
    0.0004
    0.0296
    0.0331
   -0.0047
   -0.2007
   -0.1703
   -0.0715
   -0.0219
   -0.0678
   -0.0253
    0.0009
    0.0518
   -0.0580
   -0.1710
   -0.0815
   -0.0583
   -0.1538
   -0.1298
   -0.0482
   -0.0245
    0.0561
    0.0508
   -0.0088
    0.0084
    0.0241
    0.0532
   -0.0058
   -0.0239
    0.0357
    0.0782
    0.0999
    0.1188
    0.1552
    0.1053
    0.0791
    0.0656
    0.0205
    0.0077
    0.0015
    0.0617
    0.1492
    0.2210
    0.2192
    0.1817
    0.0648
   -0.1403
   -0.2258
   -1.0003
   -1.6085
   -0.9260
   -0.4292
   -0.1932
   -0.4838
   -0.6344
   -0.2179
   -0.0287
    0.0367
   -0.0975
   -0.2264
   -0.6622
   -0.2508
   -0.0235
   -0.0156
   -0.0076
    0.1016
    0.1026
   -1.0828
   -1.6276
   -0.6236
   -0.2344
   -0.2590
   -0.1588
   -0.0555
    0.0619
    0.0491
   -1.0914
   -2.6913
   -1.0311
   -0.3838
   -0.1598
   -0.0937
   -0.0459
    0.0627
    0.1437
    0.1841
    0.1664
    0.1204
   -0.0186
    0.0397
   -0.1014
   -0.0525
   -0.0193
   -0.0046
   -0.0283
    0.0307];

GISS_temp0 = [   -27
   -19
   -25
   -26
   -31
   -30
   -27
   -34
   -27
   -16
   -39
   -27
   -32
   -33
   -34
   -26
   -17
   -13
   -25
   -15
    -8
   -14
   -24
   -30
   -34
   -24
   -18
   -39
   -32
   -34
   -32
   -33
   -30
   -29
   -13
    -8
   -28
   -37
   -32
   -19
   -19
   -14
   -24
   -21
   -21
   -16
    -1
   -14
   -12
   -26
    -7
    -2
    -7
   -19
    -7
   -12
    -5
     6
    11
     1
     4
     9
     2
     9
    19
     6
    -5
     0
    -4
    -6
   -16
    -4
     3
    10
   -10
   -11
   -18
     8
     9
     6
    -1
     7
     4
     8
   -21
   -12
    -3
    -1
    -5
     8
     3
   -11
    -1
    14
    -8
    -4
   -16
    13
     4
    10
    20
    26
     5
    26
     9
     5
    13
    27
    33
    21
    36
    35
    12
    13
    23
    38
    29
    41
    58
    33
    35
    48
    56
    56
    49
    62
    55
    58
    44
    57
    63]/100;


GISS_LLGHG0 = GISS_LLGHG0(41:end);
GISS_Aerosols0 = GISS_Aerosols0(41:end);
GISS_OtherRF0 = GISS_OtherRF0(41:end);
    
GISS_temp0 = GISS_temp0(41:end);
GISS_temp0 = GISS_temp0 - GISS_temp0(1);

GISS_years0=GISS_years0(41:end);

decadeavgM = zeros(floor(length(GISS_LLGHG0)/dt),length(GISS_LLGHG0));
for i=1:size(decadeavgM,1)
	decadeavgM(i,(i-1)*dt+[1:dt]) = (1/dt)*ones(1,dt);
end

GISS_years = decadeavgM*GISS_years0;
GISS_LLGHG = decadeavgM*GISS_LLGHG0;
GISS_Aerosols = decadeavgM*GISS_Aerosols0;
GISS_OtherRF = decadeavgM*GISS_OtherRF0;
GISS_temp = decadeavgM*GISS_temp0;
GISS_temp = GISS_temp-GISS_temp(1);
end
