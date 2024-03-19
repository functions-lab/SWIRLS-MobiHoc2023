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
phaseSet = [-1 3 3 -2];
bandSet = ["CBW20" "CBW40"]; % ["CBW20" "CBW40" "CBW80" "CBW160"];
snrSet = 0: 2: 20;
manual = -1;

setupNum = length(rateSet);
bandNum = length(bandSet);
snrNum = length(snrSet);
accTimeBitMat = zeros(setupNum, bandNum, snrNum, 12);
for setupIdx = 1: setupNum
    rate = rateSet(setupIdx);
    carrier = carrierSet(setupIdx);
    phase = phaseSet(setupIdx);

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
            subNum = length(subList);
            sigNum = 24;
            
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
                    subLabel(fileNum, :) = load(fileLabel).SIG.LSIG.sub(subList);
                    sigLabel(fileNum, :) = load(fileLabel).SIG.LSIG.bitOrig;

                    signal = File2Wave(fileData);
                    if manual > 0
                        signalPower = sqrt(mean(abs(signal).^2));
                        noisePower = signalPower / (10^(manual/20)*sqrt(2));
                        noise = noisePower * (randn(1, length(signal)) + 1i*randn(1, length(signal)));
                        wave = signal + noise;
                    else
                        wave = signal;
                    end
                    constel(fileNum, :) = DSP_LSIG(wave, subList, carrier, rate, phase, band);
                end
            end
            constel(fileNum+1: end, :) = [];
            sigLabel(fileNum+1: end, :) = [];
            subLabel(fileNum+1: end, :) = [];
            
            %%
            if ~exist("Result", "dir")
                mkdir("Result");
            end
            if ~exist("Result/LSIG_"+band+"_"+rate+"_"+snr+"/", 'dir')
                mkdir("Result/LSIG_"+band+"_"+rate+"_"+snr+"/");
            end
            for subIdx = 1: subNum
                figure('Position', [0 0 500 500]);
                posIdx = find(subLabel(:, subIdx)==-1);
                scatter(real(constel(posIdx, subIdx)), imag(constel(posIdx, subIdx)), ...
                    50, '+', 'red', 'linewidth', 2);
                hold on;
                negIdx = find(subLabel(:, subIdx)==1);
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
                saveas(gcf, "Result/LSIG_"+band+"_"+rate+"_"+snr+"/"+subList(subIdx)+".png")
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
            accTimeSubTest = zeros(1, subNum);
            for subIdx = 1: subNum
            %     subPredTest(:, subIdx) = DemodSVM(constelTrain(:, subIdx), subLabelTrain(:, subIdx), constelTest(:, subIdx));
                subPredTest(:, subIdx) = DemodThres(constelTrain(:, subIdx), subLabelTrain(:, subIdx), constelTest(:, subIdx));
                accTimeSubTest(subIdx) = sum(subPredTest(:, subIdx)==subLabelTest(:, subIdx))/testNum;
            end
            
            %%
            
            errorTimeTest = zeros(testNum, 1);
            accTimeBitTest = zeros(1, 12);
            for testIdx = 1: testNum
            %     disp(sigLabelTest(testIdx, 6: 17));
                [predTimeTest, bit] = Sub2Time(subPredTest(testIdx, :), subList);
                accTimeBitTest = accTimeBitTest + (bit'==sigLabelTest(testIdx, 6: 17))/testNum;
                labelTimeTest = LSIG2Time(sigLabelTest(testIdx, :));
                errorTimeTest(testIdx) = abs(predTimeTest - labelTimeTest);
            end
            disp(accTimeBitTest);
            accTimeBitMat(setupIdx, bandIdx, snrIdx, :) = accTimeBitTest;
            disp(mean(errorTimeTest));
            error = errorTimeTest;
            save("Result/"+prot+"_Time_"+band+"_"+rate+"_"+snr+".mat", "error");
        end
    end
end
save("Result/"+prot+"_accBitLSIG.mat", "accTimeBitMat");