clear all;
clc;
%% Setup
% Read in ASCII file
file = 'text.txt';
f = fopen(file);
% Collect ASCII codes
c = fread(f,inf,'uchar');
% c = double('aaaaaabbbbcd');

% Create empty matrix to store character counts
charcount = zeros(128,1);
for i = 1:128
    charcount(i) = sum(c==i);
end

% Sort ascii codes by their frequency
[codeFrequency, asciiCode] = sort(charcount,'descend');
nonZeroElements = length(find(codeFrequency));
sortedAsciiCode = asciiCode(1:nonZeroElements);
sortedCodeFrequency = codeFrequency(1:nonZeroElements);

% Create probability distribution for characters
% pmf = charcount/sum(charcount);
pmf = sortedCodeFrequency/sum(sortedCodeFrequency);

% Plot relative frequency
figure
bar(pmf);
title('Symbol Probability Distribution')
xlabel('symbols');
ylabel('Probability');

% Store the initial symbols and their probabilities
for i = 1:length(sortedAsciiCode)
    sortedSymbols{i} = char(sortedAsciiCode(i));
end

%% Encoding
disp('*** Encoding... ***');
initialSymbols = sortedSymbols;
initialProbs = transpose(pmf);
sortedProbs = initialProbs;
% Initialize a dummy variable to increment
j = 1;
% Start timer
timeElapsed = tic;

% Begin chomping
while(length(sortedProbs) > 1)
    % Sort the incoming symbols and their probabilities
    [sortedProbs, index] = sort(sortedProbs,'descend');
    sortedSymbols = sortedSymbols(index);
    
    % Combine symbols and their probabilities
    combinedNode = strcat(sortedSymbols(end),sortedSymbols(end-1));
    combinedProb = sum(sortedProbs(end-1:end));
    
    % Remove the individual symbols and probabilities
    sortedSymbols = sortedSymbols(1:end-2); 
    sortedProbs = sortedProbs(1:end-2);
    
    % Introduce combined symbols and probabilities to the list
    sortedSymbols = [sortedSymbols,combinedNode];
    sortedProbs = [sortedProbs,combinedProb];
    
    % Store new symbols and probabilities to a new container
    newSymbols(j) = combinedNode;
    newProbs(j) = combinedProb;
    j = j+1;
end

% Create Huffman tree
huffmanTree = [newSymbols, initialSymbols];
huffmanTreeCodes = [newProbs, initialProbs];

% Sort Huffman tree
[sortedTreeProbs, index] = sort(huffmanTreeCodes,'descend');
sortedTree = huffmanTree(index);

% Stop timer
timeElapsed = toc;
disp('*** Encoding Finished! ***');
%% Generate Huffman tree
disp('*** Making Huffman Tree... ***');
% Calculate tree Parameters
parent(1) = 0;
numChildren = 2; 
for i = 2:length(sortedTree)
    % Get each symbol
    child = sortedTree{i};
    % Find the parent symbol (search until shortest match is found)
    count = 1;
    parentMaybe = sortedTree{i-count};
    diff = strfind(parentMaybe,child);
    while(isempty(diff))
        count = count + 1;
        parentMaybe = sortedTree{i-count};
        diff = strfind(parentMaybe,child);
    end
    parent(i) = i - count;
end
% Make treeplot
treeplot(parent)
legend({'code','path'},'FontName', 'Times New Roman', ...
       'FontSize',10,'Interpreter','LaTeX');
title(strcat("Static Huffman Coding Tree - ",file), 'FontName', 'Times New Roman', ...
       'FontSize',12,'Color','k', 'Interpreter', 'LaTeX');
set(gca, 'XTick',[], 'YTick', []);
[xs,ys,h,s] = treelayout(parent);
text(xs,ys,sortedTree);

% Get tree labels
for i = 2:length(sortedTree);
    % Get child coordinates
    childXcoor = xs(i);
    childYcoor = ys(i);
   
    % Get parent coordinates
    parentXcoor = xs(parent(i));
    parentYcoor = ys(parent(i));
    
    % Get the weights
    midXcoor = (childXcoor + parentXcoor)/2;
    midYcoor = (childYcoor + parentYcoor)/2;
    
    % Generate the weights
    % positive slope = 1; negative slope = 0)
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
for i = 1:length(sortedTree)
    % Initialize code
    code{i} = '';
    
    % Loop untill root is found
    index = i;
    p = parent(index);
    while(p ~= 0)
        % Turn weight into code symbol
        w = num2str(weight(index));
        
        % Concatenate code symbol
        code{i} = strcat(w,code{i});
        
        % Towards root!
        index = parent(index);
        p = parent(index);
    end
end
% Generate codebook
codeBook = [sortedTree', code'];
%% Spacing Saved & Compression Ratio
% Calculate Compression Ratio (Uncompressed/Compressed)
% bits = sum(cellfun('length',codeBook(:,2)));
% compressionRatio = length(c)*8/bits
% 
% % Calculate amount of space saved
% spaceSaved = 1 - compressionRatio^-1