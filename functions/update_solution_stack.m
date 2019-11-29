function [ solution_stack, reports , current_report ] = update_solution_stack( solution_stack , atom_code , lenght , ref_key , position_keys, atom_table_current_row,atom_table_current_col,atom_code_table,distance, reports , current_report , atom_code_table_sinonimi)

if ~isempty(solution_stack)    
    %control if solution already exist
    codes=cell2mat(solution_stack(:,1));
    id=find(codes==atom_code);
    
else
    
    id=[];
    
end

% code key count valid active value distance

%add new solution
if isempty(id)
    
    
    if isempty(solution_stack)
        
        solution_stack={[atom_code] [atom_code_table(atom_code,1)] [lenght-1] [0] [0] [] [distance]};
        
    else
        solution_stack(end+1,:)={[atom_code] [atom_code_table(atom_code,1)] [lenght-1] [0] [0] [] [distance]};
    end
    
    
    id=size(solution_stack,1);
    
    %update solution
else
    
    %dec count
    solution_stack{id,3}=solution_stack{id,3}-1;
    
    %if doesn't valid solution add distance values
    if solution_stack{id,4}==0
        solution_stack{id,7}=solution_stack{id,7}+distance;
    end
    
end

%control position
pos=position_keys(atom_table_current_row,atom_table_current_col);

deleted=0;

%if lengh - count != position delete
if  ~((atom_code_table(solution_stack{id,1},2)-solution_stack{id,3})==pos)
    
    if pos==1
        
        %delete old and add new. (es.  reference. Referecne code ...)
        %if the old counts is <1 then save and delete
        %old value.  (es.  Contract(key1): PROPERTY CAT  Our Contract(key1)
        %Rcf (key19): UI  E3000310-003  ) (one key is subset of another key)
        
        if solution_stack{id,3}>-2
            
            solution_stack(id,:)=[];
            
        else
            
            [ reports , current_report ] = update_reports( reports ,  atom_code_table(solution_stack{id,1},1) , solution_stack{id,6} , current_report , atom_code_table_sinonimi{solution_stack{id,1},1} );
            %delete saved solution
            solution_stack(id,:)=[];
            
        end
        
        if isempty(solution_stack)
            
            solution_stack={[atom_code] [atom_code_table(atom_code,1)] [lenght-1] [0] [0] [] [distance]};
            
        else
            solution_stack(end+1,:)={[atom_code] [atom_code_table(atom_code,1)] [lenght-1] [0] [0] [] [distance]};
        end
        
        id=size(solution_stack,1);
        
    else
        
        
        if solution_stack{id,5}==0
            
            solution_stack(id,:)=[];
            
            deleted=1;
            
        end
        
    end
    
end

if deleted==0
    
    %validity control
    if  solution_stack{id,3}==0
        solution_stack{id,4}=1;
    end
    
end


end

