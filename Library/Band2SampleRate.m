function [rate] = Band2SampleRate(band)
    bandChar = char(band);
    rate = round(str2double(bandChar(4: end))*1e6);
end