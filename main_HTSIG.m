clear;
clf;
clc;
close all;
addpath(genpath("../Library"));

rng(0);

path = "./Data/";
prot = "HT";
rateSet = [10000000 5000000 2500000 1250000];
carrierSet = [-4531250 781250 2031250 3593750];
phaseSet = [3 -1; 1 -1; 1 -1; 0 0];
bandSet = ["CBW20" "CBW40"]; % ["CBW20" "CBW40" "CBW80" "CBW160"];
snrSet = 0: 2: 20;
manual = -1;

setupNum = length(rateSet);
bandNum = length(bandSet);
snrNum = length(snrSet);
accMcsBitMat = zeros(setupNum, bandNum, snrNum, 5);
accBandBitMat = zeros(setupNum, bandNum, snrNum, 1);
accPsudBitMat = zeros(setupNum, bandNum, snrNum, 16);
for setupIdx = 1: setupNum
    rate = rateSet(setupIdx);
    carrier = carrierSet(setupIdx);
    phase = phaseSet(setupIdx, :);

    for bandIdx = 1: bandNum
        band = bandSet(bandIdx);
        for snrIdx = 1: snrNum
            snr = snrSet(snrIdx);
            close all;
            disp(rate+" "+band+" "+snr);
            folderLabel = path + "Label/";
            folderData = path + "NoAlias-" + carrier + "_" + rate + "_" + snr + "dB/";
        
            %%
            rateTx = Band2SampleRate(band);
            rateRx = rate;
            subNum = round(rateTx/20e6) * 64;
            subSolve = zeros(1, subNum);
            for subIdx = 1: subNum
                carrierSub = rateTx/subNum*(subIdx-1)-10e6;
                if(carrierSub>=carrier-rateRx/2)&&(carrierSub<carrier+rateRx/2)
                    subSolve(subIdx) = 1;
                end
            end
            subList = find(subSolve == 1);
            subNum = 2 * length(subList);
            sigNum = 48;
            
            %%
            constel = zeros(10000, subNum);
            subLabel = zeros(10000, subNum);
            sigLabel = zeros(10000, sigNum);
            fileNum = 0;
            for folderIdx = 1: 100
                folderName = prot + "_" + band + "_" + folderIdx + "/";
                for index = 1: 500
                    fileName = prot + "_" + band + "_" + folderIdx + "_" + index;
                    fileData = folderData + folderName + fileName + ".bin";
                    fileLabel = folderLabel + folderName + fileName + ".mat";
                    if ~exist(fileData, 'file') || ~exist(fileLabel, 'file')
                        continue;
                    end
                    fileNum = fileNum + 1;
                    subLabel(fileNum, :) = load(fileLabel).SIG.HTSIG.sub([subList subList+round(rateTx/20e6)*64]);
                    sigLabel(fileNum, :) = load(fileLabel).SIG.HTSIG.bitOrig;

                    signal = File2Wave(fileData);
                    if manual > 0
                        signalPower = sqrt(mean(abs(signal).^2));
                        noisePower = signalPower / (10^(manual/20)*sqrt(2));
                        noise = noisePower * (randn(1, length(signal)) + 1i*randn(1, length(signal)));
                        wave = signal + noise;
                    else
                        wave = signal;
                    end
                    constel(fileNum, :) = DSP_HTSIG(wave, subList, carrier, rate, phase, band);
                end
            end
            constel(fileNum+1: end, :) = [];
            sigLabel(fileNum+1: end, :) = [];
            subLabel(fileNum+1: end, :) = [];
            
            %%
            if ~exist("Result", "dir")
                mkdir("Result");
            end
            if ~exist("Result/HTSIG_"+band+"_"+rate+"_"+snr+"/", "dir")
                mkdir("Result/HTSIG_"+band+"_"+rate+"_"+snr+"/");
            end
            for subIdx = 1: subNum
                figure('Position', [0 0 500 500]);
                posIdx = find(abs(subLabel(:, subIdx)+1i)<1e-5);
                scatter(real(constel(posIdx, subIdx)), imag(constel(posIdx, subIdx)), ...
                    50, '+', 'red', 'linewidth', 2);
                hold on;
                negIdx = find(abs(subLabel(:, subIdx)-1i)<1e-5);
                scatter(real(constel(negIdx, subIdx)), imag(constel(negIdx, subIdx)), ...
                    50, 'o', 'blue', 'linewidth', 2);
                otherIdx = 1: fileNum;
                otherIdx([posIdx; negIdx]) = [];
                scatter(real(constel(otherIdx, subIdx)), imag(constel(otherIdx, subIdx)), ...
                    50, 'o', 'green', 'linewidth', 2);
            %     legend("bit 0", "bit 1");
                hold off;
                axis([-2 2 -2 2]);
                xticks([-1 1]);
                xticklabels(["" ""]);
                yticks(0);
                yticklabels("");
                set(gca, 'LineWidth', 2, 'FontSize', 20, 'FontName', 'Arial');
                grid on;
                box on;
                saveas(gcf, "Result/HTSIG_"+band+"_"+rate+"_"+snr+"/"+subIdx+".png")
            end
            
            %%
            randList = rand(fileNum, 1);
            trainIdx = (1: fileNum)'; % Must include 0/1 labels for all the subcarriers
            testIdx = (1: fileNum)';
            trainNum = size(trainIdx, 1);
            constelTrain = constel(trainIdx, :);
            subLabelTrain = subLabel(trainIdx, :);
            testNum = size(testIdx, 1);
            constelTest = constel(testIdx, :);
            subLabelTest = subLabel(testIdx, :);
            sigLabelTest = sigLabel(testIdx, :);
            
            subPredTest = zeros(testNum, subNum);
            accTest = zeros(1, subNum);
            for subIdx = 1: subNum
            %     subPredTest(:, subIdx) = DemodSVM(constelTrain(:, subIdx), subLabelTrain(:, subIdx), constelTest(:, subIdx));
                subPredTest(:, subIdx) = DemodThres(constelTrain(:, subIdx), subLabelTrain(:, subIdx), constelTest(:, subIdx));
                accTest(subIdx) = sum(subPredTest(:, subIdx)==subLabelTest(:, subIdx))/testNum;
            end
            disp(accTest);
            
            %%
            
            errorPsduTest = zeros(testNum, 1);
            accMcsBitTest = zeros(1, 5);
            accBandBitTest = zeros(1, 1);
            accPsduBitTest = zeros(1, 16);
            confMcsTest = zeros(32, 32);
            mcsSet = 0: 31;
            confModuTest = zeros(4, 4);
            moduSet = [2 4 16 64];
            confCodeTest = zeros(4, 4);
            codeSet = [2 3 4 6];
            confAntTest = zeros(4, 4);
            antSet = [1 2 3 4];
            confBandTest = zeros(2, 2);
            bandSet = ["CBW20" "CBW40"];
            for testIdx = 1: testNum
            %     disp(sigLabelTest(testIdx, [1: 5 8: 24]));
                [predPsduTest, predMcsTest, predModuTest, predCodeTest, predAntTest, predBandTest, bit] = Sub2PSDU(subPredTest(testIdx, :), [subList subList+64]);
                accMcsBitTest = accMcsBitTest + (bit(1: 5)'==sigLabelTest(testIdx, 1: 5))/testNum;
                accBandBitTest = accBandBitTest + (bit(6)'==sigLabelTest(testIdx, 8))/testNum;
                accPsduBitTest = accPsduBitTest + (bit(7: 22)'==sigLabelTest(testIdx, 9: 24))/testNum;
                labelPsduTest = HTSIG2Psdu(sigLabelTest(testIdx, :));
                errorPsduTest(testIdx) = abs(predPsduTest - labelPsduTest);
            
                mcsNow = HTSIG2Mcs(sigLabelTest(testIdx, :));
                confMcsTest(predMcsTest==mcsSet, mcsNow==mcsSet) = ...
                    confMcsTest(predMcsTest==mcsSet, mcsNow==mcsSet) + 1;
                [moduNow, codeNow] = SplitMCS(mcsNow, "HT");
                antNow = floor(mcsNow/8) + 1;
                bandNow = HTSIG2Band(sigLabelTest(testIdx, :));
                confModuTest(predModuTest==moduSet, moduNow==moduSet) = ...
                    confModuTest(predModuTest==moduSet, moduNow==moduSet) + 1;
                confCodeTest(predCodeTest==codeSet, codeNow==codeSet) = ...
                    confCodeTest(predCodeTest==codeSet, codeNow==codeSet) + 1;
                confAntTest(predAntTest==antSet, antNow==antSet) = ...
                    confAntTest(predAntTest==antSet, antNow==antSet) + 1;
                confBandTest(predBandTest==bandSet, bandNow==bandSet) = ...
                    confBandTest(predBandTest==bandSet, bandNow==bandSet) + 1;
            end
            disp([accMcsBitTest accBandBitTest accPsduBitTest]);
            accMcsBitMat(setupIdx, bandIdx, snrIdx, :) = accMcsBitTest;
            accBandBitMat(setupIdx, bandIdx, snrIdx, :) = accBandBitTest;
            accPsudBitMat(setupIdx, bandIdx, snrIdx, :) = accPsduBitTest;

            disp(mean(errorPsduTest));
            disp(trace(confModuTest)/testNum);
            disp(trace(confCodeTest)/testNum);
            disp(trace(confAntTest)/testNum);
            disp(trace(confBandTest)/testNum);
            error = errorPsduTest;
            mcsMat = confMcsTest;
            moduMat = confModuTest;
            codeMat = confCodeTest;
            antMat = confAntTest;
            bandMat = confBandTest;
            save("Result/"+prot+"_PSDU_"+band+"_"+rate+"_"+snr+".mat", "error");
            save("Result/"+prot+"_Speed_"+band+"_"+rate+"_"+snr+".mat", "mcsMat", "moduMat", "codeMat", "antMat", "bandMat");
        end
    end
end
save("Result/"+prot+"_accBitHTSIG.mat", "accMcsBitMat", "accBandBitMat", "accPsudBitMat");