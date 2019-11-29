function  generate_report( reports , nome_file , keys_name )

reportfile= fullfile('results','output.csv');

if (exist(fullfile(pwd,reportfile),'file')==0)
    
    fid = fopen(reportfile,'w');
    
    %make title
    fprintf(fid,'%s','name_file,num_section,');
    
    for j=1:length(keys_name)
        fprintf(fid,'%s %s',keys_name{j},',Generate_From_Key,Position,' );
    end
    
else
    fid = fopen(reportfile,'a');
end

%write info
num_reports=size(reports,2);
num_keys=size(keys_name,1);


for r=1:num_reports
    
    fprintf(fid,'\n');
    
    fprintf(fid,'%s %s %s %s',nome_file,',',num2str(r),',');
    
    if ~isempty(reports{r})
        
        for k=1:num_keys
            
            str_value=[];
            
            id=find(cell2mat(reports{r}(:,1))==k, 1);
            
            value_added=0;
             
            if isempty(id)
                
                str_value='';
                
            else
                
                value_added=1;
                
                value = reports{r}{id,2};                
               
                for v=1:size(value,2)
                    str_value=[str_value ' ' value{v}];                   
                end
                
                
            end
            
            %for CSV problem
            str_value=strrep(str_value, ',', '.');                        
            
            str_value=strrep(str_value, '\n', '');
            
            str_value=strrep(str_value, '\r', '');
            
            str_value=strrep(str_value, ';', '');
            
            if value_added==1
                
                fprintf(fid,'%s %s %s',str_value,',',reports{r}{id,3},',',num2str(id),',');
                
                
            else
                fprintf(fid,'%s %s %s',str_value,',',reports{r}{id,3},',','',',');
            end
            
            
            
        end
        
    end
    
end

fclose(fid);

end