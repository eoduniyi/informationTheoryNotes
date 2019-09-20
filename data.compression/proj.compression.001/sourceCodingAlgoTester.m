%% 3. US Constitution
file = 'american_constitution.txt';
US2_sfe_data = sourceCodingAlgo(file,'SFE');
US2_vh_data = sourceCodingAlgo(file,'Huffman');
US2_ah_data = sourceCodingAlgo(file,'AdaptiveHuffman');
US2_lz78_data = sourceCodingAlgo(file,'LZ78');
disp('-----------------------------------------------------');
disp(' ');
%% 4. CHILDES1
file = 'childes1.txt';
CHILDES1_sfe_data = sourceCodingAlgo(file,'SFE');
CHILDES1_vh_data = sourceCodingAlgo(file,'Huffman');
CHILDES1_ah_data = sourceCodingAlgo(file,'AdaptiveHuffman');
CHILDES1_lz78_data = sourceCodingAlgo(file,'LZ78');
disp('-----------------------------------------------------');
disp(' ');
%% 5. CHILDES2
file = 'childes2.txt';
% CHILDES2_sfe_data = sourceCodingAlgo(file,'SFE');
% CHILDES2_vh_data = sourceCodingAlgo(file,'Huffman');
% CHILDES2_ah_data = sourceCodingAlgo(file,'AdaptiveHuffman');
CHILDES2_lz78_data = sourceCodingAlgo(file,'LZ78');
disp('-----------------------------------------------------');
disp(' ');
%% 6. CHILDES3
file = 'childes3.txt';
CHILDES3_sfe_data = sourceCodingAlgo(file,'SFE');
CHILDES3_vh_data = sourceCodingAlgo(file,'Huffman');
CHILDES3_ah_data = sourceCodingAlgo(file,'AdaptiveHuffman');
CHILDES3_lz78_data = sourceCodingAlgo(file,'LZ78');
disp('-----------------------------------------------------');
disp(' ');