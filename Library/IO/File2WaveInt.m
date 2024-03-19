function [wave] = File2WaveInt(fileName)
    fileID = fopen(fileName, 'r');
    waveBoth = fread(fileID, 'uint8');
    fclose(fileID);

    waveNorm = (waveBoth - 2^7)/2^7;

    waveReal = waveNorm(1: 2: end);
    waveImag = waveNorm(2: 2: end);
    wave = waveReal + 1i * waveImag;
    wave = wave.';
end