function [specHTSIGCal] = DSP_HTSIG(wave, subList, carrier, rate, phase, band)
    rateHigh = Band2SampleRate(band);
    rateLow = rate;
    symTime = 4e-6;
    symLenHigh = round(symTime*rateHigh);
    symLenLow = round(symTime*rateLow);
    fftTime = 3.2e-6;
    fftLenLow = round(fftTime*rateLow);
    fftLenHigh = round(fftTime*rateHigh);
    subBand = 20e6/64;
    startSym = floor((symLenLow-fftLenLow)/2+1);
    endSym = floor((symLenLow+fftLenLow)/2);
    

    pfOffset = comm.PhaseFrequencyOffset('SampleRate', rateLow, 'FrequencyOffsetSource', 'Input port');

    waveLSTF = wave(1: 2*symLenLow);
    stsLen = round(0.8e-6 * rateLow);
    startIdx = round(0.75*stsLen);
    cfo_1 = wlan.internal.cfoEstimate(waveLSTF(startIdx+(1: 9*stsLen)).', stsLen).*rateLow/stsLen;
    wave = pfOffset(wave.', -cfo_1).';

    waveLLTF = wave(2*symLenLow + (1: 2*symLenLow));
    ltsLen = round(3.2e-6 * rateLow);
    startIdx = round(0.375*ltsLen);
    cfo_2 = wlan.internal.cfoEstimate(waveLLTF(startIdx+(1: 2*ltsLen)).', ltsLen).*rateLow/ltsLen;
    wave = pfOffset(wave.', -cfo_2).';

    subOffset = carrier / subBand;
    if carrier ~= 0
        cfo_3 = (subOffset+0.5-round(subOffset/4)*4)*subBand;
        wave = pfOffset(wave.', -cfo_3).';
    end
    

    cfg = wlanHTConfig("ChannelBandwidth", band);
    lltfTx = wlanLLTF(cfg).';
    lltfTx = lltfTx((symLenHigh-fftLenHigh)/2+1: (symLenHigh+fftLenHigh)/2);
    specLLTFRef = fftshift(fft(lltfTx))/8.8752;
    specLLTFRef = specLLTFRef(subList);
    
    waveLLTF = wave(2*symLenLow+(1: 2*symLenLow));
    waveLLTF = waveLLTF(startSym: endSym);
    specLLTFAct = fftshift(fft(waveLLTF));
    CSI = specLLTFAct ./ specLLTFRef;

    waveHTSIG_1 = wave(5*symLenLow+(1: symLenLow));
    waveHTSIG_1 = waveHTSIG_1(startSym: endSym);
    specHTSIGAct_1 = fftshift(fft(waveHTSIG_1));
    specHTSIGCal_1 = specHTSIGAct_1 ./ CSI .* exp(1i*pi/4*(subList+phase(1)));

    waveHTSIG_2 = wave(6*symLenLow+(1: symLenLow));
    waveHTSIG_2 = waveHTSIG_2(startSym: endSym);
    specHTSIGAct_2 = fftshift(fft(waveHTSIG_2));
    specHTSIGCal_2 = specHTSIGAct_2 ./ CSI .* exp(1i*pi/4*(subList+phase(2)));
    specHTSIGCal = [specHTSIGCal_1 specHTSIGCal_2];
end