function [ reports , current_report ] = update_reports( reports , key , value , current_report , str_sinonimo  )

if isempty(reports{current_report})
    id=[];
else    
    id=find(cell2mat(reports{current_report}(:,1))==key);
end

%if solution already exist open new report
if ~isempty(id)
    
    current_report=current_report+1; 
    reports{current_report}={key value str_sinonimo};         
            
else

    if isempty(reports{current_report})
        reports{current_report}={key value str_sinonimo};  
    else
        reports{current_report}(end+1,:)={key value str_sinonimo};  
    end

end

end

