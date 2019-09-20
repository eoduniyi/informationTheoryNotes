function [codeBook, compressionRatio, spaceSaved, timeElapsed, entropy, T] = SFE_2018(charcount,~,message)
%% Setup
% Sort ascii codes by their frequency
[codeFrequency, asciiCode] = sort(charcount,'descend');
nonZeroElements = length(find(codeFrequency));
sortedAsciiCode = asciiCode(1:nonZeroElements);
sortedAsciiCode = sortedAsciiCode(1:end-2);
sortedCodeFrequency = codeFrequency(1:nonZeroElements);
sortedCodeFrequency = sortedCodeFrequency(1:end-2);

% Create probability distribution for characters
pmf = sortedCodeFrequency/sum(sortedCodeFrequency);
% sortedSymbols = cell(1:length(sortedAsciiCode));
for b = 1:length(sortedAsciiCode)
    sortedSymbols{b} = char(sortedAsciiCode(b));
end

% Get initial symbol length
symbolLength = ceil(log2(1/pmf(1))+1);
cdf = 0; 
cdfBar = 0; 

% Calculate entropy
entropy = -sum((pmf).*log2(pmf));
%% Encoding
disp('*** Encoding... ***');
tic;
% Calculate CDF and CDF-bar
for i = 1:length(pmf)-1
   % Solving for Pk for every codeword
   cdf = cdf + pmf(i);
   cdfBar = [cdfBar 0]+[zeros(1,i) cdf];
   
   % Compute individual codeword length
   symbolLength = [symbolLength 0]+[zeros(1,i) ceil(log2(1/pmf(i+1)))];
end

bitString = 0;
% Calculate CDF-bar-binary
for i = 1:length(cdfBar)
    cdfBarBinary = cdfBar(i);
    
    for j=1:symbolLength(i)    
        cdfBarBinary = mod(cdfBarBinary,1)*2;
        % Converting pmf point into a binary number       
        binaryx(j) = cdfBarBinary-mod(cdfBarBinary,1); 
    end
    
    % Converting binary into a bit-string (i.e some whole number)
    bitString(i) = binaryx(1)*10^(symbolLength(i)-1);
    for k = 2:symbolLength(i)
        bitString(i) = bitString(i) + binaryx(k)*10^(symbolLength(i)-k);  
    end                                       
end

% bit string construction
for i = 1:length(bitString)
   temp = 1;                                      
   for j = symbolLength(i):-1:1
       % MSB
       MSB = floor(bitString(i)/10^(j-1));
       % Rest of the bits 
       bitString(i) = mod(bitString(i),10^(j-1));             
       % Construct final bit-string
       if(MSB == 1)
           if(temp == 1)
                finalBitString = '1';                      
           else
                finalBitString = [finalBitString '1'];
           end
       else
           if(temp == 1)
                finalBitString = '0';
           else
                finalBitString = [finalBitString '0'];
           end
       end
       C{i,:} = {finalBitString};
       temp = temp + 1;
   end
end
timeElapsed = toc;
disp('*** Encoding Finished! ***');
%% Generate codebook
codeBook = [C{:}]';
% Epect initialSymbols from sourceCodingAlgo.m
codeBook = [sortedSymbols',codeBook];

% Computing expected codeword length
codeWordLength = symbolLength(1)*pmf(1); 
n = 1;
symbolLength = symbolLength(1:end-2);
pmf = pmf(1:end-2);
for temp=1:length(pmf)-1 
   codeWordLength = codeWordLength + symbolLength(temp+1)*pmf(temp+1);
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