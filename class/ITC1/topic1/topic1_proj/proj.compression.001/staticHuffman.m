function [codeBook, compressionRatio, spaceSaved, timeElapsed, entropy, T] = staticHuffman(charcount,alphabet,message,file)
%% Setup
% Expects charcount from souceCodingAlgo.m
% Sort ascii codes by their frequency
[codeFrequency, asciiCode] = sort(charcount,'descend');
nonZeroElements = length(find(codeFrequency));
sortedAsciiCode = asciiCode(1:nonZeroElements);

% Create probability distribution for characters
% pmf = sortedCodeFrequency/sum(sortedCodeFrequency);

% Import probability distribution
letterFrq = importdata('letter-frequency2.csv');
pmf = letterFrq.data./100;

% Calculate entropy
entropy = -sum((pmf).*log2(pmf));

% Plot relative frequency
figure
% bar(pmf);
symbols = {char(sortedAsciiCode)};
bar(pmf);
title('Symbol Probability Distribution')
xlabel('Symbols');
ylabel('Probability');
set(gca,'XTick',1:length(pmf),'XTickLabel',symbols);
grid on;

% Store the initial symbols and their probabilities
n = length(sortedAsciiCode);
sortedSymbols(1:n) = {'red'};
for b = 1:length(sortedAsciiCode)
    sortedSymbols{b} = char(sortedAsciiCode(b));
end
% n = length(sortedAsciiCode);
% sortedSymbols(1:n) = {'red'};
% sortedSymbols
% sortedProbs
% newProbs
% newSymbols
%% Encoding
disp('*** Encoding... ***');
initialSymbols = sortedSymbols;
initialProbs = transpose(pmf);
sortedProbs = initialProbs;
% Initialize a dummy variable to increment
j = 1;
% Start timer
tic;
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
[~, index] = sort(huffmanTreeCodes,'descend');
sortedTree = huffmanTree(index);

% Stop timer
timeElapsed = toc;
disp('*** Encoding Finished! ***');
%% Generate Huffman tree
disp('*** Making Huffman Tree... ***');
% Calculate tree Parameters
% parent = zeroes(length(sortedTree(2:end)),1);
parent(1) = 0;
for b = 2:length(sortedTree)
    % Get each symbol
    child = sortedTree{b};
    % Find the parent symbol (search until shortest match is found)
    count = 1;
    parentMaybe = sortedTree{b-count};
    diff = strfind(parentMaybe,child);
    while(isempty(diff))
        count = count + 1;
        parentMaybe = sortedTree{b-count};
        diff = strfind(parentMaybe,child);
    end
    parent(b) = b - count;
end
% Make treeplot
figure
treeplot(parent)
legend({'code','path'},'FontName', 'Times New Roman', ...
       'FontSize',10,'Interpreter','LaTeX');
title(strcat("Static Huffman Coding Tree - ",file), 'FontName', 'Times New Roman', ...
       'FontSize',12,'Color','k', 'Interpreter', 'LaTeX');
set(gca, 'XTick',[], 'YTick', []);
grid on;
[xs,ys,~,~] = treelayout(parent);
text(xs,ys,sortedTree);
% Get tree labels
for b = 2:length(sortedTree)
    % Get child coordinates
    childXcoor = xs(b);
    childYcoor = ys(b);
   
    % Get parent coordinates
    parentXcoor = xs(parent(b));
    parentYcoor = ys(parent(b));
    
    % Get the weights
    midXcoor = (childXcoor + parentXcoor)/2;
    midYcoor = (childYcoor + parentYcoor)/2;
    
    % Generate the weights
    % positive slope = 1; negative slope = 0)
    slope = (parentYcoor - childYcoor)/(parentXcoor - childXcoor);
    if(slope > 0)
        weight(b) = 0;
    else
        weight(b) = 1;
    end
    text(midXcoor, midYcoor, num2str(weight(b)));
end
disp('*** Huffman Tree Finished! ***');
%% Generate codebook
for b = 1:length(sortedTree)
    % Initialize code
    code{b} = '';
    
    % Loop untill root is found
    index = b;
    p = parent(index);
    while(p ~= 0)
        % Turn weight into code symbol
        w = num2str(weight(index));
        
        % Concatenate code symbol
        code{b} = strcat(w,code{b});
        
        % Towards root!
        index = parent(index);
        p = parent(index);
    end
end
% Generate codebook
codeBook = [sortedTree', code'];
% So in principal I need to index the code for only the
% characters than are in my initial symbol set.
alphabetCodeBookCodes = ismember(codeBook(:,1),alphabet);
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