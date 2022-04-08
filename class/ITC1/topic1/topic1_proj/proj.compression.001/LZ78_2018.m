function [codeBook, compressionRatio, spaceSaved, timeElapsed, entropy, T, binaryrep] = LZ78_2018(charcount,alphabet,message)
%% Setup
alphabetcodes = [];
% Sort ascii codes by their frequency
[codeFrequency, asciiCode] = sort(charcount,'descend');
nonZeroElements = length(find(codeFrequency));
sortedAsciiCode = asciiCode(1:nonZeroElements);
sortedAsciiCode = char(sortedAsciiCode);
sortedAsciiCode(1) = '_';
index1 = find(ismember(sortedAsciiCode,newline));
index2 = find(ismember(sortedAsciiCode,char(13)));
sortedAsciiCode(sortedAsciiCode(:,1) == newline) = [];
sortedAsciiCode(sortedAsciiCode(:,1) == char(13)) = [];
sortedAsciiCode = double(sortedAsciiCode);
sortedCodeFrequency = codeFrequency(1:nonZeroElements);
sortedCodeFrequency([index1,index2],:) = [];

% Create probability distribution for characters
pmf = sortedCodeFrequency/sum(sortedCodeFrequency);

% Save the original pmf and alphabet
% Store for future evidence
out = [string(pmf) char(sortedAsciiCode)];
% Calculate entropy
entropy = -sum((pmf).*log2(pmf));

% Create Look ahead buffer
lookAheadBuffer = transpose(message);
symbolLength = ceil(log2(1/pmf(1))+1); 

for i = 1:length(pmf)-1
   % Compute individual codeword length
   symbolLength = [symbolLength 0]+[zeros(1,i) ceil(log2(1/pmf(i+1)))];
end

% Initialize Dictionary
dict = [];

% Clean up input string
for i = 1:length(lookAheadBuffer)
    if(strcmpi(char(32), lookAheadBuffer(i)) || strcmpi(newline,lookAheadBuffer(i)))
        lookAheadBuffer(i) = regexprep(lookAheadBuffer(i), {char(32) newline}, '_');
    end
end
%% Encoding
codeBook = cell(1,length(lookAheadBuffer));
binaryrep = cell(1,length(lookAheadBuffer));
disp('*** Encoding... ***');
tic;
% Stream all characters
i = 1;
index = 1;
% disp('The length of the lookahead buffer is:');
% length(lookAheadBuffer)
while(i <= length(lookAheadBuffer))
    compareString = lookAheadBuffer(i);
    searchBuffer = find(ismember(dict, compareString), 1);
    if(~isempty(searchBuffer))     
        % Check for consecutive characters
        consecChars = 1;
        j = 1;
        while(consecChars && ((i+j-1) < length(lookAheadBuffer)))
            compareString = strcat(compareString, lookAheadBuffer(i+j));
            searchBuffer = find(ismember(dict, compareString),1);
            if(~isempty(searchBuffer))
                consecChars = 1;
                j = j+1;
            else
                consecChars = 0;
            end
        end             
        % Process the matched string
        streamInit = compareString(1:end-1);
        streamTail = compareString(end:end);
        streamTail = strcat('''', streamTail, '''');
        if((i+j-1) >= length(lookAheadBuffer))
            streamInit = compareString;
            % End of file
            streamTail = 'END';
        end        
        searchBuffer = find(ismember(dict, streamInit));
        % Turn first element into binary
        binaryhead = num2str(dec2bin(searchBuffer));
        % Turn second element into binary
        binarytail = num2str(dec2bin(find(ismember(alphabet,streamTail))));
        binaryrep{i} = strcat(binaryhead,binarytail);
        code = ['(' num2str(searchBuffer) ', ' streamTail ')'];
    else
        binaryhead = num2str(dec2bin(0));
        binarytail = num2str(dec2bin(find(ismember(alphabet,compareString))));
        binaryrep{i} = strcat(binaryhead,binarytail);
        code = ['(0, ' '''' compareString '''' ')'];
        alphabetcodes = cat(1,alphabetcodes,string(code));
    end   
    % Generate codebook
    if(~cellfun('isempty', {code}))
        codeBook{i} = code;
        dict{index} = compareString;
    end

    i = i + length(compareString);
    index = index + 1;
end
timeElapsed = toc;
disp('*** Encoding Finished! ***');
% length(dict)
% length(codeBook)
% length(binaryrep)
%% Generate codebook
% Not sure why I keep getting this error in my code...
% But w/e nerf all the empty cells
codeBook(:,any(cellfun(@isempty,codeBook),1)) = [];
binaryrep(:,any(cellfun(@isempty,binaryrep),1)) = [];
codeBook = [codeBook',binaryrep'];

% Create a codebook for alphabet
alphabetCodeBookIndex = ismember(codeBook(:,1),alphabetcodes);
alphabetCodeBookCodes = codeBook(alphabetCodeBookIndex,1:2);

% Create a new set of initial symbol lengths
expectedlength = [];
sortedAsciiCode = char(sortedAsciiCode);
for i = 1:length(sortedAsciiCode)
    index = cellfun('length',regexp(alphabetCodeBookCodes(:,1),sortedAsciiCode(i))) == 1;
    pmfcode = alphabetCodeBookCodes(index,2);
    expectedlength = cat(1,expectedlength,string(pmfcode));
end

% Create a new set of initial symbol lengths
symbolLength2 = [];
for l = 1:length(expectedlength)
    slfr = strlength(expectedlength(l)); % sn: snlfr = symbol length foreal
    symbolLength2 = cat(1,symbolLength2,slfr);
end

% Give me the characters that are missing from alphabet codebook
missing_idx = not(ismember(char(out(:,2)),char(alphabetCodeBookCodes(:,1))));
% Nuke index with missing character
pmf(missing_idx,:) = [];
% Normalize pmf
pmf = pmf/sum(pmf);
codeWordLength = symbolLength2(1)*pmf(1); 
n = 1;
for temp=1:length(pmf)-1 
   codeWordLength = codeWordLength + symbolLength2(temp+1)*pmf(temp+1);
end
T = codeWordLength/n;
%% Space Saved & Compression Ratio
% Calculate Compression Ratio (Uncompressed/Compressed)
bits = sum(cellfun('length',binaryrep));
compressionRatio = length(lookAheadBuffer)*8/bits;

% Calculate amount of space saved
spaceSaved = 1 - compressionRatio^-1;

binaryrep = alphabetCodeBookCodes;
end