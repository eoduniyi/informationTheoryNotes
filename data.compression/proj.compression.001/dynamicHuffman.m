function [codeBook, compressionRatio, spaceSaved, timeElapsed, entropy, T] = dynamicHuffman(charcount, alphabet,message,file)
%% Setup
% Expects charcount from souceCodingAlgo.m
% Sort ascii codes by their frequency
[codeFrequency, ~] = sort(charcount,'descend');
nonZeroElements = length(find(codeFrequency));
sortedCodeFrequency = codeFrequency(1:nonZeroElements);

% Create probability distribution for characters
pmf = sortedCodeFrequency/sum(sortedCodeFrequency);

% Calculate entropy
entropy = -sum((pmf).*log2(pmf));
% Alright the depth of my tree is always N = 2*n + 1
N = 2*length(unique(alphabet)) + 1;
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

%% Encoding
disp('*** Encoding... ***');
tic;
% Stream all characters
c = message;
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
%     t = '';
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
% n = length(list);
% sortedTreeAH(1:n) = {'red'};
% sortedTreeAH = cell(1:length(list));
for i = 1:length(list)
    sortedTreeAH{i} = list(i).val;
end

% parentAH = zeroes(length(sortedTreeAH(2:end),1));
parentAH = zeros(1,length(sortedTreeAH)-2);
parentAH(1) = 0;
for i = 2:length(sortedTreeAH)
    parentAH(i) = abs(list(i).parent.order - length(list) - 1);
end

% Plot Huffman tree
% Make treeplot
figure
treeplot(parentAH)
legend({'code','path'},'FontName', 'Times New Roman', ...
       'FontSize',10,'Interpreter','LaTeX');
title(strcat("Adaptive Huffman Coding Tree - ",file), 'FontName', 'Times New Roman', ...
       'FontSize',12,'Color','k', 'Interpreter', 'LaTeX');
set(gca, 'XTick',[], 'YTick', []);
grid on;
[xs,ys,~,~] = treelayout(parentAH);
text(xs,ys,sortedTreeAH);

% weight = zeros(length(sortedTreeAH(2:end)),1);
% Get tree parameters
[xs,ys,~,~] = treelayout(parentAH);
weight = zeros(1,length(sortedTreeAH)-2);
for i = 2:length(sortedTreeAH)
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
% code = cell(1:length(sortedTreeAH));
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
Match = cellfun(@(x) ismember(x,alphabet), codeSymbols, 'UniformOutput', 0);
index = cell2mat(Match);
codeBook = codeBook(index,:);
alphabetCodeBookCodes = cell2mat(cellfun(@(x)any(ischar(x)),codeBook(:,1),'UniformOutput',false));
codeBook = codeBook(alphabetCodeBookCodes,1:2);

symbolLength2 = strlength(code);
pmf = pmf(1:end-2);
codeWordLength = symbolLength2(1)*pmf(1); 
n = 1;
for temp=1:length(pmf)-1 
   codeWordLength = codeWordLength + symbolLength2(temp+1)*pmf(temp+1);
end
T = codeWordLength/n;
%% Spacing Saved & Compression Ratio
% Fuck, so not only do I need the codeBook codes of all my alphabet
% characters, but then I need to use this set to find and replace each
% character in my alphabet with it's code
% Ex: {P,r,e,s,e} -> {001,100,100,003,000}
bits = 0;
for b = 1:length(message)
    bit_index = ismember(codeBook(:,1),message(b));
    bit = char(codeBook(bit_index,2));
    bit = length(bit);
    bits = bits + bit;
end

% Calculate Compression Ratio (Uncompressed/Compressed)
% bits = sum(cellfun('length',codeBook(:,2)));
compressionRatio = length(message)*8/bits;

% Calculate amount of space saved
spaceSaved = 1 - compressionRatio^-1;
end