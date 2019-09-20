%% Setup
disp('*** Starting Adaptive Huffman... ***');
% So, the first thing I need to do is read in the input data:
% Read in ASCII file
f = fopen('text.txt');
% Collect ASCII codes
c = fread(f,inf,'uchar');
% Check message/Convert back to char 
c = char(c');

% Create an empty matrix to store character counts
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
pmf = sortedCodeFrequency/sum(sortedCodeFrequency);

% Get initial symbol length
symbolLength = ceil(log2(1/pmf(1))+1); 
cdf = 0; 
cdfBar = 0; 

% Calculate entropy
entropy = -sum((pmf).*log2(pmf));
%% Encoding
disp('*** Encoding... ***');
timeElapsed = tic;
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
% computing for average codeword length
codeWordLength = symbolLength(1)*pmf(1); 
n = 0;
for temp=1:length(pmf)-1 
   codeWordLength = codeWordLength + symbolLength(temp+1)*symbolLength(temp+1);
end
T = codeWordLength/n; 
%% Space Saved & Compression Ratio
% Calculate Compression Ratio (Uncompressed/Compressed)
% bits = sum(cellfun('length',codeBook(index,2)));
% compressionRatio = length(c)*8/bits
% 
% % Calculate amount of space saved
% spaceSavin = 1 - compressionRatio^-1