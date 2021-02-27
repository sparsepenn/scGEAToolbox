    function obj = estimatepotency(obj,speciesid,forced)
        if nargin<3, forced=false; end
        if nargin<2, speciesid=[]; end
        if forced || sum(strcmp('cell_potency',obj.list_cell_attributes))==0
            if isempty(speciesid)
                speciesid=input('Species: 1=human,2=mouse >>');
            end
            r=sc_potency(obj.X,obj.g,speciesid);
            obj.list_cell_attributes=[obj.list_cell_attributes,...
                {'cell_potency',r}];
            disp('cell_potency added.');
        else
            disp('cell_potency existed.');
        end
    end
