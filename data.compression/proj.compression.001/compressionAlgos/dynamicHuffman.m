clear all;
clc;
%% Setup
% Read in ASCII file
file = 'text.txt';
f = fopen(file);
% Collect ASCII codes
c = fread(f,inf,'uchar');
c = char(c');
% c = double('aaaaaabbbbcd');

% Create empty matrix to store character counts
initialSymbols = {};
for i = 1:length(c)
    initialSymbols{i} = c(i);
end
initialSymbols = unique(initialSymbols);

% Alright the depth of my tree is always N = 2*n + 1
% Though, I don't know how many unique characters I have
N = 2*length(unique(initialSymbols)) + 1;

% Create an empty tree
% Initialize an array of 147 array objects
list = node(N); % => The root node should have the highest valuep(ID)

% Create a structure to maps values (ID) to unique keys (weight?)
map = containers.Map();

% Top of the tree
treeTop = N;

% So in huffman coding, there is this thing called NTY
% NYT stands for Not Yet Transmitted, essentially, this a method for
% This is done everytime I allocate a new symbol
% There is always one NYT and its value (ID) is 1 and weight is 0
% This is the first node in the tree
% node(valuep,weightp,orderp,leftp,rightp,parentp)
NYT = node('NYT',0,N,NaN,NaN,NaN); % => So, this is

% Set root node
root = NYT;
list(treeTop) = root;

% Now I have one less tree node to give away
treeTop = treeTop - 1;

% Initialize the output to the empty char
out = '';
%% Encoding
disp('*** Encoding... ***');
timeElapsed = tic;
% Stream all characters
for n = 1:length(c)
    tempout = '';
    % Do you have a place in the tree?
    if(isKey(map,c(n)))
        % Get the value at that node (object)
        temp = map(c(n));
        while(temp.haveParent())
            if(temp.parent.left == temp)
                tempout = strcat(tempout,'0');
            else
                tempout = strcat(tempout,'1');
            end
            temp = temp.parent;
        end
%         tempout = flip(tempout); % Not sure what I'm fliping
%         disp(tempout); % Not sure what i'm displaying...
    else
        temp = NYT;
        while(temp.haveParent())
            if(temp.parent.left == temp)
                tempout = strcat(tempout,'0');
            else
                tempout = strcat(tempout,'1');
            end
            temp = temp.parent;
        end
                
    end
    t = '';
    if(~isKey(map,c(n)))
        temp = NYT;
        % Note sure what retVal is
        retVal = node(c(n),1,NYT.order-1,NaN,NaN,temp);
        list(treeTop) = retVal;
        treeTop = treeTop - 1;
        NYT = node('NYT',0,NYT.order-2,NaN,NaN,temp);
        list(treeTop) = NYT;
        treeTop = treeTop - 1;
        temp.left = NYT;
        temp.right = retVal;
        temp.weight = temp.weight + 1;
        temp.val = NaN;
        map(c(n)) = retVal;
        if(~(map(c(n)).parent.haveParent()))
            continue
        end
        t = map(c(n)).parent.parent;
    else
        t = map(c(n));
    end
    
    while(t.haveParent())
        temp = t;
        
        i = t.order + 1;
        while((list(i).weight == t.weight) && i < N)
            i = i+1;
        end
        
        i = i-1;
        
        if((list(i).order > temp.order) && (list(i) ~= t.parent))
            temp = list(i);
            temp2 = list(temp.order);
            list(temp.order) = list(t.order);
            list(t.order) = temp2;
            
            if(t.parent.left == t)
                t.parent.left = temp;
                if(temp.parent.right == temp)
                    temp.parent.right = t;
                else
                    temp.parent.left = t;
                end
            else
                t.parent.right = temp;
                if(temp.parent.left == temp)
                    temp.parent.left = t;
                else
                    temp.parent.right = t;
                end
            end
            
            temp2 = temp.parent;
            temp.parent = t.parent;
            t.parent = temp2;
            order = t.order;
            t.order = temp.order;
            temp.order = order;
        end
        t.weight = t.weight + 1;
        t = t.parent;
    end
    t.weight = t.weight + 1;
end
timeElapsed = toc;
disp('*** Encoding Finished! ***');
%% Generate Huffman tree
disp('*** Making Huffman Tree... ***');
% Calculate tree parameters
% The newSymbols are the combined nodes and the initial symbols are the leaves
list = flip(list); % sn: make sure the list doesn't get flipped everytime
for i = 1:length(list)
    sortedTreeAH{i} = list(i).val;
end

parentAH(1) = 0;
for i = 2:length(sortedTreeAH)
    parentAH(i) = abs(list(i).parent.order - length(list) - 1);
end

% Plot Huffman tree
% Make treeplot
treeplot(parentAH)
legend({'code','path'},'FontName', 'Times New Roman', ...
       'FontSize',10,'Interpreter','LaTeX');
title(strcat("Adaptive Huffman Coding Tree - ",file), 'FontName', 'Times New Roman', ...
       'FontSize',12,'Color','k', 'Interpreter', 'LaTeX');
set(gca, 'XTick',[], 'YTick', []);
[xs,ys,h,s] = treelayout(parentAH);
text(xs,ys,sortedTreeAH);

% Get tree parameters
[xs,ys,h,s] = treelayout(parentAH);
for i = 2:length(sortedTreeAH);
    % Get child coordinates
    childXcoor = xs(i);
    childYcoor = ys(i);
   
    % Get parent coordinates
    parentXcoor = xs(parentAH(i));
    parentYcoor = ys(parentAH(i));
    
    % Get the weights
    midXcoor = (childXcoor + parentXcoor)/2;
    midYcoor = (childYcoor + parentYcoor)/2;
    
    % Generate the weights
    % positive slope = 1; negative slope = 0
    slope = (parentYcoor - childYcoor)/(parentXcoor - childXcoor);
    if(slope > 0)
        weight(i) = 0;
    else
        weight(i) = 1;
    end
    text(midXcoor, midYcoor, num2str(weight(i)));
end
disp('*** Huffman Tree Finished! ***');
%% Generate codebook
code = {};
for i = 1:length(sortedTreeAH)
    % Initialize code
    code{i} = '';
    
    % Loop untill root is found
    index = i;
    p = parentAH(index);
    while(p ~= 0)
        % Turn weight into code symbol
        w = num2str(weight(index));
        
        % Concatenate code symbol
        code{i} = strcat(w,code{i});
        
        % Towards root!
        index = parentAH(index);
        p = parentAH(index);
    end
end
% Generate codebook
codeBook = [sortedTreeAH', code'];
codeSymbols = codeBook(:,1);
codeSymbols(~cellfun('isclass',codeSymbols,'char')) = {'0'};
Match = cellfun(@(x) ismember(x,initialSymbols), codeSymbols, 'UniformOutput', 0);
index = find(cell2mat(Match));
finalCodeBook = codeBook(index,:)
%% Space Saved & Compression Ratio
% Calculate Compression Ratio (Uncompressed/Compressed)
% bits = sum(cellfun('length',codeBook(index,2)));
% compressionRatio = length(c)*8/bits
% 
% % Calculate amount of space saved
% spaceSavin = 1 - compressionRatio^-1