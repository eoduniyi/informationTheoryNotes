classdef node < handle
    %Tree Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        val % Node name (ID) 
        weight % This is the frequency
        order % This is the order of the node
        left % The node to the left of the node
        right % The node to the right of the node
        parent % The parent of some child
    end
    
    methods
        function obj = node(valuep,weightp,orderp,leftp,rightp,parentp)
            if nargin == 1
                obj(1,valuep) = node;                
                
            elseif nargin > 0
                obj.val = valuep;
                obj.weight = weightp;
                obj.order = orderp;
                obj.left = leftp;
                obj.right = rightp;
                obj.parent = parentp;
            else                 
                obj.val = 0 ;
                obj.weight = 0;
                obj.order = 0 ;
                obj.left = NaN ;
                obj.right = NaN;
                obj.parent = NaN ;
            end
        end
        
        function output = haveParent(obj)
            output = isobject(obj.parent);
        end
       
    end
    
end
