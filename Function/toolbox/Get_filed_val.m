function [Data] = Get_filed_val(stru,field)
% get the field value from stru
    Data=[]; 
    af=fieldnames(stru);
    n=length(af);
    for i=1:n
        if strcmp(af{i} ,field)==0
            break;
        end
    end
    if (strcmp(af(i),field)~=0)
        disp('---error---');
        disp(['The filed ',field,' is not in this struct!']);
        disp('---end---');
    return;
    end
    m=length(stru);
    for i=1:m
        Data=eval(['[Data;stru(i).',field,'];']);
    end   
end

