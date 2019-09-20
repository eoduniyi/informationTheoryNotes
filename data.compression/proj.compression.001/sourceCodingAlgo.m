function [data] = sourceCodingAlgo(file,algoName)
% Description: 
% A basic information theory compression (entropy coding) utility. 
% Allow users to specify one of four information theory compression schemes.
%              
% Input(s): 
% file - Some .txt file to be compressed
% algoName - One of four compression schemes: 'SFE', 'Huffman', 'AdaptiveHuffman', 'LZ78'      
%
% Output(s): 
% data - A structure array with the the following containers
%   data.alphabet - The n-symbol system alphabet 
%   data.codebook - The generated codebook 
%   data.compratio - The calculated compression ratio 
%   data.spacedsave - The calculated amount of space saved 
%   data.comptime -  The calculated time elapsed
%   data.entropy - The calculated entropy, H(x) of the n-symbol system
%   data.avgcodelength - The calculated average code word length, l(x)
%
% *Specific to LZ78 procedure* -  
%   data.binaryrep - The generated alphabet codewords
%
% Format:
% eg. [SFE_data] =  sourceCodingAlgo('fileToBeCompressed.txt','SFE');
%% Source file and ASCII setup:
% sn: I might want to do some file error handling (i.e don't compression
% any non .txt files..
f = fopen(file); % sn: Assumes file is in the same directory as this function atm.
% Collect ASCII codes
c = fread(f,inf,'uchar');
% Read message
message = char(c');
message = strtrim(message); % sn: not sure if I'm always going to need this...

% Get ASCII code counts
charcount = zeros(128,1);
for i = 1:128
    charcount(i) = sum(c==i);
end

% Get all the unique characters
alphabet = cell(1,length(message));
for i = 1:length(message)
    alphabet{i} = message(i);
end
alphabet = unique(alphabet);

% Set Algorithm:
switch algoName
%% Shannon-Fano-Elias coding:
%  Call the Shannon-Fano-Elias compression function
   case 'SFE'
        disp('*** Starting Shannon-Fano-Elias coding... ***');
        [codeBook, compressionRatio, spaceSaved, timeElapsed, entropy, T] = SFE_2018(charcount,alphabet,message);
        disp('*** Finished Shannon-Fano-Elias procedure! ***');
        data.alphabet = alphabet;
        data.codebook = codeBook;
        data.compratio = compressionRatio;
        data.spacesaved = spaceSaved;
        data.comptime = timeElapsed;
        data.entropy = entropy;
        data.avgcodelength = T;
        disp(' ');
%% Static Huffman coding:
%  Call Static Huffman compression function
    case 'Huffman'
        disp('*** Starting Vanilla Huffman coding... ***');
        [codeBook, compressionRatio, spaceSaved, timeElapsed, entropy, T] = staticHuffman(charcount,alphabet,message,file);
        disp('*** Finished Vanilla Huffman procedure! ***');
        data.alphabet = alphabet;
        data.codebook = codeBook;
        data.compratio = compressionRatio;
        data.spacesaved = spaceSaved;
        data.comptime = timeElapsed;
        data.entropy = entropy;
        data.avgcodelength = T;
        disp(' ');
%% Adaptive Huffman coding:
%  Call the Adaptive Huffman compression function
    case 'AdaptiveHuffman'
        disp('*** Starting Adaptive Huffman coding... ***');
        [codeBook, compressionRatio, spaceSaved, timeElapsed, entropy, T] = dynamicHuffman(charcount,alphabet,message,file);
        disp('*** Finished Adaptive Huffman procedure! ***');
        data.alphabet = alphabet;
        data.codebook = codeBook;
        data.compratio = compressionRatio;
        data.spacesaved = spaceSaved;
        data.comptime = timeElapsed;
        data.entropy = entropy;
        data.avgcodelength = T;
        disp(' ');
%% LZ78 coding:
%  Call the LZ78 compression function
   case 'LZ78'
        disp('*** Starting LZ78 coding... ***');
        [codeBook, compressionRatio, spaceSaved, timeElapsed, entropy, T, binaryrep] = LZ78_2018(charcount,alphabet,message); 
        disp('*** Finished LZ78 procedure! ***');
        data.alphabet = alphabet;
        data.codebook = codeBook;
        data.compratio = compressionRatio;
        data.spacesaved = spaceSaved;
        data.comptime = timeElapsed;
        data.entropy = entropy;
        data.avgcodelength = T;
        data.binaryrep = binaryrep;
        disp(' ');
%% Future schemes:
%  Future compression schemes to be included: LZMK
    otherwise
        disp('This compression scheme is not available at this time'); % sn: Maybe I should take the name anyways
        disp('\n');
end
end