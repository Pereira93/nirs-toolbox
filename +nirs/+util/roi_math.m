function C = roi_math(A,op,B)
% This function preforms math on regions of interest (denoted by tables)
% and returns a compound ROI
%
% Examples:
% ROIleft - defining ROI
% ROIright - defining ROI
% ROI(left-right) = roi_math(ROIleft,'-',ROIright)
%
% ROI(2*left) = roi_math(ROIleft,'*',2)
%
% ROI(left-2*right) = roi_math(ROIleft,'-',roi_math(ROIright,'*',2))

MAXSRC=64;
MAXDET=64;

switch(op)
    case('-')
        fcn=@(a,b)minus(a,b);
    case('+')
        fcn=@(a,b)plus(a,b);
    case('*')
        fcn=@(a,b)times(a,b);
    case('/')
        fcn=@(a,b)rdivide(a,b);
end

if(~istable(A))
    mlt=B;
        mlt.Name=[];
        mlt.weight=zeros(height(mlt),1);
        mlt=unique(mlt);
        mlt.weight=repmat(A,height(mlt),1);
        mlt.Name=repmat({num2str(A)},height(mlt),1);
        A=mlt;
        
end

if(~istable(B))
    mlt=A;
        mlt.Name=[];
        mlt.weight=zeros(height(mlt),1);
        mlt=unique(mlt);
        mlt.weight=repmat(B,height(mlt),1);
        mlt.Name=repmat({num2str(B)},height(mlt),1);
        B=mlt;
        
end

if(~ismember(A.Properties.VariableNames,'weight'))
    A.weight=ones(height(A),1);
    A.Name=repmat({'A'},height(A),1);
end

if(~ismember(B.Properties.VariableNames,'weight'))
    B.weight=ones(height(B),1);
    B.Name=repmat({'B'},height(B),1);
end

% Deal with NaN's
if(~isempty(find(isnan(B.source))))
    lstNaN=find(isnan(B.source));
    src=[1:MAXSRC]';
    for i=1:length(lstNaN)
        t=repmat(B(lstNaN(i),:),length(src),1);
        t.source=src;
        B=[B; t];
    end
end
if(~isempty(find(isnan(A.source))))
    lstNaN=find(isnan(A.source));
     src=[1:MAXSRC]';
    for i=1:length(lstNaN)
        t=repmat(A(lstNaN(i),:),length(src),1);
        t.source=src;
        A=[A; t];
    end
end
if(~isempty(find(isnan(B.detector))))
    lstNaN=find(isnan(B.detector));
    det=[1:MAXDET]';
    for i=1:length(lstNaN)
        t=repmat(B(lstNaN(i),:),length(det),1);
        t.detector=det;
        B=[B; t];
    end
end
if(~isempty(find(isnan(A.detector))))
    lstNaN=find(isnan(A.detector));
    det=[1:MAXDET]';
    for i=1:length(lstNaN)
        t=repmat(A(lstNaN(i),:),length(det),1);
        t.detector=det;
        A=[A; t];
    end
end



unameA=unique(A.Name);
unameB=unique(B.Name);

C=table;
for i=1:length(unameA)
     lstA=find(ismember(A.Name,unameA{i}));
    for j=1:length(unameB)
        lstB=find(ismember(B.Name,unameB{j}));
        mlt=[A(lstA,:); B(lstB,:)];
        mlt.Name=[];
        mlt.weight=zeros(height(mlt),1);
        mlt=unique(mlt);
       mltA=mlt;
       mltB=mlt;
        for idx=1:length(lstA)
            mltA.weight(find(mlt.source==A.source(lstA(idx)) & ...
                mlt.detector==A.detector(lstA(idx))))=A.weight(lstA(idx));
        end
        for idx=1:length(lstB)
            mltB.weight(find(mlt.source==B.source(lstB(idx)) & ...
                mlt.detector==B.detector(lstB(idx))))=B.weight(lstB(idx));
        end
        mlt.weight=fcn(mltA.weight,mltB.weight);
        mlt.Name=repmat({[unameA{i} ' ' op ' ' unameB{j}]},height(mlt),1);
        C=[C; mlt];
    end      
end

C(C.weight==0,:)=[];

return


