%% To define the exchangable blocks by using the genetic kinship 
% to revise the relatedness extracted from a questionnaire: acspsw02 in the
% ABCD Data Release v1.0. Here, by using the genetic kinship estimated by 
% the KING package, we can have more detailed inforamtion about the 
% DZ, MZ, FS, and HS.
% However, the kinship was not exactly the same as the family
% relatedness specified in the questionnaire. Therefore, we had done some
% corrections by combing both questionnair information and the kinship. 
% 1) if two subjects had a kinship greater than 0.354, they might
% be MZ. However, if they did not reported the same age, then we had to
% randomly delete one of them from the data set and set the sibling type of
% the remaining subject as 'NS'.
% 2) if two subjeects had a kinship greater than 0.177, they might be DZ
% when they reported the same age, or FS when they reported different ages.
% However, if they reported two different ages with less than 7 months 
% difference, we had to delete randomly one of them from the data set.  
% 3) if two subjects had a kinship greater than 0.0884, they might be HS. 
% 4) if one of twins or siblings was missing the genetic data, we had to
% delete this subject and set the sibling type of the remaining twin or 
% sibling(s) as 'NS'.

%% written by Shen Chun, cshen17@fudan.edu.cn
%% reviewed by Dr Qiang Luo, qluo@fudan.edu.cn
%% released on 21 Mar 2020
%% please cite: Shen, et al. Biological Psychiatry 2020

%% Input:
% 'imagingInfo2.mat' ---- this data structure was generated by the code 'ABCDfamilyrelatedness.m'.
%                       c for subject ID; 
%                       famID_1 for family ID; 
%                       famRela for family relatioinship from the questionannire; 
%                       sibtype  ---- sibling type; 
%                       famtype --- family type
%
% 'ID_3076.mat'    ---- 1 variable: M-by-1 cell.
%% Output: 
% The multi-level blocks was saved in 'EB_abcd_3036.mat' with two variables:
%                     B --- as an input to palm_quickperms (provided by PALM -- Permutation Analysis of Linear Models); 
%                     ID_3036 for the subject ID.
% The multi-level block permuted sample in  'crosslag_permorder_3036.mat', namely the 'Pset'.

%% NOTE: This code can be adapted to generate the permutation
% sample to perform the multi-level block permutation for the
% participants you have selected from the ABCD cohort.

% Two things need to be dealt with:
% 1. Two data files are neccessary:
% 1.1 'familyinfo.mat' has 3 variables: ID (N-by-1 cell), famRela(N-by-1
% double), famID (N-by-1, double). This information was extrated from the
% acspsw02 questionnaire. The famRela can be 0--singleton, 1--sibling,
% 2--twin, 3--triplet
% 1.2  'ID_3076.mat' has 1 variable: M-by-1 cell. These participant IDs are
% selected according to your criterion
% 2. complex family type
% In the participants selected in our study (Shen and Luo, et al.
% Biological Psychiatry 2020), we had one special family type that had two
% twins and two of three triplets (the third triplet was not seleted into our
% study). Therefore, in this family, the twins were not exchangable with the
% triplets (see the codes in lines 114-117 of this file). 

% Once you have prepared those two data files in point 1, then you can
% check if you have some speical family types as descrbed in point 2. If
% so, you need to deal with them according to the exchangability. 



%kinship based on gene
load('ID_3076.mat')
load('imagingInfo2.mat')

[cc,ia,ib] = intersect(ID_3076,imagingInfo2.c);%n=3036
famRela = imagingInfo2.famRela(ib,:);
famRela = cellstr(famRela);
famID = imagingInfo2.famID_1(ib);
%tabulate(famRela)
% Value    Count   Percent
%      FS      145      4.78%
%      NS     2348     77.34%
%      DZ      319     10.51%
%      MZ      211      6.95%
%      HS       13      0.43%
F = unique(famID); % 2693
tt = tabulate(famID);
tt1 = tabulate(tt(:,2));
%Value    Count   Percent
%      1     2358     87.56%
%      2      328     12.18%
%      3        6      0.22%
%      4        1      0.00%
%in 3515 sample
FF = unique(imagingInfo2.famID_1); % 3077
tt2 = tabulate(imagingInfo2.famID_1);
tt3 = tabulate(tt2(:,2));
%Value    Count
%      1     2693   
%      2      376     
%      3        7     
%      4        1     

%10 single
famid_s = tt(tt(:,2)==1,1);
idx_s = setdiff(famid_s,famID(strcmp(famRela,'NS')));
[~,~,ib1] = intersect(idx_s,famID);%3FS, 5DZ, 1HS, 1MZ become NS
famRela = char(famRela);
famRela(ib1,:) = repmat('NS',length(ib1),1);
%tabulate(famRela)
% Value    Count   Percent
%      FS      142      4.68%
%      NS     2358     77.67%
%      DZ      314     10.34%
%      MZ      210      6.92%
%      HS       12      0.40%

%triple
famid_t = tt(tt(:,2)==3,1);
famid_t_3515 = tt2(tt2(:,2)==3,1);
tripdif = setdiff(famid_t_3515,famid_t);%famID = 4424
t_rela = famRela(famID ==4424,:);%whole family 4424 are not in 3076

ID_3036 = cc;
save kinship_gene_3036 ID_3036 famID famRela;
%%
clear,clc
load('kinship_gene_3036.mat')

N = size(ID_3036,1);

%sibtype
sibtype = zeros(N,1);
for n = 1:N,
    if any(strcmpi(famRela(n,:),{'FS','NS'})),
        sibtype(n) = 10;
    elseif strcmpi(famRela(n,:),'HS'),
        sibtype(n) = 11;
    elseif strcmpi(famRela(n,:),'DZ'),
        sibtype(n) = 100;
    elseif strcmpi(famRela(n,:),'MZ'),
        sibtype(n) = 1000;
    end
end

% Label each family according to their type. The "type" is
% determined by the number and type of siblings.
F = unique(famID);% 2693
%t = tabulate(famID);
%t = t(t(:,2)~=0,:);
%tt = tabulate(t(:,2));
%tt = tt(tt(:,2)~=0,:);%family size = [1,4]
famtype = zeros(N,1);
for f = 1:numel(F),
    fidx = (F(f) == famID);
    famtype(fidx) = sum(sibtype(fidx));
end
%tt1 = tabulate(famtype);
%tt1 = tt1(tt1(:,2)~=0,:);
%sum(tt1(:,2))
% 10 famtypes [10,20,22,200,210,300,400,2000,2010,2100]

%unique subs, two pair of twins in one family
%NDAR_INVEC2CN745 and NDAR_INVV9BM1RB5 are twins based on age
%no. 1607 and 3017 are twins
tt2 = tabulate(famID);
famid4 = tt2(tt2(:,2)==4,:);
idx4 = ID_3036(famID==famid4(1));
%using kinship can't determine DZ twins or FS
sibtype(strcmp(ID_3036,'NDAR_INVEC2CN745'))=101;
sibtype(strcmp(ID_3036,'NDAR_INVV9BM1RB5'))=101;

[~,idx] = sortrows([famID sibtype]);% ascending sort by famid(1) sibtype(2) age(3)
[~,idxback] = sort(idx);
sibtype = sibtype(idx);
famID = famID(idx);
famtype = famtype(idx);

% Now make the blocks for each family
B = cell(numel(F),1);
for f = 1:numel(F),
    fidx = (F(f) == famID);
    ft = famtype(find(fidx,1));% return the first indice =fidx
    if any(ft == [10,20,22,200,300,400,2000]),% within-family shuffle
        B{f} = horzcat(famID(fidx),sibtype(fidx));
    else
        B{f} = horzcat(-famID(fidx),sibtype(fidx));
    end
end

% Concatenate all. Prepending the famtype ensures that the
% families of the same type can be shuffled whole-block. Also,
% add column with -1, for within-block at the outermost level
B = horzcat(-ones(N,1),famtype,cell2mat(B));

B = B(idxback,:);
            
save EB_abcd_3036 B ID_3036;
%% calling palm_quickperms to generate the permuted sample
%create permutation order
EBfile = 'EB_abcd_3036.mat';
PSfile = 'crosslag_permorder_3036.mat';
PermSamplePALM(EBfile, PSfile)

%% extract the behavioural data for the 
%3036 behavior data
clear,clc

tb = readtable('long_data_0815_formplus.xlsx');
load('ID_3076.mat')
load('EB_abcd_3036.mat','ID_3036')

[~,ia,~] = intersect(ID_3076,ID_3036);
data_3036 = tb(ia,:);
writetable(data_3036, 'data3036ABCD.csv'); % ID_3036;